import 'package:flutter/material.dart';

class AppTheme {
  static const Color coffeeBrown = Color(0xFF4E342E);
  static const Color coffeeCream = Color(0xFFFFF8E7);
  static const Color coffeeAmber = Color(0xFFFFB300);
  static const Color coffeeEspresso = Color(0xFF2C1810);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: coffeeBrown,
      brightness: Brightness.light,
      primary: coffeeBrown,
      secondary: coffeeAmber,
      surface: coffeeCream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: coffeeCream,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: coffeeEspresso,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: coffeeAmber,
        foregroundColor: coffeeEspresso,
      ),
    );
  }
}
