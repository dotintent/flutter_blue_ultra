import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'package:permission_handler/permission_handler.dart';

import '../cubits/scan_cubit.dart';
import '../widgets/app_snack_bar.dart';
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
  StreamSubscription<AppMessage>? _messageSub;

  @override
  void initState() {
    super.initState();
    _messageSub = context.read<ScanCubit>().messages.listen((message) {
      if (!mounted) return;
      showAppMessage(context, message);
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  Future<void> _select(ScanResult result) async {
    if (result.device.platformName.isNotEmpty) {
      widget.onDeviceSelected(result.device, result.rssi);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = DsColors.of(dialogContext);
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DsRadius.large),
            side: BorderSide(color: colors.borderHi),
          ),
          title: Text(
            'Connect to an unnamed device?',
            style: DsTextStyles.headingSm(color: colors.textPrimary),
          ),
          content: Text(
            'This peripheral advertises no name. Connecting opens a GATT '
            'link to ${result.device.remoteId.str}, which may belong to '
            'someone nearby.',
            style: DsTextStyles.bodySm(color: colors.textDim),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: DsTextStyles.bodySm(color: colors.textDim),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Connect',
                style: DsTextStyles.bodySmBold(color: colors.accent),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    widget.onDeviceSelected(result.device, result.rssi);
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return BlocBuilder<ScanCubit, ScanState>(
      // The 200 ms elapsed tick only drives the status card, which subscribes
      // to it separately — it must not rebuild the whole device list.
      buildWhen: (p, c) =>
          p.scanning != c.scanning ||
          p.results != c.results ||
          p.adapterState != c.adapterState,
      builder: (context, state) {
        final adapterOn = state.adapterState == BluetoothAdapterState.on;
        final adapterKnown =
            state.adapterState != BluetoothAdapterState.unknown;
        final adapterOff = adapterKnown && !adapterOn;
        final scanning = state.scanning && adapterOn;
        final results = state.results;

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
                const _StatusCard(),
                if (!adapterOff) ...[
                  const SizedBox(height: DsSpace.s32),
                  DsSectionHeader(
                    label: 'Nearby',
                    count: results.length,
                    trailingLabel: 'In order found',
                  ),
                  const SizedBox(height: DsSpace.s8),
                  if (results.isEmpty)
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
                    for (final result in results)
                      DeviceRow(
                        result: result,
                        onTap: () => _select(result),
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

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanCubit, ScanState>(
      buildWhen: (p, c) =>
          p.scanning != c.scanning ||
          p.busy != c.busy ||
          p.adapterState != c.adapterState ||
          p.results.length != c.results.length ||
          p.progress != c.progress,
      builder: (context, state) {
        final cubit = context.read<ScanCubit>();
        final adapterOn = state.adapterState == BluetoothAdapterState.on;
        final adapterOff =
            state.adapterState != BluetoothAdapterState.unknown && !adapterOn;

        final phase = adapterOff
            ? ScanStatusPhase.adapterOff
            : state.scanning && adapterOn
                ? ScanStatusPhase.scanning
                : ScanStatusPhase.idle;

        return ScanStatusCard(
          phase: phase,
          deviceCount: state.results.length,
          progress: state.progress,
          busy: state.busy,
          onPrimaryAction: phase == ScanStatusPhase.adapterOff
              ? openAppSettings
              : cubit.toggleScan,
        );
      },
    );
  }
}
