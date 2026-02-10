import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/data/repositories/accommodation_repository.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';

class GetAccommodationsParams extends Equatable {
  final int page;
  final int limit;

  const GetAccommodationsParams({
    this.page = 1,
    this.limit = 12,
  });

  @override
  List<Object?> get props => [page, limit];
}

final getAccommodationsUsecaseProvider = Provider<GetAccommodationsUseCase>((ref) {
  final repository = ref.read(accommodationRepositoryProvider);
  return GetAccommodationsUseCase(repository: repository);
});

class GetAccommodationsUseCase {
  final IAccommodationRepository _repository;

  GetAccommodationsUseCase({required IAccommodationRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<AccommodationEntity>>> call(
    GetAccommodationsParams params,
  ) async {
    return await _repository.getAccommodations(
      page: params.page,
      limit: params.limit,
    );
  }
}
