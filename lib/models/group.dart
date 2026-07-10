enum GroupVisibility {
  public('public'),
  private('private'),
  inviteOnly('invite_only');

  final String dbValue;
  const GroupVisibility(this.dbValue);

  static GroupVisibility fromDb(String? value) => GroupVisibility.values
      .firstWhere((v) => v.dbValue == value, orElse: () => GroupVisibility.private);
}

class Group {
  final String id;
  final String name;
  final String? description;
  final String inviteCode;
  final String creatorId;
  final DateTime createdAt;
  final int memberCount;
  final GroupVisibility visibility;

  const Group({
    required this.id,
    required this.name,
    this.description,
    required this.inviteCode,
    required this.creatorId,
    required this.createdAt,
    this.memberCount = 0,
    this.visibility = GroupVisibility.private,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    // member_count column (migration 024); fallback to the aggregate shape
    // Supabase returns for .select('*, group_members(count)').
    int count = (json['member_count'] as num?)?.toInt() ?? 0;
    if (count == 0) {
      final members = json['group_members'];
      if (members is List && members.isNotEmpty) {
        count = (members.first['count'] as num?)?.toInt() ?? members.length;
      }
    }
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      inviteCode: json['invite_code'] as String,
      creatorId: json['creator_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      memberCount: count,
      visibility: GroupVisibility.fromDb(json['visibility'] as String?),
    );
  }
}
