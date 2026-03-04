import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/get_bookings_usecase.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late GetBookingsUseCase usecase;
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
    usecase = GetBookingsUseCase(mockRepository);
  });

  final tBooking = BookingEntity(
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
    extras: const [],
    specialRequest: null,
    paymentStatus: 'unpaid',
    expiresAt: null,
  );

  test('should return list of bookings from repository', () async {
    // Arrange
    when(() => mockRepository.getBookings()).thenAnswer((_) async => [tBooking]);

    // Act
    final result = await usecase();

    // Assert
    expect(result, [tBooking]);
    verify(() => mockRepository.getBookings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}