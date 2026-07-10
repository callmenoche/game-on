import 'package:flutter_test/flutter_test.dart';
import 'package:game_on/models/profile.dart';

void main() {
  final now = DateTime(2025, 6, 15);
  final sampleJson = {
    'id': 'user-123',
    'username': 'testplayer',
    'bio': 'Love padel',
    'favorite_sports': ['padel', 'football'],
    'availability_json': {
      'monday': ['morning', 'evening']
    },
    'avatar_url': 'https://example.com/avatar.jpg',
    'created_at': '2025-01-01T00:00:00Z',
    'updated_at': '2025-06-15T00:00:00Z',
    'onboarded': true,
    'birth_date': '1995-03-20',
    'gender': 'M',
    'show_age': true,
    'show_gender': false,
    'accepted_terms_at': '2025-06-01T00:00:00Z',
    'default_location_name': 'Paris',
    'default_geo_lat': 48.8566,
    'default_geo_lng': 2.3522,
  };

  group('Profile.fromJson', () {
    test('parses all fields correctly', () {
      final p = Profile.fromJson(sampleJson);
      expect(p.id, 'user-123');
      expect(p.username, 'testplayer');
      expect(p.bio, 'Love padel');
      expect(p.favoriteSports, ['padel', 'football']);
      expect(p.availabilityJson['monday'], ['morning', 'evening']);
      expect(p.avatarUrl, 'https://example.com/avatar.jpg');
      expect(p.onboarded, true);
      expect(p.birthDate, DateTime(1995, 3, 20));
      expect(p.gender, 'M');
      expect(p.showAge, true);
      expect(p.showGender, false);
      expect(p.acceptedTermsAt, isNotNull);
      expect(p.defaultLocationName, 'Paris');
      expect(p.defaultGeoLat, 48.8566);
      expect(p.defaultGeoLng, 2.3522);
    });

    test('handles missing optional fields', () {
      final minimal = {
        'id': 'user-456',
        'username': 'minimal',
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      };
      final p = Profile.fromJson(minimal);
      expect(p.bio, isNull);
      expect(p.favoriteSports, isEmpty);
      expect(p.availabilityJson, isEmpty);
      expect(p.avatarUrl, isNull);
      expect(p.onboarded, true);
      expect(p.birthDate, isNull);
      expect(p.gender, isNull);
      expect(p.showAge, true);
      expect(p.showGender, true);
      expect(p.defaultLocationName, isNull);
      expect(p.defaultGeoLat, isNull);
    });
  });

  group('Profile.toJson', () {
    test('serialises mutable fields', () {
      final p = Profile.fromJson(sampleJson);
      final json = p.toJson();
      expect(json['bio'], 'Love padel');
      expect(json['favorite_sports'], ['padel', 'football']);
      expect(json['birth_date'], '1995-03-20');
      expect(json['gender'], 'M');
      expect(json['show_age'], true);
      expect(json['show_gender'], false);
      expect(json['default_location_name'], 'Paris');
      expect(json['default_geo_lat'], 48.8566);
      expect(json['default_geo_lng'], 2.3522);
      // id and username should NOT be in toJson
      expect(json.containsKey('id'), false);
      expect(json.containsKey('username'), false);
    });
  });

  group('Profile.copyWith', () {
    test('copies with overridden fields', () {
      final p = Profile.fromJson(sampleJson);
      final copy = p.copyWith(bio: 'New bio', showAge: false);
      expect(copy.bio, 'New bio');
      expect(copy.showAge, false);
      // Non-overridden fields stay the same
      expect(copy.username, 'testplayer');
      expect(copy.gender, 'M');
      expect(copy.defaultLocationName, 'Paris');
    });
  });

  group('Profile.age', () {
    test('returns null when birthDate is null', () {
      final p = Profile(
        id: '1',
        username: 'u',
        createdAt: now,
        updatedAt: now,
        birthDate: null,
      );
      expect(p.age, isNull);
    });

    test('computes age correctly', () {
      final p = Profile(
        id: '1',
        username: 'u',
        createdAt: now,
        updatedAt: now,
        birthDate: DateTime(2000, 1, 1),
      );
      // age depends on current date — just check it's reasonable
      expect(p.age, greaterThanOrEqualTo(25));
      expect(p.age, lessThanOrEqualTo(30));
    });
  });
}
