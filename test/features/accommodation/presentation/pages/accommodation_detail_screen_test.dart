import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/pages/accommodation_detail_screen.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/state/accommodation_state.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/view_model/accommodation_view_model.dart';

class _FakeAccommodationViewModel extends AccommodationViewModel {
  final AccommodationState _fakeState;

  _FakeAccommodationViewModel(this._fakeState);

  @override
  AccommodationState build() => _fakeState;

  @override
  Future<void> getAccommodations({bool loadMore = false}) async {}

  @override
  Future<void> getAccommodationById(String id) async {}

  @override
  Future<void> searchAccommodations(String query, {bool loadMore = false}) async {}

  @override
  Future<void> filterByPriceRange({
    required double minPrice,
    required double maxPrice,
    bool loadMore = false,
  }) async {}

  @override
  void clearFilters() {}

  @override
  void clearError() {}
}

Future<void> _pumpDetailScreen(
  WidgetTester tester,
  AccommodationState state,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accommodationViewModelProvider.overrideWith(
          () => _FakeAccommodationViewModel(state),
        ),
      ],
      child: const MaterialApp(
        home: AccommodationDetailScreen(accommodationId: '1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows not found message when no accommodation is selected', (tester) async {
    const state = AccommodationState();

    await _pumpDetailScreen(tester, state);

    expect(
      find.text('Accommodation not found. Please check your network or try again later.'),
      findsOneWidget,
    );
  });

  testWidgets('shows location missing message when accommodation has no location', (tester) async {
    const accommodation = AccommodationEntity(
      id: '1',
      name: 'Test Hotel',
      address: 'Test Address',
      overview: 'Nice place',
      images: [],
      amenities: [],
      ecoFriendlyHighlights: [],
      pricePerNight: 1000,
    );

    const state = AccommodationState(
      status: AccommodationStatus.loaded,
      selectedAccommodation: accommodation,
    );

    await _pumpDetailScreen(tester, state);

    expect(
      find.text('Location data is missing for this accommodation.'),
      findsOneWidget,
    );
  });
}