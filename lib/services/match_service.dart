import '../models/match.dart';
import '../models/match_participant.dart';
import 'supabase_client.dart';

class MatchService {
  static final _matches = SupabaseService.table('matches');
  static final _participants = SupabaseService.table('match_participants');

  // ── Feed ──────────────────────────────────────────────────────────────────

  Future<List<Match>> fetchOpenMatches({SportType? sport}) async {
    var query = _matches
        .select()
        .eq('status', 'open')
        .order('date_time', ascending: true);

    if (sport != null) {
      query = _matches
          .select()
          .eq('status', 'open')
          .eq('sport_type', sport.name)
          .order('date_time', ascending: true);
    }

    final data = await query;
    return (data as List).map((e) => Match.fromJson(e)).toList();
  }

  // ── Realtime ──────────────────────────────────────────────────────────────

  /// Emits the full updated [Match] whenever a match row changes.
  Stream<Match> watchMatch(String matchId) {
    return SupabaseService.client
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .map((rows) => Match.fromJson(rows.first));
  }

  /// Emits the participant list whenever someone joins or leaves.
  Stream<List<MatchParticipant>> watchParticipants(String matchId) {
    return SupabaseService.client
        .from('match_participants')
        .stream(primaryKey: ['match_id', 'user_id'])
        .eq('match_id', matchId)
        .map((rows) => rows.map(MatchParticipant.fromJson).toList());
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<Match> createMatch(Match match) async {
    final data = await _matches.insert(match.toJson()).select().single();
    return Match.fromJson(data);
  }

  Future<void> joinMatch(String matchId) async {
    final userId = SupabaseService.currentUser!.id;
    await _participants.insert({'match_id': matchId, 'user_id': userId});
  }

  Future<void> leaveMatch(String matchId) async {
    final userId = SupabaseService.currentUser!.id;
    await _participants
        .delete()
        .eq('match_id', matchId)
        .eq('user_id', userId);
  }

  Future<bool> isParticipant(String matchId) async {
    final userId = SupabaseService.currentUser!.id;
    final data = await _participants
        .select()
        .eq('match_id', matchId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  Future<void> cancelMatch(String matchId) async {
    await _matches.update({'status': 'cancelled'}).eq('id', matchId);
  }

  /// Returns a map of userId → username for the given user IDs.
  Future<Map<String, String>> fetchProfiles(List<String> userIds) async {
    if (userIds.isEmpty) return {};
    final data = await SupabaseService.table('profiles')
        .select('id, username')
        .inFilter('id', userIds);
    return {
      for (final r in data as List)
        r['id'] as String: r['username'] as String? ?? 'Player'
    };
  }
}
