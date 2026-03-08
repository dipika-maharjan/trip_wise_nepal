import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:trip_wise_nepal/app/theme/theme_data.dart';
import 'package:trip_wise_nepal/app/theme/theme_provider.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:trip_wise_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:trip_wise_nepal/features/splash/presentation/pages/splash_screen.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<Uri?>? _deepLinkSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  final navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();
  DateTime? _lastShakeTime;
  DateTime? _lastTiltBackTime;
  double? _lastTiltHorizontal;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _initShakeDetection();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }

    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    try {
      final token = uri.queryParameters['token'];

      final isResetPath = uri.host == 'reset-password' ||
          uri.path == '/reset-password' ||
          uri.path.startsWith('/reset-password');

      if (isResetPath && token != null && token.isNotEmpty) {
        // Delay to ensure navigator is ready.
        Future.delayed(const Duration(milliseconds: 300), () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => ResetPasswordScreen(token: token),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error handling deep link: $e');
    }
  }

  void _initShakeDetection() {
    try {
      _accelerometerSubscription = accelerometerEvents.listen((event) {
        final double force =
            event.x.abs() + event.y.abs() + event.z.abs();

        // Basic shake threshold; adjust if too sensitive/not sensitive enough.
        if (force > 30) {
          final now = DateTime.now();
          if (_lastShakeTime == null ||
              now.difference(_lastShakeTime!) > const Duration(seconds: 3)) {
            _lastShakeTime = now;
            _handleShakeLogout();
          }
        }

        // Tilt-based "go back" gesture using accelerometer.
        // Work in both portrait and landscape by using the axis
        // that has the larger absolute value (more horizontal).
        // Require both a strong tilt AND a quick change so that
        // simply holding the device still does not trigger it.
        const tiltThreshold = 9.0; // how strong the horizontal tilt must be
        const minDelta = 3.0; // how much it must change since last reading

        // Ignore very strong movements that are likely pure shakes.
        if (force < 35) {
          final double currentHorizontal =
              event.x.abs() > event.y.abs() ? event.x : event.y;

          final double previousHorizontal = _lastTiltHorizontal ?? currentHorizontal;
          _lastTiltHorizontal = currentHorizontal;

          final double delta = (currentHorizontal - previousHorizontal).abs();

          final bool passesThreshold =
              currentHorizontal > tiltThreshold || currentHorizontal < -tiltThreshold;
          final bool changedQuickly = delta > minDelta;

          if (passesThreshold && changedQuickly) {
            final now = DateTime.now();
            if (_lastTiltBackTime == null ||
                now.difference(_lastTiltBackTime!) > const Duration(seconds: 2)) {
              _lastTiltBackTime = now;
              debugPrint(
                  'Tilt back detected with horizontal=$currentHorizontal, delta=$delta, force=$force');
              final context = navigatorKey.currentContext;
              if (context != null && Navigator.canPop(context)) {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tilt detected → Going back'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                } catch (_) {
                  // If there is no ScaffoldMessenger, just ignore; back nav still happens.
                }
                navigatorKey.currentState?.maybePop();
              } else {
                debugPrint('Tilt detected but cannot pop (at root screen).');
              }
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Shake detection error: $e');
    }
  }

  Future<void> _handleShakeLogout() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Shake detected. Do you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLogout) return;

    await ref.read(authViewModelProvider.notifier).logout();

    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: getApplicationTheme(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,
      title: 'TripWise Nepal',
      home: const SplashScreen(),
    );
  }
}