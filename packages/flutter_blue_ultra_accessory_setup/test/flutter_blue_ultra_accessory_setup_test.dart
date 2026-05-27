import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';
import 'package:flutter_blue_ultra_accessory_setup/src/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:objective_c/objective_c.dart' as objc;

import 'mocks/delegate_adapter_mock.dart';
import 'mocks/ffi_accessory_event_mock.dart';
import 'mocks/ffi_accessory_mock.dart';
import 'mocks/ffi_accessory_session_mock.dart';
import 'mocks/ffi_accessory_settings_mock.dart';
import 'mocks/ffi_nserror_mock.dart';
import 'mocks/native_code_error_mock.dart';
import 'mocks/objc_ns_array_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FFIAccessorySessionMock sessionMock;
  late FFIAccessorySessionAdapter sessionAdapter;
  late FlutterAccessorySetup sut;
  late DelegateAdapterMock delegateAdapter;

  List<Object>? listToConvert;
  late objc.NSArray convertedList;

  objc.NSError? nsErrorToConvert;
  late NativeCodeError convertedError;

  setUp(() {
    convertedList = NSArrayMock();
    convertedError = NativeCodeErrorMock();
    sessionMock = FFIAccessorySessionMock();
    sessionAdapter = FFIAccessorySessionAdapter(sessionMock);
    sut = FlutterAccessorySetup(
        sessionAdapter: sessionAdapter,
        delegateAdapterFactory: DelegateAdapterMock.new,
        listConverter: (list) {
          listToConvert = list;
          return convertedList;
        },
        nsErrorConverter: (nsError) {
          nsErrorToConvert = nsError;
          return convertedError;
        });
    sut.activate();
    delegateAdapter = sessionAdapter.delegateAdapter as DelegateAdapterMock;
    sessionMock.resetMock();
  });

  tearDown(() {
    sut.dispose();
  });

  // Tests

  test('session calls activate and sets up delegate adapter when the `activate` method called',
      () async {
    // Given
    // When
    sut.activate();
    // Then
    expect(sessionAdapter.delegateAdapter, isNotNull);
    expect(sessionMock.calls,
        equals([SessionMockMethodCall.setDelegate, SessionMockMethodCall.activate]));
  });

  test('session calls invalidate when the `dispose` method called', () async {
    // Given
    // When
    sut.dispose();
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.invalidate]));
  });

  test('session ignores events received after dispose', () async {
    // Given
    final event = FFIASAccessoryEventMock(ASAccessoryEventType.ASAccessoryEventTypeInvalidated);
    sut.dispose();
    // When / Then
    expect(() => delegateAdapter.handleEvent(event), returnsNormally);
    expect(sessionMock.calls, equals([SessionMockMethodCall.invalidate]));
  });

  test('dispose completes pending showPicker future with StateError', () async {
    // Given
    // No native callback: the future stays pending until dispose completes it.
    final pendingFuture = sut.showPicker();

    // When
    sut.dispose();

    // Then
    await expectLater(pendingFuture, throwsA(isA<StateError>()));
    expect(sessionMock.calls,
        equals([SessionMockMethodCall.showPicker, SessionMockMethodCall.invalidate]));
  });

  test('dispose completes pending removeAccessory future with StateError', () async {
    // Given
    final accessory = FFIASAccessoryMock();
    // No native callback: the future stays pending until dispose completes it.
    final pendingFuture = sut.removeAccessory(accessory);

    // When
    sut.dispose();

    // Then
    await expectLater(pendingFuture, throwsA(isA<StateError>()));
    expect(sessionMock.calls,
        equals([SessionMockMethodCall.removeAccessory, SessionMockMethodCall.invalidate]));
  });

  test('session sends events', () async {
    // Given
    final expectedEvents = [
      ASAccessoryEventType.ASAccessoryEventTypeActivated,
      ASAccessoryEventType.ASAccessoryEventTypePickerDidPresent,
      ASAccessoryEventType.ASAccessoryEventTypeAccessoryAdded,
      ASAccessoryEventType.ASAccessoryEventTypePickerDidDismiss,
      ASAccessoryEventType.ASAccessoryEventTypeAccessoryChanged,
      ASAccessoryEventType.ASAccessoryEventTypeAccessoryRemoved,
      ASAccessoryEventType.ASAccessoryEventTypeInvalidated
    ].map((type) => FFIASAccessoryEventMock(type)).toList();

    // Then
    expectLater(
      sut.eventStream,
      emitsInOrder(expectedEvents),
    ).timeout(const Duration(seconds: 1));

    // When
    expectedEvents.forEach(delegateAdapter.handleEvent);
  });

  test('event stream supports multiple listeners', () async {
    // Given
    final event = FFIASAccessoryEventMock(ASAccessoryEventType.ASAccessoryEventTypeActivated);

    // Then
    final firstListener = expectLater(
      sut.eventStream,
      emits(event),
    ).timeout(const Duration(seconds: 1));
    final secondListener = expectLater(
      sut.eventStream,
      emits(event),
    ).timeout(const Duration(seconds: 1));

    // When
    delegateAdapter.handleEvent(event);

    // Then
    await Future.wait([firstListener, secondListener]);
  });

  // Success

  test('session shows picker', () async {
    // Given
    sessionMock.showPickerCallback = () => delegateAdapter.didShowPickerWithError(null);
    // When
    await sut.showPicker().timeout(const Duration(seconds: 1));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.showPicker]));
  });

  test('session shows picker for items', () async {
    // Given
    sessionMock.showPickerForItemsCallback = () => delegateAdapter.didShowPickerWithError(null);
    final List<ASPickerDisplayItem> items = [];
    // When
    await sut.showPickerForItems(items).timeout(const Duration(seconds: 1));
    // Then
    expect(listToConvert, equals(items));
    expect(sessionMock.calls, equals([SessionMockMethodCall.showPickerForItems]));
    expect(sessionMock.showPickerForItemsValue, equals(convertedList));
  });

  test('session renames accessory', () async {
    // Given
    final accessory = FFIASAccessoryMock();
    final options = ASAccessoryRenameOptions.ASAccessoryRenameSSID;
    sessionMock.renameAccessoryOptionsCallback =
        () => delegateAdapter.didRenameAccessoryWithError(accessory, null);
    // When
    await sut.renameAccessory(accessory, options).timeout(const Duration(seconds: 1));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.renameAccessoryOptions]));
    expect(sessionMock.renameAccessoryOptionsAccessoryValue, equals(accessory));
    expect(sessionMock.renameAccessoryOptionsOptionsValue, equals(options));
  });

  test('session removes accessory', () async {
    // Given
    final accessory = FFIASAccessoryMock();
    sessionMock.removeAccessoryCallback =
        () => delegateAdapter.didRemoveAccessoryWithError(accessory, null);
    // When
    await sut.removeAccessory(accessory).timeout(const Duration(seconds: 1));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.removeAccessory]));
    expect(sessionMock.removeAccessoryValue, equals(accessory));
  });

  test('session finishes authorization of the accessory', () async {
    // Given
    final accessory = FFIASAccessoryMock();
    final settings = FFIASAccessorySettingsMock();
    sessionMock.finishAuthorizationForAccessorySettingsCallback =
        () => delegateAdapter.didFinishAuthorizationForAccessoryWithError(accessory, null);
    // When
    await sut
        .finishAuthorizationForAccessory(accessory, settings)
        .timeout(const Duration(seconds: 1));
    // Then
    expect(
        sessionMock.calls, equals([SessionMockMethodCall.finishAuthorizationForAccessorySettings]));
    expect(sessionMock.finishAuthorizationForAccessorySettingsAccessoryValue, equals(accessory));
    expect(sessionMock.finishAuthorizationForAccessorySettingsSettingsValue, equals(settings));
  });

  test('session fails authorization of the accessory', () async {
    // Given
    final accessory = FFIASAccessoryMock();
    sessionMock.failAuthorizationForAccessoryCallback =
        () => delegateAdapter.didFailAuthorizationForAccessoryWithError(accessory, null);
    // When
    await sut.failAuthorizationForAccessory(accessory).timeout(const Duration(seconds: 1));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.failAuthorizationForAccessory]));
    expect(sessionMock.failAuthorizationForAccessoryValue, equals(accessory));
  });

  // Failures

  test('session throws errors when shows picker', () async {
    // Given
    final error = FFINSErrorMock();
    sessionMock.showPickerCallback = () => delegateAdapter.didShowPickerWithError(error);
    // When
    expect(
        () async => sut.showPicker().timeout(const Duration(seconds: 1)), throwsA(convertedError));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.showPicker]));
    expect(error, equals(nsErrorToConvert));
  });

  test('session throws errors when shows picker for items', () async {
    // Given
    final error = FFINSErrorMock();
    sessionMock.showPickerForItemsCallback = () => delegateAdapter.didShowPickerWithError(error);
    final List<ASPickerDisplayItem> items = [];
    // When
    expect(() async => sut.showPickerForItems(items).timeout(const Duration(seconds: 1)),
        throwsA(convertedError));
    // Then
    expect(listToConvert, equals(items));
    expect(sessionMock.calls, equals([SessionMockMethodCall.showPickerForItems]));
    expect(sessionMock.showPickerForItemsValue, equals(convertedList));
    expect(error, equals(nsErrorToConvert));
  });

  test('session throws errors when renames accessory', () async {
    // Given
    final error = FFINSErrorMock();
    final accessory = FFIASAccessoryMock();
    final options = ASAccessoryRenameOptions.ASAccessoryRenameSSID;
    sessionMock.renameAccessoryOptionsCallback =
        () => delegateAdapter.didRenameAccessoryWithError(accessory, error);
    // When
    expect(() async => sut.renameAccessory(accessory, options).timeout(const Duration(seconds: 1)),
        throwsA(convertedError));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.renameAccessoryOptions]));
    expect(sessionMock.renameAccessoryOptionsAccessoryValue, equals(accessory));
    expect(sessionMock.renameAccessoryOptionsOptionsValue, equals(options));
    expect(error, equals(nsErrorToConvert));
  });

  test('session removes accessory', () async {
    // Given
    final error = FFINSErrorMock();
    final accessory = FFIASAccessoryMock();
    sessionMock.removeAccessoryCallback =
        () => delegateAdapter.didRemoveAccessoryWithError(accessory, error);
    // When
    expect(() async => sut.removeAccessory(accessory).timeout(const Duration(seconds: 1)),
        throwsA(convertedError));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.removeAccessory]));
    expect(sessionMock.removeAccessoryValue, equals(accessory));
    expect(error, equals(nsErrorToConvert));
  });

  test('session finishes authorization of the accessory', () async {
    // Given
    final error = FFINSErrorMock();
    final accessory = FFIASAccessoryMock();
    final settings = FFIASAccessorySettingsMock();
    sessionMock.finishAuthorizationForAccessorySettingsCallback =
        () => delegateAdapter.didFinishAuthorizationForAccessoryWithError(accessory, error);
    // When
    expect(
        () async => sut
            .finishAuthorizationForAccessory(accessory, settings)
            .timeout(const Duration(seconds: 1)),
        throwsA(convertedError));
    // Then
    expect(
        sessionMock.calls, equals([SessionMockMethodCall.finishAuthorizationForAccessorySettings]));
    expect(sessionMock.finishAuthorizationForAccessorySettingsAccessoryValue, equals(accessory));
    expect(sessionMock.finishAuthorizationForAccessorySettingsSettingsValue, equals(settings));
    expect(error, equals(nsErrorToConvert));
  });

  test('session throws errors when fails authorization of the accessory', () async {
    // Given
    final error = FFINSErrorMock();
    final accessory = FFIASAccessoryMock();
    sessionMock.failAuthorizationForAccessoryCallback =
        () => delegateAdapter.didFailAuthorizationForAccessoryWithError(accessory, error);
    // When
    expect(
        () async =>
            sut.failAuthorizationForAccessory(accessory).timeout(const Duration(seconds: 1)),
        throwsA(convertedError));
    // Then
    expect(sessionMock.calls, equals([SessionMockMethodCall.failAuthorizationForAccessory]));
    expect(sessionMock.failAuthorizationForAccessoryValue, equals(accessory));
    expect(error, equals(nsErrorToConvert));
  });
}
