import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/features/booking/data/repositories/booking_repository.dart';
import 'package:trip_wise_nepal/features/booking/domain/usecases/cancel_booking_usecase.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late CancelBookingUseCase usecase;
  late MockBookingRepository mockRepository;

  setUp(() {
    mockRepository = MockBookingRepository();
    usecase = CancelBookingUseCase(mockRepository);
  });

  const tId = '1';

  test('should call cancelBooking on repository with correct id', () async {
    // Arrange
    when(() => mockRepository.cancelBooking(tId)).thenAnswer((_) async {});

    // Act
    await usecase(tId);

    // Assert
    verify(() => mockRepository.cancelBooking(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}