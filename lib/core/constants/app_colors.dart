import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00897B);
  static const Color secondary = Color(0xFF9CCC65);
  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color shadow = Color(0x1A000000);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF26A69A), Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
