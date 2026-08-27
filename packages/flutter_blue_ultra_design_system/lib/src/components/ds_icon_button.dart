import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';

enum DsIconButtonVariant { outlined, filled, plain }

class DsIconButton extends StatelessWidget {
  const DsIconButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = DsIconButtonVariant.outlined,
    this.size,
    this.tooltip,
    this.style,
  });

  DsIconButton.icon({
    super.key,
    required IconData icon,
    this.onPressed,
    this.variant = DsIconButtonVariant.outlined,
    this.size,
    this.tooltip,
    this.style,
    double? iconSize,
  }) : child = Icon(icon, size: iconSize);

  final Widget child;
  final VoidCallback? onPressed;
  final DsIconButtonVariant variant;
  final double? size;
  final String? tooltip;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final dimensions = DsDimensions.of(context);
    final dimension = size ?? dimensions.controlSmall;

    final variantStyle = switch (variant) {
      DsIconButtonVariant.filled => IconButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          disabledBackgroundColor: colors.surfaceHi,
          disabledForegroundColor: colors.textFaint,
        ),
      DsIconButtonVariant.outlined => IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textFaint,
          side: BorderSide(color: colors.border, width: dimensions.borderWidth),
        ),
      DsIconButtonVariant.plain => IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: colors.textPrimary,
          disabledForegroundColor: colors.textFaint,
        ),
    };

    final sizing = IconButton.styleFrom(
      minimumSize: Size.square(dimension),
      fixedSize: Size.square(dimension),
      padding: EdgeInsets.zero,
      shape: const CircleBorder(),
    );

    final resolved =
        style?.merge(sizing).merge(variantStyle) ??
            sizing.merge(variantStyle);

    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: resolved,
      icon: child,
    );
  }
}
