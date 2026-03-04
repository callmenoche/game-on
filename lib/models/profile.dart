class Profile {
  final String id;
  final String username;
  final String? bio;
  final List<String> favoriteSports;
  final Map<String, dynamic> availabilityJson;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool onboarded;

  const Profile({
    required this.id,
    required this.username,
    this.bio,
    this.favoriteSports = const [],
    this.availabilityJson = const {},
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.onboarded = true,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        username: json['username'] as String,
        bio: json['bio'] as String?,
        favoriteSports: List<String>.from(json['favorite_sports'] as List? ?? []),
        availabilityJson:
            Map<String, dynamic>.from(json['availability_json'] as Map? ?? {}),
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        onboarded: json['onboarded'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'bio': bio,
        'favorite_sports': favoriteSports,
        'availability_json': availabilityJson,
        'avatar_url': avatarUrl,
      };

  Profile copyWith({
    String? username,
    String? bio,
    List<String>? favoriteSports,
    Map<String, dynamic>? availabilityJson,
    String? avatarUrl,
    bool? onboarded,
  }) =>
      Profile(
        id: id,
        username: username ?? this.username,
        bio: bio ?? this.bio,
        favoriteSports: favoriteSports ?? this.favoriteSports,
        availabilityJson: availabilityJson ?? this.availabilityJson,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        onboarded: onboarded ?? this.onboarded,
      );
}
