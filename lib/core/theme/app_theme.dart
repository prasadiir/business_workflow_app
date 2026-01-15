import 'package:flutter/material.dart';

class AppTheme {
  // More beginner-style color choices
  static const Color primaryColor = Colors.deepPurple;
  static const Color secondaryColor = Colors.purpleAccent;
  static const Color successColor = Colors.lightGreen;
  static const Color errorColor = Colors.redAccent;
  static const Color warningColor = Colors.amber;
  static const Color infoColor = Colors.cyan;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black45;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      brightness: Brightness.light,
      useMaterial3: true,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.yellow[50], // light background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6), // smaller radius
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.deepPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 3, // visible but simple
        ),
      ),
    );
  }
}
