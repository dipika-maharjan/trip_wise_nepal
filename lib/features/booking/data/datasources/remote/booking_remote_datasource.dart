import 'package:trip_wise_nepal/features/booking/data/datasources/booking_datasource.dart';
import 'package:trip_wise_nepal/features/booking/data/models/booking_api_model.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/core/api/api_endpoints.dart';

class BookingRemoteDataSource implements IBookingDataSource {
  final ApiClient _apiClient;

  BookingRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<BookingApiModel>?> getBookings() async {
    final response = await _apiClient.get(ApiEndpoints.getBookings);
    if (response.statusCode == 200 && response.data['data'] != null) {
      // Each item is expected to be { booking: {...}, extras: [...] }
      return (response.data['data'] as List)
          .map((item) {
            final bookingJson = item['booking'] ?? item;
            if (item['extras'] != null) {
              bookingJson['extras'] = item['extras'];
            }
            return BookingApiModel.fromJson(bookingJson);
          })
          .toList();
    }
    return null;
  }

  @override
  Future<BookingApiModel?> getBookingById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.getBookingById(id));
    if (response.statusCode == 200 && response.data['data'] != null) {
      final data = response.data['data'];
      final bookingJson = data['booking'] ?? data;
      if (data['extras'] != null) {
        bookingJson['extras'] = data['extras'];
      }
      return BookingApiModel.fromJson(bookingJson);
    }
    return null;
  }

  @override
  Future<BookingApiModel?> createBooking(Map<String, dynamic> bookingData) async {
    final response = await _apiClient.post(ApiEndpoints.createBooking, data: bookingData);
    if ((response.statusCode == 201 || response.statusCode == 200) && response.data['data'] != null) {
      return BookingApiModel.fromJson(response.data['data']);
    }
    return null;
  }

  @override
  Future<void> cancelBooking(String id) async {
    await _apiClient.delete(ApiEndpoints.cancelBooking(id));
  }
}
