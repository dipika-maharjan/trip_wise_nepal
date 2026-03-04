import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/booking/data/models/booking_api_model.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_list_screen.dart';
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

Future<void> _pumpListScreen(
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
        home: BookingListScreen(),
      ),
    ),
  );
  await tester.pump();
}

BookingEntity _createTestBooking({String paymentStatus = 'unpaid'}) {
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
    totalPrice: 1000,
    status: 'pending',
    extras: const <BookingExtra>[],
    specialRequest: null,
    paymentStatus: paymentStatus,
    expiresAt: null,
  );
}

void main() {
  testWidgets('shows empty state when no bookings', (tester) async {
    await _pumpListScreen(
      tester,
      const BookingState(status: BookingStatus.loaded, bookings: []),
    );

    expect(find.text('You have no bookings yet.'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Book Accommodation'),
      findsOneWidget,
    );
  });

  testWidgets('shows loading indicator when status is loading', (tester) async {
    await _pumpListScreen(
      tester,
      const BookingState(status: BookingStatus.loading),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message when status is error', (tester) async {
    await _pumpListScreen(
      tester,
      const BookingState(status: BookingStatus.error, errorMessage: 'Failed to load'),
    );

    expect(find.text('Failed to load'), findsOneWidget);
  });

  testWidgets('shows booking card when data is present', (tester) async {
    final booking = _createTestBooking();
    await _pumpListScreen(
      tester,
      BookingState(
        status: BookingStatus.loaded,
        bookings: [booking],
      ),
    );

    expect(find.text('Test Hotel'), findsOneWidget);
    expect(find.text('Deluxe'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'View Details'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Edit Booking'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
  });

  testWidgets('disables Edit Booking button when booking is paid', (tester) async {
    final booking = _createTestBooking(paymentStatus: 'paid');
    await _pumpListScreen(
      tester,
      BookingState(
        status: BookingStatus.loaded,
        bookings: [booking],
      ),
    );

    final editButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Edit Booking'),
    );
    expect(editButton.onPressed, isNull);
  });
}