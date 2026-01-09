part of '../flutter_blue_ultra.dart';

/// Backward-compatible wrapper: use `FlutterBluePlus` with the same API,
/// internally delegating to `FlutterBlueUltra` to preserve behavior and state.
@Deprecated('Use FlutterBlueUltra instead')
class FlutterBluePlus {
  @Deprecated('Use FlutterBlueUltra.logLevel instead')
  static LogLevel get logLevel => FlutterBlueUltra.logLevel;

  @Deprecated('Use FlutterBlueUltra.isSupported instead')
  static Future<bool> get isSupported async => FlutterBlueUltra.isSupported;

  @Deprecated('Use FlutterBlueUltra.adapterStateNow instead')
  static BluetoothAdapterState get adapterStateNow => FlutterBlueUltra.adapterStateNow;

  @Deprecated('Use FlutterBlueUltra.adapterName instead')
  static Future<String> get adapterName async => FlutterBlueUltra.adapterName;

  @Deprecated('Use FlutterBlueUltra.isScanning instead')
  static Stream<bool> get isScanning => FlutterBlueUltra.isScanning;

  @Deprecated('Use FlutterBlueUltra.isScanningNow instead')
  static bool get isScanningNow => FlutterBlueUltra.isScanningNow;

  @Deprecated('Use FlutterBlueUltra.lastScanResults instead')
  static List<ScanResult> get lastScanResults => FlutterBlueUltra.lastScanResults;

  @Deprecated('Use FlutterBlueUltra.scanResults instead')
  static Stream<List<ScanResult>> get scanResults => FlutterBlueUltra.scanResults;

  @Deprecated('Use FlutterBlueUltra.onScanResults instead')
  static Stream<List<ScanResult>> get onScanResults => FlutterBlueUltra.onScanResults;

  @Deprecated('Use FlutterBlueUltra.events instead')
  static final BluetoothEvents events = FlutterBlueUltra.events;

  @Deprecated('Use FlutterBlueUltra.logs instead')
  static Stream<String> get logs => FlutterBlueUltra.logs;

  @Deprecated('Use FlutterBlueUltra.setOptions instead')
  static Future<void> setOptions({
    bool showPowerAlert = true,
    bool restoreState = false,
  }) async =>
      FlutterBlueUltra.setOptions(showPowerAlert: showPowerAlert, restoreState: restoreState);

  @Deprecated('Use FlutterBlueUltra.turnOn instead')
  static Future<void> turnOn({int timeout = 60}) async => FlutterBlueUltra.turnOn(timeout: timeout);

  @Deprecated('Use FlutterBlueUltra.adapterState instead')
  static Stream<BluetoothAdapterState> get adapterState async* {
    yield* FlutterBlueUltra.adapterState;
  }

  @Deprecated('Use FlutterBlueUltra.connectedDevices instead')
  static List<BluetoothDevice> get connectedDevices => FlutterBlueUltra.connectedDevices;

  @Deprecated('Use FlutterBlueUltra.systemDevices instead')
  static Future<List<BluetoothDevice>> systemDevices(List<Guid> withServices) async =>
      FlutterBlueUltra.systemDevices(withServices);

  @Deprecated('Use FlutterBlueUltra.bondedDevices instead')
  static Future<List<BluetoothDevice>> get bondedDevices async => FlutterBlueUltra.bondedDevices;

  @Deprecated('Use FlutterBlueUltra.startScan instead')
  static Future<void> startScan({
    List<Guid> withServices = const [],
    List<String> withRemoteIds = const [],
    List<String> withNames = const [],
    List<String> withKeywords = const [],
    List<MsdFilter> withMsd = const [],
    List<ServiceDataFilter> withServiceData = const [],
    Duration? timeout,
    Duration? removeIfGone,
    bool continuousUpdates = false,
    int continuousDivisor = 1,
    bool oneByOne = false,
    bool androidLegacy = false,
    AndroidScanMode androidScanMode = AndroidScanMode.lowLatency,
    bool androidUsesFineLocation = false,
    bool androidCheckLocationServices = true,
    List<Guid> webOptionalServices = const [],
  }) async =>
      FlutterBlueUltra.startScan(
        withServices: withServices,
        withRemoteIds: withRemoteIds,
        withNames: withNames,
        withKeywords: withKeywords,
        withMsd: withMsd,
        withServiceData: withServiceData,
        timeout: timeout,
        removeIfGone: removeIfGone,
        continuousUpdates: continuousUpdates,
        continuousDivisor: continuousDivisor,
        oneByOne: oneByOne,
        androidLegacy: androidLegacy,
        androidScanMode: androidScanMode,
        androidUsesFineLocation: androidUsesFineLocation,
        androidCheckLocationServices: androidCheckLocationServices,
        webOptionalServices: webOptionalServices,
      );

  @Deprecated('Use FlutterBlueUltra.stopScan instead')
  static Future<void> stopScan() async => FlutterBlueUltra.stopScan();

  @Deprecated('Use FlutterBlueUltra.cancelWhenScanComplete instead')
  static void cancelWhenScanComplete(StreamSubscription subscription) =>
      FlutterBlueUltra.cancelWhenScanComplete(subscription);

  @Deprecated('Use FlutterBlueUltra.setLogLevel instead')
  static Future<void> setLogLevel(LogLevel level, {color = true}) async =>
      FlutterBlueUltra.setLogLevel(level, color: color);

  @Deprecated('Use FlutterBlueUltra.getPhySupport instead')
  static Future<PhySupport> getPhySupport() async => FlutterBlueUltra.getPhySupport();

  @Deprecated('Deprecated in Android SDK 33 with no replacement')
  static Future<void> turnOff({int timeout = 10}) async => FlutterBlueUltra.turnOff(timeout: timeout);

  @Deprecated('Use adapterState.first == BluetoothAdapterState.on instead')
  static Future<bool> get isOn async => FlutterBlueUltra.isOn;

  @Deprecated('Use adapterName instead')
  static Future<String> get name => FlutterBlueUltra.name;

  @Deprecated('Use adapterState instead')
  static Stream<BluetoothAdapterState> get state => FlutterBlueUltra.state;

  @Deprecated('Use systemDevices instead')
  static Future<List<BluetoothDevice>> get connectedSystemDevices => FlutterBlueUltra.connectedSystemDevices;

  @Deprecated('No longer needed, remove this from your code')
  // ignore: avoid_returning_null_for_void
  static void get instance => FlutterBlueUltra.instance;

  @Deprecated('Use isSupported instead')
  static Future<bool> get isAvailable async => FlutterBlueUltra.isAvailable;

  @Deprecated('removed. read MIGRATION.md for simple alternatives')
  static Stream<ScanResult> scan() => FlutterBlueUltra.scan();
}
