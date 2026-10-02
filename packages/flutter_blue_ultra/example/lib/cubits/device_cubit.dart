import 'dart:async';
import 'dart:io' show Platform;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import '../models/ble_error_text.dart';
import '../models/ble_models.dart';
import '../widgets/app_snack_bar.dart';

const Duration _kRssiPollInterval = Duration(seconds: 2);
const Duration _kDisconnectTimeout = Duration(seconds: 3);
const int _kRequestedMtu = 512;

/// Connect attempts per user-initiated try. Radios routinely reject the first
/// attempt with a transient error (Android's GATT 133/147, CoreBluetooth's
/// connection timeout) and succeed immediately after, which is why a manual
/// "Retry" used to look like a fix — the app now does it for the user.
const int _kMaxConnectAttempts = 3;

/// Silent reconnects after an established link drops. Bounded so a device
/// that keeps dropping surfaces the failure instead of looping forever.
const int _kMaxAutoReconnects = 1;

/// A link that survived this long counts as healthy, so the next drop starts
/// a fresh reconnect budget. Without it a device that reconnects and drops
/// again seconds later would flap forever, since every success would clear
/// the budget it had just spent.
const Duration _kStableLinkThreshold = Duration(seconds: 30);

const List<Duration> _kRetryBackoff = [
  Duration(milliseconds: 400),
  Duration(milliseconds: 1200),
];

const Object _sentinel = Object();

class DeviceState extends Equatable {
  const DeviceState({
    this.connState = ConnectionPhase.disconnected,
    this.failure = DeviceFailure.none,
    this.failureDetail,
    this.services = const [],
    this.expanded = const {},
    this.mtu = 23,
    this.currentRssi = 0,
    this.latencyMs,
    this.attempt = 1,
    this.disconnecting = false,
  });

  final ConnectionPhase connState;
  final DeviceFailure failure;
  final String? failureDetail;
  final List<BluetoothService> services;
  final Set<String> expanded;
  final int mtu;
  final int currentRssi;
  final int? latencyMs;
  final int attempt;
  final bool disconnecting;

  int get maxAttempts => _kMaxConnectAttempts;

  bool get retrying => attempt > 1;

  DeviceState copyWith({
    ConnectionPhase? connState,
    DeviceFailure? failure,
    Object? failureDetail = _sentinel,
    List<BluetoothService>? services,
    Set<String>? expanded,
    int? mtu,
    int? currentRssi,
    int? latencyMs,
    int? attempt,
    bool? disconnecting,
  }) =>
      DeviceState(
        connState: connState ?? this.connState,
        failure: failure ?? this.failure,
        failureDetail: failureDetail == _sentinel
            ? this.failureDetail
            : failureDetail as String?,
        services: services ?? this.services,
        expanded: expanded ?? this.expanded,
        mtu: mtu ?? this.mtu,
        currentRssi: currentRssi ?? this.currentRssi,
        latencyMs: latencyMs ?? this.latencyMs,
        attempt: attempt ?? this.attempt,
        disconnecting: disconnecting ?? this.disconnecting,
      );

