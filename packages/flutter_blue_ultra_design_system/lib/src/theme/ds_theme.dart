import 'package:flutter/material.dart';

import '../tokens/dimension_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'ds_colors.dart';
import 'ds_dimensions.dart';
import 'ds_typography.dart';

class DsTheme {
  const DsTheme._();

  static ThemeData dark({
    DsColors? colors,
    DsTypography? typography,
    DsDimensions? dimensions,
  }) =>
      build(
        colors: colors ?? DsColors.dark,
        typography: typography ?? DsTypography.standard,
        dimensions: dimensions ?? DsDimensions.standard,
      );

  static ThemeData light({
    DsColors? colors,
    DsTypography? typography,
    DsDimensions? dimensions,
  }) =>
      build(
        colors: colors ?? DsColors.light,
        typography: typography ?? DsTypography.standard,
        dimensions: dimensions ?? DsDimensions.standard,
      );

  static ThemeData build({
    required DsColors colors,
    required DsTypography typography,
    required DsDimensions dimensions,
  }) {
    final textTheme =
        typography.toTextTheme(colors.textPrimary, colors.textDim);
    final pill = RoundedRectangleBorder(borderRadius: dimensions.pillRadius);

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors.toColorScheme(),
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      extensions: <ThemeExtension<dynamic>>[colors, typography, dimensions],
      iconTheme: IconThemeData(
        color: colors.textPrimary,
        size: dimensions.iconMedium,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: dimensions.appBarHeight,
        titleSpacing: 0,
        titleTextStyle: typography.titleMedium.copyWith(
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: colors.textPrimary,
          size: dimensions.iconMedium,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        space: 0,
        thickness: dimensions.borderWidth,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: dimensions.cardRadius,
          side: BorderSide(
            color: colors.border,
            width: dimensions.borderWidth,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimensions.screenPadding,
          vertical: dimensions.spaceSm,
        ),
        minVerticalPadding: dimensions.spaceSm,
        horizontalTitleGap: DsSpace.s14,
        iconColor: colors.textDim,
        textColor: colors.textPrimary,
        titleTextStyle: typography.titleSmall.copyWith(
          color: colors.textPrimary,
        ),
        subtitleTextStyle: typography.monoSmall.copyWith(color: colors.textDim),
        tileColor: Colors.transparent,
        selectedTileColor: colors.accentSoft,
        selectedColor: colors.accent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.chipBg,
        selectedColor: colors.accent,
        secondarySelectedColor: colors.accentSoft,
        disabledColor: colors.surfaceAlt,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.spaceSm,
          vertical: dimensions.spaceXxs,
        ),
        labelPadding: EdgeInsets.zero,
        labelStyle: typography.labelSmall.copyWith(
          color: colors.textPrimary,
          fontWeight: DsFontWeight.regular,
          letterSpacing: DsTracking.chip,
        ),
        secondaryLabelStyle: typography.labelSmall.copyWith(
          color: colors.accent,
          fontWeight: DsFontWeight.regular,
          letterSpacing: DsTracking.chip,
        ),
        side: BorderSide(color: colors.border, width: dimensions.borderWidth),
        shape: const StadiumBorder(),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.brandFill,
          foregroundColor: colors.onAccent,
          disabledBackgroundColor: colors.surfaceHi,
          disabledForegroundColor: colors.textFaint,
          minimumSize: Size.fromHeight(dimensions.controlLarge),
          padding: EdgeInsets.symmetric(horizontal: dimensions.spaceXxl),
          textStyle: typography.button,
          shape: pill,
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textFaint,
          minimumSize: Size.fromHeight(dimensions.controlLarge),
          padding: EdgeInsets.symmetric(horizontal: dimensions.spaceXxl),
          textStyle: typography.button,
          side: BorderSide(
            color: colors.borderHi,
            width: dimensions.borderWidth,
          ),
          shape: pill,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          disabledForegroundColor: colors.textFaint,
          textStyle: typography.button,
          shape: pill,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textFaint,
          highlightColor: colors.accentSoft,
          minimumSize: Size.square(dimensions.controlSmall),
          fixedSize: Size.square(dimensions.controlSmall),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.surfaceHi,
        circularTrackColor: Colors.transparent,
        strokeWidth: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surfaceAlt,
        contentTextStyle: typography.bodySmall.copyWith(
          color: colors.textPrimary,
        ),
        actionTextColor: colors.accent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimensions.radiusMedium),
          side: BorderSide(color: colors.border, width: dimensions.borderWidth),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        hintStyle: typography.mono.copyWith(color: colors.textFaint),
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimensions.spaceMd,
          vertical: dimensions.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radiusSmall),
          borderSide: BorderSide(
            color: colors.border,
            width: dimensions.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radiusSmall),
          borderSide: BorderSide(
            color: colors.border,
            width: dimensions.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radiusSmall),
          borderSide: BorderSide(
            color: colors.accent,
            width: dimensions.borderWidth,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(dimensions.radiusLarge),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.surfaceHi,
          borderRadius: BorderRadius.circular(dimensions.radiusSmall),
        ),
        textStyle: typography.monoSmall.copyWith(color: colors.textPrimary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onAccent
              : colors.textDim,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.accent
              : colors.surfaceHi,
        ),
        trackOutlineColor: WidgetStateProperty.all(colors.border),
      ),
    );
  }
}
