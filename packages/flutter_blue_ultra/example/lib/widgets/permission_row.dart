import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class PermissionRow extends StatelessWidget {
  const PermissionRow({
    super.key,
    required this.index,
    required this.label,
    required this.description,
    this.denied = false,
  });

  final int index;
  final String label;
  final String description;
  final bool denied;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DsSpace.s16),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    index.toString().padLeft(2, '0'),
                    style: DsTextStyles.monoMd(color: colors.textFaint),
                  ),
                  const SizedBox(width: DsSpace.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: DsTextStyles.monoLabel(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: DsSpace.s2),
                        Text(
                          description,
                          style: DsTextStyles.bodySm(color: colors.textDim),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (denied) ...[
              const SizedBox(width: DsSpace.s16),
              Icon(
                Icons.cancel,
                size: DsSize.iconLarge,
                color: colors.destructive,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
