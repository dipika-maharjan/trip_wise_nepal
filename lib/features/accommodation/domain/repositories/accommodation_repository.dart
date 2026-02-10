import 'package:dartz/dartz.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';

abstract interface class IAccommodationRepository {
  Future<Either<Failure, List<AccommodationEntity>>> getAccommodations({
    int page = 1,
    int limit = 12,
  });
  
  Future<Either<Failure, AccommodationEntity>> getAccommodationById(String id);
  
  Future<Either<Failure, List<AccommodationEntity>>> searchAccommodations({
    required String query,
    int page = 1,
    int limit = 12,
  });
  
  Future<Either<Failure, List<AccommodationEntity>>> getAccommodationsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int limit = 12,
  });
}
