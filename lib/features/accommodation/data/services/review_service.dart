import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ReviewService(apiClient);
});

class ReviewService {
  final ApiClient _apiClient;
  ReviewService(this._apiClient);

  Future<Response> getReviews({
    required String accommodationId,
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.get(
      '/reviews',
      queryParameters: {
        'accommodationId': accommodationId,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<Response> createReview({
    required String accommodationId,
    required int rating,
    required String comment,
  }) async {
    return await _apiClient.post(
      '/reviews',
      data: {
        'accommodationId': accommodationId,
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<Response> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    return await _apiClient.put(
      '/reviews/$reviewId',
      data: {
        'rating': rating,
        'comment': comment,
      },
    );
  }

  Future<Response> deleteReview({
    required String reviewId,
  }) async {
    return await _apiClient.delete('/reviews/$reviewId');
  }
}
