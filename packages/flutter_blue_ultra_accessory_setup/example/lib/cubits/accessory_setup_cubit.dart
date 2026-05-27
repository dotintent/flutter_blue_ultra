import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_accessory_setup/flutter_blue_ultra_accessory_setup.dart';
import 'package:flutter_blue_ultra_accessory_setup/gen/ios/accessory_setup_bindings.dart';

import '../models/accessory_setup_config.dart';

class AccessorySetupState extends Equatable {
  const AccessorySetupState({
    this.isActivated = false,
    this.isPickerLoading = false,
    this.connectedId,
    this.authorizingId,
    this.initError,
    this.pendingAccessory,
    this.accessories = const [],
    this.verifiedPairedIds = const <String>{},
    this.eventLog = const [],
  });

  final bool isActivated;
  final bool isPickerLoading;
  final String? connectedId;
  final String? authorizingId;
  final String? initError;
  final ASAccessory? pendingAccessory;
  final List<ASAccessory> accessories;
  final Set<String> verifiedPairedIds;
  final List<String> eventLog;

  bool get canOpenPicker =>
      isActivated &&
      !isPickerLoading &&
      authorizingId == null &&
      initError == null;

  List<ASAccessory> get authorizedAccessories {
    final pendingId = pendingAccessory?.dartBluetoothIdentifier;
    return accessories
        .where((a) => a.state == ASAccessoryState.ASAccessoryStateAuthorized)
        .where((a) => verifiedPairedIds.contains(a.dartBluetoothIdentifier))
        .where((a) => a.dartBluetoothIdentifier != authorizingId)
        .where((a) => a.dartBluetoothIdentifier != pendingId)
        .toList(growable: false);
  }

  List<ASAccessory> get unverifiedAccessories {
    final pendingId = pendingAccessory?.dartBluetoothIdentifier;
    return accessories
        .where((a) => a.state == ASAccessoryState.ASAccessoryStateAuthorized)
        .where((a) => !verifiedPairedIds.contains(a.dartBluetoothIdentifier))
        .where((a) => a.dartBluetoothIdentifier != authorizingId)
        .where((a) => a.dartBluetoothIdentifier != pendingId)
        .toList(growable: false);
  }

  List<ASAccessory> get awaitingAuthorizationAccessories => accessories
      .where((a) =>
          a.state == ASAccessoryState.ASAccessoryStateAwaitingAuthorization)
      .toList(growable: false);

  List<ASAccessory> get unpairedAccessories => [
        ...unverifiedAccessories,
        ...awaitingAuthorizationAccessories,
      ];

  AccessorySetupState copyWith({
    bool? isActivated,
    bool? isPickerLoading,
    Object? connectedId = _sentinel,
    Object? authorizingId = _sentinel,
    Object? initError = _sentinel,
    Object? pendingAccessory = _sentinel,
    List<ASAccessory>? accessories,
    Set<String>? verifiedPairedIds,
    List<String>? eventLog,
  }) {
    return AccessorySetupState(
      isActivated: isActivated ?? this.isActivated,
      isPickerLoading: isPickerLoading ?? this.isPickerLoading,
      connectedId: identical(connectedId, _sentinel)
          ? this.connectedId
          : connectedId as String?,
      authorizingId: identical(authorizingId, _sentinel)
          ? this.authorizingId
          : authorizingId as String?,
      initError: identical(initError, _sentinel)
          ? this.initError
          : initError as String?,
      pendingAccessory: identical(pendingAccessory, _sentinel)
          ? this.pendingAccessory
          : pendingAccessory as ASAccessory?,
      accessories: accessories ?? this.accessories,
      verifiedPairedIds: verifiedPairedIds ?? this.verifiedPairedIds,
      eventLog: eventLog ?? this.eventLog,
    );
  }

  @override
  List<Object?> get props => [
        isActivated,
        isPickerLoading,
        connectedId,
        authorizingId,
        initError,
        pendingAccessory,
        accessories,
        verifiedPairedIds,
        eventLog,
      ];
}

const Object _sentinel = Object();

class AccessorySetupCubit extends Cubit<AccessorySetupState> {
  AccessorySetupCubit({
    this.config = accessorySetupConfig,
    FlutterAccessorySetup? accessorySetup,
  })  : _accessorySetup = accessorySetup ?? FlutterAccessorySetup(),
        super(const AccessorySetupState());

