import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.fraunces(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.fraunces(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.fraunces(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.fraunces(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
        labelMedium: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      );

  static TextStyle get headline1 => textTheme.displayMedium!;

  static TextStyle get headline2 => textTheme.headlineLarge!;

  static TextStyle get headline3 => textTheme.headlineMedium!;

  static TextStyle get headline4 => textTheme.titleLarge!;

  static TextStyle get bodyLarge => textTheme.bodyLarge!;

  static TextStyle get bodyMedium => textTheme.bodyMedium!;

  static TextStyle get bodySmall => textTheme.bodySmall!;

  static TextStyle get labelLarge => textTheme.labelLarge!;

  static TextStyle get labelMedium => textTheme.labelMedium!;

  static TextStyle get caption => textTheme.bodySmall!;

  static TextStyle get button => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );

  static TextStyle get price => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      );
}
