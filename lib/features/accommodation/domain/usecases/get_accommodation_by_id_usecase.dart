import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/data/repositories/accommodation_repository.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';

final getAccommodationByIdUsecaseProvider = Provider<GetAccommodationByIdUseCase>((ref) {
  final repository = ref.read(accommodationRepositoryProvider);
  return GetAccommodationByIdUseCase(repository: repository);
});

class GetAccommodationByIdUseCase {
  final IAccommodationRepository _repository;

  GetAccommodationByIdUseCase({required IAccommodationRepository repository})
      : _repository = repository;

  Future<Either<Failure, AccommodationEntity>> call(String id) async {
    return await _repository.getAccommodationById(id);
  }
}
