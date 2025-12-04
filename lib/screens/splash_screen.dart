import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00B99A),
                Color(0xFF0C7272)
              ],
              begin: Alignment.topRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "TripWiseNepal",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  width: 120,
                ),
                
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                      "Find Your Dream Destination With Us!",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
