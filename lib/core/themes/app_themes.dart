import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes{

  // dark theme settings
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A101C), // deep navy blue ()xFF -> opacity 100% full)
    primaryColor: const Color(0xFF3DFFAC), // mint green
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3DFFAC),
      secondary: Color(0xFFFF5252),
      surface: Color(0x1AFFFFFF), // 0x1A -> 10% opacity
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
  );

  // light theme settings
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F6F9),
    primaryColor: const Color(0xFF00B074),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00B074),
      secondary: Color(0xFFD32F2F),
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
  );

}













