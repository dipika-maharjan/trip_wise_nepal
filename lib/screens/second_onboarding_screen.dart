import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/screens/login_screen.dart';
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
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Travel With Confidence",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "See honest reviews from a global community so you always know you’re booking the right place.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w300),
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
                            'assets/images/second_onboarding.png',
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),


                      const SizedBox(height: 20),
                      const Text(
                        "Explore Nepal, TripWise!",
                        style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Back + Next buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: MyButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        text: "Back",
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 140,
                      height: 50,
                      child: MyButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ThirdOnboardingScreen()),
                          );
                        },
                        text: "Next",
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
