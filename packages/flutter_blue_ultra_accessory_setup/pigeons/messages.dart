// Pigeon schema for the AccessorySetupKit bridge.
//
// Run `dart run pigeon --input pigeons/messages.dart` to regenerate the Dart
// and Swift channel code. Generated files:
//   - lib/src/messages.g.dart
//   - ios/flutter_blue_ultra_accessory_setup/Sources/flutter_blue_ultra_accessory_setup/Messages.g.swift
//
// Pigeon schema conventions: `@HostApi`/`@FlutterApi` must be abstract classes
// (one_member_abstracts), and doc comments reference cross-package types that
// aren't imported here (comment_references).
// ignore_for_file: one_member_abstracts, comment_references
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartOptions: DartOptions(),
  swiftOut:
      'ios/flutter_blue_ultra_accessory_setup/Sources/flutter_blue_ultra_accessory_setup/Messages.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'flutter_blue_ultra_accessory_setup',
))

/// Mirrors `ASAccessoryEventType`. Raw values are not exposed to Dart; the
/// native side maps the platform enum onto these cases.
enum AccessoryEventType {
  unknown,
  activated,
  invalidated,
  migrationComplete,
  accessoryAdded,
  accessoryRemoved,
  accessoryChanged,
  accessoryDiscovered,
  pickerDidPresent,
  pickerDidDismiss,
  pickerSetupBridging,
  pickerSetupFailed,
  pickerSetupPairing,
  pickerSetupRename,
}

/// Mirrors `ASAccessoryState`.
enum AccessoryState {
  unauthorized,
  awaitingAuthorization,
  authorized,
}

/// A serializable view of `NSError` raised by the native layer.
class NativeError {
  NativeError({
    required this.domain,
    required this.code,
    required this.message,
  });

  String domain;
  int code;
  String message;
}

/// A serializable view of `ASAccessory`. The real native object is retained on
/// the host side, keyed by [bluetoothIdentifier].
class Accessory {
  Accessory({
    this.bluetoothIdentifier,
    required this.displayName,
    required this.state,
    this.ssid,
  });

  String? bluetoothIdentifier;
  String displayName;
  AccessoryState state;
  String? ssid;
}

/// A session event delivered from the native layer to Dart.
class AccessoryEvent {
  AccessoryEvent({
    required this.type,
    this.accessory,
    this.error,
  });

  AccessoryEventType type;
  Accessory? accessory;
  NativeError? error;
}

/// Configuration for a single entry shown in the picker.
class PickerDisplayItem {
  PickerDisplayItem({
    required this.name,
    required this.imageBytes,
    this.serviceUuid,
  });

  String name;
  Uint8List imageBytes;
  String? serviceUuid;
}

/// Mirrors `ASAccessory.RenameOptions`.
class RenameOptions {
  RenameOptions({this.renameSSID = false});

  bool renameSSID;
}

/// Mirrors the mutable fields of `ASAccessorySettings`.
class AccessorySettings {
  AccessorySettings({
    this.ssid,
    this.bluetoothTransportBridgingIdentifier,
  });

  String? ssid;
  Uint8List? bluetoothTransportBridgingIdentifier;
}

/// Dart -> native calls. Methods that wrap an AccessorySetupKit completion
/// handler are `@async`; their futures complete (or throw a [PlatformException])
/// when the native callback fires.
@HostApi()
abstract class AccessorySetupApi {
  /// Activates the session. Returns immediately; the
  /// [AccessoryEventType.activated] event signals completion.
  void activate();

  @async
  void showPicker();

  @async
  void showPickerForItems(List<PickerDisplayItem> items);

  @async
  void showPickerForDevice(String name, Uint8List imageBytes, String serviceUuid);

  @async
  void removeAccessory(String accessoryId);

  @async
  void renameAccessory(String accessoryId, RenameOptions options);

  @async
  void finishAuthorization(String accessoryId, AccessorySettings settings);

  @async
  void failAuthorization(String accessoryId);

  List<Accessory> getAccessories();

  List<String> getLogs();

  void invalidate();
}

/// Native -> Dart calls.
@FlutterApi()
abstract class AccessorySetupFlutterApi {
  void onAccessoryEvent(AccessoryEvent event);
}
