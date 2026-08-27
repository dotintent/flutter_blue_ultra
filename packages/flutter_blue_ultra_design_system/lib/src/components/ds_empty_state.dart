import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../theme/ds_typography.dart';

class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.iconWidget,
    this.description,
    this.action,
    this.padding,
    this.iconSize = 26,
    this.titleStyle,
  });

  final String title;
  final IconData? icon;
  final Widget? iconWidget;
  final String? description;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final double iconSize;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final typography = DsTypography.of(context);
    final dimensions = DsDimensions.of(context);
    final icon = this.icon;
    final description = this.description;
    final action = this.action;

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            dimensions.screenPadding,
            dimensions.spaceXxl,
            dimensions.screenPadding,
            dimensions.spaceXxl,
          ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) ...[
              iconWidget!,
              SizedBox(height: dimensions.spaceMd),
            ] else if (icon != null) ...[
              Icon(icon, color: colors.textFaint, size: iconSize),
              SizedBox(height: dimensions.spaceMd),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ??
                  typography.bodySmall.copyWith(color: colors.textDim),
            ),
            if (description != null) ...[
              SizedBox(height: dimensions.spaceSm),
              Text(
                description,
                textAlign: TextAlign.center,
                style: typography.bodySmall.copyWith(color: colors.textFaint),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: dimensions.spaceLg),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
