import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/get_accommodation_by_id_usecase.dart';

class MockAccommodationRepository extends Mock implements IAccommodationRepository {}

void main() {
  late GetAccommodationByIdUseCase usecase;
  late MockAccommodationRepository mockRepository;

  setUp(() {
    mockRepository = MockAccommodationRepository();
    usecase = GetAccommodationByIdUseCase(repository: mockRepository);
  });

  const tId = '1';

  const tAccommodation = AccommodationEntity(
    id: tId,
    name: 'Test Hotel',
    address: 'Kathmandu',
    overview: 'Nice place',
    images: ['https://example.com/image.jpg'],
    amenities: ['WiFi'],
    ecoFriendlyHighlights: ['Solar'],
    pricePerNight: 1500,
    location: LocationEntity(lat: 27.7, lng: 85.3),
    rating: 4.5,
  );

  group('GetAccommodationByIdUseCase', () {
    test('should return accommodation when fetch is successful', () async {
      // Arrange
      when(() => mockRepository.getAccommodationById(tId))
          .thenAnswer((_) async => const Right(tAccommodation));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, const Right(tAccommodation));
      verify(() => mockRepository.getAccommodationById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when fetch fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Not found');
      when(() => mockRepository.getAccommodationById(tId))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tId);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getAccommodationById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct id to repository', () async {
      // Arrange
      when(() => mockRepository.getAccommodationById(any()))
          .thenAnswer((_) async => const Right(tAccommodation));

      // Act
      await usecase(tId);

      // Assert
      verify(() => mockRepository.getAccommodationById(tId)).called(1);
    });
  });
}