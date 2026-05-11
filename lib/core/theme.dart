import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tokens.dart';

/// Console design-system theme.
///
/// Typography: IBM Plex Sans (UI / body) — loaded via google_fonts.
/// Numeric accent: IBM Plex Mono — applied in widgets that render numbers.
/// Palette: single brand accent (Signal Cyan). Near-monochrome chrome.
class AppTheme {
  static ThemeData light() => _buildTheme(_lightCs());
  static ThemeData dark() => _buildTheme(_darkCs());

  static ColorScheme _lightCs() => ColorScheme(
        brightness: Brightness.light,
        primary: AppTokens.brandAccent,
        onPrimary: AppTokens.lTextHi,
        primaryContainer: const Color(0xFFCFF9FE),
        onPrimaryContainer: const Color(0xFF082F36),
        secondary: AppTokens.success,
        onSecondary: AppTokens.lTextHi,
        secondaryContainer: const Color(0xFFCFFAED),
        onSecondaryContainer: const Color(0xFF052E1F),
        surface: AppTokens.lBg1,
        onSurface: AppTokens.lTextHi,
        surfaceContainerHighest: AppTokens.lBg2,
        onSurfaceVariant: AppTokens.lTextMd,
        error: AppTokens.danger,
        onError: Colors.white,
        outline: AppTokens.lBorder,
        outlineVariant: AppTokens.lBorder,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppTokens.bg1,
        onInverseSurface: AppTokens.textHi,
        inversePrimary: AppTokens.brandAccent,
      );

  static ColorScheme _darkCs() => ColorScheme(
        brightness: Brightness.dark,
        primary: AppTokens.brandAccent,
        onPrimary: AppTokens.bg0,
        primaryContainer: const Color(0xFF0E3A43),
        onPrimaryContainer: const Color(0xFF9FECFB),
        secondary: AppTokens.success,
        onSecondary: AppTokens.bg0,
        secondaryContainer: const Color(0xFF0E3A2B),
        onSecondaryContainer: const Color(0xFF9AFAD8),
        surface: AppTokens.bg1,
        onSurface: AppTokens.textHi,
        surfaceContainerHighest: AppTokens.bg2,
        onSurfaceVariant: AppTokens.textMd,
        error: AppTokens.danger,
        onError: Colors.white,
        outline: AppTokens.border,
        outlineVariant: AppTokens.border,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: AppTokens.lBg1,
        onInverseSurface: AppTokens.lTextHi,
        inversePrimary: AppTokens.brandAccent,
      );

  static ThemeData _buildTheme(ColorScheme cs) {
    final isLight = cs.brightness == Brightness.light;
    final bgColor = isLight ? AppTokens.lBg0 : AppTokens.bg0;
    final surfaceColor = isLight ? AppTokens.lBg1 : AppTokens.bg1;
    final borderColor = isLight ? AppTokens.lBorder : AppTokens.border;
    final inputFill = isLight ? AppTokens.lBg2 : AppTokens.bg2;

    // IBM Plex Sans for UI text
    final textTheme = GoogleFonts.ibmPlexSansTextTheme(
      isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
    ).apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: textTheme,
      scaffoldBackgroundColor: bgColor,
      cardColor: surfaceColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.ibmPlexSans(
          color: cs.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rCard),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: BorderSide(color: cs.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: GoogleFonts.ibmPlexSans(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
          ),
          textStyle: GoogleFonts.ibmPlexSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.rInput),
          ),
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: inputFill,
        selectedColor: cs.primaryContainer,
        labelStyle: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rChip),
          side: BorderSide(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: isLight ? AppTokens.bg2 : AppTokens.bg2,
        contentTextStyle: GoogleFonts.ibmPlexSans(
          color: AppTokens.textHi,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceColor,
        indicatorColor: cs.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.ibmPlexSans(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
        ),
      ),
    );
  }

  /// Helper: monospace style for numeric display. Use IBM Plex Mono.
  static TextStyle monoStyle({
    required double size,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) =>
      GoogleFonts.ibmPlexMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );
}
