// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const Color bgStart = Color(0xFFEAF4FF);
  static const Color bgEnd = Color(0xFFF5FAFF);

  // Primary
  static const Color primary = Color(0xFF5DA9E9);
  static const Color secondary = Color(0xFF8ED1FC);

  // Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F8FB);

  // Text
  static const Color textMain = Color(0xFF1E293B);
  static const Color textSub = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFFF7675);

  // Receipt (B&W untuk thermal)
  static const Color receiptBlack = Color(0xFF000000);
  static const Color receiptWhite = Color(0xFFFFFFFF);
  static const Color receiptGray = Color(0xFF808080);

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgStart, bgEnd],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  // Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> get innerShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(2, 2),
    ),
  ];
}
