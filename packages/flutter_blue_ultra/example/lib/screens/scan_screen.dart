import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cubits/scan_cubit.dart';
import '../widgets/brand_header.dart';
import '../widgets/device_row.dart';
import '../widgets/scan_status_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, required this.onDeviceSelected});

  final void Function(BluetoothDevice device, int rssi) onDeviceSelected;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCubit(),
      child: _ScanView(onDeviceSelected: onDeviceSelected),
    );
  }
}

class _ScanView extends StatefulWidget {
  const _ScanView({required this.onDeviceSelected});

  final void Function(BluetoothDevice device, int rssi) onDeviceSelected;

  @override
  State<_ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<_ScanView> {
  StreamSubscription<String>? _messageSub;

  @override
  void initState() {
    super.initState();
    _messageSub = context.read<ScanCubit>().messages.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return BlocBuilder<ScanCubit, ScanState>(
      // The 200 ms elapsed tick isn't rendered by this design, so it must not
      // drive rebuilds here.
      buildWhen: (p, c) =>
          p.scanning != c.scanning ||
          p.results != c.results ||
          p.adapterState != c.adapterState,
      builder: (context, state) {
        final cubit = context.read<ScanCubit>();
        final adapterOn = state.adapterState == BluetoothAdapterState.on;
        final adapterKnown =
            state.adapterState != BluetoothAdapterState.unknown;
        final adapterOff = adapterKnown && !adapterOn;
        final scanning = state.scanning && adapterOn;

        final sorted = [...state.results]
          ..sort((a, b) => b.rssi.compareTo(a.rssi));

        final phase = adapterOff
            ? ScanStatusPhase.adapterOff
            : scanning
                ? ScanStatusPhase.scanning
                : ScanStatusPhase.idle;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(DsSpace.s20),
              children: [
                const BrandHeader(),
                const SizedBox(height: DsSpace.s24),
                RichText(
                  text: TextSpan(
                    style: DsTextStyles.heading2xl(color: colors.textPrimary),
                    children: [
                      const TextSpan(text: 'Devices, '),
                      TextSpan(
                        text: 'nearby.',
                        style: DsTextStyles.heading2xl(
                          color: colors.accent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DsSpace.s32),
                ScanStatusCard(
                  phase: phase,
                  deviceCount: state.results.length,
                  onPrimaryAction: () => switch (phase) {
                    ScanStatusPhase.adapterOff => openAppSettings(),
                    ScanStatusPhase.scanning => cubit.stopScan(),
                    ScanStatusPhase.idle => cubit.startScan(),
                  },
                ),
                if (!adapterOff) ...[
                  const SizedBox(height: DsSpace.s32),
                  DsSectionHeader(
                    label: 'Nearby',
                    count: sorted.length,
                    trailingLabel: 'By RSSI',
                  ),
                  const SizedBox(height: DsSpace.s8),
                  if (sorted.isEmpty)
                    DsEmptyState(
                      icon: scanning ? Icons.search : Icons.search_off,
                      title: scanning
                          ? 'Looking for devices…'
                          : 'No devices found',
                      description: scanning
                          ? 'Listening for advertising packets…'
                          : 'Nothing advertised during the scan.',
                    )
                  else
                    for (final result in sorted)
                      DeviceRow(
                        result: result,
                        onTap: () => widget.onDeviceSelected(
                          result.device,
                          result.rssi,
                        ),
                      ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
