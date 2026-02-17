import 'package:trip_wise_nepal/features/booking/data/datasources/booking_datasource.dart';
import 'package:trip_wise_nepal/features/booking/data/models/booking_api_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';

class BookingRepository {
  final IBookingDataSource _datasource;

  BookingRepository({required IBookingDataSource datasource}) : _datasource = datasource;

  Future<List<BookingEntity>> getBookings() async {
    final apiModels = await _datasource.getBookings();
    return apiModels?.map((m) {
      final booking = m as BookingApiModel;
      return BookingEntity(
        id: booking.id,
        accommodationId: booking.accommodationId,
        accommodationName: booking.accommodationName,
        accommodationImage: booking.accommodationImage,
        roomTypeId: booking.roomTypeId,
        roomTypeName: booking.roomTypeName,
        checkIn: booking.checkIn,
        checkOut: booking.checkOut,
        guests: booking.guests,
        roomsBooked: booking.roomsBooked,
        totalPrice: booking.totalPrice,
        status: booking.status,
        extras: booking.extras,
      );
    }).toList() ?? [];
  }

  Future<BookingEntity?> getBookingById(String id) async {
    final m = await _datasource.getBookingById(id);
    if (m == null) return null;
    return BookingEntity(
      id: m.id,
      accommodationId: m.accommodationId,
      accommodationName: m.accommodationName,
      accommodationImage: m.accommodationImage,
      roomTypeId: m.roomTypeId,
      roomTypeName: m.roomTypeName,
      checkIn: m.checkIn,
      checkOut: m.checkOut,
      guests: m.guests,
      roomsBooked: m.roomsBooked,
      totalPrice: m.totalPrice,
      status: m.status,
      extras: m.extras,
    );
  }

  Future<BookingEntity?> createBooking(Map<String, dynamic> bookingData) async {
    final m = await _datasource.createBooking(bookingData);
    if (m == null) return null;
    return BookingEntity(
      id: m.id,
      accommodationId: m.accommodationId,
      accommodationName: m.accommodationName,
      accommodationImage: m.accommodationImage,
      roomTypeId: m.roomTypeId,
      roomTypeName: m.roomTypeName,
      checkIn: m.checkIn,
      checkOut: m.checkOut,
      guests: m.guests,
      roomsBooked: m.roomsBooked,
      totalPrice: m.totalPrice,
      status: m.status,
      extras: m.extras,
    );
  }

  Future<void> cancelBooking(String id) async {
    await _datasource.cancelBooking(id);
  }
}
