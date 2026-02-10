import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';

class AccommodationApiModel {
  final String? id;
  final String name;
  final String address;
  final String overview;
  final List<String> images;
  final List<String> amenities;
  final List<String> ecoFriendlyHighlights;
  final double pricePerNight;
  final LocationModel? location;
  final String? availableFrom;
  final String? availableUntil;
  final double? rating;
  final int? totalReviews;
  final bool isActive;

  AccommodationApiModel({
    this.id,
    required this.name,
    required this.address,
    required this.overview,
    required this.images,
    required this.amenities,
    required this.ecoFriendlyHighlights,
    required this.pricePerNight,
    this.location,
    this.availableFrom,
    this.availableUntil,
    this.rating,
    this.totalReviews,
    this.isActive = true,
  });

  // fromJson
  factory AccommodationApiModel.fromJson(Map<String, dynamic> json) {
    return AccommodationApiModel(
      id: json['_id'] as String?,
      name: json['name'] as String,
      address: json['address'] as String,
      overview: json['overview'] as String,
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      ecoFriendlyHighlights:
          List<String>.from(json['ecoFriendlyHighlights'] ?? []),
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
      availableFrom: json['availableFrom'] as String?,
      availableUntil: json['availableUntil'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalReviews: json['totalReviews'] as int?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'overview': overview,
      'images': images,
      'amenities': amenities,
      'ecoFriendlyHighlights': ecoFriendlyHighlights,
      'pricePerNight': pricePerNight,
      'location': location?.toJson(),
      'availableFrom': availableFrom,
      'availableUntil': availableUntil,
      'isActive': isActive,
    };
  }

  // toEntity
  AccommodationEntity toEntity() {
    return AccommodationEntity(
      id: id,
      name: name,
      address: address,
      overview: overview,
      images: images,
      amenities: amenities,
      ecoFriendlyHighlights: ecoFriendlyHighlights,
      pricePerNight: pricePerNight,
      location: location?.toEntity(),
      availableFrom: availableFrom,
      availableUntil: availableUntil,
      rating: rating,
      totalReviews: totalReviews,
      isActive: isActive,
    );
  }

  // toEntityList
  static List<AccommodationEntity> toEntityList(
    List<AccommodationApiModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}

class LocationModel {
  final double lat;
  final double lng;
  final String? mapUrl;

  LocationModel({
    required this.lat,
    required this.lng,
    this.mapUrl,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      mapUrl: json['mapUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'mapUrl': mapUrl,
    };
  }

  LocationEntity toEntity() {
    return LocationEntity(
      lat: lat,
      lng: lng,
      mapUrl: mapUrl,
    );
  }
}
