import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_wise_nepal/core/providers/shared_preferences_provider.dart';

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserUsername = 'user_username';
  static const String _keyUserProfilePicture = 'user_profile_picture';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Normalize profile picture URL from backend
  String? _normalizeProfilePictureUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Don't store default-profile.png - treat it as no profile picture
    if (url.contains('default-profile.png')) return null;
    
    // If it's already a full URL, return as-is
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    
    // If it already has /uploads/ prefix, return as-is
    if (url.startsWith('/uploads/')) return url;
    
    // Otherwise, add /uploads/ prefix to bare filename
    return '/uploads/$url';
  }

  // Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String fullName,
    required String username,
    String? profilePicture,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserFullName, fullName);
    await _prefs.setString(_keyUserUsername, username);
    
    // Normalize and save profile picture URL
    final normalizedUrl = _normalizeProfilePictureUrl(profilePicture);
    if (normalizedUrl != null) {
      await _prefs.setString(_keyUserProfilePicture, normalizedUrl);
    } else {
      await _prefs.remove(_keyUserProfilePicture);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserFullName);
  }

  // Get current user username
  String? getCurrentUserUsername() {
    return _prefs.getString(_keyUserUsername);
  }

  // Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  // Update user profile picture after upload
  Future<void> updateUserProfilePicture(String imageUrl) async {
    final normalizedUrl = _normalizeProfilePictureUrl(imageUrl);
    if (normalizedUrl != null) {
      await _prefs.setString(_keyUserProfilePicture, normalizedUrl);
    } else {
      await _prefs.remove(_keyUserProfilePicture);
    }
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserFullName);
    await _prefs.remove(_keyUserUsername);
    await _prefs.remove(_keyUserProfilePicture);
  }
}