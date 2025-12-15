import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/theme/theme_data.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      title: 'TripWise Nepal',
      home: SplashScreen(),
    );
  }
}