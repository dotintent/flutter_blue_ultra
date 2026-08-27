import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_typography.dart';

class DsBrandMark extends StatelessWidget {
  const DsBrandMark({
    super.key,
    this.label = 'intent',
    this.height = 18,
    this.color,
    this.dotColor,
    this.dotRatio = 0.3,
    this.gap = 5,
    this.textStyle,
  });

  final String label;
  final double height;
  final Color? color;
  final Color? dotColor;
  final double dotRatio;
  final double gap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final typography = DsTypography.of(context);
    final dotSize = height * dotRatio;

    return SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: dotColor ?? colors.accent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: gap),
          Text(
            label,
            style: (textStyle ?? typography.brand).copyWith(
              fontSize: textStyle?.fontSize ?? height,
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
