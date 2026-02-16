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
      return (response.data['data'] as List)
          .map((json) => BookingApiModel.fromJson(json))
          .toList();
    }
    return null;
  }

  @override
  Future<BookingApiModel?> getBookingById(String id) async {
    final response = await _apiClient.get(ApiEndpoints.getBookingById(id));
    if (response.statusCode == 200 && response.data['data'] != null) {
      return BookingApiModel.fromJson(response.data['data']);
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
