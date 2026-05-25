import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntentColors {
  IntentColors._();

  static const Color accent = Color(0xFFFF3B5C);
  static const Color accentSoftDark = Color(0x24FF3B5C);
  static const Color accentSoftLight = Color(0x1AFF3B5C);

  static const Color bgDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF141414);
  static const Color surfaceAltDark = Color(0xFF1C1C1C);
  static const Color surfaceHiDark = Color(0xFF262626);
  static const Color borderDark = Color(0x14FFFFFF);
  static const Color borderHiDark = Color(0x29FFFFFF);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textDimDark = Color(0xFF9A9A9A);
  static const Color textFaintDark = Color(0xFF5A5A5A);
  static const Color successDark = Color(0xFF7CE0A8);
  static const Color warnDark = Color(0xFFF5C66F);
  static const Color chipBgDark = Color(0x0FFFFFFF);

  static const Color bgLight = Color(0xFFE8E8E8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceAltLight = Color(0xFFF1F1F1);
  static const Color surfaceHiLight = Color(0xFFDCDCDC);
  static const Color borderLight = Color(0x1A000000);
  static const Color borderHiLight = Color(0x33000000);
  static const Color textLight = Color(0xFF0A0A0A);
  static const Color textDimLight = Color(0xFF6A6A6A);
  static const Color textFaintLight = Color(0xFF9A9A9A);
  static const Color successLight = Color(0xFF1CA86A);
  static const Color warnLight = Color(0xFFC8842A);
  static const Color chipBgLight = Color(0x0D000000);
}

@immutable
class IntentTheme extends ThemeExtension<IntentTheme> {
  const IntentTheme({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.surfaceHi,
    required this.border,
    required this.borderHi,
    required this.textPrimary,
    required this.textDim,
    required this.textFaint,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.warn,
    required this.chipBg,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color surfaceHi;
  final Color border;
  final Color borderHi;
  final Color textPrimary;
  final Color textDim;
  final Color textFaint;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color warn;
  final Color chipBg;
  final bool isDark;

  static const IntentTheme dark = IntentTheme(
    bg: IntentColors.bgDark,
    surface: IntentColors.surfaceDark,
    surfaceAlt: IntentColors.surfaceAltDark,
    surfaceHi: IntentColors.surfaceHiDark,
    border: IntentColors.borderDark,
    borderHi: IntentColors.borderHiDark,
    textPrimary: IntentColors.textDark,
    textDim: IntentColors.textDimDark,
    textFaint: IntentColors.textFaintDark,
    accent: IntentColors.accent,
    accentSoft: IntentColors.accentSoftDark,
    success: IntentColors.successDark,
    warn: IntentColors.warnDark,
    chipBg: IntentColors.chipBgDark,
    isDark: true,
  );

  static const IntentTheme light = IntentTheme(
    bg: IntentColors.bgLight,
    surface: IntentColors.surfaceLight,
    surfaceAlt: IntentColors.surfaceAltLight,
    surfaceHi: IntentColors.surfaceHiLight,
    border: IntentColors.borderLight,
    borderHi: IntentColors.borderHiLight,
    textPrimary: IntentColors.textLight,
    textDim: IntentColors.textDimLight,
    textFaint: IntentColors.textFaintLight,
    accent: IntentColors.accent,
    accentSoft: IntentColors.accentSoftLight,
    success: IntentColors.successLight,
    warn: IntentColors.warnLight,
    chipBg: IntentColors.chipBgLight,
    isDark: false,
  );

  @override
  IntentTheme copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceAlt,
    Color? surfaceHi,
    Color? border,
    Color? borderHi,
    Color? textPrimary,
    Color? textDim,
    Color? textFaint,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? warn,
    Color? chipBg,
    bool? isDark,
  }) {
    return IntentTheme(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceHi: surfaceHi ?? this.surfaceHi,
      border: border ?? this.border,
      borderHi: borderHi ?? this.borderHi,
      textPrimary: textPrimary ?? this.textPrimary,
      textDim: textDim ?? this.textDim,
      textFaint: textFaint ?? this.textFaint,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      warn: warn ?? this.warn,
      chipBg: chipBg ?? this.chipBg,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  IntentTheme lerp(IntentTheme? other, double t) {
    if (other == null) return this;
    return IntentTheme(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceHi: Color.lerp(surfaceHi, other.surfaceHi, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderHi: Color.lerp(borderHi, other.borderHi, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      textFaint: Color.lerp(textFaint, other.textFaint, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }

  static IntentTheme of(BuildContext context) {
    return Theme.of(context).extension<IntentTheme>()!;
  }
}

class IntentTextStyles {
  IntentTextStyles._();

  static TextStyle serifDisplay(double size, Color color,
          {double letterSpacing = -1.5}) =>
      GoogleFonts.crimsonPro(
          fontSize: size,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: letterSpacing,
          height: 1.0);

  static TextStyle serifTitle(double size, Color color) =>
      GoogleFonts.crimsonPro(
          fontSize: size,
          fontWeight: FontWeight.w500,
          color: color,
          letterSpacing: -0.3,
          height: 1.15);

  static TextStyle mono(double size, Color color,
          {double letterSpacing = 0.3}) =>
      GoogleFonts.jetBrainsMono(
          fontSize: size,
          fontWeight: FontWeight.w400,
          color: color,
          letterSpacing: letterSpacing);

  static TextStyle monoLabel(double size, Color color) =>
      GoogleFonts.jetBrainsMono(
          fontSize: size,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 1.4);

  static TextStyle sans(double size, Color color,
          {FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.inter(
          fontSize: size,
          fontWeight: weight,
          color: color,
          letterSpacing: 0.0);
}

ThemeData buildDarkTheme() => _buildTheme(IntentTheme.dark, Brightness.dark);
ThemeData buildLightTheme() => _buildTheme(IntentTheme.light, Brightness.light);

ThemeData _buildTheme(IntentTheme it, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: it.bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: it.accent,
      onPrimary: Colors.white,
      secondary: it.accent,
      onSecondary: Colors.white,
      error: it.accent,
      onError: Colors.white,
      surface: it.surface,
      onSurface: it.textPrimary,
    ),
    textTheme: GoogleFonts.interTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    ),
    extensions: [it],
    appBarTheme: AppBarTheme(
      backgroundColor: it.bg,
      foregroundColor: it.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    dividerTheme: DividerThemeData(color: it.border, space: 0, thickness: 1),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: it.accent),
    ),
  );
}
