import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import '../cubits/characteristic_cubit.dart';
import '../models/ble_models.dart';
import '../models/gatt_names.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

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
        device: device,
        service: service,
        characteristic: characteristic,
        negotiatedMtu: negotiatedMtu,
      ),
    );
  }
}

class _CharacteristicView extends StatefulWidget {
  const _CharacteristicView({
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
  State<_CharacteristicView> createState() => _CharacteristicViewState();
}

class _CharacteristicViewState extends State<_CharacteristicView>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late final bool _canRead;
  late final bool _canWrite;
  late final bool _canNotify;
  late final List<String> _tabs;
  StreamSubscription<String>? _messageSub;

  @override
  void initState() {
    super.initState();
    final props = widget.characteristic.properties;
    _canRead = props.read;
    _canWrite = props.write || props.writeWithoutResponse;
    _canNotify = props.notify || props.indicate;

    _tabs = [
      if (_canRead) 'Read',
      if (_canWrite) 'Write',
      if (_canNotify) 'Notify',
    ];

    if (_tabs.isNotEmpty) {
      final initialIndex =
          _canRead ? 0 : (_canNotify ? _tabs.indexOf('Notify') : 0);
      _tabController = TabController(
          length: _tabs.length, vsync: this, initialIndex: initialIndex);
    }

    _messageSub = context.read<CharacteristicCubit>().messages.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  String get _shortUuid {
    final uuid = widget.characteristic.characteristicUuid.str;
    final short = shortUuid(uuid);
    if (short != null) return '0x$short';
    return uuid.length > 8 ? uuid.substring(0, 8) : uuid;
  }

  String get _charName =>
      kGattCharacteristicNames[
          shortUuid(widget.characteristic.characteristicUuid.str)] ??
      widget.characteristic.characteristicUuid.str;

  String get _serviceName =>
      kGattServiceNames[shortUuid(widget.service.serviceUuid.str)] ??
      widget.service.serviceUuid.str;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    final props = widget.characteristic.properties;

    return BlocBuilder<CharacteristicCubit, CharacteristicState>(
      builder: (context, state) {
        final cubit = context.read<CharacteristicCubit>();

        return Scaffold(
          backgroundColor: it.background,
          body: Column(
            children: [
              DsAppBar(
                title: 'Characteristic',
                subtitle: _serviceName,
                leading: DsIconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child:
                      Icon(Icons.arrow_back, size: 18, color: it.textPrimary),
                ),
                trailing: DsIconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(
                        text: widget.characteristic.characteristicUuid.str));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UUID copied')),
                    );
                  },
                  child: Icon(Icons.copy, size: 16, color: it.textPrimary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('· $_shortUuid',
                        style: DsTypography.monoLabel(11, color: it.accent)),
                    const SizedBox(height: 10),
                    Text(_charName,
                        style: DsTypography.serif(28, color: it.textPrimary)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (props.read) const DsChip(label: 'READ'),
                        if (props.write) const DsChip(label: 'WRITE'),
                        if (props.writeWithoutResponse)
                          const DsChip(label: 'WRITE NO RSP'),
                        if (props.notify)
                          const DsChip(
                              label: 'NOTIFY', variant: DsChipVariant.notify),
                        if (props.indicate)
                          const DsChip(
                              label: 'INDICATE', variant: DsChipVariant.notify),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.characteristic.characteristicUuid.str,
                      style: DsTypography.monoStyle(10.5, color: it.textDim,
                          letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
              if (_tabController != null) ...[
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: it.border)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: it.textPrimary,
                    unselectedLabelColor: it.textDim,
                    indicatorColor: it.accent,
                    indicatorWeight: 2,
                    labelStyle: DsTypography.sans(13, color: it.textPrimary,
                        weight: FontWeight.w600),
                    unselectedLabelStyle: DsTypography.sans(13, color: it.textDim,
                        weight: FontWeight.w500),
                    tabs: _tabs.map((t) => Tab(text: t)).toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      if (_canRead)
                        _ReadTab(
                          value: state.lastValue,
                          format: state.format,
                          onRead: cubit.doRead,
                          onFormatChange: cubit.setFormat,
                        ),
                      if (_canWrite)
                        _WriteTab(
                          input: state.writeInput,
                          onInputChange: cubit.setWriteInput,
                          onWrite: cubit.doWrite,
                          negotiatedMtu: widget.negotiatedMtu,
                          isWriteNoResponse:
                              props.writeWithoutResponse && !props.write,
                        ),
                      if (_canNotify)
                        _NotifyTab(
                          notifying: state.notifying,
                          stream: state.packets,
                          onToggle: state.notifying
                              ? cubit.stopNotify
                              : cubit.startNotify,
                          format: state.format,
                        ),
                    ],
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: Text(
                      'No supported operations',
                      style: DsTypography.sans(14, color: it.textDim),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ReadTab extends StatelessWidget {
  const _ReadTab({
    required this.value,
    required this.format,
    required this.onRead,
    required this.onFormatChange,
  });

  final List<int> value;
  final ValueFormat format;
  final VoidCallback onRead;
  final void Function(ValueFormat) onFormatChange;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Last value · ${value.isEmpty ? '—' : '${value.length} byte${value.length == 1 ? '' : 's'}'}',
                  style: DsTypography.monoStyle(10, color: it.textFaint,
                      letterSpacing: 1.4),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: ValueFormat.values.map((f) {
                  final active = f == format;
                  return GestureDetector(
                    onTap: () => onFormatChange(f),
                    child: Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: active ? it.textPrimary : Colors.transparent,
                        border: Border.all(
                            color: active ? it.textPrimary : it.border),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        f.label(),
                        style: DsTypography.monoStyle(10, color: active ? it.background : it.textDim,
                            letterSpacing: 0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DsCard(
            padding: const EdgeInsets.all(DsSpace.s24),
            child: SelectableText(
              value.isEmpty ? '—' : format.format(value),
              style:
                  DsTypography.monoStyle(22, color: it.textPrimary, letterSpacing: 0.4),
            ),
          ),
          const SizedBox(height: 14),
          DsButton(
            label: 'Read',
            icon: Icons.download,
            onPressed: onRead,
          ),
        ],
      ),
    );
  }
}

class _WriteTab extends StatefulWidget {
  const _WriteTab({
    required this.input,
    required this.onInputChange,
    required this.onWrite,
    required this.negotiatedMtu,
    required this.isWriteNoResponse,
  });

  final String input;
  final void Function(String) onInputChange;
  final VoidCallback onWrite;
  final int negotiatedMtu;
  final bool isWriteNoResponse;

  @override
  State<_WriteTab> createState() => _WriteTabState();
}

class _WriteTabState extends State<_WriteTab> {
  static const _quickFill = ['00', '01', 'FF', '0A0B0C'];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.input);
  }

  @override
  void didUpdateWidget(covariant _WriteTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.input != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.input,
        selection: TextSelection.collapsed(offset: widget.input.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    final byteCount =
        (widget.input.replaceAll(RegExp(r'\s'), '').length / 2).floor();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payload (hex)',
              style:
                  DsTypography.monoStyle(10, color: it.textFaint, letterSpacing: 1.4)),
          const SizedBox(height: 10),
          DsCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(DsRadius.medium),
            child: TextField(
              controller: _controller,
              onChanged: widget.onInputChange,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
              ],
              style: DsTypography.monoStyle(16, color: it.textPrimary),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: InputBorder.none,
                hintText: 'e.g. 01 FF A0',
                hintStyle: DsTypography.monoStyle(16, color: it.textFaint),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '$byteCount BYTE · MAX ${widget.negotiatedMtu > 3 ? widget.negotiatedMtu - 3 : 0}',
                  style: DsTypography.monoStyle(10, color: it.textDim,
                      letterSpacing: 0.5)),
              Text(
                  widget.isWriteNoResponse
                      ? 'WRITE_WITHOUT_RSP'
                      : 'WRITE_REQUEST',
                  style: DsTypography.monoStyle(10, color: it.textDim,
                      letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 18),
          Text('Quick fill',
              style:
                  DsTypography.monoStyle(10, color: it.textFaint, letterSpacing: 1.4)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 4,
            children: _quickFill
                .map((p) => GestureDetector(
                      onTap: () => widget.onInputChange(p.replaceAll(' ', '')),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: it.border),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Center(
                          child: Text(p,
                              style: DsTypography.monoStyle(12, color: it.textPrimary)),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 18),
          DsButton(
              label: 'Write', icon: Icons.upload, onPressed: widget.onWrite),
        ],
      ),
    );
  }
}

class _NotifyTab extends StatelessWidget {
  const _NotifyTab({
    required this.notifying,
    required this.stream,
    required this.onToggle,
    required this.format,
  });

  final bool notifying;
  final List<NotifyPacket> stream;
  final VoidCallback onToggle;
  final ValueFormat format;

  @override
  Widget build(BuildContext context) {
    final it = DsColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notifying ? 'Subscribed' : 'Subscribe to notifications',
                      style: DsTypography.serif(15, color: it.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notifying
                          ? '${stream.length} packet${stream.length == 1 ? '' : 's'} · CCCD 0x0001'
                          : 'CCCD 0x0000',
                      style: DsTypography.monoStyle(11, color: it.textDim),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 30,
                  decoration: BoxDecoration(
                    color: notifying ? it.accent : it.surfaceHi,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: notifying
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('· Stream',
                  style: DsTypography.monoStyle(10, color: it.textFaint,
                      letterSpacing: 1.4)),
              Text(
                notifying ? 'LIVE' : 'IDLE',
                style: DsTypography.monoLabel(10, color: notifying ? it.accent : it.textFaint),
              ),
            ],
          ),
        ),
        Container(height: 1, color: it.border),
        Expanded(
          child: stream.isEmpty
              ? Center(
                  child: Text(
                    notifying
                        ? 'Waiting for first packet…'
                        : 'Toggle to subscribe.',
                    style: DsTypography.serifItalic(13, color: it.textDim),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                  itemCount: stream.length,
                  separatorBuilder: (_, __) =>
                      Container(height: 1, color: it.border),
                  itemBuilder: (_, i) {
                    final p = stream[i];
                    final parsed = p.parsed;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  format.format(p.bytes),
                                  style:
                                      DsTypography.monoStyle(12, color: it.textPrimary),
                                ),
                                if (parsed != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    parsed,
                                    style: DsTypography.serifItalic(13, color: it.accent),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${p.timestamp.hour.toString().padLeft(2, '0')}:'
                            '${p.timestamp.minute.toString().padLeft(2, '0')}:'
                            '${p.timestamp.second.toString().padLeft(2, '0')}',
                            style: DsTypography.monoStyle(10, color: it.textFaint),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
