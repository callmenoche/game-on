import '../models/group.dart';
import 'supabase_client.dart';

class GroupService {
  static final _groups  = SupabaseService.table('groups');
  static final _members = SupabaseService.table('group_members');

  Future<List<Group>> fetchMyGroups() async {
    final data = await _groups.select().order('created_at', ascending: false);
    return (data as List).map((e) => Group.fromJson(e)).toList();
  }

  Future<Group> createGroup({required String name, String? description}) async {
    final userId = SupabaseService.currentUser!.id;
    final data = await _groups
        .insert({'name': name, 'description': description, 'creator_id': userId})
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

  /// Returns the group if the invite code is valid, null otherwise.
  Future<Group?> joinByCode(String code) async {
    final data = await _groups
        .select()
        .eq('invite_code', code.trim().toUpperCase())
        .maybeSingle();
    if (data == null) return null;
    final group = Group.fromJson(data);
    final userId = SupabaseService.currentUser!.id;
    await _members.upsert({
      'group_id': group.id,
      'user_id': userId,
      'role': 'member',
    });
    return group;
  }

  Future<void> leaveGroup(String groupId) async {
    final userId = SupabaseService.currentUser!.id;
    await _members.delete().eq('group_id', groupId).eq('user_id', userId);
  }

  /// Returns {userId → username} for all members of [groupId].
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