  @override
  List<Object?> get props => [
        connState,
        failure,
        failureDetail,
        services,
        expanded,
        mtu,
        currentRssi,
        latencyMs,
        attempt,
        disconnecting,
      ];
}

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit({required this.device, required int initialRssi})
      : super(DeviceState(currentRssi: initialRssi));

  final BluetoothDevice device;

  StreamSubscription<BluetoothConnectionState>? _connSub;
  StreamSubscription<({int rssi, int latencyMs})>? _rssiSub;
  Timer? _retryTimer;
  bool _discoverInFlight = false;
  bool _reachedConnected = false;
  bool _abandoned = false;
  int _autoReconnects = 0;
  DateTime? _connectedAt;
  final StreamController<AppMessage> _messages =
      StreamController<AppMessage>.broadcast();

  /// One-shot UI events (snackbars). See [CharacteristicCubit.messages] for
  /// the rationale: keeps transient messages out of state so identical ones
  /// fired twice in a row both reach the listener.
  Stream<AppMessage> get messages => _messages.stream;

  Future<void> connect() async {
    if (state.connState == ConnectionPhase.connecting ||
        state.connState == ConnectionPhase.discovering ||
        state.connState == ConnectionPhase.connected) {
      return;
    }
    _abandoned = false;
    _autoReconnects = 0;
    _connectedAt = null;
    await _attempt(1);
  }

  Future<void> _attempt(int attempt) async {
    if (isClosed || _abandoned) return;

    _retryTimer?.cancel();
    await _rssiSub?.cancel();
    _rssiSub = null;
    await _connSub?.cancel();
    _connSub = null;
    _reachedConnected = false;

    if (isClosed || _abandoned) return;
    emit(state.copyWith(
      connState: ConnectionPhase.connecting,
      failure: DeviceFailure.none,
      failureDetail: null,
      attempt: attempt,
    ));

    try {
      // `connectionState` replays the cached state on listen, which is
      // `disconnected` for a device we have never connected to. Only a drop
      // *after* we reached `connected` is a real failure here — connect-time
      // failures surface as a throw from `device.connect()` below.
      _connSub = device.connectionState.listen((s) {
        if (isClosed || _abandoned) return;
        if (s == BluetoothConnectionState.connected) {
          _discover();
        } else if (s == BluetoothConnectionState.disconnected &&
            _reachedConnected) {
          _onLinkDropped();
        }
      });

      await device.connect(autoConnect: false);
    } catch (e) {
      if (isClosed || _abandoned) return;
      if (attempt < _kMaxConnectAttempts && isRetryableBleError(e)) {
        _scheduleRetry(attempt + 1);
        return;
      }
      emit(state.copyWith(
        connState: ConnectionPhase.disconnected,
        failure: DeviceFailure.connectFailed,
        failureDetail: describeBleError(e),
      ));
      _messages
          .add(AppMessage.error('Connection failed. ${describeBleError(e)}'));
    }
  }

  void _scheduleRetry(int attempt) {
    // The stack keeps the failed link cached; clearing it first is what makes
    // the immediate retry succeed as reliably as a manual one does.
    unawaited(_safeDisconnect());
    emit(state.copyWith(
      connState: ConnectionPhase.connecting,
      attempt: attempt,
    ));
    final backoff =
        _kRetryBackoff[(attempt - 2).clamp(0, _kRetryBackoff.length - 1)];
    _retryTimer = Timer(backoff, () => unawaited(_attempt(attempt)));
  }

  void _onLinkDropped() {
    unawaited(_rssiSub?.cancel());
    _rssiSub = null;

    final connectedAt = _connectedAt;
    if (connectedAt != null &&
        DateTime.now().difference(connectedAt) > _kStableLinkThreshold) {
      _autoReconnects = 0;
    }
    _connectedAt = null;

    if (_autoReconnects < _kMaxAutoReconnects) {
      _autoReconnects++;
      _messages.add(const AppMessage.warning('Link dropped — reconnecting…'));
      _scheduleRetry(1);
      return;
    }

    emit(state.copyWith(
      connState: ConnectionPhase.disconnected,
      failure: DeviceFailure.connectionLost,
      failureDetail: 'The device stopped responding after '
          '${_autoReconnects + 1} attempts.',
    ));
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
          _messages.add(
            AppMessage.warning('MTU request failed. ${describeBleError(e)}'),
          );
        }
      }
      if (isClosed || _abandoned) return;
      _reachedConnected = true;
      _connectedAt = DateTime.now();
      emit(state.copyWith(
        services: services,
        mtu: mtu,
        connState: ConnectionPhase.connected,
        failure: DeviceFailure.none,
        failureDetail: null,
        attempt: 1,
      ));
      _startRssi();
    } catch (e) {
      if (isClosed || _abandoned) return;
      emit(state.copyWith(
        connState: ConnectionPhase.disconnected,
        failure: DeviceFailure.discoveryFailed,
        failureDetail: describeBleError(e),
      ));
      _messages.add(
        AppMessage.error('Service discovery failed. ${describeBleError(e)}'),
      );
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

  /// Abandons an in-flight connect. Returns as soon as the app has stopped
  /// caring about the attempt — the platform teardown runs in the background
  /// so the screen can close immediately instead of waiting on a radio that
  /// is, by definition, not responding.
  Future<void> cancelConnect() async {
    _abandoned = true;
    _retryTimer?.cancel();
    await _connSub?.cancel();
    _connSub = null;
    await _rssiSub?.cancel();
    _rssiSub = null;
    if (!isClosed) {
      emit(state.copyWith(
        connState: ConnectionPhase.disconnected,
        failure: DeviceFailure.none,
        failureDetail: null,
        attempt: 1,
      ));
    }
    unawaited(_safeDisconnect());
  }

  /// Tears down an established link. Unlike [cancelConnect] this waits for the
  /// platform so the caller can report a failure rather than claiming success.
  Future<bool> disconnect() async {
    _abandoned = true;
    _retryTimer?.cancel();
    await _connSub?.cancel();
    _connSub = null;
    await _rssiSub?.cancel();
    _rssiSub = null;
    if (!isClosed) emit(state.copyWith(disconnecting: true));

    try {
      await device.disconnect().timeout(_kDisconnectTimeout);
      if (!isClosed) {
        emit(state.copyWith(
          connState: ConnectionPhase.disconnected,
          failure: DeviceFailure.none,
          failureDetail: null,
          disconnecting: false,
        ));
      }
      return true;
    } catch (e) {
      if (!isClosed) emit(state.copyWith(disconnecting: false));
      _messages.add(
        AppMessage.warning('Disconnect failed. ${describeBleError(e)}'),
      );
      return false;
    }
  }

  Future<void> _safeDisconnect() async {
    try {
      await device.disconnect().timeout(_kDisconnectTimeout);
    } catch (_) {
      // Nothing useful to do: the screen is going away either way, and an
      // uncaught error here would take the app down with it.
    }
  }

  @override
  Future<void> close() async {
    _abandoned = true;
    _retryTimer?.cancel();
    await _connSub?.cancel();
    await _rssiSub?.cancel();
    await _messages.close();
    await _safeDisconnect();
    return super.close();
  }
}
