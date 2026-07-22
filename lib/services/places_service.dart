import 'supabase_client.dart';

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

/// Calls Google's Places/Geocoding APIs through the `places-proxy` Supabase
/// Edge Function rather than directly.
///
/// Google's legacy Places REST API never returns CORS headers, so a direct
/// browser call (Flutter web) is blocked outright regardless of API key
/// configuration; it also rejects HTTP-referrer-restricted keys. Proxying
/// through our own Edge Function sidesteps both — the Google key lives only
/// as a server-side secret, and the function sets its own CORS headers.
class PlacesService {
  static Future<Map<String, dynamic>?> _invoke(
    Map<String, String> queryParameters,
  ) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'places-proxy',
        queryParameters: queryParameters,
      );
      if (res.data == null) return null;
      return res.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Returns autocomplete suggestions for [input].
  /// Returns empty list if the request fails.
  static Future<List<PlaceSuggestion>> autocomplete(
    String input,
    String sessionToken,
  ) async {
    if (input.trim().isEmpty) return [];
    final body = await _invoke({
      'action': 'autocomplete',
      'input': input,
      'sessiontoken': sessionToken,
    });
    if (body == null) return [];
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
  }

  /// Returns place details (name + coordinates) for [placeId].
  /// Returns null on failure.
  static Future<({String name, double lat, double lng})?> getDetails(
    String placeId,
    String sessionToken,
  ) async {
    final body = await _invoke({
      'action': 'details',
      'place_id': placeId,
      'sessiontoken': sessionToken,
    });
    if (body == null) return null;
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
  }

  /// Reverse geocodes [lat]/[lng] to a human-readable address string.
  /// Returns null on failure.
  static Future<String?> reverseGeocode(double lat, double lng) async {
    final body = await _invoke({
      'action': 'geocode',
      'latlng': '$lat,$lng',
    });
    if (body == null) return null;
    final results = body['results'] as List<dynamic>? ?? [];
    if (results.isEmpty) return null;
    return (results.first as Map<String, dynamic>)['formatted_address']
        as String?;
  }
}
