import 'dart:async';
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import '../models/ble_error_text.dart';
import '../models/ble_models.dart';
import '../widgets/app_snack_bar.dart';

const int _kNotifyRingBufferSize = 40;

/// How long a subscription may sit silent before the UI says so. Plenty of
/// characteristics only notify on change, and an indefinite spinner reads as
/// a hang rather than as "nothing has happened yet".
const Duration _kQuietNotifyHint = Duration(seconds: 10);

const Object _sentinel = Object();

class CharacteristicState extends Equatable {
  const CharacteristicState({
    this.lastValue = const [],
    this.notifying = false,
    this.writeInput = '01',
    this.format = ValueFormat.hex,
    this.packets = const [],
    this.reading = false,
    this.writing = false,
    this.lastReadAt,
    this.notifyQuiet = false,
  });

  final List<int> lastValue;
  final bool notifying;
  final String writeInput;
  final ValueFormat format;
  final List<NotifyPacket> packets;
  final bool reading;
  final bool writing;
  final DateTime? lastReadAt;
  final bool notifyQuiet;

  CharacteristicState copyWith({
    List<int>? lastValue,
    bool? notifying,
    String? writeInput,
    ValueFormat? format,
    List<NotifyPacket>? packets,
    bool? reading,
    bool? writing,
    Object? lastReadAt = _sentinel,
    bool? notifyQuiet,
  }) =>
      CharacteristicState(
        lastValue: lastValue ?? this.lastValue,
        notifying: notifying ?? this.notifying,
        writeInput: writeInput ?? this.writeInput,
        format: format ?? this.format,
        packets: packets ?? this.packets,
        reading: reading ?? this.reading,
        writing: writing ?? this.writing,
        lastReadAt:
            lastReadAt == _sentinel ? this.lastReadAt : lastReadAt as DateTime?,
        notifyQuiet: notifyQuiet ?? this.notifyQuiet,
      );

  @override
  List<Object?> get props => [
        lastValue,
        notifying,
        writeInput,
        format,
        packets,
        reading,
        writing,
        lastReadAt,
        notifyQuiet,
      ];
}

class CharacteristicCubit extends Cubit<CharacteristicState> {
  CharacteristicCubit({required this.characteristic})
      : super(const CharacteristicState()) {
    if (characteristic.properties.read) {
      doRead(announce: false);
    }
  }

  final BluetoothCharacteristic characteristic;
  StreamSubscription<List<int>>? _notifySub;
  Timer? _quietTimer;
  final StreamController<AppMessage> _messages =
      StreamController<AppMessage>.broadcast();

  /// One-shot UI events (snackbars). Distinct from state so identical messages
  /// fired twice in a row both arrive at the listener.
  Stream<AppMessage> get messages => _messages.stream;

  /// [announce] is off for the read the constructor fires: the screen is still
  /// opening, and a toast for work the user did not ask for is noise. Every
  /// button-driven read confirms itself — re-reading an unchanged value used
  /// to leave the screen looking completely inert.
  Future<void> doRead({bool announce = true}) async {
    if (isClosed || state.reading) return;
    emit(state.copyWith(reading: true));
    try {
      final value = await characteristic.read();
      if (isClosed) return;
      emit(state.copyWith(
        lastValue: value,
        reading: false,
        lastReadAt: DateTime.now(),
      ));
      if (announce) {
        final count = value.length;
        _messages.add(AppMessage.success(
          count == 0
              ? 'Read OK — the characteristic returned no bytes'
              : 'Read OK — $count ${count == 1 ? 'byte' : 'bytes'}',
        ));
      }
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(reading: false));
      _messages.add(AppMessage.error('Read failed. ${describeBleError(e)}'));
    }
  }

  Future<void> doWrite() async {
    if (isClosed || state.writing) return;
    final clean = state.writeInput.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) {
      _messages.add(
        const AppMessage.warning('Enter a hex payload before writing.'),
      );
      return;
    }
    if (clean.length.isOdd) {
      _messages.add(const AppMessage.warning(
        'Hex payload needs an even number of digits — one byte is two digits.',
      ));
      return;
    }
    emit(state.copyWith(writing: true));
    try {
      final bytes = _hexStringToBytes(clean);
      if (characteristic.properties.write) {
        await characteristic.write(bytes);
      } else {
        await characteristic.write(bytes, withoutResponse: true);
      }
      if (isClosed) return;
      emit(state.copyWith(writing: false));
      _messages.add(AppMessage.success(
        'Wrote ${bytes.length} ${bytes.length == 1 ? 'byte' : 'bytes'}',
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(writing: false));
      _messages.add(AppMessage.error('Write failed. ${describeBleError(e)}'));
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
        _quietTimer?.cancel();
        final next = [
          NotifyPacket(
            timestamp: DateTime.now(),
            bytes: value,
            parsed: _tryParse(value),
          ),
          ...state.packets,
        ];
        if (next.length > _kNotifyRingBufferSize) next.removeLast();
        emit(state.copyWith(
          lastValue: value,
          packets: next,
          notifyQuiet: false,
        ));
      });
      await characteristic.setNotifyValue(true);
      if (isClosed) return;
      emit(state.copyWith(notifying: true, notifyQuiet: false));
      _quietTimer?.cancel();
      _quietTimer = Timer(_kQuietNotifyHint, () {
        if (isClosed || !state.notifying || state.packets.isNotEmpty) return;
        emit(state.copyWith(notifyQuiet: true));
      });
    } catch (e) {
      await _notifySub?.cancel();
      _notifySub = null;
      if (isClosed) return;
      _messages.add(
        AppMessage.error('Subscribe failed. ${describeBleError(e)}'),
      );
    }
  }

  Future<void> stopNotify() async {
    _quietTimer?.cancel();
    await _notifySub?.cancel();
    _notifySub = null;
    try {
      await characteristic.setNotifyValue(false);
    } catch (_) {}
    if (isClosed) return;
    emit(state.copyWith(notifying: false, notifyQuiet: false));
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
    _quietTimer?.cancel();
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
