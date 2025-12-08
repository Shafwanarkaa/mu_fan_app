import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Manchester United Colors
  static const Color muRed = Color(0xFFDA291C);
  static const Color muBlack = Color(0xFF000000);
  static const Color muGold = Color(0xFFFBE122);
  static const Color muDarkGrey = Color(0xFF1A1A1A);
  static const Color muWhite = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: muRed,
      scaffoldBackgroundColor: muBlack,
      colorScheme: const ColorScheme.dark(
        primary: muRed,
        secondary: muGold,
        surface: muDarkGrey,
        onSurface: muWhite,
        error: Color(0xFFCF6679),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: muWhite,
        displayColor: muWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: muBlack,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: muWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: muGold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: muDarkGrey,
        selectedItemColor: muGold,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
      cardTheme: CardTheme(
        color: muDarkGrey,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white10, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: muRed,
          foregroundColor: muWhite,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
