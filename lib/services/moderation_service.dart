import 'supabase_client.dart';

class ModerationService {
  static final _blocks = SupabaseService.table('user_blocks');
  static final _reports = SupabaseService.table('user_reports');

  Future<Set<String>> fetchBlockedIds() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return {};
    final data =
        await _blocks.select('blocked_id').eq('blocker_id', userId);
    return (data as List).map((r) => r['blocked_id'] as String).toSet();
  }

  Future<void> blockUser(String userId) async {
    await _blocks.upsert({
      'blocker_id': SupabaseService.currentUser!.id,
      'blocked_id': userId,
    });
  }

  Future<void> unblockUser(String userId) async {
    await _blocks
        .delete()
        .eq('blocker_id', SupabaseService.currentUser!.id)
        .eq('blocked_id', userId);
  }

  /// Files a report. [matchId] links the report to a specific match.
  Future<void> reportUser({
    required String reportedUserId,
    String? matchId,
    required String reason,
    String? details,
  }) async {
    await _reports.insert({
      'reporter_id': SupabaseService.currentUser!.id,
      'reported_user_id': reportedUserId,
      'match_id': matchId,
      'reason': reason,
      'details': details == null || details.isEmpty ? null : details,
    });
  }
}
