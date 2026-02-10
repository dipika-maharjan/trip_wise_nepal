import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/app/theme/theme_data.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:app_links/app_links.dart';

import 'features/splash/presentation/pages/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _deepLinkSubscription;
  final navigatorKey = GlobalKey<NavigatorState>();
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
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

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: getApplicationTheme(),
      title: 'TripWise Nepal',
      home: const SplashScreen(),
    );
  }
}