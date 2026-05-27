import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';
import 'package:flutter_blue_ultra_accessory_setup/src/helpers.dart';
import 'package:flutter_blue_ultra_accessory_setup/src/testing.dart';
import 'package:objective_c/objective_c.dart';

/// The main class of the library that provides service functionality
/// Use it to activate the session and find and configure devices
class FlutterAccessorySetup {
  Stream<ASAccessoryEvent> get eventStream => _eventsController.stream;
  List<ASAccessory> get accessories => _sessionAdapter.accessories.toList();
  late final FFIAccessorySessionAdapter _sessionAdapter;
  final _eventsController = StreamController<ASAccessoryEvent>.broadcast();
  bool _isDisposed = false;

  DelegateAdapter? _delegateAdapter;

  // TODO: bind completers to accessories to enable multiple calls
  Completer<void>? _showPickerCompleter;
  Completer<void>? _renameAccessoryCompleter;
  Completer<void>? _removeAccessoryCompleter;
  Completer<void>? _finishAuthorizationForAccessoryCompleter;
  Completer<void>? _failAuthorizationForAccessoryCompleter;

  late NSArray Function(List<Object>) _convertToNSArray;
  late NativeCodeError Function(NSError) _convertToNativeCodeError;

  FlutterAccessorySetup({
    FFIAccessorySessionAdapter? sessionAdapter,
    DelegateAdapterFactory delegateAdapterFactory = DelegateAdapter.new,
    NSArray Function(List<Object>)? listConverter,
    NativeCodeError Function(NSError)? nsErrorConverter,
  }) {
    _convertToNSArray = listConverter ?? (list) => list.toNSArray();
    _convertToNativeCodeError = nsErrorConverter ?? (nsError) => NativeCodeError(nsError);
    _sessionAdapter =
        sessionAdapter ?? FFIAccessorySessionAdapter(FFIAccessorySession.alloc().init());
    _delegateAdapter = delegateAdapterFactory(
        handleEvent: _handleEvent,
        didShowPickerWithError: _didShowPicker,
        didRenameAccessoryWithError: _didRenameAccessory,
        didRemoveAccessoryWithError: _didRemoveAccessory,
        didFinishAuthorizationForAccessoryWithError: _didFinishAuthorization,
        didFailAuthorizationForAccessoryWithError: _didFailAuthorization);
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    // Invalidate can prevent native callbacks from arriving, so fail pending
    // public futures before tearing down the session.
    _completePendingOperationCompletersWithDisposeError();
    _sessionAdapter.invalidate();
    _eventsController.close();
    _delegateAdapter = null;
  }

  // region Interface

  /// Activates the session.
  /// You should activate the session before using it
  void activate() {
    _throwIfDisposed();
    _sessionAdapter.setDelegateAdapter(_delegateAdapter!);
    _sessionAdapter.activate();
  }

