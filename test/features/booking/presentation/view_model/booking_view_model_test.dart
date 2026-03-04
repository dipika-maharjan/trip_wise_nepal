import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';

void main() {
  test('bookingViewModelProvider has initial state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(bookingViewModelProvider);

    expect(state.status, BookingStatus.initial);
    expect(state.bookings, isEmpty);
    expect(state.selectedBooking, isNull);
    expect(state.errorMessage, isNull);
  });
}