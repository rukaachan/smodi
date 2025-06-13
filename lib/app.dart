import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smodi/features/auth/screens/initial_loading_screen.dart'; // Import the new screen

class SmodiApp extends StatelessWidget {
  const SmodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smodi',
      theme: _buildTheme(Brightness.dark),
      debugShowCheckedModeBanner: false,
      // The app's one and only entry point is the InitialLoadingScreen.
      home: const InitialLoadingScreen(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    // Define a modern, cohesive color palette.
    const primaryColor = Color(0xFF0A192F); // Deep Navy
    const secondaryColor = Color(0xFF112240); // Lighter Navy
    const accentColor = Color(0xFF64FFDA); // Neon Mint
    const textColor = Color(0xFFCCD6F6); // Light Slate
    // const subtleTextColor = Color(0xFF8892B0); // Slate

    final baseTheme = ThemeData(brightness: brightness);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: accentColor,
        secondary: accentColor,
        surface: secondaryColor,
        onSurface: textColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        error: Colors.redAccent,
      ),
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
