import 'package:flutter/material.dart';

const _seed = Color(0xFF4CAF82);
const _darkBg = Color(0xFF1C1C1E);

class AppTheme {
  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  );

  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      surface: _darkBg,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: _darkBg,
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  );
}