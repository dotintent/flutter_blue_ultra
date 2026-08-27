import 'package:flutter/material.dart';

import '../theme/ds_colors.dart';
import '../theme/ds_dimensions.dart';
import '../theme/ds_typography.dart';
import 'ds_brand_mark.dart';

class DsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DsAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.trailing,
    this.brand = false,
    this.showDivider = true,
    this.backgroundColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.height,
    this.titleWidget,
  });

  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? trailing;
  final bool brand;
  final bool showDivider;
  final Color? backgroundColor;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final double? height;
  final Widget? titleWidget;

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final typography = DsTypography.of(context);
    final dimensions = DsDimensions.of(context);
    final subtitle = this.subtitle;
    final leading = this.leading;
    final trailing = this.trailing;
    final resolvedActions =
        trailing == null ? actions : <Widget>[...actions, trailing];

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? colors.background,
      toolbarHeight: preferredSize.height,
      titleSpacing: leading == null ? dimensions.screenPadding : dimensions.spaceSm,
      leading: leading == null
          ? null
          : Padding(
              padding: EdgeInsets.only(left: dimensions.spaceLg),
              child: Center(child: leading),
            ),
      leadingWidth: leading == null
          ? null
          : dimensions.spaceLg + dimensions.controlSmall + dimensions.spaceSm,
      shape: showDivider
          ? Border(
              bottom: BorderSide(
                color: colors.border,
                width: dimensions.borderWidth,
              ),
            )
          : null,
      title: titleWidget ??
          (brand
              ? const DsBrandMark()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? '',
                      style: titleTextStyle ??
                          typography.titleMedium
                              .copyWith(color: colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: dimensions.spaceXxs),
                      Text(
                        subtitle,
                        style: subtitleTextStyle ??
                            typography.monoSmall
                                .copyWith(color: colors.textDim),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                )),
      actions: resolvedActions.isEmpty
          ? null
          : [
              ...resolvedActions,
              SizedBox(width: dimensions.spaceLg),
            ],
    );
  }
}
