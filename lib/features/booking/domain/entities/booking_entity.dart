import 'package:trip_wise_nepal/features/booking/data/models/booking_api_model.dart';
class BookingEntity {
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
  final String? specialRequest;

  BookingEntity({
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
    this.specialRequest,
  });
}
