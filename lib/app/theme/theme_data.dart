import 'package:flutter/material.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Montserrat-Regular',

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF136767),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF136767),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
  );
}
