class Group {
  final String id;
  final String name;
  final String? description;
  final String inviteCode;
  final String creatorId;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    this.description,
    required this.inviteCode,
    required this.creatorId,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        inviteCode: json['invite_code'] as String,
        creatorId: json['creator_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
