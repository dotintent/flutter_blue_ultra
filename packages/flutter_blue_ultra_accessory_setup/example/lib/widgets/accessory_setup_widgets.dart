import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';

import '../cubits/accessory_setup_cubit.dart';
import '../theme/app_theme.dart';
import 'atoms.dart';

class AccessoryStatusPanel extends StatelessWidget {
  const AccessoryStatusPanel({super.key, required this.state});

  final AccessorySetupState state;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final color = state.initError != null
        ? it.accent
        : state.authorizingId != null
            ? it.warn
            : state.isActivated
                ? it.success
                : it.warn;
    final status = state.initError != null
        ? 'SetupKit unavailable'
        : state.authorizingId != null
            ? 'Checking pairing'
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
                      : state.authorizingId != null
                          ? 'PAIRING.CHECK'
                          : state.isActivated
                              ? 'SESSION.READY'
                              : 'SESSION.STARTING',
                  style: IntentTextStyles.monoLabel(10, it.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: IntentTextStyles.serifTitle(20, it.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (state.authorizingId != null ||
                    state.connectedId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.authorizingId ?? state.connectedId!,
                    style: IntentTextStyles.mono(10.5, it.textDim),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IntentChip(
            label:
                state.authorizedAccessories.length.toString().padLeft(2, '0'),
            kind: state.authorizedAccessories.isEmpty
                ? ChipKind.muted
                : ChipKind.defaultKind,
            small: false,
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: it.textFaint, size: 26),
            const SizedBox(height: 10),
            Text(
              title,
              style: IntentTextStyles.sans(13, it.textDim),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AccessoryTile extends StatelessWidget {
  const AccessoryTile({
    super.key,
    required this.accessory,
    required this.paired,
    required this.onRemove,
  });

  final ASAccessory accessory;
  final bool paired;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final authorized =
        accessory.state == ASAccessoryState.ASAccessoryStateAuthorized;
    final label = paired
        ? 'PAIRED'
        : authorized
            ? 'CONNECTED'
            : 'AWAITING';
    final kind = paired
        ? ChipKind.defaultKind
        : authorized
            ? ChipKind.notify
            : ChipKind.muted;
    final id = accessory.dartBluetoothIdentifier;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: it.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: it.borderHi),
            ),
            child: Center(
              child: Icon(
                Icons.bluetooth,
                size: 20,
                color: paired ? it.success : it.warn,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id ?? 'No Bluetooth ID',
                  style: IntentTextStyles.serifTitle(16, it.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                IntentChip(
                  label: label,
                  kind: kind,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IntentIconBtn(
            onTap: onRemove,
            child: Icon(Icons.close, color: it.accent, size: 18),
          ),
        ],
      ),
    );
  }
}

class EventLogList extends StatelessWidget {
  const EventLogList({super.key, required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    if (entries.isEmpty) {
      return const EmptyState(
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
                  style: IntentTextStyles.mono(10.5, it.textDim),
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
    final it = IntentTheme.of(context);
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          color: active ? it.accent : it.surfaceHi,
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              const Icon(Icons.add_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              loading ? 'Opening picker' : 'Show picker',
              style: IntentTextStyles.sans(
                14,
                Colors.white,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
