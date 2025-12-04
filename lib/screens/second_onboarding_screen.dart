import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/screens/third_onboarding_screen.dart';
import 'package:trip_wise_nepal/widgets/my_button.dart';

class SecondOnboardingScreen extends StatefulWidget {
  const SecondOnboardingScreen({super.key});

  @override
  State<SecondOnboardingScreen> createState() => _SecondOnboardingScreenState();
}

class _SecondOnboardingScreenState extends State<SecondOnboardingScreen> {
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
                "Travel With Confidence",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "See honest reviews from a global community so you always know you’re booking the right place.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w300
                ),
              ),

              const SizedBox(height: 40),
              Image.asset(
                'assets/images/second_onboarding.png',
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
                          builder: (context) => const ThirdOnboardingScreen()),
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
