import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../theme/ds_text_styles.dart';

class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.label,
    this.count,
    this.trailing,
    this.trailingLabel,
    this.padding,
    this.labelStyle,
    this.showRule = true,
    this.uppercase = true,
  });

  final String label;
  final int? count;
  final Widget? trailing;
  final String? trailingLabel;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final bool showRule;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final dimensions = DsDimensions.of(context);
    final count = this.count;
    final trailingLabel = this.trailingLabel;
    final resolved = uppercase ? label.toUpperCase() : label;
    final text = count == null ? resolved : '$resolved · $count';

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Text(
            text,
            style: labelStyle ?? DsTextStyles.monoLabel(color: colors.textDim),
          ),
          if (showRule) ...[
            SizedBox(width: dimensions.spaceMd),
            Expanded(
              child: Container(
                height: dimensions.borderWidth,
                color: colors.border,
              ),
            ),
            SizedBox(width: dimensions.spaceMd),
          ] else
            const Spacer(),
          if (trailingLabel != null)
            Text(
              trailingLabel.toUpperCase(),
              style: DsTextStyles.monoLabel(color: colors.textFaint),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
