import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../theme/ds_typography.dart';

class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.label,
    this.count,
    this.trailing,
    this.padding,
    this.labelStyle,
    this.countStyle,
    this.showRule = true,
    this.uppercase = true,
  });

  final String label;
  final int? count;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final TextStyle? countStyle;
  final bool showRule;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final typography = DsTypography.of(context);
    final dimensions = DsDimensions.of(context);
    final count = this.count;
    final trailing = this.trailing;

    return Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
            dimensions.screenPadding,
            dimensions.spaceXl,
            dimensions.screenPadding,
            dimensions.spaceMd,
          ),
      child: Row(
        children: [
          Text(
            uppercase ? label.toUpperCase() : label,
            style: labelStyle ??
                typography.labelSmall.copyWith(color: colors.textFaint),
          ),
          if (count != null) ...[
            SizedBox(width: dimensions.spaceSm),
            Text(
              '· $count',
              style: countStyle ??
                  typography.labelSmall.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
            ),
          ],
          if (showRule) ...[
            SizedBox(width: dimensions.spaceMd),
            Expanded(
              child: Container(
                height: dimensions.borderWidth,
                color: colors.border,
              ),
            ),
          ] else
            const Spacer(),
          if (trailing != null) ...[
            SizedBox(width: dimensions.spaceSm),
            trailing,
          ],
        ],
      ),
    );
  }
}
