import 'dart:io';
import 'package:dio/dio.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';
import 'package:trip_wise_nepal/core/services/storage/token_service.dart';

/// Interface for profile remote data source
abstract interface class IProfileRemoteDataSource {
  /// Upload profile image to server
  /// Returns image URL on success
  Future<String> uploadProfileImage(File imageFile);
}

/// Implementation of profile remote data source
class ProfileRemoteDataSource implements IProfileRemoteDataSource {
  final Dio _dio;
  final TokenService _tokenService;

  ProfileRemoteDataSource({
    required Dio dio,
    required TokenService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Get token from service
      final token = await _tokenService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found. Please login first.');
      }

      // Create multipart form data with image file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Make PUT request with Bearer token
      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Check if request was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        // Check success flag
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Upload failed');
        }

        // Extract imageUrl from response
        // Backend returns: { success: true, data: { imageUrl: "/uploads/..." } }
        final profileData = data['data'] as Map<String, dynamic>?;
        final imageUrl = profileData?['imageUrl'];

        if (imageUrl == null || imageUrl.toString().isEmpty) {
          throw Exception('Image URL not found in response');
        }

        return imageUrl.toString();
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