  final AccessorySetupConfig config;
  final FlutterAccessorySetup _accessorySetup;

  StreamSubscription<ASAccessoryEvent>? _eventsSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  final StreamController<String> _messages =
      StreamController<String>.broadcast();

  Stream<String> get messages => _messages.stream;

  void initialize() {
    try {
      _eventsSubscription = _accessorySetup.eventStream.listen(_onEvent);
      _accessorySetup.activate();
    } catch (e) {
      emit(state.copyWith(initError: '$e'));
      _log('setup init error: $e');
    }
  }

  void _onEvent(ASAccessoryEvent event) {
    _log('event: ${event.dartDescription}');
    if (isClosed) return;

    final eventType = event.eventType;
    final accessories = _accessorySetup.accessories;
    switch (eventType) {
      case ASAccessoryEventType.ASAccessoryEventTypeActivated:
        emit(state.copyWith(
          isActivated: true,
          accessories: accessories,
        ));
      case ASAccessoryEventType.ASAccessoryEventTypeAccessoryAdded:
      case ASAccessoryEventType.ASAccessoryEventTypeAccessoryChanged:
        emit(state.copyWith(
          pendingAccessory: event.accessory,
          accessories: accessories,
        ));
      case ASAccessoryEventType.ASAccessoryEventTypePickerDidDismiss:
        emit(state.copyWith(
          isPickerLoading: false,
          accessories: accessories,
        ));
        _onPickerDismissed();
      case ASAccessoryEventType.ASAccessoryEventTypeAccessoryRemoved:
        emit(state.copyWith(
          pendingAccessory: null,
          accessories: accessories,
        ));
      default:
        emit(state.copyWith(accessories: accessories));
    }
  }

  void _onPickerDismissed() {
    final accessory = state.pendingAccessory;

    final id = accessory?.dartBluetoothIdentifier;
    if (accessory == null || id == null) {
      emit(state.copyWith(pendingAccessory: null));
      _log('picker dismissed without a picked accessory');
      return;
    }
    if (accessory.state ==
        ASAccessoryState.ASAccessoryStateAwaitingAuthorization) {
      emit(state.copyWith(pendingAccessory: null, authorizingId: id));
      _removeTemporaryAccessory(accessory, id);
      return;
    }
    if (accessory.state != ASAccessoryState.ASAccessoryStateAuthorized) {
      emit(state.copyWith(pendingAccessory: null));
      _log('accessory not authorized, state: ${accessory.state}');
      return;
    }
    emit(state.copyWith(pendingAccessory: null, authorizingId: id));
    connectWithoutScanning(id, pickedAccessory: accessory);
  }

  Future<void> showPicker() async {
    if (!state.canOpenPicker) return;
    emit(state.copyWith(isPickerLoading: true));
    try {
      await _removeUnverifiedAccessories();
      await FlutterBlueUltra.stopScan();
      await _accessorySetup.showPickerForDevice(
        config.deviceName,
        config.assetPath,
        config.serviceUuid,
      );
    } on NativeCodeError catch (e) {
      emit(state.copyWith(isPickerLoading: false));
      _log('picker error (native): $e');
      _messages.add('Picker error: ${e.description}');
    } catch (e) {
      emit(state.copyWith(isPickerLoading: false));
      _log('picker error: $e');
      _messages.add('Picker error: $e');
    }
  }

  Future<void> removeAccessory(ASAccessory accessory) async {
    _log('removing accessory ${accessory.dartBluetoothIdentifier}');
    try {
      await _accessorySetup.removeAccessory(accessory);
      if (!isClosed) {
        final id = accessory.dartBluetoothIdentifier;
        emit(state.copyWith(
          connectedId: id == state.connectedId ? null : _sentinel,
          accessories: _accessorySetup.accessories,
          verifiedPairedIds: _verifiedIdsWithout(id),
        ));
      }
    } catch (e) {
      _log('remove error: $e');
      _messages.add('Remove failed: $e');
    }
  }

