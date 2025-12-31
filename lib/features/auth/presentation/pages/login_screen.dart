import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen/home_screen.dart';
import 'package:trip_wise_nepal/features/dashboard/presentation/pages/bottom_screen_layout.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/register_screen.dart';
import 'package:trip_wise_nepal/core/widgets/my_button.dart';
import 'package:trip_wise_nepal/core/widgets/my_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Image.asset(
                      'assets/images/logo2.png',
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: Text(
                      "Login to your account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyTextField(
                    controller: emailController,
                    hintText: "Enter your email address",
                    labelText: "Email Address",
                    errorMessage: "Please enter your email",
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: passwordController,
                    hintText: "Enter your password",
                    labelText: "Password",
                    errorMessage: "Please enter your password",
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: MyButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const BottomScreenLayout()),
                          );
                        },
                        text: "Login",
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/google.png", height: 22),
                          const SizedBox(width: 10),
                          Text("Continue with Google", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/facebook.png", height: 22),
                          const SizedBox(width: 10),
                          Text("Continue with Facebook", style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 18),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
