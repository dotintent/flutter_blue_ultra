import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';

import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../cubits/accessory_setup_cubit.dart';

class AccessoryStatusPanel extends StatelessWidget {
  const AccessoryStatusPanel({super.key, required this.state});

  final AccessorySetupState state;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    final color = state.initError != null
        ? it.accent
        : state.isActivated
            ? it.success
            : it.warn;
    final status = state.initError != null
        ? 'SetupKit unavailable'
        : state.isActivated
            ? 'Session activated'
            : 'Activating session';

    return Container(
      decoration: BoxDecoration(
        color: it.surface,
        border: Border.all(color: it.border),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.45)),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.bluetooth, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.initError != null
                      ? 'SETUP.ERROR'
                      : state.isActivated
                          ? 'SESSION.READY'
                          : 'SESSION.STARTING',
                  style: DsTypography.monoLabel(10, color: it.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: DsTypography.serif(20, color: it.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.connectedId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.connectedId!,
                    style: DsTypography.monoStyle(10.5, color: it.textDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          DsChip(
            label: state.accessories.length.toString().padLeft(2, '0'),
            variant: state.accessories.isEmpty
                ? DsChipVariant.muted
                : DsChipVariant.neutral,
            size: DsChipSize.medium,
          ),
        ],
      ),
    );
  }
}

class AccessoryTile extends StatelessWidget {
  const AccessoryTile({
    super.key,
    required this.accessory,
    required this.onRemove,
  });

  final Accessory accessory;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    final authorized = accessory.state == AccessoryState.authorized;
    final id = accessory.bluetoothIdentifier;

    return DsListRow(
      minTileHeight: 76,
      contentPadding: const EdgeInsets.symmetric(horizontal: DsSpace.s20),
      leading: DsAvatar(
        child: Icon(
          Icons.bluetooth,
          color: authorized ? it.success : it.warn,
        ),
      ),
      title: Text(
        id ?? 'No Bluetooth ID',
        style: DsTypography.serif(16, color: it.textPrimary),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: DsSpace.s4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: DsChip(
            label: authorized ? 'AUTHORIZED' : 'AWAITING',
            variant:
                authorized ? DsChipVariant.neutral : DsChipVariant.notify,
          ),
        ),
      ),
      trailing: DsIconButton(
        onPressed: onRemove,
        tooltip: 'Remove accessory',
        child: Icon(
          Icons.close,
          color: it.accent,
          size: DsSize.iconMedium,
        ),
      ),
    );
  }
}

class EventLogList extends StatelessWidget {
  const EventLogList({super.key, required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    if (entries.isEmpty) {
      return const DsEmptyState(
        icon: Icons.notes,
        title: 'No events yet.',
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: it.surface,
          border: Border.all(color: it.border),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in entries)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: it.border)),
                ),
                child: Text(
                  entry,
                  style: DsTypography.monoStyle(10.5, color: it.textDim),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AccessoryPickerButton extends StatelessWidget {
  const AccessoryPickerButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DsButton(
      label: loading ? 'Opening picker' : 'Show picker',
      icon: Icons.add_circle_outline,
      loading: loading,
      onPressed: enabled ? onPressed : null,
    );
  }
}
