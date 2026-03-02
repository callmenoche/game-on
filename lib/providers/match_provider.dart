import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';

enum DateFilter { any, today, thisWeek }

class MatchProvider extends ChangeNotifier {
  final _service = MatchService();

  List<Match> _allMatches = [];
  bool _isLoading = false;
  String? _error;
  SportType? _selectedSport;
  DateFilter _dateFilter = DateFilter.any;
  final Set<String> _joinedIds = {};
  RealtimeChannel? _channel;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Match> get matches {
    var result = _allMatches;
    if (_selectedSport != null) {
      result = result.where((m) => m.sportType == _selectedSport).toList();
    }
    result = _applyDateFilter(result);
    return result;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  SportType? get selectedSport => _selectedSport;
  DateFilter get dateFilter => _dateFilter;
  bool isJoined(String matchId) => _joinedIds.contains(matchId);

  /// All loaded matches the current user has joined (for calendar view).
  List<Match> get joinedMatches =>
      _allMatches.where((m) => _joinedIds.contains(m.id)).toList();

  // ── Init ──────────────────────────────────────────────────────────────────

  MatchProvider() {
    _init();
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

  Future<void> joinMatch(String matchId) async {
    _joinedIds.add(matchId);
    _updateMatchLocally(matchId, delta: -1);
    try {
      await _service.joinMatch(matchId);
    } catch (_) {
      _joinedIds.remove(matchId);
      _updateMatchLocally(matchId, delta: 1);
      _error = 'Could not join match.';
      notifyListeners();
    }
  }

  Future<void> joinMatchWithGuests(String matchId, int guestCount) async {
    final total = 1 + guestCount;
    _joinedIds.add(matchId);
    _updateMatchLocally(matchId, delta: -total);
    try {
      await _service.joinMatchWithGuests(matchId, guestCount);
    } catch (_) {
      _joinedIds.remove(matchId);
      _updateMatchLocally(matchId, delta: total);
      _error = 'Could not join match.';
      notifyListeners();
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

  Future<bool> createMatch({
    required SportType sport,
    required String location,
    required DateTime dateTime,
    required int totalSpots,
    SkillLevel skillLevel = SkillLevel.allLevels,
    int guestCount = 0,
    bool isUnlimited = false,
    int durationMinutes = 60,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;

    final match = Match(
      id: '',
      creatorId: userId,
      sportType: sport,
      locationName: location,
      dateTime: dateTime,
      totalSpots: isUnlimited ? null : totalSpots,
      playersNeeded: isUnlimited ? null : totalSpots - 1 - guestCount,
      skillLevel: skillLevel,
      createdAt: DateTime.now(),
      durationMinutes: durationMinutes,
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
      _error = 'Could not create match.';
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

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
