import 'package:flutter_test/flutter_test.dart';
import 'package:game_on/models/match.dart';

void main() {
  final sampleJson = {
    'id': 'match-001',
    'creator_id': 'user-001',
    'sport_type': 'padel',
    'location_name': 'Central Park',
    'geo_lat': 48.85,
    'geo_lng': 2.35,
    'date_time': '2025-07-20T18:00:00Z',
    'total_spots': 4,
    'players_needed': 2,
    'status': 'open',
    'skill_level': 'intermediate',
    'created_at': '2025-06-01T00:00:00Z',
    'confirmed_at': null,
    'duration_minutes': 90,
    'group_id': null,
    'title': 'Evening Padel',
    'description': 'Bring your racket',
    'allowed_genders': null,
    'profiles': {'username': 'creator1', 'avatar_url': null},
  };

  group('Match.fromJson', () {
    test('parses all fields correctly', () {
      final m = Match.fromJson(sampleJson);
      expect(m.id, 'match-001');
      expect(m.creatorId, 'user-001');
      expect(m.sportType, SportType.padel);
      expect(m.locationName, 'Central Park');
      expect(m.geoLat, 48.85);
      expect(m.geoLng, 2.35);
      expect(m.totalSpots, 4);
      expect(m.playersNeeded, 2);
      expect(m.status, MatchStatus.open);
      expect(m.skillLevel, SkillLevel.intermediate);
      expect(m.confirmedAt, isNull);
      expect(m.durationMinutes, 90);
      expect(m.groupId, isNull);
      expect(m.title, 'Evening Padel');
      expect(m.description, 'Bring your racket');
      expect(m.allowedGenders, isNull);
      expect(m.creatorUsername, 'creator1');
    });

    test('handles unlimited match (null totalSpots)', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['total_spots'] = null
        ..['players_needed'] = null;
      final m = Match.fromJson(json);
      expect(m.isUnlimited, true);
      expect(m.isFull, false);
    });
  });

  group('Match computed properties', () {
    test('spotsTaken is correct', () {
      final m = Match.fromJson(sampleJson);
      expect(m.spotsTaken, 2); // 4 total - 2 needed
    });

    test('isFull when playersNeeded is 0', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['players_needed'] = 0
        ..['status'] = 'full';
      final m = Match.fromJson(json);
      expect(m.isFull, true);
    });

    test('isFull is false for unlimited', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['total_spots'] = null
        ..['players_needed'] = null;
      final m = Match.fromJson(json);
      expect(m.isFull, false);
    });

    test('isConfirmed when confirmedAt is set', () {
      final json = Map<String, dynamic>.from(sampleJson)
        ..['confirmed_at'] = '2025-07-20T19:00:00Z';
      final m = Match.fromJson(json);
      expect(m.isConfirmed, true);
    });

    test('isGenderRestricted', () {
      final m = Match.fromJson(sampleJson);
      expect(m.isGenderRestricted, false);

      final restricted = Map<String, dynamic>.from(sampleJson)
        ..['allowed_genders'] = ['M'];
      final m2 = Match.fromJson(restricted);
      expect(m2.isGenderRestricted, true);
    });

    test('durationLabel formats correctly', () {
      expect(Match.fromJson(sampleJson).durationLabel, '1h 30min'); // 90 min
      final json60 = Map<String, dynamic>.from(sampleJson)
        ..['duration_minutes'] = 60;
      expect(Match.fromJson(json60).durationLabel, '1h');
      final json45 = Map<String, dynamic>.from(sampleJson)
        ..['duration_minutes'] = 45;
      expect(Match.fromJson(json45).durationLabel, '45min');
    });
  });

  group('Match.toJson', () {
    test('serialises for DB insert', () {
      final m = Match.fromJson(sampleJson);
      final json = m.toJson();
      expect(json['creator_id'], 'user-001');
      expect(json['sport_type'], 'padel');
      expect(json['location_name'], 'Central Park');
      expect(json['skill_level'], 'intermediate');
      expect(json['duration_minutes'], 90);
      expect(json['title'], 'Evening Padel');
      expect(json.containsKey('id'), false);
    });
  });

  group('Match.copyWith', () {
    test('overrides selected fields', () {
      final m = Match.fromJson(sampleJson);
      final copy = m.copyWith(playersNeeded: 0, status: MatchStatus.full);
      expect(copy.playersNeeded, 0);
      expect(copy.status, MatchStatus.full);
      expect(copy.sportType, SportType.padel);
      expect(copy.locationName, 'Central Park');
    });
  });

  group('SportType', () {
    test('fromString resolves known sports', () {
      expect(SportType.fromString('padel'), SportType.padel);
      expect(SportType.fromString('football'), SportType.football);
      expect(SportType.fromString('basketball'), SportType.basketball);
      expect(SportType.fromString('tennis'), SportType.tennis);
      expect(SportType.fromString('running'), SportType.running);
      expect(SportType.fromString('cycling'), SportType.cycling);
    });

    test('fromString falls back to other', () {
      expect(SportType.fromString('unknown_sport'), SportType.other);
    });
  });

  group('SkillLevel', () {
    test('fromString resolves known levels', () {
      expect(SkillLevel.fromString('beginner'), SkillLevel.beginner);
      expect(SkillLevel.fromString('intermediate'), SkillLevel.intermediate);
      expect(SkillLevel.fromString('expert'), SkillLevel.expert);
      expect(SkillLevel.fromString('all_levels'), SkillLevel.allLevels);
    });

    test('fromString falls back to allLevels', () {
      expect(SkillLevel.fromString('pro'), SkillLevel.allLevels);
    });

    test('dbValue round-trips', () {
      for (final level in SkillLevel.values) {
        expect(SkillLevel.fromString(level.dbValue), level);
      }
    });
  });
}
