
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/review_service.dart';
import '../../data/models/review_model.dart';
import 'review_state.dart';

final reviewNotifierProvider = StateNotifierProvider.family<ReviewNotifier, ReviewState, String>(
  (ref, accommodationId) => ReviewNotifier(ref, accommodationId),
);

class ReviewNotifier extends StateNotifier<ReviewState> {
  final Ref ref;
  final String accommodationId;

  ReviewNotifier(this.ref, this.accommodationId) : super(ReviewState());

  Future<void> fetchReviews({bool refresh = false}) async {
    if (state.isLoading) return;
    final page = refresh ? 1 : state.page;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await ref.read(reviewServiceProvider).getReviews(
        accommodationId: accommodationId,
        page: page,
        limit: 10,
      );
      final data = response.data['data'] as List;
      final reviews = data.map((e) => ReviewModel.fromJson(e)).toList();
      final hasMore = reviews.length == 10;

      state = state.copyWith(
        reviews: refresh ? reviews : [...state.reviews, ...reviews],
        isLoading: false,
        hasMore: hasMore,
        page: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = ReviewState();
  }
}
