import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();
  static const bool isPhysicalDevice = false;

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
}