import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/screens/second_onboarding_screen.dart';
import 'package:trip_wise_nepal/widgets/my_button.dart';

class FirstOnboardingScreen extends StatefulWidget {
  final VoidCallback onNext;
  const FirstOnboardingScreen({
    super.key,
    required this.onNext
  });

  @override
  State<FirstOnboardingScreen> createState() => _FirstOnboardingScreenState();
}

class _FirstOnboardingScreenState extends State<FirstOnboardingScreen> {
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
                "Discover Your Next Destination",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                "Access thousands of breathtaking destinations. "
                    "Swipe, search, and get inspired with curated collections across Nepal.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w300
                ),
              ),

              const SizedBox(height: 40),
              Image.asset(
                'assets/images/first_onboarding.png',
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
                          builder: (context) => const SecondOnboardingScreen()),
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
