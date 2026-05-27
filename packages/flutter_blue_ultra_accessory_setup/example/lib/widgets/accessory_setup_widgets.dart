import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';

import '../cubits/accessory_setup_cubit.dart';

class AccessoryStatusBanner extends StatelessWidget {
  const AccessoryStatusBanner({super.key, required this.state});

  final AccessorySetupState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = state.initError != null
        ? colors.error
        : state.isActivated
            ? Colors.greenAccent
            : Colors.amberAccent;
    final status = state.initError != null
        ? 'SetupKit unavailable'
        : state.isActivated
            ? 'Session activated'
            : 'Activating session';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 10),
            Flexible(child: Text(status)),
            if (state.connectedId != null) ...[
              const SizedBox(width: 10),
              const Text('·'),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  state.connectedId!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AccessorySection extends StatelessWidget {
  const AccessorySection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
            child,
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
    required this.onRemove,
  });

  final ASAccessory accessory;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final authorized = accessory.state == ASAccessoryState.ASAccessoryStateAuthorized;
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.bluetooth,
        color: authorized ? Colors.greenAccent : Colors.amberAccent,
      ),
      title: Text(accessory.dartBluetoothIdentifier ?? 'No Bluetooth ID'),
      subtitle: Text(authorized ? 'Authorized' : 'Awaiting authorization'),
      trailing: IconButton(
        icon: Icon(Icons.close, color: colors.error),
        tooltip: 'Remove',
        onPressed: onRemove,
      ),
    );
  }
}

class EventLogList extends StatelessWidget {
  const EventLogList({super.key, required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Text('No events yet.');
    }
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontFamily: 'monospace',
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Text(entry, style: textStyle),
          ),
      ],
    );
  }
}
