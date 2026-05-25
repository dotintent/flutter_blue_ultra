import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubits/device_cubit.dart';
import '../models/gatt_names.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms.dart';
import 'characteristic_screen.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({
    super.key,
    required this.device,
    required this.rssi,
  });

  final BluetoothDevice device;
  final int rssi;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DeviceCubit(device: device, initialRssi: rssi)..connect(),
      child: _DeviceBody(device: device, rssi: rssi),
    );
  }
}

class _DeviceBody extends StatefulWidget {
  const _DeviceBody({
    required this.device,
    required this.rssi,
  });

  final BluetoothDevice device;
  final int rssi;

  @override
  State<_DeviceBody> createState() => _DeviceBodyState();
}

class _DeviceBodyState extends State<_DeviceBody> {
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

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final name = widget.device.platformName;
    final mac = widget.device.remoteId.str;

    return BlocBuilder<DeviceCubit, DeviceState>(
      // Skip the high-frequency RSSI tick (every 2 s) — only the RSSI stat
      // cell needs it, and it has its own BlocSelector below. Everything
      // else in this tree is rebuilt only when meaningful state changes.
      buildWhen: (p, c) =>
          p.connState != c.connState ||
          p.services != c.services ||
          p.mtu != c.mtu ||
          p.expanded != c.expanded,
      builder: (context, state) {
        final connected = state.connState == ConnectionDotState.connected;

        return Scaffold(
          backgroundColor: it.bg,
          body: Column(
            children: [
              IntentAppBar(
                title: 'Device',
                subtitle: mac,
                leading: IntentIconBtn(
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      Icon(Icons.arrow_back, size: 18, color: it.textPrimary),
                ),
                trailing: IntentIconBtn(
                  onTap: connected
                      ? () async {
                          await context.read<DeviceCubit>().disconnect();
                          if (context.mounted) Navigator.of(context).pop();
                        }
                      : null,
                  child: Icon(
                    connected ? Icons.link_off : Icons.more_vert,
                    size: 18,
                    color: connected ? it.accent : it.textPrimary,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -30,
                            right: -50,
                            child: Opacity(
                              opacity: 0.5,
                              child: SunburstDecor(size: 220),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConnectionDot(state: state.connState),
                                const SizedBox(height: 12),
                                Text(
                                  name.isNotEmpty ? name : 'Unnamed',
                                  style: name.isNotEmpty
                                      ? IntentTextStyles.serifTitle(
                                          32, it.textPrimary)
                                      : GoogleFonts.crimsonPro(
                                          fontSize: 32,
                                          color: it.textDim,
                                          fontStyle: FontStyle.italic,
                                        ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$mac · TX ${widget.rssi > 0 ? '+' : ''}${widget.rssi} dBm',
                                  style: IntentTextStyles.mono(11, it.textDim),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: it.border)),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: Row(
                        children: [
                          // Only this cell needs the RSSI tick — selector
                          // limits the rebuild to ~1 Text widget, not the
                          // whole screen, every 2 s.
                          Expanded(
                            child: BlocSelector<DeviceCubit, DeviceState, int>(
                              selector: (s) => s.currentRssi,
                              builder: (_, rssi) => _StatCell(
                                  label: 'RSSI', value: '$rssi', unit: 'dBm'),
                            ),
                          ),
                          Container(
                              width: 1,
                              height: 40,
                              color: it.border,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 14)),
                          Expanded(
                            child: _StatCell(
                                label: 'MTU',
                                value: '${state.mtu}',
                                unit: 'byte'),
                          ),
                          Container(
                              width: 1,
                              height: 40,
                              color: it.border,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 14)),
                          Expanded(
                            child: _StatCell(
                                label: 'Latency',
                                value: connected ? '12' : '—',
                                unit: 'ms'),
                          ),
                        ],
                      ),
                    ),
                    if (!connected) ...[
                      const SizedBox(height: 40),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: state.connState ==
                                        ConnectionDotState.disconnected
                                    ? it.borderHi
                                    : it.accent),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state.connState !=
                                  ConnectionDotState.disconnected) ...[
                                _SpinnerWidget(color: it.accent),
                                const SizedBox(width: 10),
                              ],
                              Text(
                                state.connState == ConnectionDotState.connecting
                                    ? 'ESTABLISHING GATT…'
                                    : state.connState ==
                                            ConnectionDotState.discovering
                                        ? 'DISCOVERING SERVICES…'
                                        : 'DISCONNECTED',
                                style: IntentTextStyles.monoLabel(
                                    12,
                                    state.connState ==
                                            ConnectionDotState.disconnected
                                        ? it.textPrimary
                                        : it.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            if (state.connState ==
                                ConnectionDotState.disconnected) {
                              await context.read<DeviceCubit>().connect();
                            } else {
                              await context.read<DeviceCubit>().disconnect();
                              if (context.mounted) Navigator.of(context).pop();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            child: Text(
                              state.connState == ConnectionDotState.disconnected
                                  ? 'RETRY'
                                  : 'CANCEL',
                              style: IntentTextStyles.monoLabel(11, it.textDim),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      SectionHeader(
                        label: 'Services',
                        count: state.services.length,
                        trailing: Text('GATT',
                            style: IntentTextStyles.mono(10, it.textFaint,
                                letterSpacing: 1)),
                      ),
                      ...state.services.map((s) => _ServiceCard(
                            service: s,
                            expanded:
                                state.expanded.contains(s.serviceUuid.str),
                            onToggle: () => context
                                .read<DeviceCubit>()
                                .toggleService(s.serviceUuid.str),
                            onCharSelected: (c) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CharacteristicScreen(
                                  device: widget.device,
                                  service: s,
                                  characteristic: c,
                                  negotiatedMtu: state.mtu,
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(height: 80),
                    ],
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

class _StatCell extends StatelessWidget {
  const _StatCell(
      {required this.label, required this.value, required this.unit});
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    // Caller is responsible for wrapping in Expanded — keeps this widget
    // free of Flex assumptions so BlocSelector can wrap it cleanly.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                IntentTextStyles.mono(9.5, it.textFaint, letterSpacing: 1.2)),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            style: IntentTextStyles.serifDisplay(24, it.textPrimary,
                letterSpacing: -0.5),
            children: [
              TextSpan(text: value),
              TextSpan(
                text: ' $unit',
                style: IntentTextStyles.mono(11, it.textDim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.expanded,
    required this.onToggle,
    required this.onCharSelected,
  });

  final BluetoothService service;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(BluetoothCharacteristic) onCharSelected;

  String get _displayName =>
      kGattServiceNames[shortUuid(service.serviceUuid.str)] ??
      service.serviceUuid.str;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: it.border)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: it.accent),
                    ),
                    child: Center(
                      child: Text('S',
                          style: IntentTextStyles.monoLabel(9, it.accent)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_displayName,
                            style: IntentTextStyles.serifTitle(
                                16, it.textPrimary)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            UUIDText(
                                uuid: service.serviceUuid.str, short: true),
                            const SizedBox(width: 8),
                            Text(
                              '· ${service.characteristics.length} char',
                              style: IntentTextStyles.mono(10.5, it.textFaint),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child:
                        Icon(Icons.chevron_right, size: 18, color: it.textDim),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            ...service.characteristics.map((c) => _CharRow(
                  characteristic: c,
                  onTap: () => onCharSelected(c),
                )),
        ],
      ),
    );
  }
}

class _CharRow extends StatelessWidget {
  const _CharRow({required this.characteristic, required this.onTap});
  final BluetoothCharacteristic characteristic;
  final VoidCallback onTap;

  String get _displayName =>
      kGattCharacteristicNames[
          shortUuid(characteristic.characteristicUuid.str)] ??
      characteristic.characteristicUuid.str;

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);
    final props = characteristic.properties;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 14),
        padding: const EdgeInsets.fromLTRB(28, 10, 20, 10),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: it.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_displayName,
                      style: IntentTextStyles.sans(13.5, it.textPrimary,
                          weight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  UUIDText(
                      uuid: characteristic.characteristicUuid.str, short: true),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (props.read) const IntentChip(label: 'R'),
                if (props.write || props.writeWithoutResponse)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: IntentChip(label: 'W'),
                  ),
                if (props.notify || props.indicate)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: IntentChip(
                        label: props.notify ? 'N' : 'I', kind: ChipKind.notify),
                  ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 13, color: it.textFaint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpinnerWidget extends StatefulWidget {
  const _SpinnerWidget({required this.color});
  final Color color;

  @override
  State<_SpinnerWidget> createState() => _SpinnerWidgetState();
}

class _SpinnerWidgetState extends State<_SpinnerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Transform.rotate(
          angle: _c.value * 2 * 3.14159,
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              value: 0.75,
              strokeWidth: 2,
              color: widget.color,
            ),
          ),
        ),
      );
}
