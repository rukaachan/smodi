import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smodi/features/auth/screens/auth_gate_screen.dart';

class SmodiApp extends StatelessWidget {
  const SmodiApp({super.key});

  @override
  Widget build(BuildContext context) {
    //
    // --- APPLICATION ROOT ---
    // This widget defines the top-level configuration for the app,
    // including the theme, routing, and the initial screen.
    //
    return MaterialApp(
      title: 'Smodi',
      // The theme is designed to be modern, clean, and beautiful, aligning
      // with the 2025 aesthetic requested. It uses a dark mode-first approach.
      theme: _buildTheme(Brightness.dark),
      debugShowCheckedModeBanner: false,
      // The AuthGate will be the first screen the user sees. It will decide
      // whether to show the login screen or the main app dashboard based on
      // the user's authentication state.
      home: const AuthGateScreen(),
    );
  }

  /// Builds the application's theme data.
  /// Inspired by Apple's HIG: focuses on clarity, depth, and deference to content.
  ThemeData _buildTheme(Brightness brightness) {
    // Define a modern, cohesive color palette.
    // This example uses a deep navy base with vibrant neon accents.
    // It creates a high-contrast, visually engaging experience.
    const primaryColor = Color(0xFF0A192F); // Deep Navy
    const secondaryColor = Color(0xFF112240); // Lighter Navy
    const accentColor = Color(0xFF64FFDA); // Neon Mint
    const textColor = Color(0xFFCCD6F6); // Light Slate
    const subtleTextColor = Color(0xFF8892B0); // Slate

    final baseTheme = ThemeData(brightness: brightness);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: accentColor,
        secondary: accentColor,
        background: primaryColor,
        surface: secondaryColor,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onBackground: textColor,
        onSurface: textColor,
        error: Colors.redAccent,
      ),
      // Typography is critical for clarity (Apple HIG).
      // We use Google Fonts for a clean, modern look. 'Inter' is a great
      // choice for UI design due to its high readability.
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0, // Flat design for a modern look
        centerTitle: true,
      ),
      // Define a default style for floating action buttons.
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.black,
      ),
      // Define a default style for all buttons.
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
