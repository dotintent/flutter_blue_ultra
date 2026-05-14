import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import '../widgets/atoms.dart';

const Duration _kRssiPollInterval = Duration(seconds: 2);
const int _kRequestedMtu = 512;

class DeviceState extends Equatable {
  const DeviceState({
    this.connState = ConnectionDotState.disconnected,
    this.services = const [],
    this.expanded = const {},
    this.mtu = 23,
    this.currentRssi = 0,
  });

  final ConnectionDotState connState;
  final List<BluetoothService> services;
  final Set<String> expanded;
  final int mtu;
  final int currentRssi;

  DeviceState copyWith({
    ConnectionDotState? connState,
    List<BluetoothService>? services,
    Set<String>? expanded,
    int? mtu,
    int? currentRssi,
  }) =>
      DeviceState(
        connState: connState ?? this.connState,
        services: services ?? this.services,
        expanded: expanded ?? this.expanded,
        mtu: mtu ?? this.mtu,
        currentRssi: currentRssi ?? this.currentRssi,
      );

  @override
  List<Object?> get props => [connState, services, expanded, mtu, currentRssi];
}

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit({required this.device, required int initialRssi})
      : super(DeviceState(currentRssi: initialRssi));

  final BluetoothDevice device;

  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<int>? _rssiSub;
  bool _discoverInFlight = false;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  /// One-shot UI events (snackbars). See [CharacteristicCubit.messages] for
  /// the rationale: keeps transient messages out of state so identical ones
  /// fired twice in a row both reach the listener.
  Stream<String> get messages => _messages.stream;

  Future<void> connect() async {
    if (state.connState == ConnectionDotState.connecting ||
        state.connState == ConnectionDotState.discovering ||
        state.connState == ConnectionDotState.connected) {
      return;
    }
    await _rssiSub?.cancel();
    _rssiSub = null;
    await _connSub?.cancel();
    _connSub = null;
    emit(state.copyWith(connState: ConnectionDotState.connecting));
    try {
      _connSub = device.connectionState.listen((s) {
        if (isClosed) return;
        if (s == BluetoothConnectionState.connected) {
          _discover();
        } else if (s == BluetoothConnectionState.disconnected) {
          emit(state.copyWith(connState: ConnectionDotState.disconnected));
        }
      });

      await device.connect(autoConnect: false);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(connState: ConnectionDotState.disconnected));
      _messages.add('Connection failed: $e');
    }
  }

  Future<void> _discover() async {
    if (_discoverInFlight) return;
    _discoverInFlight = true;
    emit(state.copyWith(connState: ConnectionDotState.discovering));
    try {
      final services = await device.discoverServices();
      int mtu = state.mtu;
      try {
        mtu = await device.requestMtu(_kRequestedMtu);
      } catch (e) {
        _messages.add('MTU request failed: $e');
      }
      if (isClosed) return;
      final newExpanded = Set<String>.from(state.expanded);
      if (services.isNotEmpty) {
        newExpanded.add(services.last.serviceUuid.str);
      }
      emit(state.copyWith(
        services: services,
        mtu: mtu,
        connState: ConnectionDotState.connected,
        expanded: newExpanded,
      ));
      _startRssi();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(connState: ConnectionDotState.disconnected));
      _messages.add('Service discovery failed: $e');
    } finally {
      _discoverInFlight = false;
    }
  }

  void _startRssi() {
    _rssiSub?.cancel();
    // `readRssi` throws when the link is gone. Without `onError` the
    // unhandled error tears down the subscription and the RSSI display
    // freezes at its last value with no visible feedback — so we swallow
    // the error and let the connection-state listener drive the UI back
    // to "disconnected".
    _rssiSub = Stream.periodic(_kRssiPollInterval)
        .asyncMap((_) => device.readRssi())
        .listen(
      (rssi) {
        if (isClosed) return;
        emit(state.copyWith(currentRssi: rssi));
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  void toggleService(String uuid) {
    final next = Set<String>.from(state.expanded);
    if (next.contains(uuid)) {
      next.remove(uuid);
    } else {
      next.add(uuid);
    }
    emit(state.copyWith(expanded: next));
  }

  Future<void> disconnect() async {
    await _rssiSub?.cancel();
    _rssiSub = null;
    await device.disconnect();
  }

  @override
  Future<void> close() async {
    await _connSub?.cancel();
    await _rssiSub?.cancel();
    await _messages.close();
    await device.disconnect();
    return super.close();
  }
}
