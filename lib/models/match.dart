import 'package:flutter/material.dart';

enum MatchStatus { open, full, cancelled }

// ─── Skill level ───────────────────────────────────────────────────────────────

enum SkillLevel {
  beginner,
  intermediate,
  expert,
  allLevels;

  /// Value stored in the database (snake_case).
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

  String get emoji => switch (this) {
        SkillLevel.beginner     => '🟢',
        SkillLevel.intermediate => '🟡',
        SkillLevel.expert       => '🔴',
        SkillLevel.allLevels    => '✨',
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

// ─── Sport type ────────────────────────────────────────────────────────────────

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

  static SportType fromString(String value) => SportType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => SportType.other,
      );
}

// ─── Match ─────────────────────────────────────────────────────────────────────

class Match {
  final String id;
  final String creatorId;
  final SportType sportType;
  final String locationName;
  final double? geoLat;
  final double? geoLng;
  final DateTime dateTime;
  final int totalSpots;
  final int playersNeeded;
  final MatchStatus status;
  final SkillLevel skillLevel;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.creatorId,
    required this.sportType,
    required this.locationName,
    this.geoLat,
    this.geoLng,
    required this.dateTime,
    required this.totalSpots,
    required this.playersNeeded,
    this.status = MatchStatus.open,
    this.skillLevel = SkillLevel.allLevels,
    required this.createdAt,
  });

  int get spotsTaken => totalSpots - playersNeeded;
  bool get isFull => status == MatchStatus.full || playersNeeded == 0;

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as String,
        creatorId: json['creator_id'] as String,
        sportType: SportType.fromString(json['sport_type'] as String),
        locationName: json['location_name'] as String,
        geoLat: (json['geo_lat'] as num?)?.toDouble(),
        geoLng: (json['geo_lng'] as num?)?.toDouble(),
        dateTime: DateTime.parse(json['date_time'] as String).toLocal(),
        totalSpots: json['total_spots'] as int,
        playersNeeded: json['players_needed'] as int,
        status: MatchStatus.values.firstWhere(
          (e) => e.name == (json['status'] as String),
          orElse: () => MatchStatus.open,
        ),
        skillLevel: SkillLevel.fromString(
            json['skill_level'] as String? ?? 'all_levels'),
        createdAt: DateTime.parse(json['created_at'] as String),
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
      };

  Match copyWith({int? playersNeeded, MatchStatus? status}) => Match(
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
      );
}
