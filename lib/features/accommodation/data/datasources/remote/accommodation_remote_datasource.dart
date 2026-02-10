import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';
import 'package:trip_wise_nepal/features/accommodation/data/datasources/accommodation_datasource.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/accommodation_api_model.dart';

final accommodationRemoteDatasourceProvider =
    Provider<IAccommodationDataSource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AccommodationRemoteDataSource(apiClient: apiClient);
});

class AccommodationRemoteDataSource implements IAccommodationDataSource {
  final ApiClient _apiClient;

  AccommodationRemoteDataSource({required ApiClient apiClient}) 
      : _apiClient = apiClient;

  @override
  Future<List<AccommodationApiModel>?> getAccommodations({
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getAccommodations,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> accommodationsList = data['data'];
          return accommodationsList
              .map((json) => AccommodationApiModel.fromJson(json))
              .toList();
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AccommodationApiModel?> getAccommodationById(String id) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getAccommodationById(id),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return AccommodationApiModel.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccommodationApiModel>?> searchAccommodations({
    required String query,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.searchAccommodations,
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> accommodationsList = data['data'];
          return accommodationsList
              .map((json) => AccommodationApiModel.fromJson(json))
              .toList();
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AccommodationApiModel>?> getAccommodationsByPriceRange({
    required double minPrice,
    required double maxPrice,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.getAccommodationsByPriceRange,
        queryParameters: {
          'minPrice': minPrice,
          'maxPrice': maxPrice,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> accommodationsList = data['data'];
          return accommodationsList
              .map((json) => AccommodationApiModel.fromJson(json))
              .toList();
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
