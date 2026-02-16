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
  });
}
