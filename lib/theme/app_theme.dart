import 'package:flutter/material.dart';

/// Paleta "Moderna / Fintech / Productividad" (verde esmeralda + gris claro).
class AppTheme {
  static const Color primary = Color(0xFF0F9D58); // Verde principal (10%)
  static const Color primarySoft = Color(0xFFE8F5E9); // Verde suave: tarjetas y estados seleccionados
  static const Color textDark = Color(0xFF1E293B); // Neutral oscuro: texto principal
  static const Color background = Color(0xFFF8FAFC); // Neutral claro: fondo general (60%)
  static const Color danger = Color(0xFFEF4444); // Alerta / error / acciones destructivas

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      onPrimary: Colors.white,
      secondary: primary,
      surface: Colors.white,
      onSurface: textDark,
      error: danger,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
