import 'package:trip_wise_nepal/features/accommodation/data/models/optional_extra_api_model.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';

class OptionalExtraRemoteDatasource {
  final ApiClient _apiClient;

  OptionalExtraRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<OptionalExtraApiModel>> getOptionalExtrasByAccommodationId(String accommodationId) async {
    final response = await _apiClient.get(
      '/optional-extras',
      queryParameters: {'accommodationId': accommodationId},
    );
    if (response.statusCode == 200 && response.data['success'] == true) {
      final List<dynamic> extras = response.data['data'];
      return extras.map((e) => OptionalExtraApiModel.fromJson(e)).toList();
    }
    return [];
  }
}
