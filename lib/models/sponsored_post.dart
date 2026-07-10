class SponsoredPost {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String linkUrl;
  final String? sportType; // SportType.name, null = all sports
  final double? geoLat;
  final double? geoLng;
  final double? radiusKm;

  const SponsoredPost({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.linkUrl,
    this.sportType,
    this.geoLat,
    this.geoLng,
    this.radiusKm,
  });

  factory SponsoredPost.fromJson(Map<String, dynamic> json) => SponsoredPost(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        linkUrl: json['link_url'] as String,
        sportType: json['sport_type'] as String?,
        geoLat: (json['geo_lat'] as num?)?.toDouble(),
        geoLng: (json['geo_lng'] as num?)?.toDouble(),
        radiusKm: (json['radius_km'] as num?)?.toDouble(),
      );
}
