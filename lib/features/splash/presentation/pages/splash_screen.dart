import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trip_wise_nepal/app/routes/app_routes.dart';
import 'package:trip_wise_nepal/core/services/storage/user_session_service.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen_layout.dart';
import 'package:trip_wise_nepal/features/onboarding/presentation/pages/first_onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // Check if user is already logged in
    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      // Navigate to Dashboard if user is logged in
      AppRoutes.pushAndRemoveUntil(context, const BottomScreenLayout());
    } else {
      // Navigate to Onboarding if user is not logged in
      AppRoutes.pushAndRemoveUntil(
        context,
        FirstOnboardingScreen(
          onNext: () {
            
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF0C7272),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TripWiseNepal",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  width: 120,
                ),
                
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                        "Find Your Dream Destination With Us!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
