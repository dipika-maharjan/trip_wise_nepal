import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/profile_screen.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserSessionService mockUserSessionService;

  setUp(() {
    mockUserSessionService = MockUserSessionService();
    when(() => mockUserSessionService.getCurrentUserFullName()).thenReturn('Test User');
    when(() => mockUserSessionService.getCurrentUserEmail()).thenReturn('test@example.com');
    when(() => mockUserSessionService.getCurrentUserProfilePicture()).thenReturn('');
  });

  Future<void> pumpProfileScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('ProfileScreen displays user info and profile image section', (tester) async {
    await pumpProfileScreen(tester);

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
  });

  testWidgets('ProfileScreen shows menu buttons', (tester) async {
    await pumpProfileScreen(tester);

    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('My Trips'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Tapping camera icon shows image picker options', (tester) async {
    await pumpProfileScreen(tester);
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    expect(find.text('Choose Profile Picture'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
  });

  testWidgets('Tapping Logout shows confirmation dialog', (tester) async {
    await pumpProfileScreen(tester);

    // Scroll to make sure Logout is visible
    final logoutFinder = find.text('Logout').last;
    await tester.ensureVisible(logoutFinder);
    await tester.tap(logoutFinder);
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to logout?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Logout'), findsNWidgets(3)); // Menu, dialog title, and dialog button
  });
}