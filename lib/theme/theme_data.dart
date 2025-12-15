import 'package:flutter/material.dart';

ThemeData getApplicationTheme(){
  return ThemeData(
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.white,
  fontFamily: 'Montserrat Regular',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontFamily: 'Montserrat-Regular',
        ),
        backgroundColor: Color(0xFF136767),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),
      ),
    ),
  );
}