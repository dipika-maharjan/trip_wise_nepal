

class BookingExtra {
  final String id;
  final String name;
  final int quantity;
  final double total;
  BookingExtra({required this.id, required this.name, required this.quantity, required this.total});
  factory BookingExtra.fromJson(Map<String, dynamic> json) {
    final idRaw = json['extraId'];
    final nameRaw = json['name'];
    return BookingExtra(
      id: idRaw == null ? '' : idRaw.toString(),
      name: nameRaw == null ? '' : nameRaw.toString(),
      quantity: json['quantity'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

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
  final List<BookingExtra> extras;

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
    required this.extras,
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
    // Defensive: ensure extras is a List<Map<String, dynamic>>
    List<BookingExtra> extrasList = [];
    if (json['extras'] is List) {
      for (final e in (json['extras'] as List)) {
        if (e is Map<String, dynamic>) {
          extrasList.add(BookingExtra.fromJson(e));
        } else if (e != null) {
          try {
            extrasList.add(BookingExtra.fromJson(Map<String, dynamic>.from(e)));
          } catch (_) {}
        }
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
      extras: extrasList,
    );
  }
}
