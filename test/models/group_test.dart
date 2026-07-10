import 'package:flutter_test/flutter_test.dart';
import 'package:game_on/models/group.dart';

void main() {
  final sampleJson = {
    'id': 'group-001',
    'name': 'My Team',
    'description': 'Weekly padel sessions',
    'invite_code': 'ABCD1234',
    'creator_id': 'user-001',
    'created_at': '2025-06-01T00:00:00Z',
  };

  group('Group.fromJson', () {
    test('parses all fields correctly', () {
      final g = Group.fromJson(sampleJson);
      expect(g.id, 'group-001');
      expect(g.name, 'My Team');
      expect(g.description, 'Weekly padel sessions');
      expect(g.inviteCode, 'ABCD1234');
      expect(g.creatorId, 'user-001');
      expect(g.createdAt, DateTime.parse('2025-06-01T00:00:00Z'));
      expect(g.memberCount, 0);
    });

    test('handles null description', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['description'] = null;
      final g = Group.fromJson(json);
      expect(g.description, isNull);
    });

    test('parses member count from Supabase count response', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['group_members'] = [{'count': 7}];
      final g = Group.fromJson(json);
      expect(g.memberCount, 7);
    });

    test('defaults member count to 0 when no group_members', () {
      final g = Group.fromJson(sampleJson);
      expect(g.memberCount, 0);
    });
  });
}
