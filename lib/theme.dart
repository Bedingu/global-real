import 'package:flutter/material.dart';

class AppTheme {
  // 🔵 Azul institucional Global Real
  static const Color primaryBlue = Color(0xFF232845);

  // 🎨 Cores de apoio
  static const Color background = Color(0xFFF4F4F4);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: background,

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    // 🧱 Cards
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 2,
    ),

    // 🔘 Botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),

    // 🔤 Textos
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textSecondary,
      ),
    ),

    // 🎯 Ícones
    iconTheme: const IconThemeData(
      color: primaryBlue,
    ),

    // 📄 Dividers
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
    ),
  );
}
