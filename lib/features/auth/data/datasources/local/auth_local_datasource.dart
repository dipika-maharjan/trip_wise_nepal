import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/core/services/hive/hive_service.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/auth/data/datasources/auth_datasource.dart';
import 'package:trip_wise_nepal/features/auth/data/models/auth_hive_model.dart';

// Create provider
final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return AuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class AuthLocalDatasource implements IAuthLocalDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  })  : _hiveService = hiveService,
        _userSessionService = userSessionService;

  @override
  Future<AuthHiveModel> register(AuthHiveModel user) async {
    return await _hiveService.register(user);
  }

  @override
  Future<AuthHiveModel?> login(String email, String password) async {
    try {
      final user = _hiveService.login(email, password);
      if (user != null && user.authId != null) {
        // Always save user to Hive to ensure persistence
        await _hiveService.register(user);
        // Save user session to persist login across app restarts
        await _userSessionService.saveUserSession(
          userId: user.authId!,
          email: user.email,
          fullName: user.fullName,
          username: user.username,
          profilePicture: user.profilePicture ?? '',
        );
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getCurrentUser() async {
    try {
      print('[DEBUG] getCurrentUser: Checking if user is logged in...');
      if (!_userSessionService.isLoggedIn()) {
        print('[DEBUG] getCurrentUser: Not logged in');
        return null;
      }

      final userId = _userSessionService.getCurrentUserId();
      print('[DEBUG] getCurrentUser: userId from session = $userId');
      if (userId == null) {
        print('[DEBUG] getCurrentUser: userId is null');
        return null;
      }

      final user = _hiveService.getUserById(userId);
      print('[DEBUG] getCurrentUser: user from Hive = $user');
      return user;
    } catch (e, st) {
      print('[ERROR] getCurrentUser exception: $e\n$st');
      return null;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _userSessionService.clearSession();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthHiveModel?> getUserById(String authId) async {
    try {
      return _hiveService.getUserById(authId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthHiveModel?> getUserByEmail(String email) async {
    try {
      return _hiveService.getUserByEmail(email);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> updateUser(AuthHiveModel user) async {
    try {
      return await _hiveService.updateUser(user);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String authId) async {
    try {
      await _hiveService.deleteUser(authId);
      // Clear session if deleting current user
      final currentUserId = _userSessionService.getCurrentUserId();
      if (currentUserId == authId) {
        await _userSessionService.clearSession();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
