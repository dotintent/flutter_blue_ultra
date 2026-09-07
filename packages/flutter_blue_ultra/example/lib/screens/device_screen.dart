import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../cubits/device_cubit.dart';
import '../models/ble_models.dart';
import '../widgets/connection_dot.dart';
import '../widgets/screen_nav.dart';
import '../widgets/service_row.dart';
import '../widgets/skeleton_row.dart';
import '../widgets/stat_card.dart';
import 'characteristic_screen.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key, required this.device, required this.rssi});

  final BluetoothDevice device;
  final int rssi;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeviceCubit(device: device, initialRssi: rssi)..connect(),
      child: _DeviceView(device: device),
    );
  }
}

class _DeviceView extends StatefulWidget {
  const _DeviceView({required this.device});

  final BluetoothDevice device;

  @override
  State<_DeviceView> createState() => _DeviceViewState();
}

class _DeviceViewState extends State<_DeviceView> {
  StreamSubscription<String>? _messageSub;

  @override
  void initState() {
    super.initState();
    _messageSub = context.read<DeviceCubit>().messages.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  Future<void> _disconnect(BuildContext context) async {
    await context.read<DeviceCubit>().disconnect();
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final name = widget.device.platformName;
    final remoteId = widget.device.remoteId.str;

    return BlocBuilder<DeviceCubit, DeviceState>(
      // Skip the 2 s RSSI/latency tick — only the telemetry row needs it and
      // it has its own BlocSelector below.
      buildWhen: (p, c) =>
          p.connState != c.connState ||
          p.failure != c.failure ||
          p.services != c.services ||
          p.mtu != c.mtu ||
          p.expanded != c.expanded,
      builder: (context, state) {
        final cubit = context.read<DeviceCubit>();
        final connected = state.connState == ConnectionPhase.connected;
        final busy = state.connState == ConnectionPhase.connecting ||
            state.connState == ConnectionPhase.discovering;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                ScreenNav(
                  actions: [
                    if (connected)
                      NavPillButton(
                        label: 'Disconnect',
                        onPressed: () => _disconnect(context),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DsSpace.s20,
                      vertical: DsSpace.s16,
                    ),
                    children: [
                      ConnectionDot(
                        phase: state.connState,
                        failure: state.failure,
                      ),
                      const SizedBox(height: DsSpace.s8),
                      Text(
                        name.isNotEmpty ? name : '(unnamed)',
                        style: DsTextStyles.headingXl(
                          color: colors.textPrimary,
                          fontStyle: name.isNotEmpty ? null : FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: DsSpace.s8),
                      Text(
                        remoteId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DsTextStyles.monoMd(color: colors.textDim),
                      ),
                      if (connected) ...[
                        const SizedBox(height: DsSpace.s20),
                        BlocSelector<DeviceCubit, DeviceState,
                            (int, int, int?)>(
                          selector: (s) => (s.currentRssi, s.mtu, s.latencyMs),
                          builder: (_, telemetry) {
                            final (rssi, mtu, latency) = telemetry;
                            return TelemetryRow(
                              stats: [
                                StatCardData(
                                  label: 'RSSI',
                                  value: '$rssi',
                                  unit: 'dBm',
                                ),
                                StatCardData(
                                  label: 'MTU',
                                  value: '$mtu',
                                  unit: 'byte',
                                ),
                                StatCardData(
                                  label: 'LATENCY',
                                  value: latency == null ? '—' : '$latency',
                                  unit: 'ms',
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: DsSpace.s20),
                        DsSectionHeader(
                          label: 'Services',
                          count: state.services.length,
                          trailingLabel: 'GATT',
                        ),
                        const SizedBox(height: DsSpace.s8),
                        if (state.services.isEmpty)
                          const DsEmptyState(
                            icon: Icons.layers_clear,
                            title: 'No services found',
                            description:
                                "This device didn't expose any GATT services.",
                          )
                        else
                          for (final service in state.services) ...[
                            ServiceRow(
                              service: service,
                              expanded: state.expanded
                                  .contains(service.serviceUuid.str),
                              onToggle: () =>
                                  cubit.toggleService(service.serviceUuid.str),
                            ),
                            if (state.expanded
                                .contains(service.serviceUuid.str))
                              for (final characteristic
                                  in service.characteristics)
                                CharacteristicRow(
                                  characteristic: characteristic,
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CharacteristicScreen(
                                        device: widget.device,
                                        service: service,
                                        characteristic: characteristic,
                                        negotiatedMtu: state.mtu,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                      ] else ...[
                        const SizedBox(height: DsSpace.s20),
                        if (state.connState == ConnectionPhase.discovering)
                          for (var i = 0; i < 3; i++) const SkeletonRow(),
                        if (busy)
                          DsEmptyState(
                            iconWidget:
                                state.connState == ConnectionPhase.connecting
                                    ? const DsSpinner(size: DsSize.iconXXLarge)
                                    : null,
                            title: state.connState == ConnectionPhase.connecting
                                ? 'Establishing GATT...'
                                : 'Discovering services...',
                            action: DsButton(
                              label: 'Cancel',
                              expand: false,
                              variant: DsButtonVariant.outlined,
                              onPressed: () => _disconnect(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: colors.surface,
                                side: BorderSide(color: colors.borderHi),
                              ),
                            ),
                          )
                        else
                          DsEmptyState(
                            icon: switch (state.failure) {
                              DeviceFailure.connectionLost => Icons.link_off,
                              DeviceFailure.connectFailed => Icons.sync_problem,
                              DeviceFailure.discoveryFailed =>
                                Icons.sync_problem,
                              DeviceFailure.none => Icons.bluetooth_disabled,
                            },
                            title: switch (state.failure) {
                              DeviceFailure.connectionLost =>
                                'The connection was lost',
                              DeviceFailure.connectFailed =>
                                "The device didn't respond",
                              DeviceFailure.discoveryFailed =>
                                'Service discovery failed',
                              DeviceFailure.none => 'Disconnected',
                            },
                            description: switch (state.failure) {
                              DeviceFailure.connectionLost =>
                                'Retry to reconnect.',
                              DeviceFailure.connectFailed =>
                                'Retry to connect.',
                              DeviceFailure.discoveryFailed =>
                                "Connected, but couldn't read services.",
                              DeviceFailure.none => 'Retry to connect.',
                            },
                            action: DsButton(
                              label: 'Retry',
                              expand: false,
                              onPressed: cubit.connect,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
