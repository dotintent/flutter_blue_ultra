import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../theme/ds_typography.dart';

enum DsChipVariant { neutral, notify, muted, accent }

enum DsChipSize { small, medium }

class DsChip extends StatelessWidget {
  const DsChip({
    super.key,
    required this.label,
    this.variant = DsChipVariant.neutral,
    this.size = DsChipSize.small,
    this.onPressed,
    this.avatar,
    this.backgroundColor,
    this.foregroundColor,
    this.side,
    this.labelStyle,
    this.padding,
    this.labelPadding,
    this.avatarBoxConstraints,
    this.shape,
  });

  final String label;
  final DsChipVariant variant;
  final DsChipSize size;
  final VoidCallback? onPressed;
  final Widget? avatar;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderSide? side;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? labelPadding;
  final BoxConstraints? avatarBoxConstraints;
  final OutlinedBorder? shape;

  ({Color background, Color foreground, bool bordered}) _palette(
    DsColors colors,
  ) =>
      switch (variant) {
        DsChipVariant.notify => (
            background: colors.accentSoft,
            foreground: colors.accent,
            bordered: true,
          ),
        DsChipVariant.muted => (
            background: colors.surfaceAlt,
            foreground: colors.textDim,
            bordered: true,
          ),
        DsChipVariant.accent => (
            background: colors.accent,
            foreground: colors.onAccent,
            bordered: false,
          ),
        DsChipVariant.neutral => (
            background: colors.chipBg,
            foreground: colors.textPrimary,
            bordered: true,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final typography = DsTypography.of(context);
    final dimensions = DsDimensions.of(context);
    final palette = _palette(colors);
    final isSmall = size == DsChipSize.small;

    final resolvedLabelStyle = labelStyle ??
        (isSmall ? typography.monoSmall : typography.mono).copyWith(
          color: foregroundColor ?? palette.foreground,
          fontSize: isSmall ? 10 : 11,
        );

    return RawChip(
      label: Text(label),
      avatar: avatar,
      onPressed: onPressed,
      color: WidgetStatePropertyAll(backgroundColor ?? palette.background),
      labelStyle: resolvedLabelStyle,
      side: side ??
          (palette.bordered
              ? BorderSide(color: colors.border, width: dimensions.borderWidth)
              : BorderSide.none),
      shape: shape ?? const StadiumBorder(),
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: isSmall ? dimensions.spaceSm : 10,
            vertical: isSmall ? dimensions.spaceXxs : dimensions.spaceXs,
          ),
      labelPadding: labelPadding ??
          EdgeInsets.only(left: avatar == null ? 0 : dimensions.spaceMd),
      avatarBoxConstraints: avatarBoxConstraints ??
          (avatar == null ? null : const BoxConstraints.tightFor()),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      showCheckmark: false,
      elevation: 0,
      pressElevation: 0,
    );
  }
}
