import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/src/messages.g.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records calls and lets tests control completion / failures of the Pigeon
/// host API without a platform channel.
class FakeAccessorySetupApi extends AccessorySetupApi {
  final List<String> calls = [];

  List<PickerDisplayItem>? lastItems;
  String? lastAccessoryId;
  RenameOptions? lastRenameOptions;
  AccessorySettings? lastSettings;

  List<Accessory> accessories = [];

  /// When set, [showPicker] returns this future instead of completing
  /// immediately. Used to exercise the in-progress guard.
  Completer<void>? showPickerCompleter;

  /// When non-null, the next completion-based call fails with this exception.
  PlatformException? nextError;

  Future<void> _result(String name) {
    calls.add(name);
    final error = nextError;
    if (error != null) {
      nextError = null;
      return Future<void>.error(error);
    }
    return Future<void>.value();
  }

  @override
  Future<void> activate() {
    calls.add('activate');
    return Future<void>.value();
  }

  @override
  Future<void> showPicker() {
    calls.add('showPicker');
    final completer = showPickerCompleter;
    if (completer != null) {
      return completer.future;
    }
    final error = nextError;
    if (error != null) {
      nextError = null;
      return Future<void>.error(error);
    }
    return Future<void>.value();
  }

  @override
  Future<void> showPickerForItems(List<PickerDisplayItem> items) {
    lastItems = items;
    return _result('showPickerForItems');
  }

  @override
  Future<void> showPickerForDevice(String name, Uint8List imageBytes, String serviceUuid) {
    return _result('showPickerForDevice');
  }

  @override
  Future<void> removeAccessory(String accessoryId) {
    lastAccessoryId = accessoryId;
    return _result('removeAccessory');
  }

  @override
  Future<void> renameAccessory(String accessoryId, RenameOptions options) {
    lastAccessoryId = accessoryId;
    lastRenameOptions = options;
    return _result('renameAccessory');
  }

  @override
  Future<void> finishAuthorization(String accessoryId, AccessorySettings settings) {
    lastAccessoryId = accessoryId;
    lastSettings = settings;
    return _result('finishAuthorization');
  }

  @override
  Future<void> failAuthorization(String accessoryId) {
    lastAccessoryId = accessoryId;
    return _result('failAuthorization');
  }

  @override
  Future<List<Accessory>> getAccessories() {
    calls.add('getAccessories');
    return Future<List<Accessory>>.value(accessories);
  }

  @override
  Future<List<String>> getLogs() {
    calls.add('getLogs');
    return Future<List<String>>.value(const []);
  }

  @override
  Future<void> invalidate() {
    return _result('invalidate');
  }
}

Accessory _accessory({String? id = 'AA', AccessoryState state = AccessoryState.authorized}) {
  return Accessory(bluetoothIdentifier: id, displayName: 'Device', state: state);
}

