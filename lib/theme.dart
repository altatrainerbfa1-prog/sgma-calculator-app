import 'package:flutter/material.dart';

/// Singapore Mortgage Advisory brand palette, matches the website's
/// design system (navy / gold / cream).
class SgmaColors {
  static const navy = Color(0xFF152238);
  static const navyLight = Color(0xFF233350);
  static const gold = Color(0xFFA9834C);
  static const goldLight = Color(0xFFC9A877);
  static const cream = Color(0xFFF7F4EE);
  static const ink = Color(0xFF1C1C1C);
  static const grey = Color(0xFF6B6B6B);
  static const line = Color(0xFFE4E0D6);
}

ThemeData buildSgmaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SgmaColors.navy,
      primary: SgmaColors.navy,
      secondary: SgmaColors.gold,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: SgmaColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 19,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: SgmaColors.ink,
      displayColor: SgmaColors.ink,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SgmaColors.gold,
        foregroundColor: SgmaColors.navy,
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: SgmaColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: SgmaColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: SgmaColors.gold, width: 1.4),
      ),
      labelStyle: const TextStyle(color: SgmaColors.grey, fontSize: 13),
    ),
    cardTheme: CardThemeData(
      color: SgmaColors.cream,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: SgmaColors.line),
      ),
    ),
  );
}
