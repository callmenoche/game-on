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
  final DateTime? birthDate;
  final String? gender; // 'M', 'F', or 'X'
  final bool showAge;
  final bool showGender;

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
    this.birthDate,
    this.gender,
    this.showAge = true,
    this.showGender = true,
  });

  /// Computed age from [birthDate]. Returns null if birthDate is null.
  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int years = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

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
        birthDate: json['birth_date'] != null
            ? DateTime.tryParse(json['birth_date'] as String)
            : null,
        gender: json['gender'] as String?,
        showAge: json['show_age'] as bool? ?? true,
        showGender: json['show_gender'] as bool? ?? true,
      );

  /// Serialises mutable fields for DB updates.
  /// Excludes [id] (PK) and [username] (immutable after onboarding).
  Map<String, dynamic> toJson() => {
        'bio': bio,
        'favorite_sports': favoriteSports,
        'availability_json': availabilityJson,
        'avatar_url': avatarUrl,
        'birth_date': birthDate?.toIso8601String().split('T').first,
        'gender': gender,
        'show_age': showAge,
        'show_gender': showGender,
      };

  Profile copyWith({
    String? username,
    String? bio,
    List<String>? favoriteSports,
    Map<String, dynamic>? availabilityJson,
    String? avatarUrl,
    bool? onboarded,
    DateTime? birthDate,
    String? gender,
    bool? showAge,
    bool? showGender,
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
        birthDate: birthDate ?? this.birthDate,
        gender: gender ?? this.gender,
        showAge: showAge ?? this.showAge,
        showGender: showGender ?? this.showGender,
      );
}
