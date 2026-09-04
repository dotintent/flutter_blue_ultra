import 'dart:async';
import 'dart:io' show Platform;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import '../models/ble_models.dart';

const Duration _kRssiPollInterval = Duration(seconds: 2);
const int _kRequestedMtu = 512;

class DeviceState extends Equatable {
  const DeviceState({
    this.connState = ConnectionPhase.disconnected,
    this.failure = DeviceFailure.none,
    this.services = const [],
    this.expanded = const {},
    this.mtu = 23,
    this.currentRssi = 0,
    this.latencyMs,
  });

  final ConnectionPhase connState;
  final DeviceFailure failure;
  final List<BluetoothService> services;
  final Set<String> expanded;
  final int mtu;
  final int currentRssi;
  final int? latencyMs;

  DeviceState copyWith({
    ConnectionPhase? connState,
    DeviceFailure? failure,
    List<BluetoothService>? services,
    Set<String>? expanded,
    int? mtu,
    int? currentRssi,
    int? latencyMs,
  }) =>
      DeviceState(
        connState: connState ?? this.connState,
        failure: failure ?? this.failure,
        services: services ?? this.services,
        expanded: expanded ?? this.expanded,
        mtu: mtu ?? this.mtu,
        currentRssi: currentRssi ?? this.currentRssi,
        latencyMs: latencyMs ?? this.latencyMs,
      );

  @override
  List<Object?> get props => [
        connState,
        failure,
        services,
        expanded,
        mtu,
        currentRssi,
        latencyMs,
      ];
}

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit({required this.device, required int initialRssi})
      : super(DeviceState(currentRssi: initialRssi));

  final BluetoothDevice device;

  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<({int rssi, int latencyMs})>? _rssiSub;
  bool _discoverInFlight = false;
  bool _reachedConnected = false;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  /// One-shot UI events (snackbars). See [CharacteristicCubit.messages] for
  /// the rationale: keeps transient messages out of state so identical ones
  /// fired twice in a row both reach the listener.
  Stream<String> get messages => _messages.stream;

  Future<void> connect() async {
    if (state.connState == ConnectionPhase.connecting ||
        state.connState == ConnectionPhase.discovering ||
        state.connState == ConnectionPhase.connected) {
      return;
    }
    await _rssiSub?.cancel();
    _rssiSub = null;
    await _connSub?.cancel();
    _connSub = null;
    _reachedConnected = false;
    emit(state.copyWith(
      connState: ConnectionPhase.connecting,
      failure: DeviceFailure.none,
    ));
    try {
      _connSub = device.connectionState.listen((s) {
        if (isClosed) return;
        if (s == BluetoothConnectionState.connected) {
          _discover();
        } else if (s == BluetoothConnectionState.disconnected) {
          emit(state.copyWith(
            connState: ConnectionPhase.disconnected,
            failure: _reachedConnected
                ? DeviceFailure.connectionLost
                : DeviceFailure.connectFailed,
          ));
        }
      });

      await device.connect(autoConnect: false);
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        connState: ConnectionPhase.disconnected,
        failure: DeviceFailure.connectFailed,
      ));
      _messages.add('Connection failed: $e');
    }
  }

  Future<void> _discover() async {
    if (_discoverInFlight) return;
    _discoverInFlight = true;
    emit(state.copyWith(connState: ConnectionPhase.discovering));
    try {
      final services = await device.discoverServices();
      int mtu = state.mtu;
      if (Platform.isAndroid) {
        try {
          mtu = await device.requestMtu(_kRequestedMtu);
        } catch (e) {
          _messages.add('MTU request failed: $e');
        }
      }
      if (isClosed) return;
      _reachedConnected = true;
      final newExpanded = Set<String>.from(state.expanded);
      if (services.isNotEmpty) {
        newExpanded.add(services.last.serviceUuid.str);
      }
      emit(state.copyWith(
        services: services,
        mtu: mtu,
        connState: ConnectionPhase.connected,
        failure: DeviceFailure.none,
        expanded: newExpanded,
      ));
      _startRssi();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        connState: ConnectionPhase.disconnected,
        failure: DeviceFailure.discoveryFailed,
      ));
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
    //
    // The round-trip time of the same call doubles as the "latency" stat —
    // it is a real GATT round trip rather than a synthetic number.
    _rssiSub = Stream.periodic(_kRssiPollInterval)
        .asyncMap((_) => _measureRssi())
        .listen(
      (sample) {
        if (isClosed) return;
        emit(state.copyWith(
          currentRssi: sample.rssi,
          latencyMs: sample.latencyMs,
        ));
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<({int rssi, int latencyMs})> _measureRssi() async {
    final started = DateTime.now();
    final rssi = await device.readRssi();
    return (
      rssi: rssi,
      latencyMs: DateTime.now().difference(started).inMilliseconds,
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
    await _connSub?.cancel();
    _connSub = null;
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
