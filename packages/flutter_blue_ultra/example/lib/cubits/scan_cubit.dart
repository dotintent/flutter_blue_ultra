import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

const Duration _kScanDuration = Duration(seconds: 12);
const Duration _kElapsedTick = Duration(milliseconds: 200);

class ScanState extends Equatable {
  const ScanState({
    this.results = const [],
    this.scanning = false,
    this.elapsed = 0,
    this.adapterState = BluetoothAdapterState.unknown,
  });

  final List<ScanResult> results;
  final bool scanning;
  final double elapsed;
  final BluetoothAdapterState adapterState;

  ScanState copyWith({
    List<ScanResult>? results,
    bool? scanning,
    double? elapsed,
    BluetoothAdapterState? adapterState,
  }) =>
      ScanState(
        results: results ?? this.results,
        scanning: scanning ?? this.scanning,
        elapsed: elapsed ?? this.elapsed,
        adapterState: adapterState ?? this.adapterState,
      );

  @override
  List<Object?> get props => [results, scanning, elapsed, adapterState];
}

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(const ScanState()) {
    _isScanningSub = FlutterBlueUltra.isScanning.listen((v) {
      if (isClosed) return;
      if (!v) {
        _elapsedTimer?.cancel();
        _stopwatch.stop();
      }
      emit(state.copyWith(scanning: v));
    });
    // Wait for the adapter to be on before scanning — CoreBluetooth starts
    // as CBManagerStateUnknown and takes a moment to become ready.
    _adapterSub = FlutterBlueUltra.adapterState.listen((adapterState) {
      if (isClosed) return;
      emit(state.copyWith(adapterState: adapterState));
      if (adapterState != BluetoothAdapterState.on && state.scanning) {
        stopScan();
      }
      if (adapterState == BluetoothAdapterState.on &&
          !state.scanning &&
          state.results.isEmpty &&
          !_startInFlight) {
        startScan();
      }
    });
  }

  final Stopwatch _stopwatch = Stopwatch();
  StreamSubscription<List<ScanResult>>? _scanResultsSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  Timer? _elapsedTimer;
  bool _startInFlight = false;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  Stream<String> get messages => _messages.stream;

  Future<void> startScan() async {
    if (_startInFlight || state.scanning) return;
    if (state.adapterState != BluetoothAdapterState.on) {
      _messages.add('Bluetooth is not available for scanning.');
      return;
    }
    _startInFlight = true;
    await _scanResultsSub?.cancel();
    _scanResultsSub = null;
    _elapsedTimer?.cancel();
    _stopwatch
      ..reset()
      ..start();
    emit(state.copyWith(results: const [], elapsed: 0));
    _scanResultsSub = FlutterBlueUltra.onScanResults.listen((incoming) {
      if (isClosed) return;
      final merged = List<ScanResult>.from(state.results);
      for (final r in incoming) {
        final idx =
            merged.indexWhere((e) => e.device.remoteId == r.device.remoteId);
        if (idx >= 0) {
          merged[idx] = r;
        } else {
          merged.add(r);
        }
      }
      emit(state.copyWith(results: merged));
    });

    _elapsedTimer = Timer.periodic(_kElapsedTick, (_) {
      if (isClosed) return;
      emit(state.copyWith(elapsed: _stopwatch.elapsedMilliseconds / 1000));
    });

    try {
      await FlutterBlueUltra.startScan(timeout: _kScanDuration);
    } catch (e) {
      _elapsedTimer?.cancel();
      _stopwatch.stop();
      if (!isClosed) {
        emit(state.copyWith(scanning: false));
        _messages.add('Scan failed to start: $e');
      }
    } finally {
      _startInFlight = false;
    }
  }

  Future<void> stopScan() async {
    if (_startInFlight || !state.scanning) return;
    _elapsedTimer?.cancel();
    _stopwatch.stop();
    try {
      await FlutterBlueUltra.stopScan();
    } catch (e) {
      _messages.add('Scan failed to stop: $e');
    }
  }

  @override
  Future<void> close() async {
    _elapsedTimer?.cancel();
    _stopwatch.stop();
    await _scanResultsSub?.cancel();
    await _isScanningSub?.cancel();
    await _adapterSub?.cancel();
    await _messages.close();
    await FlutterBlueUltra.stopScan();
    return super.close();
  }
}
