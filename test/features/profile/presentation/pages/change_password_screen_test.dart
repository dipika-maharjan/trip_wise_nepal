import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/profile/presentation/pages/settings_screen.dart';

void main() {
  testWidgets('shows change password UI elements', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChangePasswordScreenWithValidation(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Change Password'), findsOneWidget);
    expect(
      find.text(
        'Enter your current password. If it is correct, we will send a password reset link to your email.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Old Password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Send Reset Link'), findsOneWidget);
  });
}