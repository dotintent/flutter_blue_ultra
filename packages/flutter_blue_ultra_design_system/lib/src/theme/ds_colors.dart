import 'package:flutter/material.dart';

import '../tokens/color_tokens.dart';

@immutable
class DsColors extends ThemeExtension<DsColors> {
  const DsColors({
    required this.background,
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
    required this.onAccent,
    required this.success,
    required this.warn,
    required this.chipBg,
    required this.brightness,
  });

  final Color background;
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
  final Color onAccent;
  final Color success;
  final Color warn;
  final Color chipBg;
  final Brightness brightness;

  bool get isDark => brightness == Brightness.dark;

  static const DsColors dark = DsColors(
    background: DsColorTokens.bgDark,
    surface: DsColorTokens.surfaceDark,
    surfaceAlt: DsColorTokens.surfaceAltDark,
    surfaceHi: DsColorTokens.surfaceHiDark,
    border: DsColorTokens.borderDark,
    borderHi: DsColorTokens.borderHiDark,
    textPrimary: DsColorTokens.textDark,
    textDim: DsColorTokens.textDimDark,
    textFaint: DsColorTokens.textFaintDark,
    accent: DsColorTokens.accent,
    accentSoft: DsColorTokens.accentSoftDark,
    onAccent: DsColorTokens.onAccent,
    success: DsColorTokens.successDark,
    warn: DsColorTokens.warnDark,
    chipBg: DsColorTokens.chipBgDark,
    brightness: Brightness.dark,
  );

  static const DsColors light = DsColors(
    background: DsColorTokens.bgLight,
    surface: DsColorTokens.surfaceLight,
    surfaceAlt: DsColorTokens.surfaceAltLight,
    surfaceHi: DsColorTokens.surfaceHiLight,
    border: DsColorTokens.borderLight,
    borderHi: DsColorTokens.borderHiLight,
    textPrimary: DsColorTokens.textLight,
    textDim: DsColorTokens.textDimLight,
    textFaint: DsColorTokens.textFaintLight,
    accent: DsColorTokens.accent,
    accentSoft: DsColorTokens.accentSoftLight,
    onAccent: DsColorTokens.onAccent,
    success: DsColorTokens.successLight,
    warn: DsColorTokens.warnLight,
    chipBg: DsColorTokens.chipBgLight,
    brightness: Brightness.light,
  );

  static DsColors of(BuildContext context) =>
      Theme.of(context).extension<DsColors>() ?? dark;

  ColorScheme toColorScheme() {
    return ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      primaryContainer: accentSoft,
      onPrimaryContainer: accent,
      secondary: accent,
      onSecondary: onAccent,
      secondaryContainer: surfaceAlt,
      onSecondaryContainer: textPrimary,
      tertiary: success,
      onTertiary: onAccent,
      error: accent,
      onError: onAccent,
      errorContainer: accentSoft,
      onErrorContainer: accent,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surfaceAlt,
      surfaceContainerHigh: surfaceHi,
      surfaceContainerHighest: surfaceHi,
      onSurfaceVariant: textDim,
      outline: borderHi,
      outlineVariant: border,
      inverseSurface: textPrimary,
      onInverseSurface: background,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
    );
  }

  @override
  DsColors copyWith({
    Color? background,
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
    Color? onAccent,
    Color? success,
    Color? warn,
    Color? chipBg,
    Brightness? brightness,
  }) {
    return DsColors(
      background: background ?? this.background,
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
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warn: warn ?? this.warn,
      chipBg: chipBg ?? this.chipBg,
      brightness: brightness ?? this.brightness,
    );
  }

  @override
  DsColors lerp(DsColors? other, double t) {
    if (other == null) return this;
    return DsColors(
      background: Color.lerp(background, other.background, t)!,
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
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}
