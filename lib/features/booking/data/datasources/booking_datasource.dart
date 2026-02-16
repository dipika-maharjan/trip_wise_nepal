import '../models/booking_api_model.dart';

abstract class IBookingDataSource {
  Future<List<BookingApiModel>?> getBookings();
  Future<BookingApiModel?> getBookingById(String id);
  Future<BookingApiModel?> createBooking(Map<String, dynamic> bookingData);
  Future<void> cancelBooking(String id);
}