AccessoryEvent _event(AccessoryEventType type) => AccessoryEvent(type: type);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAccessorySetupApi api;
  late FlutterAccessorySetup sut;

  setUp(() {
    api = FakeAccessorySetupApi();
    sut = FlutterAccessorySetup(api: api);
  });

  tearDown(() {
    sut.dispose();
  });

  test('activate calls the host api', () async {
    await sut.activate();
    expect(api.calls, equals(['activate']));
  });

  test('dispose invalidates the native session', () {
    sut.dispose();
    expect(api.calls, contains('invalidate'));
  });

  test('throws after dispose', () async {
    sut.dispose();
    expect(() => sut.activate(), throwsA(isA<StateError>()));
  });

  test('ignores events received after dispose', () {
    sut.dispose();
    expect(() => sut.onAccessoryEvent(_event(AccessoryEventType.invalidated)), returnsNormally);
  });

  test('throws when a second instance is constructed before the first is disposed', () {
    // `sut` is already live (from setUp); a second instance would silently
    // steal its events, so the constructor must reject it.
    expect(() => FlutterAccessorySetup(api: FakeAccessorySetupApi()), throwsA(isA<StateError>()));
  });

  test('allows a new instance after the previous is disposed', () {
    sut.dispose();
    final next = FlutterAccessorySetup(api: FakeAccessorySetupApi());
    addTearDown(next.dispose);
    expect(next, isNotNull);
  });

  // Events

  test('emits events in order', () {
    final types = [
      AccessoryEventType.activated,
      AccessoryEventType.pickerDidPresent,
      AccessoryEventType.accessoryAdded,
      AccessoryEventType.pickerDidDismiss,
      AccessoryEventType.accessoryRemoved,
      AccessoryEventType.invalidated,
    ];

    expectLater(
      sut.eventStream.map((e) => e.type),
      emitsInOrder(types),
    ).timeout(const Duration(seconds: 1));

    types.map(_event).forEach(sut.onAccessoryEvent);
  });

  test('event stream supports multiple listeners', () async {
    final event = _event(AccessoryEventType.activated);
    final first = expectLater(sut.eventStream, emits(event)).timeout(const Duration(seconds: 1));
    final second = expectLater(sut.eventStream, emits(event)).timeout(const Duration(seconds: 1));

    sut.onAccessoryEvent(event);
    await Future.wait([first, second]);
  });

  // Picker

  test('shows picker', () async {
    await sut.showPicker().timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['showPicker']));
  });

  test('shows picker for items', () async {
    final items = [
      PickerDisplayItem(name: 'D', imageBytes: Uint8List(0), serviceUuid: '1234'),
    ];
    await sut.showPickerForItems(items).timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['showPickerForItems']));
    expect(api.lastItems, equals(items));
  });

  test('rejects a second picker call while the first is pending', () async {
    api.showPickerCompleter = Completer<void>();
    final first = sut.showPicker();

    await expectLater(sut.showPickerForItems(const []), throwsA(isA<StateError>()));

    api.showPickerCompleter!.complete();
    await first.timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['showPicker']));
  });

  test('showPickerForDevice clears in-progress state on a pre-call failure', () async {
    // The asset is not registered, so rootBundle.load throws before the host
    // call and the picker-in-progress flag must be cleared.
    await expectLater(
        sut.showPickerForDevice('Device', 'missing_asset.png', '1234'), throwsA(anything));

    await sut.showPicker().timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['showPicker']));
  });

  // Accessory operations

  test('removes an accessory by id', () async {
    await sut.removeAccessory(_accessory(id: 'XY')).timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['removeAccessory']));
    expect(api.lastAccessoryId, equals('XY'));
  });

  test('renames an accessory by id with options', () async {
    final options = RenameOptions(renameSSID: true);
    await sut.renameAccessory(_accessory(id: 'XY'), options).timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['renameAccessory']));
    expect(api.lastAccessoryId, equals('XY'));
    expect(api.lastRenameOptions, equals(options));
  });

  test('finishes authorization with settings', () async {
    final settings = AccessorySettings(ssid: 'net');
    await sut
        .finishAuthorizationForAccessory(_accessory(id: 'XY'), settings)
        .timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['finishAuthorization']));
    expect(api.lastAccessoryId, equals('XY'));
    expect(api.lastSettings, equals(settings));
  });

  test('fails authorization by id', () async {
    await sut
        .failAuthorizationForAccessory(_accessory(id: 'XY'))
        .timeout(const Duration(seconds: 1));
    expect(api.calls, equals(['failAuthorization']));
    expect(api.lastAccessoryId, equals('XY'));
  });

  test('throws when an accessory has no bluetoothIdentifier', () {
    expect(() => sut.removeAccessory(_accessory(id: null)),
        throwsA(isA<FlutterAccessorySetupError>()));
  });

  // Error mapping

  test('maps PlatformException to NativeCodeError', () async {
    api.nextError = PlatformException(code: '42', message: 'boom', details: 'com.test.domain');
    await expectLater(
      sut.removeAccessory(_accessory(id: 'XY')),
      throwsA(isA<NativeCodeError>()
          .having((e) => e.code, 'code', 42)
          .having((e) => e.domain, 'domain', 'com.test.domain')
          .having((e) => e.description, 'description', 'boom')),
    );
  });

  test('event.failure maps the wire NativeError to NativeCodeError', () {
    final event = AccessoryEvent(
      type: AccessoryEventType.pickerSetupFailed,
      error: NativeError(domain: 'com.test', code: 7, message: 'nope'),
    );
    final failure = event.failure;
    expect(failure, isA<NativeCodeError>());
    expect(failure!.domain, equals('com.test'));
    expect(failure.code, equals(7));
    expect(failure.description, equals('nope'));
    expect(_event(AccessoryEventType.activated).failure, isNull);
  });
}
