import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/accommodation/data/models/optional_extra_api_model.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/room_type_entity.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/presentation/pages/booking_form_screen.dart';

const RoomTypeEntity _testRoomType = RoomTypeEntity(
  id: 'room1',
  name: 'Deluxe',
  description: 'Nice room',
  pricePerNight: 1000,
  isActive: true,
  maxGuests: 2,
  totalRooms: 5,
);

final List<OptionalExtraApiModel> _testExtras = [
  OptionalExtraApiModel(
    id: 'extra1',
    accommodationId: 'acc1',
    name: 'Breakfast',
    description: 'Daily breakfast',
    price: 200,
    priceType: 'per_person',
    isActive: true,
  ),
];

BookingEntity _createBooking({String paymentStatus = 'pending'}) {
  return BookingEntity(
    id: 'b1',
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
    extras: const [],
    specialRequest: null,
    paymentStatus: paymentStatus,
    expiresAt: null,
  );
}

Widget _buildFormScreen({bool isEdit = false, BookingEntity? booking}) {
  return MaterialApp(
    home: BookingFormScreen(
      accommodationId: 'acc1',
      accommodationName: 'Test Hotel',
      accommodationImage: '',
      accommodationLocation: 'Test City',
      roomTypes: const [_testRoomType],
      optionalExtras: _testExtras,
      token: 'dummy',
      isEdit: isEdit,
      booking: booking,
    ),
  );
}

void main() {
  testWidgets('shows main fields and buttons for new booking', (tester) async {
    await tester.pumpWidget(_buildFormScreen());
    await tester.pumpAndSettle();

    expect(find.text('Complete Your Booking'), findsOneWidget);
    expect(find.text('Select Room Type *'), findsOneWidget);
    expect(find.text('Check-in Date *'), findsOneWidget);
    expect(find.text('Check-out Date *'), findsOneWidget);

    // Scroll until payment buttons are visible
    await tester.scrollUntilVisible(
      find.text('Confirm Booking and Pay with eSewa'),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.text('Confirm Booking and Pay with eSewa'), findsOneWidget);
    expect(find.text('Confirm Booking and Pay Later'), findsOneWidget);
  });

  testWidgets('shows Update Booking button when editing unpaid booking', (tester) async {
    final booking = _createBooking(paymentStatus: 'pending');
    await tester.pumpWidget(_buildFormScreen(isEdit: true, booking: booking));
    await tester.pumpAndSettle();

    expect(find.text('Edit Booking'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Update Booking'),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.text('Update Booking'), findsOneWidget);
    expect(find.text('Confirm Booking and Pay with eSewa'), findsNothing);
  });

  testWidgets('locks form when editing a paid booking', (tester) async {
    final booking = _createBooking(paymentStatus: 'paid');
    await tester.pumpWidget(_buildFormScreen(isEdit: true, booking: booking));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('This booking has already been paid and can no longer be updated.'),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.text('This booking has already been paid and can no longer be updated.'), findsOneWidget);
    expect(find.text('Update Booking'), findsNothing);
    expect(find.text('Confirm Booking and Pay with eSewa'), findsNothing);
  });
}