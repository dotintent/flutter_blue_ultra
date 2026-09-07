import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../models/gatt_names.dart';

class ServiceRow extends StatelessWidget {
  const ServiceRow({
    super.key,
    required this.service,
    required this.expanded,
    required this.onToggle,
  });

  final BluetoothService service;
  final bool expanded;
  final VoidCallback onToggle;

  String get _displayName =>
      kGattServiceNames[shortUuid(service.serviceUuid.str)] ?? 'Custom service';

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final count = service.characteristics.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpace.s8),
          child: Row(
            children: [
              DsAvatar(
                size: 32,
                borderColor: colors.borderHi,
                child: Text(
                  'S',
                  style: DsTextStyles.monoLabel(color: colors.textPrimary),
                ),
              ),
              const SizedBox(width: DsSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DsTextStyles.headingSm(color: colors.textPrimary),
                    ),
                    const SizedBox(height: DsSpace.s2),
                    Row(
                      children: [
                        Text(
                          DsUuidText.format(
                            service.serviceUuid.str,
                            short: true,
                          ),
                          style: DsTextStyles.monoMd(color: colors.textDim),
                        ),
                        const SizedBox(width: DsSpace.s8),
                        Text(
                          '· $count char',
                          style: DsTextStyles.monoMd(color: colors.textFaint),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DsSpace.s16),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: DsSize.iconSmall,
                color: colors.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacteristicRow extends StatelessWidget {
  const CharacteristicRow({
    super.key,
    required this.characteristic,
    required this.onTap,
  });

  final BluetoothCharacteristic characteristic;
  final VoidCallback onTap;

  String get _displayName =>
      kGattCharacteristicNames[
          shortUuid(characteristic.characteristicUuid.str)] ??
      'Custom characteristic';

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final props = characteristic.properties;

    return Padding(
      padding: const EdgeInsets.only(left: DsSpace.s40),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: colors.border),
            bottom: BorderSide(color: colors.border),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DsSpace.s12,
              DsSpace.s8,
              0,
              DsSpace.s8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            DsTextStyles.headingSm(color: colors.textPrimary),
                      ),
                      const SizedBox(height: DsSpace.s2),
                      Text(
                        DsUuidText.format(
                          characteristic.characteristicUuid.str,
                          short: true,
                        ),
                        style: DsTextStyles.monoMd(color: colors.textDim),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DsSpace.s8),
                if (props.read) const PropertyChip(label: 'R'),
                if (props.write || props.writeWithoutResponse) ...[
                  const SizedBox(width: DsSpace.s4),
                  const PropertyChip(label: 'W'),
                ],
                if (props.notify || props.indicate) ...[
                  const SizedBox(width: DsSpace.s4),
                  PropertyChip(label: props.notify ? 'N' : 'I'),
                ],
                const SizedBox(width: DsSpace.s4),
                Icon(
                  Icons.chevron_right,
                  size: DsSize.iconSmall,
                  color: colors.textFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyChip extends StatelessWidget {
  const PropertyChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DsChip(
      label: label,
      backgroundColor: colors.surfaceAlt,
      side: BorderSide(color: colors.borderHi),
      padding: const EdgeInsets.symmetric(
        horizontal: DsSpace.s8,
        vertical: DsSpace.s2,
      ),
      labelStyle: DsTextStyles.monoLabel(color: colors.textPrimary),
    );
  }
}
