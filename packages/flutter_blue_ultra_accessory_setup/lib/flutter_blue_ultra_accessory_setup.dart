import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:flutter_blue_ultra_accessory_setup/src/messages.g.dart';

export 'package:flutter_blue_ultra_accessory_setup/src/messages.g.dart'
    show
        Accessory,
        AccessoryEvent,
        AccessoryEventType,
        AccessoryState,
        AccessorySettings,
        PickerDisplayItem,
        RenameOptions;

/// The main entry point of the library.
///
/// Use it to activate the session and to discover and configure accessories
/// through Apple's AccessorySetupKit. The native session is a singleton; create
/// a single instance and [dispose] it when you are done.
class FlutterAccessorySetup implements AccessorySetupFlutterApi {
  FlutterAccessorySetup({@visibleForTesting AccessorySetupApi? api})
      : _api = api ?? AccessorySetupApi() {
    if (_instance != null) {
      throw StateError(
        'A FlutterAccessorySetup instance already exists. The native session and '
        'its event channel are app-wide singletons — dispose() the existing '
        'instance before creating another.',
      );
    }
    _instance = this;
    AccessorySetupFlutterApi.setUp(this);
  }

  /// The single live instance. The native `ASAccessorySession` and the Pigeon
  /// event channel are app-wide, so a second instance would silently steal the
  /// first's events — guarded against in the constructor.
  static FlutterAccessorySetup? _instance;

  final AccessorySetupApi _api;
  final _eventsController = StreamController<AccessoryEvent>.broadcast();
  bool _isDisposed = false;
  bool _isShowPickerInProgress = false;

  /// Stream of session events delivered from the native layer.
  Stream<AccessoryEvent> get eventStream => _eventsController.stream;

  /// The accessories currently authorized for this app.
  Future<List<Accessory>> getAccessories() {
    _throwIfDisposed();
    return _guard(() => _api.getAccessories());
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    if (identical(_instance, this)) {
      _instance = null;
    }
    AccessorySetupFlutterApi.setUp(null);
    unawaited(_api.invalidate());
    _eventsController.close();
  }

  // region Interface

  /// Activates the session. You should activate before using it; the
  /// [AccessoryEventType.activated] event signals that activation completed.
  Future<void> activate() {
    _throwIfDisposed();
    return _guard(() => _api.activate());
  }

  /// Shows the device picker.
  Future<void> showPicker() {
    return _runPickerOperation(() => _api.showPicker());
  }

  /// Shows the device picker configured with a list of [PickerDisplayItem]s.
  Future<void> showPickerForItems(List<PickerDisplayItem> items) {
    return _runPickerOperation(() => _api.showPickerForItems(items));
  }

  /// Shows the device picker configured for a single device.
  ///
  /// - [name]: the device name to display in the picker.
  /// - [asset]: the Flutter asset path of the device image to display.
  /// - [serviceID]: the service UUID advertised by the device.
  Future<void> showPickerForDevice(
    String name,
    String asset,
    String serviceID,
  ) {
    return _runPickerOperation(() async {
      final bytes = await rootBundle.load(asset);
      _throwIfDisposed();
      await _api.showPickerForDevice(
        name,
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        serviceID,
      );
    });
  }

  /// Renames the provided accessory using [RenameOptions].
  Future<void> renameAccessory(Accessory accessory, RenameOptions options) {
    return _guard(() => _api.renameAccessory(_requireId(accessory), options));
  }

  /// Removes the provided accessory (disconnects it from the app).
  Future<void> removeAccessory(Accessory accessory) {
    return _guard(() => _api.removeAccessory(_requireId(accessory)));
  }

  /// Finishes the authorization for the accessory using [AccessorySettings].
  Future<void> finishAuthorizationForAccessory(
      Accessory accessory, AccessorySettings settings) {
    return _guard(
        () => _api.finishAuthorization(_requireId(accessory), settings));
  }

  /// Fails the authorization for the accessory.
  Future<void> failAuthorizationForAccessory(Accessory accessory) {
    return _guard(() => _api.failAuthorization(_requireId(accessory)));
  }

  /// Prints logs collected by the native layer. Use it for debugging.
  Future<void> printNativeSessionLogs() async {
    _throwIfDisposed();
    final logs = await _api.getLogs();
    debugPrint('logs count: ${logs.length}');
    for (final log in logs) {
      debugPrint(log);
    }
  }

  // endregion

  // region AccessorySetupFlutterApi

  @override
  void onAccessoryEvent(AccessoryEvent event) {
    if (_isDisposed) {
      return;
    }
    _eventsController.add(event);
  }

  // endregion

  // region Helpers

  Future<void> _runPickerOperation(Future<void> Function() op) async {
    _throwIfDisposed();
    if (_isShowPickerInProgress) {
      throw StateError('A picker operation is already in progress.');
    }
    _isShowPickerInProgress = true;
    try {
      await _guard(op);
    } finally {
      _isShowPickerInProgress = false;
    }
  }

  Future<T> _guard<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on PlatformException catch (e) {
      throw NativeCodeError.fromPlatformException(e);
    }
  }

  String _requireId(Accessory accessory) {
    final id = accessory.bluetoothIdentifier;
    if (id == null) {
      throw FlutterAccessorySetupError(
        code: 1,
        description: 'Accessory has no bluetoothIdentifier.',
      );
    }
    return id;
  }

  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('FlutterAccessorySetup has been disposed.');
    }
  }

  // endregion
}

/// An error raised in the Dart layer of the library.
class FlutterAccessorySetupError implements Exception {
  FlutterAccessorySetupError({required this.code, required this.description});

  final int code;
  final String description;

  @override
  String toString() =>
      'FlutterAccessorySetupError(code: $code, description: $description)';
}

/// An error raised in the native layer of the library.
class NativeCodeError implements Exception {
  NativeCodeError({
    required this.domain,
    required this.code,
    required this.description,
  });

  /// Builds a [NativeCodeError] from a Pigeon [PlatformException]. The native
  /// layer encodes the `NSError` as `code` (numeric string), `message`
  /// (localized description) and `details` (domain).
  factory NativeCodeError.fromPlatformException(PlatformException e) {
    return NativeCodeError(
      domain: e.details is String ? e.details as String : '',
      code: int.tryParse(e.code) ?? 0,
      description: e.message ?? '',
    );
  }

  /// Maps the wire-level [NativeError] carried by an [AccessoryEvent] onto the
  /// library's single public error type.
  factory NativeCodeError.fromNativeError(NativeError e) {
    return NativeCodeError(
      domain: e.domain,
      code: e.code,
      description: e.message,
    );
  }

  final String domain;
  final int code;
  final String description;

  @override
  String toString() =>
      'NativeCodeError(domain: $domain, code: $code, description: $description)';
}

/// Convenience helpers for logging [AccessoryEvent]s.
extension AccessoryEventDartExtension on AccessoryEvent {
  /// The event's error, mapped to the library's single public error type
  /// ([NativeCodeError]), or `null` when the event carries no error.
  NativeCodeError? get failure =>
      error == null ? null : NativeCodeError.fromNativeError(error!);

  String get dartDescription {
    final picked = accessory;
    final accessoryDescription = picked == null
        ? null
        : 'Accessory(name: ${picked.displayName}, '
            'id: ${picked.bluetoothIdentifier}, state: ${picked.state})';
    return 'AccessoryEvent($type, accessory: $accessoryDescription, error: $error)';
  }
}
