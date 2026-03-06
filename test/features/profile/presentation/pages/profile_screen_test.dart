import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trip_wise_nepal/core/providers/shared_preferences_provider.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/profile/presentation/pages/profile_screen.dart';

Future<Widget> _createProfileTestWidget() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  final userSession = UserSessionService(prefs: prefs);
  await userSession.saveUserSession(
    userId: 'u1',
    email: 'test@example.com',
    fullName: 'Test User',
    username: 'testuser',
    profilePicture: null,
  );

  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      userSessionServiceProvider.overrideWithValue(userSession),
    ],
    child: const MaterialApp(
      home: ProfileScreen(),
    ),
  );
}

void main() {
  testWidgets('shows user name, email and menu options', (tester) async {
    final widget = await _createProfileTestWidget();
    await tester.pumpWidget(widget);
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}