import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:trip_wise_nepal/core/widgets/my_button.dart';
import 'package:trip_wise_nepal/core/widgets/my_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                              "Create new account",
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
                          const SizedBox(height: 25),
                          MyTextField(
                            controller: confirmPasswordController,
                            hintText: "Enter your password",
                            labelText: "Confirm Password",
                            errorMessage: "Please enter your password",
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              width: 250,
                              child: MyButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                text: "Register",
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
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(fontSize: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
