import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor =
      Color(0xFF673AB7); // Ungu Tua (untuk tombol Done, dll)
  static const Color accentColor = Color(0xFFFFC107); // Kuning Amber
  static const Color backgroundColor = Color(0xFFF3F4F6); // Abu-abu Muda
  static const Color textColor = Color(0xFF212121); // Abu-abu Gelap
  static const Color successColor = Color(0xFF4CAF50); // Hijau
  static const Color errorColor = Color(0xFFF44336); // Merah
  static const Color warningColor = Color(0xFFFF9800); // Oranye
  static const Color warnaOren = Color(0xFFFDB69F);

  // Warna gradien dari desain UI
  static const List<Color> splashGradient = [
    Color(0xFFDFF2F1),
    Color(0xFFFDB69F),
    Color(0xFF011D3A),
  ];
  static const Color textFieldFillColor =
      Color(0xFFF0F0F0); // Abu-abu sangat muda untuk background input
  static const Color tabIndicatorColor =
      Colors.white; // Warna untuk indikator tab
  static const Color socialButtonBgColor =
      Colors.white; // Warna latar belakang tombol sosial
  static const Color socialButtonBorderColor =
      Color(0xFFE0E0E0); // Warna border tombol sosial
  static const Color socialButtonIconColor =
      Colors.black87; // Warna icon tombol sosial
  static const Color headingText = Color(0xFF011D3A); // Warna Text sesuai Figma
}
