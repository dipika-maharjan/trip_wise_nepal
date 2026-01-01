import 'package:flutter/material.dart';
import 'package:trip_wise_nepal/app/theme/theme_data.dart';
import 'features/splash/presentation/pages/splash_screen.dart';

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