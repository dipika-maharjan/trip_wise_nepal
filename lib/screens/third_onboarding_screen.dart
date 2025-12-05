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
            colors: [Color(0xFFB2DFDB), Color(0xFFFFF3E0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
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
                          child: const Text("Skip", style: TextStyle(fontSize: 16, color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Plan, Book, and Review",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your journey is simplified. Find, book, and share your accommodation details, all in one place.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 1.4, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300, // Adjust height as needed
                    child: Image.asset('assets/images/third_onboarding.png', fit: BoxFit.contain),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Explore Nepal, TripWise!",
                    style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic),
                  ),
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
                      SizedBox(
                        width: 150,
                        child: MyButton(
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
