import '../models/group.dart';
import 'supabase_client.dart';

class GroupService {
  static final _groups = SupabaseService.table('groups');
  static final _members = SupabaseService.table('group_members');
  static final _requests = SupabaseService.table('group_join_requests');

  /// Groups the current user belongs to. Two-step because the groups SELECT
  /// policy also exposes public/invite_only groups (for search), so a plain
  /// select would not mean "my groups" anymore.
  Future<List<Group>> fetchMyGroups() async {
    final userId = SupabaseService.currentUser!.id;
    final memberRows =
        await _members.select('group_id').eq('user_id', userId);
    final ids =
        (memberRows as List).map((r) => r['group_id'] as String).toList();
    if (ids.isEmpty) return [];
    final data = await _groups
        .select()
        .inFilter('id', ids)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Group.fromJson(e)).toList();
  }

  /// Groups [userId] belongs to that are visible to the current viewer:
  /// groups shared with the viewer, plus any public group (RLS-enforced —
  /// see migration 028). Private/invite_only groups the viewer isn't in
  /// stay hidden.
  Future<List<Group>> fetchGroupsForUser(String userId) async {
    final memberRows = await _members.select('group_id').eq('user_id', userId);
    final ids =
        (memberRows as List).map((r) => r['group_id'] as String).toList();
    if (ids.isEmpty) return [];
    final data = await _groups
        .select()
        .inFilter('id', ids)
        .order('member_count', ascending: false);
    return (data as List).map((e) => Group.fromJson(e)).toList();
  }

  /// Up to 20 searchable groups (public + invite_only, per RLS) matching
  /// [query] by name.
  Future<List<Group>> searchGroups(String query) async {
    final data = await _groups
        .select()
        .ilike('name', '%$query%')
        .order('member_count', ascending: false)
        .limit(20);
    return (data as List).map((e) => Group.fromJson(e)).toList();
  }

  Future<Group> createGroup({
    required String name,
    String? description,
    GroupVisibility visibility = GroupVisibility.private,
  }) async {
    final userId = SupabaseService.currentUser!.id;
    final data = await _groups
        .insert({
          'name': name,
          'description': description,
          'creator_id': userId,
          'visibility': visibility.dbValue,
        })
        .select()
        .single();
    final group = Group.fromJson(data);
    // Creator is always an admin member
    await _members.insert({
      'group_id': group.id,
      'user_id': userId,
      'role': 'admin',
    });
    return group;
  }

  /// Joins via invite code (works for every visibility — knowing the code is
  /// the authorization). Returns the group, or null for an invalid code.
  Future<Group?> joinByCode(String code) async {
    final data = await SupabaseService.client
        .rpc('join_group_by_code', params: {'code': code});
    final rows = data as List;
    if (rows.isEmpty) return null;
    return Group.fromJson(rows.first as Map<String, dynamic>);
  }

  /// Instant join — allowed by RLS for public groups only.
  Future<void> joinPublicGroup(String groupId) async {
    final userId = SupabaseService.currentUser!.id;
    await _members.upsert({
      'group_id': groupId,
      'user_id': userId,
      'role': 'member',
    });
  }

  /// Files a membership request for an invite-only group.
  Future<void> requestToJoin(String groupId) async {
    final userId = SupabaseService.currentUser!.id;
    await _requests.upsert(
      {'group_id': groupId, 'user_id': userId, 'status': 'pending'},
      onConflict: 'group_id,user_id',
    );
  }

  /// Group ids the current user has a pending request for.
  Future<Set<String>> fetchMyPendingRequestGroupIds() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return {};
    final data = await _requests
        .select('group_id')
        .eq('user_id', userId)
        .eq('status', 'pending');
    return (data as List).map((r) => r['group_id'] as String).toSet();
  }

  /// Pending requests of [groupId] with usernames — admin view.
  /// Returns [{id, userId, username}].
  Future<List<Map<String, String>>> fetchPendingRequests(
      String groupId) async {
    final data = await _requests
        .select('id, user_id')
        .eq('group_id', groupId)
        .eq('status', 'pending')
        .order('created_at');
    final rows = data as List;
    if (rows.isEmpty) return [];
    final userIds = rows.map((r) => r['user_id'] as String).toList();
    final profiles = await SupabaseService.table('profiles')
        .select('id, username')
        .inFilter('id', userIds);
    final names = {
      for (final p in profiles as List)
        p['id'] as String: p['username'] as String? ?? 'Player'
    };
    return [
      for (final r in rows)
        {
          'id': r['id'] as String,
          'userId': r['user_id'] as String,
          'username': names[r['user_id']] ?? 'Player',
        }
    ];
  }

  Future<void> respondToRequest(String requestId,
      {required bool accept}) async {
    await _requests
        .update({'status': accept ? 'accepted' : 'declined'})
        .eq('id', requestId);
  }

  Future<void> leaveGroup(String groupId) async {
    final userId = SupabaseService.currentUser!.id;
    await _members.delete().eq('group_id', groupId).eq('user_id', userId);
  }

  /// Returns {userId → {username, role}} for all members of [groupId].
  Future<Map<String, dynamic>> fetchMembersWithRoles(String groupId) async {
    final membersData = await _members
        .select('user_id, role')
        .eq('group_id', groupId)
        .order('joined_at');

    final userIds = (membersData as List).map((r) => r['user_id'] as String).toList();
    if (userIds.isEmpty) return {};

    final profilesData = await SupabaseService.table('profiles')
        .select('id, username')
        .inFilter('id', userIds);

    final usernameMap = {
      for (final r in profilesData as List)
        r['id'] as String: r['username'] as String? ?? 'Player'
    };

    return {
      for (final r in membersData)
        r['user_id'] as String: {
          'username': usernameMap[r['user_id']] ?? 'Player',
          'role': r['role'] as String,
        }
    };
  }
}
