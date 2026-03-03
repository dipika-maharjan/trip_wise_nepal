import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';

abstract class IProfileRemoteDataSource {
  Future<bool> updateProfile(String name, String email);
}

class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<bool> updateProfile(String name, String email) async {
    final response = await _apiClient.post(
      ApiEndpoints.updateProfile,
      data: {
        'name': name,
        'email': email,
      },
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update profile');
    }
  }
}