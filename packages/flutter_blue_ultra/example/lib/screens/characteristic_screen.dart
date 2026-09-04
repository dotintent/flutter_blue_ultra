import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../cubits/characteristic_cubit.dart';
import '../models/ble_models.dart';
import '../models/gatt_names.dart';
import '../widgets/format_segments.dart';
import '../widgets/notify_toggle.dart';
import '../widgets/screen_nav.dart';
import '../widgets/screen_tab_bar.dart';
import '../widgets/value_field.dart';

enum _CharTab { read, write, notify }

class CharacteristicScreen extends StatelessWidget {
  const CharacteristicScreen({
    super.key,
    required this.device,
    required this.service,
    required this.characteristic,
    required this.negotiatedMtu,
  });

  final BluetoothDevice device;
  final BluetoothService service;
  final BluetoothCharacteristic characteristic;
  final int negotiatedMtu;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CharacteristicCubit(characteristic: characteristic),
      child: _CharacteristicView(
        service: service,
        characteristic: characteristic,
        negotiatedMtu: negotiatedMtu,
      ),
    );
  }
}

class _CharacteristicView extends StatefulWidget {
  const _CharacteristicView({
    required this.service,
    required this.characteristic,
    required this.negotiatedMtu,
  });

  final BluetoothService service;
  final BluetoothCharacteristic characteristic;
  final int negotiatedMtu;

  @override
  State<_CharacteristicView> createState() => _CharacteristicViewState();
}

class _CharacteristicViewState extends State<_CharacteristicView> {
  late final List<_CharTab> _tabs;
  late int _index;
  StreamSubscription<String>? _messageSub;
  final TextEditingController _payloadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final props = widget.characteristic.properties;
    _tabs = [
      if (props.read) _CharTab.read,
      if (props.write || props.writeWithoutResponse) _CharTab.write,
      if (props.notify || props.indicate) _CharTab.notify,
    ];
    _index = 0;
    _payloadController.text =
        context.read<CharacteristicCubit>().state.writeInput;

    _messageSub = context.read<CharacteristicCubit>().messages.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _payloadController.dispose();
    super.dispose();
  }

  String get _serviceName =>
      kGattServiceNames[shortUuid(widget.service.serviceUuid.str)] ??
      'Custom service';

  String get _charName =>
      kGattCharacteristicNames[
          shortUuid(widget.characteristic.characteristicUuid.str)] ??
      'Custom characteristic';

  void _copyUuid() {
    Clipboard.setData(
      ClipboardData(text: widget.characteristic.characteristicUuid.str),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UUID copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return BlocBuilder<CharacteristicCubit, CharacteristicState>(
      builder: (context, state) {
        final cubit = context.read<CharacteristicCubit>();

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                ScreenNav(
                  actions: [
                    NavCircleButton(
                      icon: Icons.copy,
                      tooltip: 'Copy UUID',
                      onPressed: _copyUuid,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DsSpace.s20,
                    vertical: DsSpace.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _serviceName.toUpperCase(),
                        style:
                            DsTextStyles.monoLabelLoud(color: colors.textDim),
                      ),
                      const SizedBox(height: DsSpace.s8),
                      Text(
                        _charName,
                        style:
                            DsTextStyles.headingXl(color: colors.textPrimary),
                      ),
                      const SizedBox(height: DsSpace.s8),
                      Text(
                        widget.characteristic.characteristicUuid.str,
                        style: DsTextStyles.monoMd(color: colors.textDim),
                      ),
                    ],
                  ),
                ),
                if (_tabs.isEmpty)
                  const Expanded(
                    child: DsEmptyState(
                      icon: Icons.block,
                      title: 'No supported operations',
                      description:
                          'This characteristic exposes no readable, writable '
                          'or notifiable properties.',
                    ),
                  )
                else ...[
                  ScreenTabBar(
                    tabs: [
                      for (final tab in _tabs)
                        switch (tab) {
                          _CharTab.read => 'Read',
                          _CharTab.write => 'Write',
                          _CharTab.notify => 'Notify',
                        },
                    ],
                    currentIndex: _index,
                    onSelected: (index) => setState(() => _index = index),
                  ),
                  Expanded(
                    child: switch (_tabs[_index]) {
                      _CharTab.read => _ReadTab(state: state, cubit: cubit),
                      _CharTab.write => _WriteTab(
                          state: state,
                          cubit: cubit,
                          controller: _payloadController,
                          negotiatedMtu: widget.negotiatedMtu,
                          properties: widget.characteristic.properties,
                        ),
                      _CharTab.notify => _NotifyTab(state: state, cubit: cubit),
                    },
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

class _ReadTab extends StatelessWidget {
  const _ReadTab({required this.state, required this.cubit});

  final CharacteristicState state;
  final CharacteristicCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final length = state.lastValue.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DsSpace.s20,
        DsSpace.s24,
        DsSpace.s20,
        DsSpace.s20,
      ),
      children: [
        Text(
          length == 0
              ? 'Last value · —'
              : 'Last value · $length ${length == 1 ? 'byte' : 'bytes'}',
          style: DsTextStyles.monoLabel(color: colors.textDim),
        ),
        const SizedBox(height: DsSpace.s8),
        FormatSegments(value: state.format, onChanged: cubit.setFormat),
        const SizedBox(height: DsSpace.s8),
        ReadonlyValueField(
          value: state.lastValue.isEmpty
              ? '—'
              : state.format.format(state.lastValue),
        ),
        const SizedBox(height: DsSpace.s16),
        DsButton(
          label: 'Read',
          icon: Icons.download,
          onPressed: cubit.doRead,
        ),
      ],
    );
  }
}

class _WriteTab extends StatelessWidget {
  const _WriteTab({
    required this.state,
    required this.cubit,
    required this.controller,
    required this.negotiatedMtu,
    required this.properties,
  });

  static const _quickFill = ['00', '01', 'FF', '0A0B0C'];

  final CharacteristicState state;
  final CharacteristicCubit cubit;
  final TextEditingController controller;
  final int negotiatedMtu;
  final CharacteristicProperties properties;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final clean = state.writeInput.replaceAll(RegExp(r'\s'), '');
    final byteCount = clean.length ~/ 2;
    final maxBytes = negotiatedMtu > 3 ? negotiatedMtu - 3 : 0;
    final withoutResponse =
        properties.writeWithoutResponse && !properties.write;

    void fill(String payload) {
      controller.value = TextEditingValue(
        text: payload,
        selection: TextSelection.collapsed(offset: payload.length),
      );
      cubit.setWriteInput(payload);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        DsSpace.s20,
        DsSpace.s24,
        DsSpace.s20,
        DsSpace.s20,
      ),
      children: [
        Text(
          'QUICK FILL',
          style: DsTextStyles.monoLabel(color: colors.textDim),
        ),
        const SizedBox(height: DsSpace.s8),
        for (var row = 0; row < _quickFill.length; row += 2) ...[
          Row(
            children: [
              for (var column = row;
                  column < row + 2 && column < _quickFill.length;
                  column++) ...[
                if (column > row) const SizedBox(width: DsSpace.s8),
                Expanded(
                  child: QuickFillChip(
                    label: _quickFill[column],
                    onTap: () => fill(_quickFill[column]),
                  ),
                ),
              ],
            ],
          ),
          if (row + 2 < _quickFill.length) const SizedBox(height: DsSpace.s8),
        ],
        const SizedBox(height: DsSpace.s16),
        PayloadField(
          controller: controller,
          label: 'PAYLOAD (HEX)',
          hint: '01FFA0',
          onChanged: cubit.setWriteInput,
          footerLeft: '$byteCount byte · max $maxBytes',
          footerRight: withoutResponse ? 'WRITE_WITHOUT_RSP' : 'WRITE_REQUEST',
        ),
        const SizedBox(height: DsSpace.s16),
        DsButton(
          label: 'Write',
          icon: Icons.upload,
          onPressed: cubit.doWrite,
        ),
      ],
    );
  }
}

