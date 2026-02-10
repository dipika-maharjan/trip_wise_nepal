import 'package:equatable/equatable.dart';

class AccommodationEntity extends Equatable {
  final String? id;
  final String name;
  final String address;
  final String overview;
  final List<String> images;
  final List<String> amenities;
  final List<String> ecoFriendlyHighlights;
  final double pricePerNight;
  final LocationEntity? location;
  final String? availableFrom;
  final String? availableUntil;
  final double? rating;
  final int? totalReviews;
  final bool isActive;

  const AccommodationEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        overview,
        images,
        amenities,
        ecoFriendlyHighlights,
        pricePerNight,
        location,
        availableFrom,
        availableUntil,
        rating,
        totalReviews,
        isActive,
      ];
}

class LocationEntity extends Equatable {
  final double lat;
  final double lng;
  final String? mapUrl;

  const LocationEntity({
    required this.lat,
    required this.lng,
    this.mapUrl,
  });

  @override
  List<Object?> get props => [lat, lng, mapUrl];
}
