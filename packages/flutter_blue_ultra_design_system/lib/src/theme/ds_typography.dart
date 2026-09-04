import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../tokens/typography_tokens.dart';

@immutable
class DsTypography extends ThemeExtension<DsTypography> {
  const DsTypography({
    required this.display,
    required this.displayEmphasis,
    required this.headline,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.titlePlaceholder,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.button,
    required this.mono,
    required this.monoSmall,
    required this.label,
    required this.labelSmall,
    required this.brand,
  });

  final TextStyle display;
  final TextStyle displayEmphasis;
  final TextStyle headline;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle titlePlaceholder;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle button;
  final TextStyle mono;
  final TextStyle monoSmall;
  final TextStyle label;
  final TextStyle labelSmall;
  final TextStyle brand;

  static TextStyle serif(
    double size, {
    Color? color,
    FontWeight weight = DsFontWeight.medium,
    double letterSpacing = DsTracking.title,
    double? height = DsLineHeight.tight,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      GoogleFonts.crimsonPro(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        fontStyle: fontStyle,
      );

  static TextStyle serifDisplay(
    double size, {
    Color? color,
    double letterSpacing = DsTracking.display,
  }) =>
      serif(
        size,
        color: color,
        letterSpacing: letterSpacing,
        height: DsLineHeight.flat,
      );

  static TextStyle monoStyle(
    double size, {
    Color? color,
    FontWeight weight = DsFontWeight.regular,
    double letterSpacing = DsTracking.mono,
    double? height,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle serifItalic(double size, {Color? color}) => serif(
        size,
        color: color,
        weight: DsFontWeight.regular,
        letterSpacing: 0,
        height: null,
        fontStyle: FontStyle.italic,
      );

  static TextStyle monoLabel(double size, {Color? color}) => monoStyle(
        size,
        color: color,
        weight: DsFontWeight.semiBold,
        letterSpacing: DsTracking.label,
      );

  static TextStyle sans(
    double size, {
    Color? color,
    FontWeight weight = DsFontWeight.regular,
    double letterSpacing = DsTracking.body,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
      );

  static final DsTypography standard = DsTypography(
    display: serif(
      DsFontSize.display,
      letterSpacing: DsTracking.display,
      height: DsLineHeight.flat,
    ),
    displayEmphasis: serif(
      DsFontSize.display,
      letterSpacing: DsTracking.display,
      height: DsLineHeight.flat,
      fontStyle: FontStyle.italic,
    ),
    headline: serif(
      DsFontSize.headline,
      letterSpacing: DsTracking.headline,
      height: DsLineHeight.flat,
    ),
    titleLarge: serif(DsFontSize.titleLarge),
    titleMedium: serif(DsFontSize.titleMedium),
    titleSmall: serif(DsFontSize.titleSmall),
    titlePlaceholder: serif(
      DsFontSize.titleSmall,
      weight: DsFontWeight.regular,
      letterSpacing: 0,
      fontStyle: FontStyle.italic,
    ),
    bodyLarge: sans(DsFontSize.bodyLarge),
    bodyMedium: sans(DsFontSize.bodyMedium),
    bodySmall: sans(DsFontSize.bodySmall),
    button: sans(
      DsFontSize.bodySm,
      weight: DsFontWeight.semiBold,
      height: DsFontSize.bodySmLeading / DsFontSize.bodySm,
    ),
    mono: monoStyle(DsFontSize.monoLarge, letterSpacing: DsTracking.monoTight),
    monoSmall: monoStyle(DsFontSize.monoMedium),
    label: monoStyle(
      DsFontSize.monoMedium,
      weight: DsFontWeight.semiBold,
      letterSpacing: DsTracking.label,
    ),
    labelSmall: monoStyle(
      DsFontSize.monoSmall,
      weight: DsFontWeight.semiBold,
      letterSpacing: DsTracking.label,
    ),
    brand: serif(
      DsFontSize.titleLarge,
      weight: DsFontWeight.regular,
      height: DsLineHeight.flat,
    ),
  );

  static Future<void> pendingFonts() => GoogleFonts.pendingFonts([
        GoogleFonts.crimsonPro(fontWeight: DsFontWeight.regular),
        GoogleFonts.crimsonPro(fontWeight: DsFontWeight.medium),
        GoogleFonts.jetBrainsMono(fontWeight: DsFontWeight.regular),
        GoogleFonts.jetBrainsMono(fontWeight: DsFontWeight.semiBold),
        GoogleFonts.inter(fontWeight: DsFontWeight.regular),
        GoogleFonts.inter(fontWeight: DsFontWeight.semiBold),
      ]);

  static DsTypography of(BuildContext context) =>
      Theme.of(context).extension<DsTypography>() ?? standard;

  TextTheme toTextTheme(Color primary, Color dim) {
    return TextTheme(
      displayLarge: display.copyWith(color: primary),
      displayMedium: display.copyWith(color: primary),
      displaySmall: headline.copyWith(color: primary),
      headlineLarge: headline.copyWith(color: primary),
      headlineMedium: headline.copyWith(color: primary),
      headlineSmall: titleLarge.copyWith(color: primary),
      titleLarge: titleLarge.copyWith(color: primary),
      titleMedium: titleMedium.copyWith(color: primary),
      titleSmall: titleSmall.copyWith(color: primary),
      bodyLarge: bodyLarge.copyWith(color: primary),
      bodyMedium: bodyMedium.copyWith(color: primary),
      bodySmall: bodySmall.copyWith(color: dim),
      labelLarge: button.copyWith(color: primary),
      labelMedium: label.copyWith(color: dim),
      labelSmall: labelSmall.copyWith(color: dim),
    );
  }

  @override
  DsTypography copyWith({
    TextStyle? display,
    TextStyle? displayEmphasis,
    TextStyle? headline,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? titlePlaceholder,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? button,
    TextStyle? mono,
    TextStyle? monoSmall,
    TextStyle? label,
    TextStyle? labelSmall,
    TextStyle? brand,
  }) {
    return DsTypography(
      display: display ?? this.display,
      displayEmphasis: displayEmphasis ?? this.displayEmphasis,
      headline: headline ?? this.headline,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      titlePlaceholder: titlePlaceholder ?? this.titlePlaceholder,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      button: button ?? this.button,
      mono: mono ?? this.mono,
      monoSmall: monoSmall ?? this.monoSmall,
      label: label ?? this.label,
      labelSmall: labelSmall ?? this.labelSmall,
      brand: brand ?? this.brand,
    );
  }

  @override
  DsTypography lerp(DsTypography? other, double t) {
    if (other == null) return this;
    return DsTypography(
      display: TextStyle.lerp(display, other.display, t)!,
      displayEmphasis:
          TextStyle.lerp(displayEmphasis, other.displayEmphasis, t)!,
      headline: TextStyle.lerp(headline, other.headline, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      titlePlaceholder:
          TextStyle.lerp(titlePlaceholder, other.titlePlaceholder, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      mono: TextStyle.lerp(mono, other.mono, t)!,
      monoSmall: TextStyle.lerp(monoSmall, other.monoSmall, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
      brand: TextStyle.lerp(brand, other.brand, t)!,
    );
  }
}
