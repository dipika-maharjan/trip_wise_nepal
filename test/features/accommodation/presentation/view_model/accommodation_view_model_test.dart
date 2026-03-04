import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/error/failures.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/usecases/get_accommodations_usecase.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/view_model/accommodation_view_model.dart';

class MockGetAccommodationsUseCase extends Mock
    implements GetAccommodationsUseCase {}

void main() {
  late ProviderContainer container;
  late MockGetAccommodationsUseCase mockGetAccommodationsUseCase;

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

  setUp(() {
    mockGetAccommodationsUseCase = MockGetAccommodationsUseCase();
    container = ProviderContainer(
      overrides: [
        getAccommodationsUsecaseProvider
            .overrideWithValue(mockGetAccommodationsUseCase),
      ],
    );
    addTearDown(container.dispose);
  });

  test('getAccommodations sets state to loaded on success', () async {
    when(
      () => mockGetAccommodationsUseCase(
        const GetAccommodationsParams(page: 1, limit: 12),
      ),
    ).thenAnswer((_) async => const Right([tAccommodation]));

    final viewModel =
        container.read(accommodationViewModelProvider.notifier);

    await viewModel.getAccommodations();

    final state = container.read(accommodationViewModelProvider);
    expect(state.status, AccommodationStatus.loaded);
    expect(state.accommodations, [tAccommodation]);
    expect(state.errorMessage, isNull);
  });

  test('getAccommodations sets state to error on failure', () async {
    const failure = ApiFailure(message: 'Server error');

    when(
      () => mockGetAccommodationsUseCase(
        const GetAccommodationsParams(page: 1, limit: 12),
      ),
    ).thenAnswer((_) async => const Left(failure));

    final viewModel =
        container.read(accommodationViewModelProvider.notifier);

    await viewModel.getAccommodations();

    final state = container.read(accommodationViewModelProvider);
    expect(state.status, AccommodationStatus.error);
    expect(state.errorMessage, failure.message);
  });
}