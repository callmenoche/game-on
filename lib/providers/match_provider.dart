import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart';
import '../models/sponsored_post.dart';
import '../services/match_service.dart';
import '../services/sponsored_post_service.dart';
import '../services/supabase_client.dart';
import '../utils/error_helpers.dart';

enum DateFilter { upcoming, today, next7, next30, custom }
enum FeedMode { public, groups }

/// Lightweight participant info for the feed cards' avatar dots.
class FeedParticipant {
  final String? avatarUrl;
  final bool isGuest; // unclaimed guest spot → generic icon

  const FeedParticipant({this.avatarUrl, required this.isGuest});
}

class MatchProvider extends ChangeNotifier {
  final _service = MatchService();
  final _sponsoredService = SponsoredPostService();

  List<Match> _allMatches = [];
  List<SponsoredPost> _allSponsoredPosts = [];
  Map<String, List<FeedParticipant>> _cardParticipants = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  SportType? _selectedSport;
  DateFilter _dateFilter = DateFilter.upcoming;
  String _searchQuery = '';
  bool _distanceFilterEnabled = false;
  double? _userLat;
  double? _userLng;
  FeedMode _feedMode = FeedMode.public;
  double _distanceKm = 10.0;
  DateTimeRange? _customDateRange;
  // User context injected from ProfileProvider (see main.dart ProxyProvider):
  // favorite sports float to the top of the feed; the default location is
  // the distance-sort reference when GPS hasn't been requested.
  Set<String> _favoriteSports = {};
  double? _homeLat;
  double? _homeLng;
  Set<String> _blockedUserIds = {};
  final Set<String> _joinedIds = {};
  RealtimeChannel? _channel;
  StreamSubscription? _authSub;

  // ── Getters ───────────────────────────────────────────────────────────────

  FeedMode get feedMode => _feedMode;

