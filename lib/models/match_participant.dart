class MatchParticipant {
  final String id;           // DB auto-uuid PK
  final String matchId;
  final String? userId;      // nullable for unclaimed guests
  final DateTime joinedAt;
  final bool isGuest;
  final String? guestClaimToken;
  final String? guestName;

  const MatchParticipant({
    required this.id,
    required this.matchId,
    this.userId,
    required this.joinedAt,
    this.isGuest = false,
    this.guestClaimToken,
    this.guestName,
  });

  /// A guest whose user_id has been filled in = claimed.
  bool get isClaimed => isGuest && userId != null;

  factory MatchParticipant.fromJson(Map<String, dynamic> json) =>
      MatchParticipant(
        id: json['id'] as String,
        matchId: json['match_id'] as String,
        userId: json['user_id'] as String?,
        joinedAt: DateTime.parse(json['joined_at'] as String),
        isGuest: json['is_guest'] as bool? ?? false,
        guestClaimToken: json['guest_claim_token'] as String?,
        guestName: json['guest_name'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'match_id': matchId,
        'user_id': userId,
      };
}
