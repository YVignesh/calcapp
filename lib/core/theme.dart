import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primaryLight = Color(0xFF5E5CE6);
  static const _primaryDark = Color(0xFF7B79FF);
  static const _secondaryLight = Color(0xFFFF6B6B);
  static const _secondaryDark = Color(0xFFFF8080);

  static ThemeData light() {
    final cs = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEEEDFF),
      onPrimaryContainer: const Color(0xFF1A1870),
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFFE4E4),
      onSecondaryContainer: const Color(0xFF5C1212),
      surface: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1C1C1E),
      surfaceContainerHighest: const Color(0xFFF5F5F7),
      onSurfaceVariant: const Color(0xFF636366),
      error: const Color(0xFFFF3B30),
      onError: Colors.white,
      outline: const Color(0xFFD1D1D6),
      outlineVariant: const Color(0xFFE5E5EA),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFF1C1C1E),
      onInverseSurface: const Color(0xFFF2F2F7),
      inversePrimary: _primaryDark,
    );

    return _buildTheme(cs);
  }

  static ThemeData dark() {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: _primaryDark,
      onPrimary: const Color(0xFF1E1B4B),
      primaryContainer: const Color(0xFF2D2B7A),
      onPrimaryContainer: const Color(0xFFCCCBFF),
      secondary: _secondaryDark,
      onSecondary: const Color(0xFF5C1212),
      secondaryContainer: const Color(0xFF5C2020),
      onSecondaryContainer: const Color(0xFFFFCDCD),
      surface: const Color(0xFF1C1C1E),
      onSurface: const Color(0xFFF2F2F7),
      surfaceContainerHighest: const Color(0xFF2C2C2E),
      onSurfaceVariant: const Color(0xFF8E8E93),
      error: const Color(0xFFFF453A),
      onError: Colors.white,
      outline: const Color(0xFF48484A),
      outlineVariant: const Color(0xFF3A3A3C),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFF2F2F7),
      onInverseSurface: const Color(0xFF1C1C1E),
      inversePrimary: _primaryLight,
    );

    return _buildTheme(cs);
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    final isLight = cs.brightness == Brightness.light;
    final textTheme = GoogleFonts.nunitoTextTheme(
      isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: isLight
          ? const Color(0xFFF5F5F7)
          : const Color(0xFF0F0F14),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.nunito(
          color: cs.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isLight
                ? const Color(0xFFE5E5EA)
                : const Color(0xFF3A3A3C),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? const Color(0xFFEEEEF5)
            : const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.nunito(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(
          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: const Size(double.infinity, 54),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isLight
            ? const Color(0xFFE5E5EA)
            : const Color(0xFF3A3A3C),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight
            ? const Color(0xFFEEEEF5)
            : const Color(0xFF2C2C2E),
        selectedColor: cs.primaryContainer,
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cs.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
