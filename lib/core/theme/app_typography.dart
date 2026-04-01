// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Receipt fonts (thermal printer optimized)
  static TextStyle receiptMono({
    double size = 10,
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black, // Tambahkan parameter color (default: hitam)
    double? letterSpacing, // Tambahkan parameter letterSpacing (bisa null)
  }) {
    return GoogleFonts.spaceMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing, // Teruskan ke GoogleFonts
      height: 1.2,
    );
  }

  static TextStyle receiptCondensed({
    double size = 12,
    FontWeight weight = FontWeight.w500,
    double? letterSpacing,
  }) {
    return GoogleFonts.barlowCondensed(
      fontSize: size,
      fontWeight: weight,
      color: Colors.black,
      height: 1.1,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle receiptSerif({
    double size = 10,
    FontWeight weight = FontWeight.w400,
    Color color = Colors.black,
  }) {
    return GoogleFonts.libreBaskerville(
      fontSize: size,
      fontWeight: weight,
      color: Colors.black,
      height: 1.3,
    );
  }

  // UI fonts
  static TextStyle get heading => GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: const Color(0xFF1E293B),
  );

  static TextStyle get subheading => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF64748B),
  );

  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: const Color(0xFF1E293B),
  );

  static TextStyle get price => GoogleFonts.jetBrainsMono(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: const Color(0xFF5DA9E9),
  );
}
