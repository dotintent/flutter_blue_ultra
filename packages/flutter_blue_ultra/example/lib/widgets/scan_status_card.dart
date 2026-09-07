import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

enum ScanStatusPhase { scanning, idle, adapterOff }

class ScanStatusCard extends StatelessWidget {
  const ScanStatusCard({
    super.key,
    required this.phase,
    required this.deviceCount,
    required this.onPrimaryAction,
  });

  final ScanStatusPhase phase;
  final int deviceCount;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final adapterOff = phase == ScanStatusPhase.adapterOff;

    final tone = switch (phase) {
      ScanStatusPhase.scanning => colors.accent,
      ScanStatusPhase.idle => colors.textFaint,
      ScanStatusPhase.adapterOff => colors.warn,
    };

    final label = switch (phase) {
      ScanStatusPhase.scanning => 'SCAN.IN_PROGRESS',
      ScanStatusPhase.idle => 'SCAN.IDLE',
      ScanStatusPhase.adapterOff => 'ADAPTER.OFF',
    };

    final content = Row(
      children: [
        DsStatusRing(
          tone: tone,
          spinning: phase == ScanStatusPhase.scanning,
          child: adapterOff
              ? Icon(
                  Icons.bluetooth_disabled,
                  size: DsSize.iconXXLarge,
                  color: colors.textPrimary,
                )
              : DsBluetoothGlyph(
                  size: DsSize.iconXXLarge,
                  color: colors.textPrimary,
                ),
        ),
        const SizedBox(width: DsSpace.s16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: DsTextStyles.monoLabelLoud(color: tone)),
              const SizedBox(height: DsSpace.s4),
              if (adapterOff)
                Text(
                  'Turn it on to scan.',
                  style: DsTextStyles.bodyXs(color: colors.textDim),
                )
              else
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: DsTextStyles.monoValue(color: colors.textPrimary),
                    children: [
                      TextSpan(text: '$deviceCount'),
                      TextSpan(
                        text: deviceCount == 1
                            ? ' device found'
                            : ' devices found',
                        style: DsTextStyles.bodyXs(color: colors.textDim),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );

    return DsCard(
      padding: const EdgeInsets.all(DsSpace.s16),
      child: adapterOff
          ? Column(
              children: [
                content,
                const SizedBox(height: DsSpace.s16),
                DsButton(label: 'Open Settings', onPressed: onPrimaryAction),
              ],
            )
          : Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: DsSpace.s16),
                _ActionButton(
                  scanning: phase == ScanStatusPhase.scanning,
                  onPressed: onPrimaryAction,
                ),
              ],
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.scanning, required this.onPressed});

  final bool scanning;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DsIconButton(
      onPressed: onPressed,
      variant: DsIconButtonVariant.filled,
      size: DsSize.controlMedium,
      tooltip: scanning ? 'Stop scan' : 'Rescan',
      style: IconButton.styleFrom(
        backgroundColor: scanning ? colors.textPrimary : colors.brandFill,
        foregroundColor: scanning ? colors.background : colors.onAccent,
      ),
      child: Icon(
        scanning ? Icons.stop_rounded : Icons.refresh,
        size: DsSize.iconXXLarge,
      ),
    );
  }
}
