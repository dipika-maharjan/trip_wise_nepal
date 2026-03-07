import 'package:dio/dio.dart';
import 'package:trip_wise_nepal/core/services/hive/hive_service.dart';
import 'package:trip_wise_nepal/features/booking/data/datasources/booking_datasource.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';

class BookingRepository {
  final IBookingDataSource _datasource;
  final HiveService _hiveService;

  BookingRepository({required IBookingDataSource datasource})
      : _datasource = datasource,
        _hiveService = HiveService.instance;

  Future<List<BookingEntity>> getBookings() async {
    try {
      final apiModels = await _datasource.getBookings();
      final entities = apiModels?.map((booking) {
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
          specialRequest: booking.specialRequest,
          paymentStatus: booking.paymentStatus,
          expiresAt: null,
        );
      }).toList() ?? [];

      // Cache latest bookings for offline use (store as simple JSON maps)
      await _hiveService.cacheBookings(entities.map((e) {
        return {
          'id': e.id,
          'accommodationId': e.accommodationId,
          'accommodationName': e.accommodationName,
          'accommodationImage': e.accommodationImage,
          'roomTypeId': e.roomTypeId,
          'roomTypeName': e.roomTypeName,
          'checkIn': e.checkIn.toIso8601String(),
          'checkOut': e.checkOut.toIso8601String(),
          'guests': e.guests,
          'roomsBooked': e.roomsBooked,
          'totalPrice': e.totalPrice,
          'status': e.status,
          'specialRequest': e.specialRequest,
          'paymentStatus': e.paymentStatus,
        };
      }).toList());

      return entities;
    } on DioException catch (_) {
      // On network-related errors, try to load cached bookings
      final cached = _hiveService.getCachedBookings();
      if (cached.isNotEmpty) {
        return cached.map((m) {
          return BookingEntity(
            id: (m['id'] as String?) ?? '',
            accommodationId: (m['accommodationId'] as String?) ?? '',
            accommodationName: m['accommodationName'] as String? ?? '',
            accommodationImage: m['accommodationImage'] as String? ?? '',
            roomTypeId: (m['roomTypeId'] as String?) ?? '',
            roomTypeName: m['roomTypeName'] as String? ?? '',
            checkIn: DateTime.parse(m['checkIn'] as String),
            checkOut: DateTime.parse(m['checkOut'] as String),
            guests: (m['guests'] as int?) ?? 1,
            roomsBooked: (m['roomsBooked'] as int?) ?? 1,
            totalPrice: (m['totalPrice'] as num?)?.toDouble() ?? 0.0,
            status: m['status'] as String? ?? '',
            extras: const [],
            specialRequest: m['specialRequest'] as String?,
            paymentStatus: m['paymentStatus'] as String?,
            expiresAt: null,
          );
        }).toList();
      }

      rethrow;
    }
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
      specialRequest: m.specialRequest,
      paymentStatus: m.paymentStatus,
      expiresAt: null,
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
      specialRequest: m.specialRequest,
      paymentStatus: m.paymentStatus,
      expiresAt: null,
    );
  }

  Future<void> cancelBooking(String id) async {
    await _datasource.cancelBooking(id);
  }
}
