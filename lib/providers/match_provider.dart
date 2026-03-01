import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/match.dart';
import '../services/match_service.dart';
import '../services/supabase_client.dart';

class MatchProvider extends ChangeNotifier {
  final _service = MatchService();

  List<Match> _allMatches = [];
  bool _isLoading = false;
  String? _error;
  SportType? _selectedSport;
  final Set<String> _joinedIds = {};
  RealtimeChannel? _channel;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Match> get matches => _selectedSport == null
      ? _allMatches
      : _allMatches.where((m) => m.sportType == _selectedSport).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  SportType? get selectedSport => _selectedSport;
  bool isJoined(String matchId) => _joinedIds.contains(matchId);

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
      // non-fatal — user simply sees no joined state
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

  /// Optimistic join: update UI immediately, roll back on error.
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

  /// Optimistic join with guests: decrements by (1 + guestCount).
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

  /// Claims a guest spot using the provided claim token.
  /// Returns true on success.
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

  /// Optimistic leave: update UI immediately, roll back on error.
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

  /// Creates a new match. Creator occupies 1 spot + [guestCount] guest spots.
  /// Returns true on success.
  Future<bool> createMatch({
    required SportType sport,
    required String location,
    required DateTime dateTime,
    required int totalSpots,
    SkillLevel skillLevel = SkillLevel.allLevels,
    int guestCount = 0,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return false;

    final match = Match(
      id: '',
      creatorId: userId,
      sportType: sport,
      locationName: location,
      dateTime: dateTime,
      totalSpots: totalSpots,
      playersNeeded: totalSpots - 1 - guestCount, // creator + guests count
      skillLevel: skillLevel,
      createdAt: DateTime.now(),
    );

    try {
      final created = await _service.createMatch(match);
      // Auto-join the creator, inserting guest placeholders if needed
      await _service.joinMatchWithGuests(created.id, guestCount);
      _joinedIds.add(created.id);
      await fetchMatches();
      return true;
    } catch (_) {
      _error = 'Could not create match.';
      notifyListeners();
      return false;
    }
  }

  void setSportFilter(SportType? sport) {
    _selectedSport = sport;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _updateMatchLocally(String matchId, {required int delta}) {
    final idx = _allMatches.indexWhere((m) => m.id == matchId);
    if (idx == -1) return;
    final m = _allMatches[idx];
    final newNeeded = (m.playersNeeded + delta).clamp(0, m.totalSpots);
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
