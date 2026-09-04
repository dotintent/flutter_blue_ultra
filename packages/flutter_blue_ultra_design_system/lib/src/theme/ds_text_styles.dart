import 'package:flutter/material.dart';

import '../tokens/typography_tokens.dart';
import 'ds_typography.dart';

class DsTextStyles {
  const DsTextStyles._();

  static double _leading(double lineHeight, double fontSize) =>
      lineHeight / fontSize;

  static TextStyle heading2xl({Color? color, FontStyle? fontStyle}) =>
      DsTypography.serif(
        DsFontSize.heading2xl,
        color: color,
        weight: DsFontWeight.semiBold,
        letterSpacing: DsTracking.heading2xl,
        height: _leading(
          DsFontSize.heading2xlLeading,
          DsFontSize.heading2xl,
        ),
        fontStyle: fontStyle ?? FontStyle.normal,
      );

  static TextStyle headingLg({Color? color, FontStyle? fontStyle}) =>
      DsTypography.serif(
        DsFontSize.headingLg,
        color: color,
        weight: DsFontWeight.semiBold,
        letterSpacing: DsTracking.heading2xl,
        height: _leading(DsFontSize.headingLgLeading, DsFontSize.headingLg),
        fontStyle: fontStyle ?? FontStyle.normal,
      );

  static TextStyle monoLabelLoud({
    Color? color,
    double size = DsFontSize.monoMd,
  }) =>
      DsTypography.monoStyle(
        size,
        color: color,
        weight: DsFontWeight.medium,
        letterSpacing: DsTracking.monoLabelLoud,
        height: size == DsFontSize.monoMd
            ? _leading(DsFontSize.monoMdLeading, DsFontSize.monoMd)
            : null,
      );

  static TextStyle headingXl({Color? color, FontStyle? fontStyle}) =>
      DsTypography.serif(
        DsFontSize.headingXl,
        color: color,
        weight: DsFontWeight.semiBold,
        letterSpacing: DsTracking.headingXl,
        height: _leading(DsFontSize.headingXlLeading, DsFontSize.headingXl),
        fontStyle: fontStyle ?? FontStyle.normal,
      );

  static TextStyle monoLg({Color? color}) => DsTypography.monoStyle(
        DsFontSize.monoLg,
        color: color,
        letterSpacing: DsTracking.monoPlain,
        height: _leading(DsFontSize.monoLgLeading, DsFontSize.monoLg),
      );

  static TextStyle headingSm({Color? color, FontStyle? fontStyle}) =>
      DsTypography.serif(
        DsFontSize.headingSm,
        color: color,
        weight: DsFontWeight.medium,
        letterSpacing: DsTracking.headingSm,
        height: _leading(DsFontSize.headingSmLeading, DsFontSize.headingSm),
        fontStyle: fontStyle ?? FontStyle.normal,
      );

  static TextStyle monoValue({Color? color}) => DsTypography.monoStyle(
        DsFontSize.monoValue,
        color: color,
        weight: DsFontWeight.bold,
        letterSpacing: DsTracking.monoValue,
        height: _leading(DsFontSize.monoValueLeading, DsFontSize.monoValue),
      );

  static TextStyle monoCaption({Color? color}) => DsTypography.monoStyle(
        DsFontSize.monoMd,
        color: color,
        letterSpacing: DsTracking.monoCaption,
        height: _leading(DsFontSize.monoMdLeading, DsFontSize.monoMd),
      );

  static TextStyle monoLabel({Color? color}) => DsTypography.monoStyle(
        DsFontSize.monoMd,
        color: color,
        weight: DsFontWeight.medium,
        letterSpacing: DsTracking.monoLabel,
        height: _leading(DsFontSize.monoMdLeading, DsFontSize.monoMd),
      );

  static TextStyle monoMd({Color? color}) => DsTypography.monoStyle(
        DsFontSize.monoMd,
        color: color,
        letterSpacing: DsTracking.monoPlain,
        height: _leading(DsFontSize.monoMdLeading, DsFontSize.monoMd),
      );

  static TextStyle bodySm({
    Color? color,
    FontWeight weight = DsFontWeight.regular,
  }) =>
      DsTypography.sans(
        DsFontSize.bodySm,
        color: color,
        weight: weight,
        height: _leading(DsFontSize.bodySmLeading, DsFontSize.bodySm),
      );

  static TextStyle bodySmMedium({Color? color}) =>
      bodySm(color: color, weight: DsFontWeight.medium);

  static TextStyle bodySmBold({Color? color}) =>
      bodySm(color: color, weight: DsFontWeight.semiBold);

  static TextStyle bodyXs({
    Color? color,
    FontWeight weight = DsFontWeight.regular,
  }) =>
      DsTypography.sans(
        DsFontSize.bodyXs,
        color: color,
        weight: weight,
        height: _leading(DsFontSize.bodyXsLeading, DsFontSize.bodyXs),
      );
}
