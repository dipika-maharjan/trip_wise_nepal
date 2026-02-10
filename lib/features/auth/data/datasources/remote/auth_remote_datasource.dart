import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';
import 'package:trip_wise_nepal/core/services/storage/token_service.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/auth/data/datasources/auth_datasource.dart';
import 'package:trip_wise_nepal/features/auth/data/models/auth_api_model.dart';

//Create Provider
final authRemoteDatasourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});
  

class AuthRemoteDatasource implements IAuthRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  AuthRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService = tokenService;


  @override
  Future<AuthApiModel?> login(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    if (response.data['success'] == true) {
      // Backend may return only {success, token} with no user payload.
      final rawUser = response.data['data'] ?? response.data['user'];

      if (rawUser is Map<String, dynamic>) {
        final user = AuthApiModel.fromJson(rawUser);

        await _userSessionService.saveUserSession(
          userId: user.id ?? '',
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          profilePicture: user.profilePicture,
        );

        final token = response.data['token'];
        await _tokenService.saveToken(token);
        return user;
      }

      // If user details are missing, still save token and synthesize a minimal user
      // so the login flow can continue instead of returning "invalid".
      final token = response.data['token'];
      if (token != null) {
        await _tokenService.saveToken(token);
      }

      final fallbackUsername = email.split('@').first;
      final user = AuthApiModel(
        id: null,
        fullName: fallbackUsername,
        email: email,
        username: fallbackUsername,
      );

      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        fullName: user.fullName,
        username: user.username,
        profilePicture: user.profilePicture,
      );

      return user;
    }

    return null;
  }

  @override
  Future<AuthApiModel> register(AuthApiModel user) async{
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: user.toJson(),
    );

    if(response.data['success'] == true){
      final data = response.data['data'] as Map<String, dynamic>;
      final registeredUser = AuthApiModel.fromJson(data);
      return registeredUser;
    }
    return user;
  }

  @override
  Future<AuthApiModel?> getUserById(String authId) {
    // TODO: implement getUserById
    throw UnimplementedError();
  }

  @override
  Future<bool> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestPasswordReset,
        data: {'email': email},
      );

      if (response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword(token),
        data: {'newPassword': newPassword},
      );

      if (response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
  

}