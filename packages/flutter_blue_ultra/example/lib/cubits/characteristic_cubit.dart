import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import '../models/ble_models.dart';

const int _kNotifyRingBufferSize = 40;

class CharacteristicState extends Equatable {
  const CharacteristicState({
    this.lastValue = const [],
    this.notifying = false,
    this.writeInput = '01',
    this.format = ValueFormat.hex,
    this.packets = const [],
  });

  final List<int> lastValue;
  final bool notifying;
  final String writeInput;
  final ValueFormat format;
  final List<NotifyPacket> packets;

  CharacteristicState copyWith({
    List<int>? lastValue,
    bool? notifying,
    String? writeInput,
    ValueFormat? format,
    List<NotifyPacket>? packets,
  }) =>
      CharacteristicState(
        lastValue: lastValue ?? this.lastValue,
        notifying: notifying ?? this.notifying,
        writeInput: writeInput ?? this.writeInput,
        format: format ?? this.format,
        packets: packets ?? this.packets,
      );

  @override
  List<Object?> get props =>
      [lastValue, notifying, writeInput, format, packets];
}

class CharacteristicCubit extends Cubit<CharacteristicState> {
  CharacteristicCubit({required this.characteristic})
      : super(const CharacteristicState()) {
    if (characteristic.properties.read) {
      doRead();
    }
  }

  final BluetoothCharacteristic characteristic;
  StreamSubscription<List<int>>? _notifySub;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  /// One-shot UI events (snackbars). Distinct from state so identical messages
  /// fired twice in a row both arrive at the listener.
  Stream<String> get messages => _messages.stream;

  Future<void> doRead() async {
    if (isClosed) return;
    try {
      final value = await characteristic.read();
      if (isClosed) return;
      emit(state.copyWith(lastValue: value));
    } catch (e) {
      _messages.add('Read failed: $e');
    }
  }

  Future<void> doWrite() async {
    if (isClosed) return;
    final clean = state.writeInput.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) {
      _messages.add('Payload is empty');
      return;
    }
    if (clean.length.isOdd) {
      _messages.add('Hex payload must have an even number of digits');
      return;
    }
    try {
      final bytes = _hexStringToBytes(clean);
      if (characteristic.properties.writeWithoutResponse) {
        await characteristic.write(bytes, withoutResponse: true);
      } else {
        await characteristic.write(bytes);
      }
      _messages.add('Written successfully');
    } catch (e) {
      _messages.add('Write failed: $e');
    }
  }

  Future<void> startNotify() async {
    if (isClosed) return;
    try {
      // Attach the listener BEFORE enabling notifications — otherwise the
      // peripheral may emit packets in the gap between setNotifyValue(true)
      // resolving and listen() registering, and we'd silently drop them.
      _notifySub = characteristic.onValueReceived.listen((value) {
        if (isClosed) return;
        final next = [
          NotifyPacket(
            timestamp: DateTime.now(),
            bytes: value,
            parsed: _tryParse(value),
          ),
          ...state.packets,
        ];
        if (next.length > _kNotifyRingBufferSize) next.removeLast();
        emit(state.copyWith(lastValue: value, packets: next));
      });
      await characteristic.setNotifyValue(true);
      if (isClosed) return;
      emit(state.copyWith(notifying: true));
    } catch (e) {
      _messages.add('Subscribe failed: $e');
    }
  }

  Future<void> stopNotify() async {
    await _notifySub?.cancel();
    _notifySub = null;
    try {
      await characteristic.setNotifyValue(false);
    } catch (_) {}
    if (isClosed) return;
    emit(state.copyWith(notifying: false));
  }

  void setWriteInput(String value) {
    if (isClosed) return;
    emit(state.copyWith(writeInput: value));
  }

  void setFormat(ValueFormat format) {
    if (isClosed) return;
    emit(state.copyWith(format: format));
  }

  @override
  Future<void> close() async {
    await _notifySub?.cancel();
    await _messages.close();
    try {
      await characteristic.setNotifyValue(false);
    } catch (_) {}
    return super.close();
  }

  static String? _tryParse(List<int> bytes) {
    try {
      final s = utf8.decode(bytes);
      if (s.codeUnits.every((c) => c >= 0x20 && c <= 0x7e)) return s;
    } catch (_) {}
    if (bytes.length == 1) return '${bytes.first}';
    if (bytes.length == 2) {
      final v = bytes[0] | (bytes[1] << 8);
      return '$v';
    }
    return null;
  }

  /// Caller is responsible for stripping whitespace and ensuring even length.
  /// See [doWrite] for the validation.
  static List<int> _hexStringToBytes(String clean) {
    final result = <int>[];
    for (int i = 0; i < clean.length; i += 2) {
      result.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}
