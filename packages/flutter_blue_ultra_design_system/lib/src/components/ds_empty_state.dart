import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../theme/ds_text_styles.dart';
import '../tokens/dimension_tokens.dart';

class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    this.icon,
    this.iconWidget,
    this.description,
    this.action,
    this.padding,
    this.iconSize = DsSize.iconXXLarge,
    this.titleStyle,
    this.iconColor,
  });

  final String title;
  final IconData? icon;
  final Widget? iconWidget;
  final String? description;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final double iconSize;
  final TextStyle? titleStyle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final dimensions = DsDimensions.of(context);
    final icon = this.icon;
    final iconWidget = this.iconWidget;
    final description = this.description;
    final action = this.action;

    return Padding(
      padding: padding ?? EdgeInsets.all(dimensions.spaceXxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconWidget != null) ...[
            iconWidget,
            SizedBox(height: dimensions.spaceMd),
          ] else if (icon != null) ...[
            Icon(icon, color: iconColor ?? colors.textDim, size: iconSize),
            SizedBox(height: dimensions.spaceMd),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle ?? DsTextStyles.monoMd(color: colors.textPrimary),
          ),
          if (description != null) ...[
            SizedBox(height: dimensions.spaceXs),
            Text(
              description,
              textAlign: TextAlign.center,
              style: DsTextStyles.monoCaption(color: colors.textDim),
            ),
          ],
          if (action != null) ...[
            SizedBox(height: dimensions.spaceXl),
            action,
          ],
        ],
      ),
    );
  }
}