  List<Match> get matches {
    var result = _allMatches;
    // Hide matches created by blocked users
    if (_blockedUserIds.isNotEmpty) {
      result =
          result.where((m) => !_blockedUserIds.contains(m.creatorId)).toList();
    }
    // Feed mode: public vs group matches
    if (_feedMode == FeedMode.public) {
      result = result.where((m) => m.groupId == null).toList();
    } else {
      result = result.where((m) => m.groupId != null).toList();
    }
    if (_selectedSport != null) {
      result = result.where((m) => m.sportType == _selectedSport).toList();
    }
    result = _applyDateFilter(result);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((m) =>
              m.locationName.toLowerCase().contains(q) ||
              m.sportType.label.toLowerCase().contains(q))
          .toList();
    }
    if (_distanceFilterEnabled && _userLat != null) {
      result = result
          .where((m) =>
              m.geoLat == null ||
              _haversineKm(_userLat!, _userLng!, m.geoLat!, m.geoLng!) <=
                  _distanceKm)
          .toList();
    }
    return _sortForFeed(result);
  }

  /// Feed ordering: favorite sports first, then soonest, then closest.
  List<Match> _sortForFeed(List<Match> list) {
    final refLat = _userLat ?? _homeLat;
    final refLng = _userLng ?? _homeLng;
    final sorted = List<Match>.of(list);
    sorted.sort((a, b) {
      final aFav = _favoriteSports.contains(a.sportType.name);
      final bFav = _favoriteSports.contains(b.sportType.name);
      if (aFav != bFav) return aFav ? -1 : 1;
      final byTime = a.dateTime.compareTo(b.dateTime);
      if (byTime != 0) return byTime;
      if (refLat == null) return 0;
      final aDist = a.geoLat == null
          ? double.infinity
          : _haversineKm(refLat, refLng!, a.geoLat!, a.geoLng!);
      final bDist = b.geoLat == null
          ? double.infinity
          : _haversineKm(refLat, refLng!, b.geoLat!, b.geoLng!);
      return aDist.compareTo(bDist);
    });
    return sorted;
  }

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  SportType? get selectedSport => _selectedSport;
  DateFilter get dateFilter => _dateFilter;
  String get searchQuery => _searchQuery;
  bool get distanceFilterEnabled => _distanceFilterEnabled;
  double get distanceKm => _distanceKm;
  DateTimeRange? get customDateRange => _customDateRange;
  bool get hasUserLocation => _userLat != null;
  bool isJoined(String matchId) => _joinedIds.contains(matchId);

  /// Distance in km from user to [m], null if either position is missing.
  double? distanceFromUser(Match m) {
    if (_userLat == null || m.geoLat == null) return null;
    return _haversineKm(_userLat!, _userLng!, m.geoLat!, m.geoLng!);
  }

  /// All loaded matches the current user has joined (for calendar view).
  List<Match> get joinedMatches =>
      _allMatches.where((m) => _joinedIds.contains(m.id)).toList();

  // ── Init ──────────────────────────────────────────────────────────────────

  String? _currentUserId;

  MatchProvider() {
    _currentUserId = SupabaseService.currentUser?.id;
    _init();

    _authSub = SupabaseService.authStateChanges.listen((data) {
      final newUserId = data.session?.user.id;
      if (newUserId == _currentUserId) return;
      _currentUserId = newUserId;
      _channel?.unsubscribe();
      _channel = null;
      _allMatches = [];
      _joinedIds.clear();
      _error = null;
      notifyListeners();
      if (newUserId != null) _init();
    });
  }

  Future<void> _init() async {
    await Future.wait(
        [fetchMatches(), _loadJoinedIds(), _loadSponsoredPosts()]);
    _subscribeRealtime();
  }

  Future<void> _loadSponsoredPosts() async {
    try {
      _allSponsoredPosts = await _sponsoredService.fetchActive();
      notifyListeners();
    } catch (_) {
      // Non-fatal: the feed simply shows no sponsored cards.
    }
  }

  /// Sponsored posts relevant to the current filters/location.
  List<SponsoredPost> get sponsoredPosts {
    final refLat = _userLat ?? _homeLat;
    final refLng = _userLng ?? _homeLng;
    return _allSponsoredPosts.where((p) {
      // Sport targeting: hide only when an active sport filter contradicts it
      if (p.sportType != null &&
          _selectedSport != null &&
          p.sportType != _selectedSport!.name) {
        return false;
      }
      // Geo targeting: applies only when we know where the user is
      if (p.geoLat != null && p.radiusKm != null && refLat != null) {
        return _haversineKm(refLat, refLng!, p.geoLat!, p.geoLng!) <=
            p.radiusKm!;
      }
      return true;
    }).toList();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> fetchMatches() async {
    _setLoading(true);
    try {
      _allMatches = await _service.fetchOpenMatches();
      _hasMore = _allMatches.length >= MatchService.pageSize;
      _error = null;
      _cardParticipants = {};
      unawaited(_loadCardParticipants(_allMatches));
    } catch (_) {
      _error = 'could_not_load_matches';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMoreMatches() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final more = await _service.fetchOpenMatches(offset: _allMatches.length);
      _allMatches.addAll(more);
      _hasMore = more.length >= MatchService.pageSize;
      _error = null;
      unawaited(_loadCardParticipants(more));
    } catch (_) {
      // Non-fatal — user can scroll to try again
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Participants of [matchId] for the feed card avatar dots
  /// (empty until the batch load completes).
  List<FeedParticipant> participantsFor(String matchId) =>
      _cardParticipants[matchId] ?? const [];

  /// Batch-loads participant avatars for a page of matches (2 queries).
  Future<void> _loadCardParticipants(List<Match> matches) async {
    if (matches.isEmpty) return;
    try {
      final rows = await SupabaseService.table('match_participants')
          .select('match_id, user_id')
          .inFilter('match_id', matches.map((m) => m.id).toList());

      final userIds = {
        for (final r in rows as List)
          if (r['user_id'] != null) r['user_id'] as String
      }.toList();

      final avatars = <String, String?>{};
      if (userIds.isNotEmpty) {
        final profiles = await SupabaseService.table('profiles')
            .select('id, avatar_url')
            .inFilter('id', userIds);
        for (final p in profiles as List) {
          avatars[p['id'] as String] = p['avatar_url'] as String?;
        }
      }

      final map = <String, List<FeedParticipant>>{};
      for (final r in rows) {
        final userId = r['user_id'] as String?;
        map.putIfAbsent(r['match_id'] as String, () => []).add(
              FeedParticipant(
                avatarUrl: userId == null ? null : avatars[userId],
                isGuest: userId == null,
              ),
            );
      }
      // Registered players first, unclaimed guest spots last
      for (final list in map.values) {
        list.sort((a, b) => (a.isGuest ? 1 : 0) - (b.isGuest ? 1 : 0));
      }
      _cardParticipants = {..._cardParticipants, ...map};
      notifyListeners();
    } catch (_) {
      // Non-fatal: cards fall back to plain filled dots.
    }
  }

  Future<void> _loadJoinedIds() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;
    try {
      final data = await SupabaseService.table('match_participants')
          .select('match_id')
          .eq('user_id', userId);
      _joinedIds
        ..clear()
        ..addAll((data as List).map((r) => r['match_id'] as String));
    } catch (_) {
      // non-fatal
    }
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  void _subscribeRealtime() {
    _channel = SupabaseService.client.channel('public:matches')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'matches',
        callback: (_) => fetchMatches(),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'match_participants',
        callback: (_) => fetchMatches(),
      )
      ..subscribe();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<bool> joinMatch(String matchId) async {
    _joinedIds.add(matchId);
    _updateMatchLocally(matchId, delta: -1);
    notifyListeners();
    try {
      await _service.joinMatch(matchId);
      return true;
    } catch (e) {
      _joinedIds.remove(matchId);
      _updateMatchLocally(matchId, delta: 1);
      _error = classifyMatchError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> joinMatchWithGuests(String matchId, int guestCount) async {
    final total = 1 + guestCount;
    _joinedIds.add(matchId);
    _updateMatchLocally(matchId, delta: -total);
    notifyListeners();
    try {
      await _service.joinMatchWithGuests(matchId, guestCount);
      return true;
    } catch (e) {
      _joinedIds.remove(matchId);
      _updateMatchLocally(matchId, delta: total);
      _error = classifyMatchError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> addGuestSpots(String matchId, int count) async {
    _updateMatchLocally(matchId, delta: -count);
    notifyListeners();
    try {
      await _service.addGuestSpots(matchId, count);
      return true;
    } catch (_) {
      _updateMatchLocally(matchId, delta: count);
      _error = 'could_not_add_guests';
      notifyListeners();
      return false;
    }
  }

  Future<bool> claimGuestSpot(String matchId, String token) async {
    try {
      await _service.claimGuestSpot(matchId, token);
      _joinedIds.add(matchId);
      await fetchMatches();
      return true;
    } catch (_) {
      _error = 'invalid_claim';
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveMatch(String matchId) async {
    _joinedIds.remove(matchId);
    _updateMatchLocally(matchId, delta: 1);
    notifyListeners();
    try {
      await _service.leaveMatch(matchId);
      return true;
    } catch (_) {
      _joinedIds.add(matchId);
      _updateMatchLocally(matchId, delta: -1);
      _error = 'could_not_leave';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMatchDetails(String matchId, {String? title, String? description}) async {
    try {
      final updated = await _service.updateMatchDetails(matchId, title: title, description: description);
      final idx = _allMatches.indexWhere((m) => m.id == matchId);
      if (idx != -1) {
        _allMatches[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createMatch({
    required SportType sport,
    required String location,
    required DateTime dateTime,
    required int totalSpots,
    SkillLevel skillLevel = SkillLevel.allLevels,
    int guestCount = 0,
    bool isUnlimited = false,
    int durationMinutes = 60,
    double? geoLat,
    double? geoLng,
    String? groupId,
    String? title,
    String? description,
    List<String>? allowedGenders,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;

    final match = Match(
      id: '',
      creatorId: userId,
      sportType: sport,
      locationName: location,
      geoLat: geoLat,
      geoLng: geoLng,
      dateTime: dateTime,
      totalSpots: isUnlimited ? null : totalSpots,
      playersNeeded: isUnlimited ? null : totalSpots,
      skillLevel: skillLevel,
      createdAt: DateTime.now(),
      durationMinutes: durationMinutes,
      groupId: groupId,
      title: title,
      description: description,
      allowedGenders: allowedGenders,
    );

    try {
      final created = await _service.createMatch(match);
      if (isUnlimited) {
        await _service.joinMatch(created.id);
      } else {
        await _service.joinMatchWithGuests(created.id, guestCount);
      }
      _joinedIds.add(created.id);
      await fetchMatches();
      return true;
    } catch (_) {
      _error = 'could_not_create';
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmMatch(String matchId) async {
    final now = DateTime.now();
    // Optimistic update
    final idx = _allMatches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      _allMatches[idx] = _allMatches[idx].copyWith(confirmedAt: now);
      notifyListeners();
    }
    try {
      await _service.confirmMatch(matchId);
      return true;
    } catch (_) {
      // Roll back
      if (idx != -1) {
        _allMatches[idx] = _allMatches[idx].copyWith();
        notifyListeners();
      }
      _error = 'could_not_confirm';
      notifyListeners();
      return false;
    }
  }

  /// Called whenever the profile changes (favorites / default location).
  void updateUserContext({
    required List<String> favoriteSports,
    double? homeLat,
    double? homeLng,
  }) {
    final favs = favoriteSports.toSet();
    if (favs.length == _favoriteSports.length &&
        favs.containsAll(_favoriteSports) &&
        homeLat == _homeLat &&
        homeLng == _homeLng) {
      return; // nothing changed — avoid notify loops
    }
    _favoriteSports = favs;
    _homeLat = homeLat;
    _homeLng = homeLng;
    // Deferred: this is called from ProxyProvider.update during build.
    scheduleMicrotask(notifyListeners);
  }

  /// Called from ProxyProvider when the block list changes.
  void setBlockedUsers(Set<String> ids) {
    if (ids.length == _blockedUserIds.length &&
        ids.containsAll(_blockedUserIds)) {
      return;
    }
    _blockedUserIds = Set.of(ids);
    scheduleMicrotask(notifyListeners);
  }

  void setSportFilter(SportType? sport) {
    _selectedSport = sport;
    notifyListeners();
  }

  void setDateFilter(DateFilter filter) {
    _dateFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFeedMode(FeedMode mode) {
    _feedMode = mode;
    notifyListeners();
  }

  void setDistanceKm(double km) {
    _distanceKm = km;
    notifyListeners();
  }

  void setCustomDateRange(DateTimeRange range) {
    _customDateRange = range;
    _dateFilter = DateFilter.custom;
    notifyListeners();
  }

  /// Enables the distance filter at [km], fetching the GPS position if needed.
  Future<void> enableDistanceFilter(double km) async {
    _distanceKm = km;
    if (!_distanceFilterEnabled) {
      await _fetchUserLocation();
      _distanceFilterEnabled = _userLat != null;
    }
    notifyListeners();
  }

  void disableDistanceFilter() {
    _distanceFilterEnabled = false;
    notifyListeners();
  }

  /// Number of non-default sheet-managed filters (shown as a badge).
  int get activeFilterCount =>
      (_dateFilter != DateFilter.upcoming ? 1 : 0) +
      (_distanceFilterEnabled ? 1 : 0);

  void resetFilters() {
    _dateFilter = DateFilter.upcoming;
    _customDateRange = null;
    _distanceFilterEnabled = false;
    notifyListeners();
  }

  Future<void> _fetchUserLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
      _userLat = pos.latitude;
      _userLng = pos.longitude;
    } catch (_) {
      // Location unavailable — filter silently stays off
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<Match> _applyDateFilter(List<Match> list) {
    final now = DateTime.now();
    const grace = Duration(minutes: 30);
    return list.where((m) {
      return switch (_dateFilter) {
        DateFilter.upcoming => m.dateTime.isAfter(now.subtract(grace)),
        DateFilter.today =>
          m.dateTime.year == now.year &&
          m.dateTime.month == now.month &&
          m.dateTime.day == now.day &&
          m.dateTime.isAfter(now.subtract(grace)),
        DateFilter.next7 =>
          m.dateTime.isAfter(now.subtract(grace)) &&
          m.dateTime.isBefore(now.add(const Duration(days: 7))),
        DateFilter.next30 =>
          m.dateTime.isAfter(now.subtract(grace)) &&
          m.dateTime.isBefore(now.add(const Duration(days: 30))),
        DateFilter.custom => _customDateRange == null
          ? m.dateTime.isAfter(now.subtract(grace))
          : !m.dateTime.isBefore(_customDateRange!.start) &&
            !m.dateTime.isAfter(_customDateRange!.end.add(const Duration(days: 1))),
      };
    }).toList();
  }

  void _updateMatchLocally(String matchId, {required int delta}) {
    final idx = _allMatches.indexWhere((m) => m.id == matchId);
    if (idx == -1) return;
    final m = _allMatches[idx];
    if (m.isUnlimited) return; // unlimited: nothing to decrement
    final newNeeded = (m.playersNeeded! + delta).clamp(0, m.totalSpots!);
    _allMatches[idx] = m.copyWith(
      playersNeeded: newNeeded,
      status: newNeeded == 0 ? MatchStatus.full : MatchStatus.open,
    );
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  static double _haversineKm(
      double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }
}
