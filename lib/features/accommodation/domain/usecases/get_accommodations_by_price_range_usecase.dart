import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/data/repositories/accommodation_repository.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';

class GetAccommodationsByPriceRangeParams extends Equatable {
  final double minPrice;
  final double maxPrice;
  final int page;
  final int limit;

  const GetAccommodationsByPriceRangeParams({
    required this.minPrice,
    required this.maxPrice,
    this.page = 1,
    this.limit = 12,
  });

  @override
  List<Object?> get props => [minPrice, maxPrice, page, limit];
}

final getAccommodationsByPriceRangeUsecaseProvider =
    Provider<GetAccommodationsByPriceRangeUseCase>((ref) {
  final repository = ref.read(accommodationRepositoryProvider);
  return GetAccommodationsByPriceRangeUseCase(repository: repository);
});

class GetAccommodationsByPriceRangeUseCase {
  final IAccommodationRepository _repository;

  GetAccommodationsByPriceRangeUseCase({
    required IAccommodationRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, List<AccommodationEntity>>> call(
    GetAccommodationsByPriceRangeParams params,
  ) async {
    return await _repository.getAccommodationsByPriceRange(
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      page: params.page,
      limit: params.limit,
    );
  }
}
