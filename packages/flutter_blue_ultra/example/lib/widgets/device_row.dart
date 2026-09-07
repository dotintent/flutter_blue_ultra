import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class DeviceRow extends StatelessWidget {
  const DeviceRow({super.key, required this.result, required this.onTap});

  final ScanResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final name = result.device.platformName;
    final hasName = name.isNotEmpty;
    final serviceCount = result.advertisementData.serviceUuids.length;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: DsSpace.s16),
          child: Row(
            children: [
              DsAvatar(
                size: 40,
                borderColor: colors.borderHi,
                child: DsBluetoothGlyph(
                  size: DsSize.iconSmall,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(width: DsSpace.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? name : '(unnamed)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DsTextStyles.headingSm(
                        color: colors.textPrimary,
                        fontStyle: hasName ? null : FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: DsSpace.s2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            result.device.remoteId.str,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DsTextStyles.monoMd(color: colors.textDim),
                          ),
                        ),
                        if (serviceCount > 0) ...[
                          const SizedBox(width: DsSpace.s8),
                          Text(
                            '· $serviceCount SVC',
                            style: DsTextStyles.monoMd(color: colors.textDim),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DsSpace.s16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DsSignalBars.rssi(
                    rssi: result.rssi,
                    activeColor: colors.textDim,
                    inactiveColor: colors.border,
                  ),
                  const SizedBox(height: DsSpace.s4),
                  Text(
                    '${result.rssi} dBm',
                    style: DsTextStyles.monoCaption(color: colors.textFaint),
                  ),
                ],
              ),
              const SizedBox(width: DsSpace.s16),
              Icon(
                Icons.chevron_right,
                size: DsSize.iconSmall,
                color: colors.textFaint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
