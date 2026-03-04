import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/accommodation/domain/entities/accommodation_entity.dart';
import 'package:trip_wise_nepal/features/accommodation/presentation/pages/accommodations_list_screen.dart';
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

Future<void> _pumpListScreen(
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
        home: AccommodationsListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows title and search field', (tester) async {
    await _pumpListScreen(tester, const AccommodationState());

    expect(find.text('Accommodations'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Search accommodations...'), findsOneWidget);
  });

  testWidgets('shows empty state when no accommodations', (tester) async {
    await _pumpListScreen(tester, const AccommodationState());

    expect(find.text('No accommodations found'), findsOneWidget);
  });

  testWidgets('shows accommodation card when data is present', (tester) async {
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
      accommodations: [accommodation],
    );

    await _pumpListScreen(tester, state);

    expect(find.text('Test Hotel'), findsOneWidget);
    expect(find.text('Test Address'), findsOneWidget);
  });
}