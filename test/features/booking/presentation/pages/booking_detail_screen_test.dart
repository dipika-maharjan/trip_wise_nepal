import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/booking/data/models/booking_api_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_detail_screen.dart';
import 'package:trip_wise_nepal/features/booking/presentation/state/booking_state.dart';
import 'package:trip_wise_nepal/features/booking/presentation/view_model/booking_view_model.dart';

class _FakeBookingViewModel extends BookingViewModel {
  final BookingState _fakeState;

  _FakeBookingViewModel(this._fakeState);

  @override
  BookingState build() => _fakeState;

  @override
  Future<void> getBookings() async {}

  @override
  Future<void> getBookingById(String id) async {}

  @override
  Future<void> createBooking(Map<String, dynamic> bookingData) async {}

  @override
  Future<void> cancelBooking(String id) async {}
}

Future<void> _pumpDetailScreen(
  WidgetTester tester,
  BookingState state,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bookingViewModelProvider.overrideWith(
          () => _FakeBookingViewModel(state),
        ),
      ],
      child: const MaterialApp(
        home: BookingDetailScreen(bookingId: '1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

BookingEntity _createBooking({String paymentStatus = 'pending'}) {
  return BookingEntity(
    id: '1',
    transactionUuid: 'tx123',
    accommodationId: 'acc1',
    accommodationName: 'Test Hotel',
    accommodationImage: '',
    roomTypeId: 'room1',
    roomTypeName: 'Deluxe',
    checkIn: DateTime(2024, 1, 1),
    checkOut: DateTime(2024, 1, 2),
    guests: 2,
    roomsBooked: 1,
    totalPrice: 1130,
    status: 'pending',
    extras: const <BookingExtra>[],
    specialRequest: null,
    paymentStatus: paymentStatus,
    expiresAt: null,
  );
}

void main() {
  testWidgets('shows error message when booking not found', (tester) async {
    await _pumpDetailScreen(
      tester,
      const BookingState(
        status: BookingStatus.error,
        selectedBooking: null,
        errorMessage: 'Not found',
      ),
    );

    expect(find.text('Not found'), findsOneWidget);
  });

  testWidgets('shows Pay with eSewa button for pending booking', (tester) async {
    final booking = _createBooking(paymentStatus: 'pending');
    await _pumpDetailScreen(
      tester,
      BookingState(
        status: BookingStatus.loaded,
        selectedBooking: booking,
      ),
    );

    expect(find.text('Pay with eSewa'), findsOneWidget);
  });

  testWidgets('hides Pay with eSewa button for paid booking', (tester) async {
    final booking = _createBooking(paymentStatus: 'paid');
    await _pumpDetailScreen(
      tester,
      BookingState(
        status: BookingStatus.loaded,
        selectedBooking: booking,
      ),
    );

    expect(find.text('Pay with eSewa'), findsNothing);
  });
}