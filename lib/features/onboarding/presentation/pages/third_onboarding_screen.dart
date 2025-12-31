import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:trip_wise_nepal/core/widgets/my_button.dart';

class ThirdOnboardingScreen extends StatefulWidget {
  const ThirdOnboardingScreen({super.key});

  @override
  State<ThirdOnboardingScreen> createState() => _ThirdOnboardingScreenState();
}

class _ThirdOnboardingScreenState extends State<ThirdOnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/third-onboarding.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button at top
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
                        backgroundColor: Colors.teal[600],
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Centered content with buttons
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Plan, Book, and Review",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        const Text(
                          "Your journey is simplified. Find, book, and share your accommodation details, all in one place.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            fontWeight: FontWeight.w300,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),


                        const SizedBox(height: 20),
                        const Text(
                          "Explore Nepal, TripWise!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // Back + Next btn
                        Row(
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
                                color: Colors.teal[600],
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
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginScreen()),
                                  );
                                },
                                text: "Next",
                                color: Colors.teal[600],
                              ),
                            ),
                          ],
                        ),
                      ],
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
