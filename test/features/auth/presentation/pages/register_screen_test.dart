import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_wise_nepal/core/providers/shared_preferences_provider.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/register_screen.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createTestWidget() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MaterialApp(
        home: RegisterScreen(),
      ),
    );
  }

  testWidgets('Register screen renders all fields and button', (tester) async {
    final widget = await createTestWidget();
    await tester.pumpWidget(widget);

    // Check for name, email, password, confirm password fields
    expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email Address'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);

    // Check for register button
    expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);
  });
}