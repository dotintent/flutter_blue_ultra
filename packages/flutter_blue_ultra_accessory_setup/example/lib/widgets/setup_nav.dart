import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class SetupNav extends StatelessWidget {
  const SetupNav({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final trailing = this.trailing;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.headingSm(color: colors.textPrimary),
                  ),
                  const SizedBox(height: DsSpace.s2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DsTextStyles.monoMd(color: colors.textDim),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: DsSpace.s12),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}

class SetupNavButton extends StatelessWidget {
  const SetupNavButton({
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
