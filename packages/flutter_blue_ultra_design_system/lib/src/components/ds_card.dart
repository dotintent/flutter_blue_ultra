import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';

class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.shape,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final dimensions = DsDimensions.of(context);
    final radius = borderRadius ?? dimensions.cardRadius;

    final resolvedShape = shape ??
        RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: borderColor ?? colors.border,
            width: dimensions.borderWidth,
          ),
        );

    final content = Padding(
      padding: padding ?? EdgeInsets.all(dimensions.spaceLg),
      child: child,
    );

    return Card(
      color: color ?? colors.surface,
      margin: margin,
      shape: resolvedShape,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: radius,
              child: content,
            ),
    );
  }
}
