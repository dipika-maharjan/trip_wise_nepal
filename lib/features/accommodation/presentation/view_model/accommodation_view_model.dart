import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/get_accommodation_by_id_usecase.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/get_accommodations_by_price_range_usecase.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/get_accommodations_usecase.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/search_accommodations_usecase.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';

final accommodationViewModelProvider =
    NotifierProvider<AccommodationViewModel, AccommodationState>(
  AccommodationViewModel.new,
);

class AccommodationViewModel extends Notifier<AccommodationState> {
  late final GetAccommodationsUseCase _getAccommodationsUsecase;
  late final GetAccommodationByIdUseCase _getAccommodationByIdUsecase;
  late final SearchAccommodationsUseCase _searchAccommodationsUsecase;
  late final GetAccommodationsByPriceRangeUseCase
      _getAccommodationsByPriceRangeUsecase;

  @override
  AccommodationState build() {
    _getAccommodationsUsecase = ref.read(getAccommodationsUsecaseProvider);
    _getAccommodationByIdUsecase = ref.read(getAccommodationByIdUsecaseProvider);
    _searchAccommodationsUsecase = ref.read(searchAccommodationsUsecaseProvider);
    _getAccommodationsByPriceRangeUsecase =
        ref.read(getAccommodationsByPriceRangeUsecaseProvider);
    return const AccommodationState();
  }

  Future<void> getAccommodations({bool loadMore = false}) async {
    if (loadMore) {
      if (!state.hasMore) return;
      state = state.copyWith(currentPage: state.currentPage + 1);
    } else {
      state = state.copyWith(
        status: AccommodationStatus.loading,
        currentPage: 1,
      );
    }

    final result = await _getAccommodationsUsecase(
      GetAccommodationsParams(
        page: state.currentPage,
        limit: 12,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AccommodationStatus.error,
        errorMessage: failure.message,
      ),
      (accommodations) {
        final updatedList = loadMore
            ? [...state.accommodations, ...accommodations]
            : accommodations;
        
        state = state.copyWith(
          status: AccommodationStatus.loaded,
          accommodations: updatedList,
          hasMore: accommodations.length == 12,
        );
      },
    );
  }

  Future<void> getAccommodationById(String id) async {
    state = state.copyWith(status: AccommodationStatus.loading);

    final result = await _getAccommodationByIdUsecase(id);

    result.fold(
      (failure) => state = state.copyWith(
        status: AccommodationStatus.error,
        errorMessage: failure.message,
      ),
      (accommodation) => state = state.copyWith(
        status: AccommodationStatus.loaded,
        selectedAccommodation: accommodation,
      ),
    );
  }

  Future<void> searchAccommodations(String query, {bool loadMore = false}) async {
    if (query.trim().isEmpty) {
      await getAccommodations();
      return;
    }

    if (loadMore) {
      if (!state.hasMore) return;
      state = state.copyWith(currentPage: state.currentPage + 1);
    } else {
      state = state.copyWith(
        status: AccommodationStatus.searching,
        currentPage: 1,
        searchQuery: query,
      );
    }

    final result = await _searchAccommodationsUsecase(
      SearchAccommodationsParams(
        query: query,
        page: state.currentPage,
        limit: 12,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AccommodationStatus.error,
        errorMessage: failure.message,
      ),
      (accommodations) {
        final updatedList = loadMore
            ? [...state.accommodations, ...accommodations]
            : accommodations;
        
        state = state.copyWith(
          status: AccommodationStatus.loaded,
          accommodations: updatedList,
          hasMore: accommodations.length == 12,
        );
      },
    );
  }

  Future<void> filterByPriceRange({
    required double minPrice,
    required double maxPrice,
    bool loadMore = false,
  }) async {
    if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice) {
      state = state.copyWith(
        status: AccommodationStatus.error,
        errorMessage: "Invalid price range",
      );
      return;
    }

    if (loadMore) {
      if (!state.hasMore) return;
      state = state.copyWith(currentPage: state.currentPage + 1);
    } else {
      state = state.copyWith(
        status: AccommodationStatus.filtering,
        currentPage: 1,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
    }

    final result = await _getAccommodationsByPriceRangeUsecase(
      GetAccommodationsByPriceRangeParams(
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: state.currentPage,
        limit: 12,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AccommodationStatus.error,
        errorMessage: failure.message,
      ),
      (accommodations) {
        final updatedList = loadMore
            ? [...state.accommodations, ...accommodations]
            : accommodations;
        
        state = state.copyWith(
          status: AccommodationStatus.loaded,
          accommodations: updatedList,
          hasMore: accommodations.length == 12,
        );
      },
    );
  }

  void clearFilters() {
    state = state.clearFilters();
    getAccommodations();
  }

  void clearError() {
    state = state.copyWith(
      status: AccommodationStatus.initial,
      errorMessage: null,
    );
  }
}