  Future<void> connectWithoutScanning(
    String id, {
    ASAccessory? pickedAccessory,
  }) async {
    _log('connecting to $id');
    if (await FlutterBlueUltra.isSupported == false) {
      _log('Bluetooth not supported');
      if (pickedAccessory != null) {
        await _removeTemporaryAccessory(pickedAccessory, id);
      } else {
        _messages.add('Bluetooth not supported');
      }
      return;
    }
    if (FlutterBlueUltra.adapterStateNow == BluetoothAdapterState.on) {
      await _connectDevice(id, pickedAccessory: pickedAccessory);
      return;
    }

    await _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBlueUltra.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on) {
        _adapterStateSubscription?.cancel();
        _connectDevice(id, pickedAccessory: pickedAccessory);
      }
    });
  }

  Future<void> _connectDevice(
    String id, {
    ASAccessory? pickedAccessory,
  }) async {
    final device = BluetoothDevice.fromId(id);
    if (pickedAccessory != null && !isClosed) {
      emit(state.copyWith(authorizingId: id));
    }
    try {
      await device.connect();
      final pairingVerified = await _validatePairing(device);
      if (!isClosed) {
        final verifiedPairedIds = pairingVerified
            ? <String>{...state.verifiedPairedIds, id}
            : state.verifiedPairedIds;
        emit(state.copyWith(
          authorizingId: pickedAccessory != null ? null : _sentinel,
          connectedId: id,
          accessories: _accessorySetup.accessories,
          verifiedPairedIds: verifiedPairedIds,
        ));
      }
      if (pairingVerified) {
        _log('connected and pairing verified for $id');
      } else {
        _log('connected to $id, pairing not verified');
        if (pickedAccessory != null) {
          _messages.add(
            'Connected, but pairing was not verified. Tap Show picker to retry.',
          );
        }
      }
    } catch (e) {
      _log('connect error: $e');
      if (pickedAccessory != null) {
        await _removeTemporaryAccessory(pickedAccessory, id);
      } else {
        _messages.add('Connection failed: $e');
      }
    }
  }

  Future<bool> _validatePairing(BluetoothDevice device) async {
    if (!config.hasPairingValidationCharacteristic) {
      return false;
    }

    final services = await device.discoverServices();
    final serviceUuid = Guid(config.pairingValidationServiceUuid!);
    final characteristicUuid =
        Guid(config.pairingValidationCharacteristicUuid!);
    BluetoothCharacteristic? validationCharacteristic;
    for (final service in services) {
      if (service.uuid != serviceUuid) continue;
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicUuid) {
          validationCharacteristic = characteristic;
          break;
        }
      }
      if (validationCharacteristic != null) break;
    }

    if (validationCharacteristic == null) {
      throw StateError('Pairing validation characteristic not found');
    }
    await validationCharacteristic.read();
    _log('pairing validation characteristic read');
    return true;
  }

  Future<void> _removeUnverifiedAccessories() async {
    final accessories = state.unverifiedAccessories.toList(growable: false);
    for (final accessory in accessories) {
      final id = accessory.dartBluetoothIdentifier;
      if (id == null) continue;
      await _removeTemporaryAccessory(accessory, id, notify: false);
    }
  }

  Future<void> _removeTemporaryAccessory(
    ASAccessory accessory,
    String id, {
    bool notify = true,
  }) async {
    try {
      await BluetoothDevice.fromId(id).disconnect();
    } catch (e) {
      _log('disconnect after pairing failure error: $e');
    }
    try {
      await _accessorySetup.removeAccessory(accessory);
    } catch (e) {
      _log('remove after pairing failure error: $e');
    }
    if (!isClosed) {
      emit(state.copyWith(
        authorizingId: null,
        connectedId: state.connectedId == id ? null : _sentinel,
        accessories: _accessorySetup.accessories,
        verifiedPairedIds: _verifiedIdsWithout(id),
      ));
    }
    if (notify) {
      _messages.add('Pairing was canceled. The accessory was removed.');
    }
  }

  Set<String> _verifiedIdsWithout(String? id) {
    if (id == null || !state.verifiedPairedIds.contains(id)) {
      return state.verifiedPairedIds;
    }
    return state.verifiedPairedIds.where((value) => value != id).toSet();
  }

  void printNativeSessionLogs() {
    _accessorySetup.printNativeSessionLogs();
  }

  void clearLog() {
    emit(state.copyWith(eventLog: const []));
  }

  void _log(String message) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final next = ['[$time] $message', ...state.eventLog];
    if (!isClosed) {
      emit(state.copyWith(eventLog: next));
    }
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await _adapterStateSubscription?.cancel();
    await _messages.close();
    _accessorySetup.dispose();
    return super.close();
  }
}
