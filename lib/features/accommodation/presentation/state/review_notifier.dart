
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/review_service.dart';
import '../../data/models/review_model.dart';
import 'review_state.dart';

final reviewNotifierProvider = StateNotifierProvider.family<ReviewNotifier, ReviewState, String>(
  (ref, accommodationId) => ReviewNotifier(ref, accommodationId),
);

class ReviewNotifier extends StateNotifier<ReviewState> {
    // Reset hasLoaded flag so reviews can be fetched again
    void resetLoaded() {
      state = state.copyWith(hasLoaded: false);
    }
  final Ref ref;
  final String accommodationId;

  ReviewNotifier(this.ref, this.accommodationId) : super(ReviewState());

  Future<void> fetchReviews({bool refresh = false}) async {
    if (state.isLoading || state.hasLoaded) return;
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
        hasLoaded: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), hasLoaded: true);
    } finally {
      // Always set isLoading to false, even if an error or empty result
      if (state.isLoading) {
        state = state.copyWith(isLoading: false, hasLoaded: true);
      }
    }
  }

  void reset() {
    state = ReviewState();
  }
}
