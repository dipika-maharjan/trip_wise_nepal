import '../../data/models/review_model.dart';

class ReviewState {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  ReviewState copyWith({
    List<ReviewModel>? reviews,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}
