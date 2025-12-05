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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ Color(0xFFB2DFDB),
              Color(0xFFFFF3E0),],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              //skip btn
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80, right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(

                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 50),
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


              //back and next btn
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: MyButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      text: "Back",
                      color: Colors.teal,
                    ),
                  ),

                  const SizedBox(width: 40),
                  MyButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    text: "Next",
                    color: Colors.teal,
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
