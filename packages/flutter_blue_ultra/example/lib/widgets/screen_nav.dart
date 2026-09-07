import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class ScreenNav extends StatelessWidget {
  const ScreenNav({super.key, this.onBack, this.actions = const <Widget>[]});

  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpace.s20,
          vertical: DsSpace.s16,
        ),
        child: Row(
          children: [
            NavCircleButton(
              icon: Icons.arrow_back,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            for (final action in actions) ...[
              const SizedBox(width: DsSpace.s8),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

class NavCircleButton extends StatelessWidget {
  const NavCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DsIconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      size: DsSize.controlMedium,
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        side: BorderSide(color: colors.borderHi),
      ),
      child: Icon(icon, size: DsSize.iconLarge),
    );
  }
}

class NavPillButton extends StatelessWidget {
  const NavPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.tone,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final color = tone ?? colors.destructive;

    return DsButton(
      label: label,
      variant: DsButtonVariant.outlined,
      size: DsButtonSize.small,
      expand: false,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: colors.textFaint,
        side: BorderSide(color: onPressed == null ? colors.border : color),
        textStyle: DsTextStyles.bodySmBold(),
        padding: const EdgeInsets.symmetric(horizontal: DsSpace.s16),
        minimumSize: const Size(0, 36),
      ),
    );
  }
}
