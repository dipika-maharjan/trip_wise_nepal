import 'package:trip_wise_nepal/core/api/api_endpoints.dart';

class ImageUrlHelper {
  // Derive the image host from the same base used by the API.
  // If ApiEndpoints.baseUrl is "http://host:5050/api", strip the trailing "/api".
  static String get baseUrl {
    final apiBase = ApiEndpoints.baseUrl;
    if (apiBase.endsWith('/api')) {
      return apiBase.substring(0, apiBase.length - 4);
    }
    return apiBase;
  }

  static String buildImageUrl(String imagePath) {
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Construct full URL - backend returns paths like "/uploads/images-xxx.jpg"
    return baseUrl + imagePath;
  }
}
