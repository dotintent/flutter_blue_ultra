import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import '../cubits/scan_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms.dart';

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
    final it = IntentTheme.of(context);
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
          backgroundColor: it.bg,
          body: Column(
            children: [
              const IntentAppBar(brand: true),
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
                            style: IntentTextStyles.monoLabel(11, it.textFaint),
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: TextSpan(
                              style: IntentTextStyles.serifDisplay(
                                  40, it.textPrimary,
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
                              style: IntentTextStyles.sans(13.5, it.textDim),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            decoration: BoxDecoration(
                              color: it.surface,
                              border: Border.all(color: it.border),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                ScanRipple(
                                    scanning: state.scanning && adapterOn),
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
                                        style: IntentTextStyles.monoLabel(
                                            10, it.accent),
                                      ),
                                      const SizedBox(height: 2),
                                      RichText(
                                        text: TextSpan(
                                          style: IntentTextStyles.serifDisplay(
                                              28, it.textPrimary,
                                              letterSpacing: -0.8),
                                          children: [
                                            TextSpan(
                                                text: state.results.length
                                                    .toString()
                                                    .padLeft(2, '0')),
                                            TextSpan(
                                              text:
                                                  ' ${state.results.length == 1 ? 'device' : 'devices'}',
                                              style: IntentTextStyles.sans(
                                                  14, it.textDim),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: adapterOn
                                      ? (state.scanning
                                          ? cubit.stopScan
                                          : cubit.startScan)
                                      : cubit.startScan,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: state.scanning && adapterOn
                                          ? it.textPrimary
                                          : it.accent,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Center(
                                      child: state.scanning && adapterOn
                                          ? Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: it.bg,
                                                borderRadius:
                                                    BorderRadius.circular(1),
                                              ),
                                            )
                                          : Icon(
                                              adapterOn
                                                  ? Icons.refresh
                                                  : Icons.bluetooth_disabled,
                                              color: Colors.white,
                                              size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (adapterBlocked) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Enable Bluetooth in system settings, then tap scan.',
                              style: IntentTextStyles.sans(12.5, it.textDim),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SectionHeader(
                      label: 'Nearby',
                      count: sorted.length,
                      trailing: Text('BY RSSI',
                          style: IntentTextStyles.mono(10, it.textFaint,
                              letterSpacing: 1)),
                    ),
                    if (sorted.isEmpty && state.scanning && adapterOn)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text(
                            'Listening…',
                            style: TextStyle(
                              fontFamily: 'Bradford',
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: it.textDim,
                            ),
                          ),
                        ),
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
    final it = IntentTheme.of(context);
    final name = result.device.platformName;
    final hasName = name.isNotEmpty;
    final mac = result.device.remoteId.str;
    final adCount = result.advertisementData.serviceUuids.length;

    return InkWell(
      onTap: onTap,
      child: Container(
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
                child: Icon(Icons.bluetooth, size: 20, color: it.textPrimary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasName ? name : '(unnamed)',
                    style: hasName
                        ? IntentTextStyles.serifTitle(16, it.textPrimary)
                        : TextStyle(
                            fontFamily: 'Bradford',
                            fontSize: 16,
                            color: it.textDim,
                            fontStyle: FontStyle.italic,
                          ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(mac,
                            style: IntentTextStyles.mono(10.5, it.textDim),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (adCount > 0) ...[
                        const SizedBox(width: 8),
                        Text('· $adCount svc',
                            style: IntentTextStyles.mono(10.5, it.textFaint)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RSSIBars(rssi: result.rssi),
                const SizedBox(height: 4),
                Text('${result.rssi} dBm',
                    style: IntentTextStyles.mono(10.5, it.textDim)),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: it.textFaint),
          ],
        ),
      ),
    );
  }
}
