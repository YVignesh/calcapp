import 'package:flutter/material.dart';

/// Console design-system tokens. Static constants only — no runtime state.
class AppTokens {
  // Brand
  static const Color brandAccent = Color(0xFF22D3EE); // Signal Cyan

  // Console greys (dark-first)
  static const Color bg0 = Color(0xFF0B0B0E); // app background
  static const Color bg1 = Color(0xFF131318); // surface
  static const Color bg2 = Color(0xFF1B1B22); // raised surface
  static const Color border = Color(0xFF2A2A33); // 1-px hairline borders
  static const Color textHi = Color(0xFFE6E6EB);
  static const Color textMd = Color(0xFF9A9AA5);
  static const Color textLo = Color(0xFF60606A);
  static const Color danger = Color(0xFFFF5470);
  static const Color success = Color(0xFF22D69E);

  // Light mirror
  static const Color lBg0 = Color(0xFFFAFAFB);
  static const Color lBg1 = Color(0xFFFFFFFF);
  static const Color lBg2 = Color(0xFFF3F3F5);
  static const Color lBorder = Color(0xFFE3E3E7);
  static const Color lTextHi = Color(0xFF0F1014);
  static const Color lTextMd = Color(0xFF5A5A65);
  static const Color lTextLo = Color(0xFF8A8A95);

  // Radii
  static const double rChip = 6;
  static const double rInput = 10;
  static const double rCard = 14;

  // App version (referenced in Settings)
  static const String appVersion = '2.0.0';

  AppTokens._();
}
