import 'package:trip_wise_nepal/features/accommodation/data/models/accommodation_api_model.dart';

abstract interface class IAccommodationDataSource {
  Future<List<AccommodationApiModel>?> getAccommodations({
    int page = 1,
    int limit = 12,
  });

  Future<AccommodationApiModel?> getAccommodationById(String id);

  Future<List<AccommodationApiModel>?> searchAccommodations({
    required String query,
    int page = 1,
    int limit = 12,
  });

  Future<List<AccommodationApiModel>?> getAccommodationsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int limit = 12,
  });
}
