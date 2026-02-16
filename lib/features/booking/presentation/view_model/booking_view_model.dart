import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/get_bookings_usecase.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/get_booking_by_id_usecase.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:trip_wise_nepal/core/api/api_client.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';

final bookingViewModelProvider = NotifierProvider<BookingViewModel, BookingState>(
  BookingViewModel.new,
);

class BookingViewModel extends Notifier<BookingState> {
  late final GetBookingsUseCase _getBookingsUseCase;
  late final GetBookingByIdUseCase _getBookingByIdUseCase;
  late final CreateBookingUseCase _createBookingUseCase;
  late final CancelBookingUseCase _cancelBookingUseCase;

  @override
  BookingState build() {
    // Initialize use cases with repository and remote datasource
    final apiClient = ApiClient();
    final remoteDataSource = BookingRemoteDataSource(apiClient: apiClient);
    final repository = BookingRepository(datasource: remoteDataSource);
    _getBookingsUseCase = GetBookingsUseCase(repository);
    _getBookingByIdUseCase = GetBookingByIdUseCase(repository);
    _createBookingUseCase = CreateBookingUseCase(repository);
    _cancelBookingUseCase = CancelBookingUseCase(repository);
    return const BookingState();
  }

  Future<void> getBookings() async {
    state = state.copyWith(status: BookingStatus.loading);
    try {
      final bookings = await _getBookingsUseCase();
      state = state.copyWith(status: BookingStatus.loaded, bookings: bookings);
    } catch (e) {
      state = state.copyWith(status: BookingStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> getBookingById(String id) async {
    state = state.copyWith(status: BookingStatus.loading);
    try {
      final booking = await _getBookingByIdUseCase(id);
      state = state.copyWith(status: BookingStatus.loaded, selectedBooking: booking);
    } catch (e) {
      state = state.copyWith(status: BookingStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> createBooking(Map<String, dynamic> bookingData) async {
    state = state.copyWith(status: BookingStatus.loading);
    try {
      await _createBookingUseCase(bookingData);
      await getBookings();
    } catch (e) {
      state = state.copyWith(status: BookingStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> cancelBooking(String id) async {
    state = state.copyWith(status: BookingStatus.loading);
    try {
      await _cancelBookingUseCase(id);
      await getBookings();
    } catch (e) {
      state = state.copyWith(status: BookingStatus.error, errorMessage: e.toString());
    }
  }
}
