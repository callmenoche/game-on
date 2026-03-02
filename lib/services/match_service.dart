import 'dart:math';

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

  Stream<Match> watchMatch(String matchId) {
    return SupabaseService.client
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .map((rows) => Match.fromJson(rows.first));
  }

  Stream<List<MatchParticipant>> watchParticipants(String matchId) {
    return SupabaseService.client
        .from('match_participants')
        .stream(primaryKey: ['id'])
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

  Future<void> joinMatchWithGuests(String matchId, int guestCount) async {
    final userId = SupabaseService.currentUser!.id;
    await _participants.insert({'match_id': matchId, 'user_id': userId});
    if (guestCount > 0) {
      final guests = List.generate(guestCount, (i) => {
        'match_id': matchId,
        'is_guest': true,
        'guest_name': 'Guest ${i + 1}',
        'guest_claim_token': _generateToken(),
      });
      await _participants.insert(guests);
    }
  }

  Future<void> claimGuestSpot(String matchId, String token) async {
    final userId = SupabaseService.currentUser!.id;
    final updated = await _participants
        .update({
          'user_id': userId,
          'is_guest': false,
          'guest_claim_token': null,
        })
        .eq('match_id', matchId)
        .eq('guest_claim_token', token)
        .isFilter('user_id', null)
        .select();
    if ((updated as List).isEmpty) {
      throw Exception('Invalid or already claimed');
    }
  }

  Future<void> removeGuestSpot(String participantId) async {
    await _participants.delete().eq('id', participantId);
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

  Future<void> confirmMatch(String matchId) async {
    await _matches
        .update({'confirmed_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', matchId);
  }

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

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _generateToken() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
