import 'package:flutter/material.dart';

class AppTheme {
  // Define our blue colors
  static const primaryBlue = Color(0xFF1A237E); // Dark blue
  static const lightBlue = Color(0xFFE8EAF6); // Very light blue
  static final mediumBlue = Color(0xFF3949AB); // Medium blue for interactive elements

  static ThemeData get darkTheme {
    const darkSurface = Color(0xFF1E1E1E);
    const darkBackground = Color(0xFF121212);
    
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.green,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBlue,
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.white, // This ensures all icons in the AppBar are white
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white, // This specifically targets the action icons
        ),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: mediumBlue,
        foregroundColor: Colors.white,
      ),
      iconTheme: IconThemeData(
        color: mediumBlue,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: primaryBlue),
        bodyLarge: TextStyle(color: primaryBlue),
        bodyMedium: TextStyle(color: primaryBlue),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: mediumBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mediumBlue, width: 2),
        ),
      ),
    );
  }
}
