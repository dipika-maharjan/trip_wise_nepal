import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_wise_nepal/features/profile/presentation/pages/settings_screen.dart';

Future<void> _pumpSettingsScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        home: SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows settings options', (tester) async {
    await _pumpSettingsScreen(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Light/Dark Mode'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('toggles theme switch', (tester) async {
    await _pumpSettingsScreen(tester);

    // Initially should be off (light mode)
    var themeSwitch = tester.widget<Switch>(find.byType(Switch));
    expect(themeSwitch.value, isFalse);

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    themeSwitch = tester.widget<Switch>(find.byType(Switch));
    expect(themeSwitch.value, isTrue);
  });
}