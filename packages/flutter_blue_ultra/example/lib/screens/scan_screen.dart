import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import '../cubits/scan_cubit.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

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
    final it = DsColors.of(context);
    return BlocBuilder<ScanCubit, ScanState>(
      // Skip the 200 ms elapsed-timer tick — only the "· 3.2s" status
      // line needs it, and it has its own BlocSelector below.
      buildWhen: (p, c) =>
          p.scanning != c.scanning ||
          p.results != c.results ||
          p.adapterState != c.adapterState,
      builder: (context, state) {
        final sorted = [...state.results]
          ..sort((a, b) => b.rssi.compareTo(a.rssi));
        final cubit = context.read<ScanCubit>();
        final adapterOn = state.adapterState == BluetoothAdapterState.on;
        final adapterReady =
            state.adapterState != BluetoothAdapterState.unknown;
        final adapterBlocked = adapterReady && !adapterOn;

        return Scaffold(
          backgroundColor: it.background,
          body: Column(
            children: [
              const DsAppBar(brand: true),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '· FLUTTER BLUE ULTRA',
                            style: DsTypography.monoLabel(11, color: it.textFaint),
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: TextSpan(
                              style: DsTypography.serifDisplay(40, color: it.textPrimary,
                                  letterSpacing: -1.5),
                              children: [
                                const TextSpan(text: 'Devices,\n'),
                                TextSpan(
                                  text: 'nearby.',
                                  style: TextStyle(
                                      color: it.accent,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // The 200 ms elapsed tick belongs to just this
                          // line — selector keeps rebuilds local.
                          BlocSelector<ScanCubit, ScanState, double>(
                            selector: (s) => s.elapsed,
                            builder: (_, elapsed) => Text(
                              state.scanning && adapterOn
                                  ? 'Listening for advertising packets · ${elapsed.toStringAsFixed(1)}s'
                                  : adapterBlocked
                                      ? 'Bluetooth is unavailable · turn it on to scan'
                                      : 'Scan stopped · ${state.results.length} found',
                              style: DsTypography.sans(13.5, color: it.textDim),
                            ),
                          ),
                          const SizedBox(height: 22),
                          DsCard(
                            child: Row(
                              children: [
                                DsPulseBeacon(
                                    active: state.scanning && adapterOn),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.scanning && adapterOn
                                            ? 'SCAN.IN_PROGRESS'
                                            : adapterBlocked
                                                ? 'ADAPTER.OFF'
                                                : 'SCAN.IDLE',
                                        style: DsTypography.monoLabel(10, color: it.accent),
                                      ),
                                      const SizedBox(height: 2),
                                      RichText(
                                        text: TextSpan(
                                          style: DsTypography.serifDisplay(28, color: it.textPrimary,
                                              letterSpacing: -0.8),
                                          children: [
                                            TextSpan(
                                                text: state.results.length
                                                    .toString()
                                                    .padLeft(2, '0')),
                                            TextSpan(
                                              text:
                                                  ' ${state.results.length == 1 ? 'device' : 'devices'}',
                                              style: DsTypography.sans(14, color: it.textDim),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DsIconButton(
                                  onPressed: adapterOn
                                      ? (state.scanning
                                          ? cubit.stopScan
                                          : cubit.startScan)
                                      : cubit.startScan,
                                  variant: DsIconButtonVariant.filled,
                                  size: DsSize.controlMedium,
                                  style: IconButton.styleFrom(
                                    backgroundColor: state.scanning && adapterOn
                                        ? it.textPrimary
                                        : it.accent,
                                    foregroundColor: it.onAccent,
                                  ),
                                  child: state.scanning && adapterOn
                                      ? Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: it.background,
                                            borderRadius:
                                                BorderRadius.circular(
                                                    DsRadius.hairline),
                                          ),
                                        )
                                      : Icon(
                                          adapterOn
                                              ? Icons.refresh
                                              : Icons.bluetooth_disabled,
                                          size: DsSize.iconMedium,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          if (adapterBlocked) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Enable Bluetooth in system settings, then tap scan.',
                              style: DsTypography.sans(12.5, color: it.textDim),
                            ),
                          ],
                        ],
                      ),
                    ),
                    DsSectionHeader(
                      label: 'Nearby',
                      count: sorted.length,
                      trailing: Text('BY RSSI',
                          style: DsTypography.monoStyle(10, color: it.textFaint,
                              letterSpacing: 1)),
                    ),
                    if (sorted.isEmpty && state.scanning && adapterOn)
                      DsEmptyState(
                        title: 'Listening…',
                        padding:
                            const EdgeInsets.symmetric(vertical: DsSpace.s48),
                        titleStyle: DsTypography.serifItalic(13, color: it.textDim),
                      ),
                    ...sorted.map((r) => _DeviceRow(
                          result: r,
                          onTap: () =>
                              widget.onDeviceSelected(r.device, r.rssi),
                        )),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.result, required this.onTap});

  final ScanResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    final name = result.device.platformName;
    final hasName = name.isNotEmpty;
    final mac = result.device.remoteId.str;
    final adCount = result.advertisementData.serviceUuids.length;

    final connectable = result.advertisementData.connectable;
    return DsListRow(
      onTap: connectable ? onTap : null,
      minTileHeight: 76,
      contentPadding: const EdgeInsets.symmetric(horizontal: DsSpace.s20),
      leading: const DsAvatar(child: Icon(Icons.bluetooth)),
      title: Text(
        hasName ? name : '(unnamed)',
        style: hasName
            ? DsTypography.serif(16, color: it.textPrimary)
            : DsTypography.serifItalic(16, color: it.textDim),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: DsSpace.s3),
        child: Row(
          children: [
            Flexible(
              child: Text(
                mac,
                style: DsTypography.monoStyle(10.5, color: it.textDim),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (adCount > 0) ...[
              const SizedBox(width: DsSpace.s8),
              Text(
                '· $adCount svc',
                style: DsTypography.monoStyle(10.5, color: it.textFaint),
              ),
            ],
          ],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              DsSignalBars.rssi(rssi: result.rssi),
              const SizedBox(height: DsSpace.s4),
              Text(
                '${result.rssi} dBm',
                style: DsTypography.monoStyle(10.5, color: it.textDim),
              ),
            ],
          ),
          const SizedBox(width: DsSpace.s4),
          Icon(Icons.chevron_right, size: DsSize.iconSmall, color: it.textFaint),
        ],
      ),
    );
  }
}
