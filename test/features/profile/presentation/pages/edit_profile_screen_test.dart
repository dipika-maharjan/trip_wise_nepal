import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/profile/presentation/pages/edit_profile_screen.dart';

void main() {
  testWidgets('shows initial name and email fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EditProfileScreen(
            initialName: 'Test User',
            initialEmail: 'test@example.com',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);

    // Verify initial values are in the TextFields
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
  });
}