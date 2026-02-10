import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/data/repositories/accommodation_repository.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';

class SearchAccommodationsParams extends Equatable {
  final String query;
  final int page;
  final int limit;

  const SearchAccommodationsParams({
    required this.query,
    this.page = 1,
    this.limit = 12,
  });

  @override
  List<Object?> get props => [query, page, limit];
}

final searchAccommodationsUsecaseProvider = Provider<SearchAccommodationsUseCase>((ref) {
  final repository = ref.read(accommodationRepositoryProvider);
  return SearchAccommodationsUseCase(repository: repository);
});

class SearchAccommodationsUseCase {
  final IAccommodationRepository _repository;

  SearchAccommodationsUseCase({required IAccommodationRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<AccommodationEntity>>> call(
    SearchAccommodationsParams params,
  ) async {
    return await _repository.searchAccommodations(
      query: params.query,
      page: params.page,
      limit: params.limit,
    );
  }
}
