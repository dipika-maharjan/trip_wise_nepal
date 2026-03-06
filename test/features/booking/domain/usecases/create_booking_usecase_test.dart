import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/create_booking_usecase.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late CreateBookingUseCase usecase;
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
    usecase = CreateBookingUseCase(mockRepository);
  });

  final tBookingData = {
    'accommodationId': 'acc1',
    'roomTypeId': 'room1',
  };

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

  test('should create booking via repository and return entity', () async {
    // Arrange
    when(() => mockRepository.createBooking(tBookingData))
        .thenAnswer((_) async => tBooking);

    // Act
    final result = await usecase(tBookingData);

    // Assert
    expect(result, tBooking);
    verify(() => mockRepository.createBooking(tBookingData)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}