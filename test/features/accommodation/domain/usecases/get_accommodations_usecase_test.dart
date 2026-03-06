import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/repositories/accommodation_repository.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/get_accommodations_usecase.dart';

class MockAccommodationRepository extends Mock implements IAccommodationRepository {}

void main() {
  late GetAccommodationsUseCase usecase;
  late MockAccommodationRepository mockRepository;

  setUp(() {
    mockRepository = MockAccommodationRepository();
    usecase = GetAccommodationsUseCase(repository: mockRepository);
  });

  const tPage = 1;
  const tLimit = 12;

  const tAccommodation = AccommodationEntity(
    id: '1',
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

  group('GetAccommodationsUseCase', () {
    test('should return list of accommodations when fetch is successful', () async {
      // Arrange
      when(
        () => mockRepository.getAccommodations(
          page: tPage,
          limit: tLimit,
        ),
      ).thenAnswer((_) async => const Right([tAccommodation]));

      // Act
      final result = await usecase(
        const GetAccommodationsParams(page: tPage, limit: tLimit),
      );

      // Assert
      expect(result, const Right([tAccommodation]));
      verify(
        () => mockRepository.getAccommodations(
          page: tPage,
          limit: tLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when fetch fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Server error');
      when(
        () => mockRepository.getAccommodations(
          page: tPage,
          limit: tLimit,
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(
        const GetAccommodationsParams(page: tPage, limit: tLimit),
      );

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockRepository.getAccommodations(
          page: tPage,
          limit: tLimit,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass correct params to repository', () async {
      // Arrange
      when(
        () => mockRepository.getAccommodations(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([tAccommodation]));

      // Act
      await usecase(
        const GetAccommodationsParams(page: tPage, limit: tLimit),
      );

      // Assert
      verify(
        () => mockRepository.getAccommodations(
          page: tPage,
          limit: tLimit,
        ),
      ).called(1);
    });
  });

  group('GetAccommodationsParams', () {
    test('should have correct props', () {
      const params = GetAccommodationsParams(page: tPage, limit: tLimit);
      expect(params.props, [tPage, tLimit]);
    });

    test('two params with same values should be equal', () {
      const params1 = GetAccommodationsParams(page: tPage, limit: tLimit);
      const params2 = GetAccommodationsParams(page: tPage, limit: tLimit);
      expect(params1, params2);
    });

    test('two params with different values should not be equal', () {
      const params1 = GetAccommodationsParams(page: tPage, limit: tLimit);
      const params2 = GetAccommodationsParams(page: 2, limit: tLimit);
      expect(params1, isNot(params2));
    });
  });
}