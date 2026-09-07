import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';

class DsListRow extends StatelessWidget {
  const DsListRow({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.showDivider = true,
    this.selected = false,
    this.contentPadding,
    this.minTileHeight,
    this.horizontalTitleGap,
    this.dividerColor,
    this.tileColor,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDivider;
  final bool selected;
  final EdgeInsetsGeometry? contentPadding;
  final double? minTileHeight;
  final double? horizontalTitleGap;
  final Color? dividerColor;
  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final dimensions = DsDimensions.of(context);

    final tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      tileColor: tileColor,
      minTileHeight: minTileHeight,
      horizontalTitleGap: horizontalTitleGap,
      contentPadding: contentPadding ??
          EdgeInsets.symmetric(
            horizontal: dimensions.screenPadding,
            vertical: dimensions.spaceSm,
          ),
    );

    if (!showDivider) return tile;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor ?? colors.border,
            width: dimensions.borderWidth,
          ),
        ),
      ),
      child: tile,
    );
  }
}
