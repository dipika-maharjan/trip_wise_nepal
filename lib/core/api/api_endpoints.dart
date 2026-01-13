class ApiEndpoints {
  ApiEndpoints._();


  static const String baseUrl = 'http://10.0.2.2:5050/api';
  //static const String baseUrl = "http://localhost:5050";
  
  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Auth endpoints
  static const String getCurrentUser = "/auth/current";
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = "/auth/logout";
  static String userById(String id) => '/auth/$id';

}