  /// Shows device picker
  Future<void> showPicker() async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _showPickerCompleter = completer;
    _sessionAdapter.showPicker();
    return completer.future;
  }

  /// Shows device picker configured with list of `ASPickerDisplayItem`
  Future<void> showPickerForItems(List<ASPickerDisplayItem> items) async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _showPickerCompleter = completer;
    _sessionAdapter.showPickerForItems_(_convertToNSArray(items));
    return completer.future;
  }

  /// Shows device picker configured for a single device
  /// parameters:
  /// - name: the name of the device to display in picker
  /// - asset: the asset of the device image to display in picker
  /// - serviceID: the service UUID advertised by device (to search for a particular device)
  Future<void> showPickerForDevice(
    String name,
    String asset,
    String serviceID,
  ) async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _showPickerCompleter = completer;

    final image = await nativeUIImageWithDartAsset(asset);
    _throwIfDisposed();
    if (image == null) {
      throw FlutterAccessorySetupError(
          code: 1, description: "Failed to load UIImage for the asset: $asset");
    }
    final descriptor = ASDiscoveryDescriptor.alloc().init();
    descriptor.bluetoothServiceUUID = CBUUID.UUIDWithString_(serviceID.toNSString());
    final item = ASPickerDisplayItem.alloc()
        .initWithName_productImage_descriptor_(name.toNSString(), image, descriptor);
    _sessionAdapter.showPickerForItems_(_convertToNSArray([item]));
    return completer.future;
  }

  /// Renames provided accessory using the `ASAccessoryRenameOptions`
  Future<void> renameAccessory(ASAccessory accessory, ASAccessoryRenameOptions options) async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _renameAccessoryCompleter = completer;
    _sessionAdapter.renameAccessory_options_(accessory, options);
    return completer.future;
  }

  /// Removes provided accessory (disconnects from the app)
  Future<void> removeAccessory(ASAccessory accessory) async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _removeAccessoryCompleter = completer;
    _sessionAdapter.removeAccessory_(accessory);
    return completer.future;
  }

  /// Finishes the Authorization for accessory using `ASAccessorySettings`
  Future<void> finishAuthorizationForAccessory(
      ASAccessory accessory, ASAccessorySettings settings) async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _finishAuthorizationForAccessoryCompleter = completer;
    _sessionAdapter.finishAuthorizationForAccessory_settings_(accessory, settings);
    return completer.future;
  }

  /// Fails the Authorization for the accessory
  Future<void> failAuthorizationForAccessory(ASAccessory accessory) async {
    _throwIfDisposed();
    final completer = Completer<void>();
    _failAuthorizationForAccessoryCompleter = completer;
    _sessionAdapter.failAuthorizationForAccessory_(accessory);
    return completer.future;
  }

  // endregion

  // region Delegate

  void _handleEvent(ASAccessoryEvent event) {
    if (_isDisposed) {
      return;
    }
    _eventsController.add(event);
  }

  void _didShowPicker(NSError? nsError) {
    if (nsError != null) {
      _showPickerCompleter?.completeError(_convertToNativeCodeError(nsError));
      return;
    }
    _showPickerCompleter?.complete();
  }

  void _didRenameAccessory(ASAccessory accessory, NSError? nsError) {
    if (nsError != null) {
      _renameAccessoryCompleter?.completeError(_convertToNativeCodeError(nsError));
      return;
    }
    _renameAccessoryCompleter?.complete();
  }

  void _didRemoveAccessory(ASAccessory accessory, NSError? nsError) {
    if (nsError != null) {
      _removeAccessoryCompleter?.completeError(_convertToNativeCodeError(nsError));
      return;
    }
    _removeAccessoryCompleter?.complete();
  }

  void _didFinishAuthorization(ASAccessory accessory, NSError? nsError) {
    if (nsError != null) {
      _finishAuthorizationForAccessoryCompleter?.completeError(_convertToNativeCodeError(nsError));
      return;
    }
    _finishAuthorizationForAccessoryCompleter?.complete();
  }

  void _didFailAuthorization(ASAccessory accessory, NSError? nsError) {
    if (nsError != null) {
      _failAuthorizationForAccessoryCompleter?.completeError(_convertToNativeCodeError(nsError));
      return;
    }
    _failAuthorizationForAccessoryCompleter?.complete();
  }

  // endregion

  // region Helpers

  void _throwIfDisposed() {
    if (_isDisposed) {
      throw StateError('FlutterAccessorySetup has been disposed.');
    }
  }

  void _completePendingOperationCompletersWithDisposeError() {
    final disposeError = StateError('FlutterAccessorySetup has been disposed.');
    _completePendingCompleterWithError(_showPickerCompleter, disposeError);
    _showPickerCompleter = null;
    _completePendingCompleterWithError(_renameAccessoryCompleter, disposeError);
    _renameAccessoryCompleter = null;
    _completePendingCompleterWithError(_removeAccessoryCompleter, disposeError);
    _removeAccessoryCompleter = null;
    _completePendingCompleterWithError(_finishAuthorizationForAccessoryCompleter, disposeError);
    _finishAuthorizationForAccessoryCompleter = null;
    _completePendingCompleterWithError(_failAuthorizationForAccessoryCompleter, disposeError);
    _failAuthorizationForAccessoryCompleter = null;
  }

  static void _completePendingCompleterWithError(Completer<void>? completer, Object error) {
    if (completer == null || completer.isCompleted) {
      return;
    }
    completer.completeError(error);
  }

  /// Prints logs from the native code
  /// Use it for debugging the native part of the code
  void printNativeSessionLogs() {
    _throwIfDisposed();
    final logs = _sessionAdapter.logs.toDartStringList();
    debugPrint("logs count: ${logs.length}");
    for (final log in logs) {
      debugPrint(log);
    }
  }

  // Loads an image from the flutter dart asset
  static Future<UIImage?> nativeUIImageWithDartAsset(String asset) async {
    final bytes = await rootBundle.load(asset);
    return UIImage.imageWithData_(bytes.toNSData());
  }

  // endregion
}

/// The class for errors occurred in the Dart code of the library
class FlutterAccessorySetupError implements Exception {
  final int code;
  final String description;

  FlutterAccessorySetupError({required this.code, required this.description});

  @override
  String toString() => 'FlutterAccessorySetupError(code: $code, description: $description)';
}

/// The class for errors occurred in the Native code of the library
class NativeCodeError implements Exception {
  final String domain;
  final int code;
  final String description;

  NativeCodeError(NSError nsError)
      : code = nsError.code,
        domain = nsError.domain.toDartString(),
        description = nsError.localizedDescription.toDartString();

  @override
  String toString() => 'NativeCodeError(domain: $domain, code: $code, description: $description)';
}

/// Exposing native properties as Dart types
extension ASAccessoryDartExtension on ASAccessory {
  String? get dartBluetoothIdentifier {
    return bluetoothIdentifier?.toDartUUIDString();
  }

  String get dartDisplayName {
    return displayName.toDartString();
  }
}

/// Exposing native properties as Dart types
extension ASAccessoryEventDartExtension on ASAccessoryEvent {
  NativeCodeError? get dartError {
    final nsError = error;
    if (nsError != null) {
      return NativeCodeError(nsError);
    }
    return null;
  }

  String get dartDescription {
    final pickedAccessory = accessory;
    final accessoryDescription = pickedAccessory == null
        ? null
        : 'Accessory(name: ${pickedAccessory.dartDisplayName}, '
            'id: ${pickedAccessory.dartBluetoothIdentifier}, '
            'state: ${pickedAccessory.state})';
    return 'AccessoryEvent($eventType, accessory: $accessoryDescription, '
        'error: $dartError)';
  }
}
