import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';

enum DateFilter { any, today, thisWeek }
enum FeedMode { public, groups }

class MatchProvider extends ChangeNotifier {
  final _service = MatchService();

  List<Match> _allMatches = [];
  bool _isLoading = false;
  String? _error;
  SportType? _selectedSport;
  DateFilter _dateFilter = DateFilter.any;
  String _searchQuery = '';
  bool _distanceFilterEnabled = false;
  double? _userLat;
  double? _userLng;
  FeedMode _feedMode = FeedMode.public;
  static const double _distanceKm = 10.0;
  final Set<String> _joinedIds = {};
  RealtimeChannel? _channel;

  // ── Getters ───────────────────────────────────────────────────────────────

  FeedMode get feedMode => _feedMode;

  List<Match> get matches {
    var result = _allMatches;
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
    return result;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  SportType? get selectedSport => _selectedSport;
  DateFilter get dateFilter => _dateFilter;
  String get searchQuery => _searchQuery;
  bool get distanceFilterEnabled => _distanceFilterEnabled;
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

    SupabaseService.authStateChanges.listen((data) {
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
    await Future.wait([fetchMatches(), _loadJoinedIds()]);
    _subscribeRealtime();
  }

  // ── Data fetching ─────────────────────────────────────────────────────────

  Future<void> fetchMatches() async {
    _setLoading(true);
    try {
      _allMatches = await _service.fetchOpenMatches();
      _error = null;
    } catch (_) {
      _error = 'Failed to load matches.';
    } finally {
      _setLoading(false);
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
      _error = e.toString();
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
      _error = e.toString();
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
      _error = 'Invalid code or spot already taken.';
      notifyListeners();
      return false;
    }
  }

  Future<void> leaveMatch(String matchId) async {
    _joinedIds.remove(matchId);
    _updateMatchLocally(matchId, delta: 1);
    try {
      await _service.leaveMatch(matchId);
    } catch (_) {
      _joinedIds.add(matchId);
      _updateMatchLocally(matchId, delta: -1);
      _error = 'Could not leave match.';
      notifyListeners();
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
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> confirmMatch(String matchId) async {
    final now = DateTime.now();
    // Optimistic update
    final idx = _allMatches.indexWhere((m) => m.id == matchId);
    if (idx != -1) {
      _allMatches[idx] = _allMatches[idx].copyWith(confirmedAt: now);
      notifyListeners();
    }
    try {
      await _service.confirmMatch(matchId);
    } catch (_) {
      // Roll back
      if (idx != -1) {
        _allMatches[idx] = _allMatches[idx].copyWith();
        notifyListeners();
      }
      _error = 'Could not confirm match.';
      notifyListeners();
    }
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

  Future<void> toggleDistanceFilter() async {
    if (_distanceFilterEnabled) {
      _distanceFilterEnabled = false;
      notifyListeners();
      return;
    }
    await _fetchUserLocation();
    _distanceFilterEnabled = _userLat != null;
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
    if (_dateFilter == DateFilter.any) return list;
    final now = DateTime.now();
    return list.where((m) {
      return switch (_dateFilter) {
        DateFilter.any => true,
        DateFilter.today =>
          m.dateTime.year == now.year &&
          m.dateTime.month == now.month &&
          m.dateTime.day == now.day,
        DateFilter.thisWeek =>
          m.dateTime.isAfter(now.subtract(const Duration(minutes: 1))) &&
          m.dateTime.isBefore(now.add(const Duration(days: 7))),
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
    _channel?.unsubscribe();
    super.dispose();
  }
}
