import 'package:flutter/material.dart';

import '../theme/ds_dimensions.dart';
import '../theme/ds_typography.dart';

enum DsButtonVariant { filled, outlined, text }

enum DsButtonSize { small, medium, large }

class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = DsButtonVariant.filled,
    this.size = DsButtonSize.large,
    this.expand = true,
    this.loading = false,
    this.style,
    this.focusNode,
    this.autofocus = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final DsButtonVariant variant;
  final DsButtonSize size;
  final bool expand;
  final bool loading;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;

  double _height(DsDimensions dimensions) => switch (size) {
        DsButtonSize.small => dimensions.controlSmall,
        DsButtonSize.medium => dimensions.controlMedium,
        DsButtonSize.large => dimensions.controlLarge,
      };

  TextStyle _textStyle(DsTypography typography) => switch (size) {
        DsButtonSize.small => typography.bodySmall.copyWith(
            fontWeight: typography.button.fontWeight,
          ),
        DsButtonSize.medium => typography.bodyMedium.copyWith(
            fontWeight: typography.button.fontWeight,
          ),
        DsButtonSize.large => typography.button,
      };

  double _iconSize(DsDimensions dimensions) => switch (size) {
        DsButtonSize.small => dimensions.iconSmall,
        DsButtonSize.medium => dimensions.iconSmall,
        DsButtonSize.large => dimensions.iconMedium,
      };

  @override
  Widget build(BuildContext context) {
    final dimensions = DsDimensions.of(context);
    final typography = DsTypography.of(context);
    final iconSize = _iconSize(dimensions);

    final sizing = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(_height(dimensions))),
      textStyle: WidgetStatePropertyAll(_textStyle(typography)),
      iconSize: WidgetStatePropertyAll(iconSize),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: size == DsButtonSize.small
              ? dimensions.spaceLg
              : dimensions.spaceXxl,
        ),
      ),
    );

    final resolvedStyle = style?.merge(sizing) ?? sizing;
    final callback = loading ? null : onPressed;
    final iconData = icon;

    final Widget? leading = loading
        ? SizedBox.square(
            dimension: iconSize,
            child: Builder(
              builder: (context) => CircularProgressIndicator(
                strokeWidth: 2,
                color: IconTheme.of(context).color,
              ),
            ),
          )
        : (iconData == null ? null : Icon(iconData));

    final Widget button = switch ((variant, leading)) {
      (DsButtonVariant.filled, null) => FilledButton(
          onPressed: callback,
          style: resolvedStyle,
          focusNode: focusNode,
          autofocus: autofocus,
          child: Text(label),
        ),
      (DsButtonVariant.filled, final Widget glyph) => FilledButton.icon(
          onPressed: callback,
          style: resolvedStyle,
          focusNode: focusNode,
          autofocus: autofocus,
          icon: glyph,
          label: Text(label),
        ),
      (DsButtonVariant.outlined, null) => OutlinedButton(
          onPressed: callback,
          style: resolvedStyle,
          focusNode: focusNode,
          autofocus: autofocus,
          child: Text(label),
        ),
      (DsButtonVariant.outlined, final Widget glyph) => OutlinedButton.icon(
          onPressed: callback,
          style: resolvedStyle,
          focusNode: focusNode,
          autofocus: autofocus,
          icon: glyph,
          label: Text(label),
        ),
      (DsButtonVariant.text, null) => TextButton(
          onPressed: callback,
          style: resolvedStyle,
          focusNode: focusNode,
          autofocus: autofocus,
          child: Text(label),
        ),
      (DsButtonVariant.text, final Widget glyph) => TextButton.icon(
          onPressed: callback,
          style: resolvedStyle,
          focusNode: focusNode,
          autofocus: autofocus,
          icon: glyph,
          label: Text(label),
        ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
