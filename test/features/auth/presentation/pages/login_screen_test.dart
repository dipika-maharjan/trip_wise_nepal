import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_wise_nepal/core/providers/shared_preferences_provider.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/login_screen.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createTestWidget() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen UI Elements', () {
    testWidgets('should display login form fields and button', (tester) async {
      final widget = await createTestWidget();
      await tester.pumpWidget(widget);

      // Check for email and password fields
      expect(
        find.widgetWithText(TextFormField, 'Email Address'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);

      // Check for login button
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('should show snackbar when fields are empty', (tester) async {
      final widget = await createTestWidget();
      await tester.pumpWidget(widget);

      // Tap the login button without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // pump to show snackbar

      // Should show snackbar with 'Please fill all fields'
      expect(find.text('Please fill all fields'), findsOneWidget);
    });
  });
}
