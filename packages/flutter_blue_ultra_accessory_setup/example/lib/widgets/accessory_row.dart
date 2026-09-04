import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class AccessoryRow extends StatelessWidget {
  const AccessoryRow({
    super.key,
    required this.accessory,
    required this.onRemove,
  });

  final Accessory accessory;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    final (tone, stateLabel) = switch (accessory.state) {
      AccessoryState.authorized => (colors.success, 'AUTHORIZED'),
      AccessoryState.awaitingAuthorization => (colors.warn, 'AWAITING AUTH'),
      AccessoryState.unauthorized => (colors.destructive, 'UNAUTHORIZED'),
    };

    final title = accessory.displayName.isNotEmpty
        ? accessory.displayName
        : (accessory.bluetoothIdentifier ?? 'Unknown accessory');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpace.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(DsRadius.small),
              border: Border.all(color: colors.border),
            ),
            child: DsBluetoothGlyph(
              size: DsSize.iconSmall,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(width: DsSpace.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DsTextStyles.headingSm(color: colors.textPrimary),
                ),
                const SizedBox(height: DsSpace.s2),
                DsChip(
                  label: stateLabel,
                  backgroundColor: tone.withValues(alpha: 0.12),
                  side: BorderSide(color: tone),
                  padding: const EdgeInsets.symmetric(
                    horizontal: DsSpace.s8,
                    vertical: DsSpace.s2,
                  ),
                  labelStyle: DsTextStyles.monoCaption(color: tone),
                ),
              ],
            ),
          ),
          const SizedBox(width: DsSpace.s12),
          Tooltip(
            message: 'Remove accessory',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              // The design draws a bare 20 px glyph flush to the top-right.
              // Keep it there, but claim a 44 px box so the tap target is
              // usable.
              child: SizedBox(
                width: DsSize.controlMedium,
                height: DsSize.controlMedium,
                child: Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.close,
                    size: DsSize.iconLarge,
                    color: colors.destructive,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
