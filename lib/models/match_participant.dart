class MatchParticipant {
  final String matchId;
  final String userId;
  final DateTime joinedAt;

  const MatchParticipant({
    required this.matchId,
    required this.userId,
    required this.joinedAt,
  });

  factory MatchParticipant.fromJson(Map<String, dynamic> json) =>
      MatchParticipant(
        matchId: json['match_id'] as String,
        userId: json['user_id'] as String,
        joinedAt: DateTime.parse(json['joined_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'match_id': matchId,
        'user_id': userId,
      };
}