class _NotifyTab extends StatelessWidget {
  const _NotifyTab({required this.state, required this.cubit});

  final CharacteristicState state;
  final CharacteristicCubit cubit;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final count = state.packets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DsSpace.s20,
            DsSpace.s24,
            DsSpace.s20,
            0,
          ),
          child: Container(
            padding: const EdgeInsets.all(DsSpace.s16),
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              borderRadius: BorderRadius.circular(DsRadius.medium),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.notifying ? 'SUBSCRIBED' : 'SUBSCRIBE',
                        style:
                            DsTextStyles.monoLabel(color: colors.textPrimary),
                      ),
                      const SizedBox(height: DsSpace.s4),
                      Text(
                        '$count ${count == 1 ? 'packet' : 'packets'} · '
                        'CCCD ${state.notifying ? '0x0001' : '0x0000'}',
                        style: DsTextStyles.monoCaption(
                          color: colors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DsSpace.s16),
                NotifyToggle(
                  value: state.notifying,
                  onChanged: (_) => state.notifying
                      ? cubit.stopNotify()
                      : cubit.startNotify(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            DsSpace.s20,
            DsSpace.s12,
            DsSpace.s20,
            DsSpace.s8,
          ),
          child: DsSectionHeader(
            label: 'Stream',
            trailing: Text(
              state.notifying ? 'LIVE' : 'IDLE',
              style: DsTextStyles.monoLabel(
                color: state.notifying ? colors.accent : colors.textFaint,
              ),
            ),
          ),
        ),
        Expanded(
          child: state.packets.isEmpty
              ? DsEmptyState(
                  iconWidget: state.notifying
                      ? const DsSpinner(size: DsSize.iconXXLarge)
                      : null,
                  icon: state.notifying ? null : Icons.notifications_off,
                  title: state.notifying
                      ? 'Waiting for first packet…'
                      : 'Notifications off',
                  description:
                      state.notifying ? null : 'Subscribe to stream values.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    DsSpace.s20,
                    0,
                    DsSpace.s20,
                    DsSpace.s20,
                  ),
                  itemCount: state.packets.length,
                  itemBuilder: (_, index) {
                    final packet = state.packets[index];
                    final at = packet.timestamp;
                    return EventLogRow(
                      value: state.format.format(packet.bytes),
                      time: '${at.hour.toString().padLeft(2, '0')}:'
                          '${at.minute.toString().padLeft(2, '0')}:'
                          '${at.second.toString().padLeft(2, '0')}',
                    );
                  },
                ),
        ),
      ],
    );
  }
}
