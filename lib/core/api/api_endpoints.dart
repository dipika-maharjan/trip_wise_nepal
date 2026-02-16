import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  
  /// Set to true when building for physical devices (Android phones, tablets, etc.)
  /// Set to false for emulators/simulators
  /// When true, uses [compIpAddress] instead of 10.0.2.2 (emulator-only address)
  static const bool isPhysicalDevice = false;

  /// IP address of the development server for physical devices
  /// Change this to your actual server IP address
  static const String compIpAddress = "192.168.101.13";

  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api';  
    }
    // if android
    if (kIsWeb) {
      return 'http://localhost:5050/api';       
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api';        
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api';       
    } else {
      return 'http://localhost:5050/api';       
    }
  }

  // static const String baseUrl = 'http://10.0.2.2:5050/api';
  // //static const String baseUrl = "http://localhost:5050";
  
  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Auth endpoints
  static const String getCurrentUser = "/auth/current";
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = "/auth/logout";
  static String userById(String id) => '/auth/$id';

  // Profile endpoints
  static const String updateProfile = '/auth/update-profile';
  static const String getProfile = '/auth/profile';

  // Password reset endpoints
  static const String requestPasswordReset = '/auth/request-password-reset';
  static String resetPassword(String token) => '/auth/reset-password/$token';

  // Accommodation endpoints
  static const String getAccommodations = '/accommodations';
  static String getAccommodationById(String id) => '/accommodations/$id';
  static const String searchAccommodations = '/accommodations/search';
  static const String getAccommodationsByPriceRange = '/accommodations/price-range';

  // Booking endpoints
    static const String getBookings = '/bookings/my-bookings';
  static String getBookingById(String id) => '/bookings/$id';
  static const String createBooking = '/bookings';
  static String cancelBooking(String id) => '/bookings/$id';
}