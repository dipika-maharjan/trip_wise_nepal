import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/screens/login_screen.dart';
import 'package:trip_wise_nepal/screens/second_onboarding_screen.dart';
import 'package:trip_wise_nepal/widgets/my_button.dart';

class FirstOnboardingScreen extends StatefulWidget {
  final VoidCallback onNext;
  const FirstOnboardingScreen({super.key, required this.onNext});

  @override
  State<FirstOnboardingScreen> createState() => _FirstOnboardingScreenState();
}

class _FirstOnboardingScreenState extends State<FirstOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2DFDB), Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),


              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Discover Your Next Destination",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Access thousands of breathtaking destinations. "
                            "Swipe, search, and get inspired with curated destinations across Nepal.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 25),


                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            minWidth: 200,
                          ),
                          child: Image.asset(
                            'assets/images/first_onboarding.png',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),


                      const SizedBox(height: 20),
                      const Text(
                        "Explore Nepal, TripWise!",
                        style: TextStyle(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Center(
                  child: SizedBox(
                    width: 300,
                    height: 55,
                    child: MyButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const SecondOnboardingScreen()),
                        );
                      },
                      text: "Get Started",
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
