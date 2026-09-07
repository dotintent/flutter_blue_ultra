import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';

class DsAvatar extends StatelessWidget {
  const DsAvatar({
    super.key,
    required this.child,
    this.size,
    this.backgroundColor,
    this.borderColor,
    this.filled = false,
  });

  final Widget child;
  final double? size;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final dimensions = DsDimensions.of(context);
    final dimension = size ?? dimensions.avatarSize;

    return Container(
      width: dimension,
      height: dimension,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? (filled ? colors.accent : Colors.transparent),
        shape: BoxShape.circle,
        border: filled && borderColor == null
            ? null
            : Border.all(
                color: borderColor ?? colors.borderHi,
                width: dimensions.borderWidth,
              ),
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          color: filled ? colors.onAccent : colors.textPrimary,
          size: dimensions.iconLarge,
        ),
        child: child,
      ),
    );
  }
}
