import 'package:equatable/equatable.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';

enum AccommodationStatus {
  initial,
  loading,
  loaded,
  error,
  searching,
  filtering,
}

class AccommodationState extends Equatable {
  final AccommodationStatus status;
  final List<AccommodationEntity> accommodations;
  final AccommodationEntity? selectedAccommodation;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final double? minPrice;
  final double? maxPrice;

  const AccommodationState({
    this.status = AccommodationStatus.initial,
    this.accommodations = const [],
    this.selectedAccommodation,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.minPrice,
    this.maxPrice,
  });

  AccommodationState copyWith({
    AccommodationStatus? status,
    List<AccommodationEntity>? accommodations,
    AccommodationEntity? selectedAccommodation,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
  }) {
    return AccommodationState(
      status: status ?? this.status,
      accommodations: accommodations ?? this.accommodations,
      selectedAccommodation:
          selectedAccommodation ?? this.selectedAccommodation,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  AccommodationState clearFilters() {
    return AccommodationState(
      status: status,
      accommodations: accommodations,
      selectedAccommodation: selectedAccommodation,
      errorMessage: errorMessage,
      currentPage: 1,
      hasMore: true,
      searchQuery: null,
      minPrice: null,
      maxPrice: null,
    );
  }

  @override
  List<Object?> get props => [
        status,
        accommodations,
        selectedAccommodation,
        errorMessage,
        currentPage,
        hasMore,
        searchQuery,
        minPrice,
        maxPrice,
      ];
}
