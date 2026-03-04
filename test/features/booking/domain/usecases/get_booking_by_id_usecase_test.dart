import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/entities/booking_entity.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/get_booking_by_id_usecase.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late GetBookingByIdUseCase usecase;
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
    usecase = GetBookingByIdUseCase(mockRepository);
  });

  const tId = '1';

  final tBooking = BookingEntity(
    id: tId,
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

  test('should return booking when repository returns entity', () async {
    // Arrange
    when(() => mockRepository.getBookingById(tId))
        .thenAnswer((_) async => tBooking);

    // Act
    final result = await usecase(tId);

    // Assert
    expect(result, tBooking);
    verify(() => mockRepository.getBookingById(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}