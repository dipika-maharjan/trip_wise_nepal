import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/screens/login_screen.dart';
import 'package:trip_wise_nepal/widgets/my_button.dart';

class ThirdOnboardingScreen extends StatefulWidget {
  const ThirdOnboardingScreen({super.key});

  @override
  State<ThirdOnboardingScreen> createState() => _ThirdOnboardingScreenState();
}

class _ThirdOnboardingScreenState extends State<ThirdOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              const Text(
                "Plan, Book, and Review",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Your journey is simplified. "
                    "Find, book, and share your accommodation details, all in one place.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w300
                ),
              ),

              const SizedBox(height: 40),
              Image.asset(
                'assets/images/third_onboarding.png',
              ),

              const SizedBox(height: 40),
              const Text(
                "Explore Nepal, TripWise!",
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                ),
              ),


              const SizedBox(height: 40),
              MyButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  text: "Next"),

            ],
          ),
        ),
      ),
    );
  }
}
