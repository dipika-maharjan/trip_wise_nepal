class ImageUrlHelper {
  static const String baseUrl = 'http://10.0.2.2:5050';

  static String buildImageUrl(String imagePath) {
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Construct full URL - backend returns paths like "/uploads/images-xxx.jpg"
    return baseUrl + imagePath;
  }
}
