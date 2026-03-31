// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF0A0A0A);
  static const _accentColor = Color(0xFFE63946);
  static const _surfaceColor = Color(0xFF1A1A1A);
  static const _cardColor = Color(0xFF242424);
  static const _textPrimary = Color(0xFFF5F5F5);
  static const _textSecondary = Color(0xFF9E9E9E);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: _accentColor,
        surface: _surfaceColor,
        onSurface: _textPrimary,
        secondary: _accentColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: _textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: _cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ).data,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: _textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: _textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        bodyMedium: TextStyle(color: _textSecondary, fontSize: 14, height: 1.5),
        bodySmall: TextStyle(color: _textSecondary, fontSize: 12),
        labelMedium: TextStyle(
          color: _accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A2A),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        prefixIconColor: _textSecondary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceColor,
        selectedColor: _accentColor,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceColor,
        contentTextStyle: const TextStyle(color: _textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _accentColor,
      ),
    );
  }

  static const Color accent = _accentColor;
  static const Color textSecondary = _textSecondary;
  static const Color surface = _surfaceColor;
  static const Color card = _cardColor;
}
