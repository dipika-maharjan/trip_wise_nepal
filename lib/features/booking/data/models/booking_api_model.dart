
class BookingApiModel {
  final String id;
  final String accommodationId;
  final String accommodationName;
  final String accommodationImage;
  final String roomTypeId;
  final String roomTypeName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int roomsBooked;
  final double totalPrice;
  final String status;

  BookingApiModel({
    required this.id,
    required this.accommodationId,
    required this.accommodationName,
    required this.accommodationImage,
    required this.roomTypeId,
    required this.roomTypeName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.roomsBooked,
    required this.totalPrice,
    required this.status,
  });

  factory BookingApiModel.fromJson(Map<String, dynamic> json) {
    final acc = json['accommodationId'] is Map<String, dynamic> ? json['accommodationId'] : null;
    final room = json['roomTypeId'] is Map<String, dynamic> ? json['roomTypeId'] : null;
    // Fix image URL if relative
    String? rawImage;
    if (acc != null && acc['images'] != null && acc['images'] is List && acc['images'].isNotEmpty) {
      rawImage = acc['images'][0];
    }
    String imageUrl = '';
    if (rawImage != null && rawImage.isNotEmpty) {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        imageUrl = rawImage;
      } else {
        imageUrl = 'http://10.0.2.2:5050$rawImage';
      }
    }
    return BookingApiModel(
      id: json['_id'] ?? '',
      accommodationId: acc != null ? acc['_id'] ?? '' : (json['accommodationId'] ?? ''),
      accommodationName: acc != null ? acc['name'] ?? '' : '',
      accommodationImage: imageUrl,
      roomTypeId: room != null ? room['_id'] ?? '' : (json['roomTypeId'] ?? ''),
      roomTypeName: room != null ? room['name'] ?? '' : '',
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      guests: json['guests'] ?? 1,
      roomsBooked: json['roomsBooked'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['bookingStatus'] ?? json['status'] ?? '',
    );
  }
}
