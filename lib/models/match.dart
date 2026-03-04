import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum MatchStatus { open, full, cancelled }

// ─── Skill level ────────────────────────────────────────────────────────────

enum SkillLevel {
  beginner,
  intermediate,
  expert,
  allLevels;

  String get dbValue => switch (this) {
        SkillLevel.beginner     => 'beginner',
        SkillLevel.intermediate => 'intermediate',
        SkillLevel.expert       => 'expert',
        SkillLevel.allLevels    => 'all_levels',
      };

  String get label => switch (this) {
        SkillLevel.beginner     => 'Beginner',
        SkillLevel.intermediate => 'Intermediate',
        SkillLevel.expert       => 'Expert',
        SkillLevel.allLevels    => 'All levels',
      };

  PhosphorIconData get icon => switch (this) {
        SkillLevel.beginner     => PhosphorIconsLight.leaf,
        SkillLevel.intermediate => PhosphorIconsLight.flame,
        SkillLevel.expert       => PhosphorIconsLight.crown,
        SkillLevel.allLevels    => PhosphorIconsLight.infinity,
      };

  Color get color => switch (this) {
        SkillLevel.beginner     => const Color(0xFF4CAF50),
        SkillLevel.intermediate => const Color(0xFFFB8C00),
        SkillLevel.expert       => const Color(0xFFE53935),
        SkillLevel.allLevels    => const Color(0xFF7C4DFF),
      };

  static SkillLevel fromString(String value) => SkillLevel.values.firstWhere(
        (e) => e.dbValue == value,
        orElse: () => SkillLevel.allLevels,
      );
}

// ─── Sport type ─────────────────────────────────────────────────────────────

enum SportType {
  padel,
  football,
  basketball,
  tennis,
  running,
  cycling,
  other;

  String get label => switch (this) {
        SportType.padel      => 'Padel',
        SportType.football   => 'Football',
        SportType.basketball => 'Basketball',
        SportType.tennis     => 'Tennis',
        SportType.running    => 'Running',
        SportType.cycling    => 'Cycling',
        SportType.other      => 'Other',
      };

  String get emoji => switch (this) {
        SportType.padel      => '🎾',
        SportType.football   => '⚽',
        SportType.basketball => '🏀',
        SportType.tennis     => '🎾',
        SportType.running    => '🏃',
        SportType.cycling    => '🚴',
        SportType.other      => '🏅',
      };

  PhosphorIconData get icon => switch (this) {
        SportType.football   => PhosphorIconsLight.soccerBall,
        SportType.padel      => PhosphorIconsLight.tennisBall,
        SportType.basketball => PhosphorIconsLight.basketball,
        SportType.tennis     => PhosphorIconsLight.tennisBall,
        SportType.running    => PhosphorIconsLight.personSimpleRun,
        SportType.cycling    => PhosphorIconsLight.bicycle,
        SportType.other      => PhosphorIconsLight.medal,
      };

  static SportType fromString(String value) => SportType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SportType.other,
      );
}

// ─── Match ───────────────────────────────────────────────────────────────────

class Match {
  final String id;
  final String creatorId;
  final SportType sportType;
  final String locationName;
  final double? geoLat;
  final double? geoLng;
  final DateTime dateTime;
  final int? totalSpots;      // null = unlimited
  final int? playersNeeded;   // null = unlimited
  final MatchStatus status;
  final SkillLevel skillLevel;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final int durationMinutes;
  final String? groupId; // null = public match
  final String? title;
  final String? description;

  const Match({
    required this.id,
    required this.creatorId,
    required this.sportType,
    required this.locationName,
    this.geoLat,
    this.geoLng,
    required this.dateTime,
    this.totalSpots,
    this.playersNeeded,
    this.status = MatchStatus.open,
    this.skillLevel = SkillLevel.allLevels,
    required this.createdAt,
    this.confirmedAt,
    this.durationMinutes = 60,
    this.groupId,
    this.title,
    this.description,
  });

  bool get isUnlimited => totalSpots == null;
  bool get isConfirmed => confirmedAt != null;

  String get durationLabel {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  /// Number of spots already taken. Always 0 for unlimited (use participant
  /// list for the real count in the detail screen).
  int get spotsTaken => isUnlimited ? 0 : totalSpots! - playersNeeded!;

  /// An unlimited match is never "full".
  bool get isFull =>
      !isUnlimited && (status == MatchStatus.full || playersNeeded == 0);

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        sportType: SportType.fromString(json['sport_type'] as String),
        locationName: json['location_name'] as String,
        geoLat: (json['geo_lat'] as num?)?.toDouble(),
        geoLng: (json['geo_lng'] as num?)?.toDouble(),
        dateTime: DateTime.parse(json['date_time'] as String).toLocal(),
        totalSpots: (json['total_spots'] as num?)?.toInt(),
        playersNeeded: (json['players_needed'] as num?)?.toInt(),
        status: MatchStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String),
          orElse: () => MatchStatus.open,
        ),
        skillLevel: SkillLevel.fromString(
            json['skill_level'] as String? ?? 'all_levels'),
        createdAt: DateTime.parse(json['created_at'] as String),
        confirmedAt: json['confirmed_at'] == null
            ? null
            : DateTime.parse(json['confirmed_at'] as String),
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
        groupId: json['group_id'] as String?,
        title: json['title'] as String?,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'creator_id': creatorId,
        'sport_type': sportType.name,
        'location_name': locationName,
        'geo_lat': geoLat,
        'geo_lng': geoLng,
        'date_time': dateTime.toUtc().toIso8601String(),
        'total_spots': totalSpots,
        'players_needed': playersNeeded,
        'status': status.name,
        'skill_level': skillLevel.dbValue,
        'duration_minutes': durationMinutes,
        if (groupId != null) 'group_id': groupId,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
      };

  Match copyWith({
    int? playersNeeded,
    MatchStatus? status,
    DateTime? confirmedAt,
    String? title,
    String? description,
  }) =>
      Match(
        id: id,
        creatorId: creatorId,
        sportType: sportType,
        locationName: locationName,
        geoLat: geoLat,
        geoLng: geoLng,
        dateTime: dateTime,
        totalSpots: totalSpots,
        playersNeeded: playersNeeded ?? this.playersNeeded,
        status: status ?? this.status,
        skillLevel: skillLevel,
        createdAt: createdAt,
        confirmedAt: confirmedAt ?? this.confirmedAt,
        durationMinutes: durationMinutes,
        groupId: groupId,
        title: title ?? this.title,
        description: description ?? this.description,
      );
}
