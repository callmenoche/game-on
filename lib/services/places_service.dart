import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });
}

class PlacesService {
  static const _key = String.fromEnvironment('GOOGLE_PLACES_KEY');
  static const _base = 'https://maps.googleapis.com/maps/api';

  static bool get hasKey => _key.isNotEmpty;

  /// Returns autocomplete suggestions for [input].
  /// Returns empty list if key is missing or request fails.
  static Future<List<PlaceSuggestion>> autocomplete(
    String input,
    String sessionToken,
  ) async {
    if (_key.isEmpty || input.trim().isEmpty) return [];
    try {
      final uri = Uri.parse('$_base/place/autocomplete/json').replace(
        queryParameters: {
          'input': input,
          'sessiontoken': sessionToken,
          'key': _key,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final predictions = body['predictions'] as List<dynamic>? ?? [];
      return predictions.map((p) {
        final structured =
            p['structured_formatting'] as Map<String, dynamic>? ?? {};
        return PlaceSuggestion(
          placeId: p['place_id'] as String? ?? '',
          mainText: structured['main_text'] as String? ?? p['description'] as String? ?? '',
          secondaryText: structured['secondary_text'] as String? ?? '',
        );
      }).where((s) => s.placeId.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns place details (name + coordinates) for [placeId].
  /// Returns null on failure.
  static Future<({String name, double lat, double lng})?> getDetails(
    String placeId,
    String sessionToken,
  ) async {
    if (_key.isEmpty) return null;
    try {
      final uri = Uri.parse('$_base/place/details/json').replace(
        queryParameters: {
          'place_id': placeId,
          'fields': 'name,geometry',
          'sessiontoken': sessionToken,
          'key': _key,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final result = body['result'] as Map<String, dynamic>?;
      if (result == null) return null;
      final loc = (result['geometry'] as Map<String, dynamic>?)?['location']
          as Map<String, dynamic>?;
      if (loc == null) return null;
      return (
        name: result['name'] as String? ?? '',
        lat: (loc['lat'] as num).toDouble(),
        lng: (loc['lng'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Reverse geocodes [lat]/[lng] to a human-readable address string.
  /// Returns null on failure.
  static Future<String?> reverseGeocode(double lat, double lng) async {
    if (_key.isEmpty) return null;
    try {
      final uri = Uri.parse('$_base/geocode/json').replace(
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': _key,
        },
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final results = body['results'] as List<dynamic>? ?? [];
      if (results.isEmpty) return null;
      return (results.first as Map<String, dynamic>)['formatted_address']
          as String?;
    } catch (_) {
      return null;
    }
  }
}
