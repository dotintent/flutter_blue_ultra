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
    this.initError,
    this.pendingAccessory,
    this.accessories = const [],
    this.eventLog = const [],
  });

  final bool isActivated;
  final bool isPickerLoading;
  final String? connectedId;
  final String? initError;
  final ASAccessory? pendingAccessory;
  final List<ASAccessory> accessories;
  final List<String> eventLog;

  bool get canOpenPicker => isActivated && !isPickerLoading && initError == null;

  AccessorySetupState copyWith({
    bool? isActivated,
    bool? isPickerLoading,
    Object? connectedId = _sentinel,
    Object? initError = _sentinel,
    Object? pendingAccessory = _sentinel,
    List<ASAccessory>? accessories,
    List<String>? eventLog,
  }) {
    return AccessorySetupState(
      isActivated: isActivated ?? this.isActivated,
      isPickerLoading: isPickerLoading ?? this.isPickerLoading,
      connectedId: identical(connectedId, _sentinel) ? this.connectedId : connectedId as String?,
      initError: identical(initError, _sentinel) ? this.initError : initError as String?,
      pendingAccessory: identical(pendingAccessory, _sentinel)
          ? this.pendingAccessory
          : pendingAccessory as ASAccessory?,
      accessories: accessories ?? this.accessories,
      eventLog: eventLog ?? this.eventLog,
    );
  }

  @override
  List<Object?> get props => [
        isActivated,
        isPickerLoading,
        connectedId,
        initError,
        pendingAccessory,
        accessories,
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
  final StreamController<String> _messages = StreamController<String>.broadcast();

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
    emit(state.copyWith(pendingAccessory: null));

    final id = accessory?.dartBluetoothIdentifier;
    if (accessory == null || id == null) {
      _log('picker dismissed without a picked accessory');
      return;
    }
    if (accessory.state != ASAccessoryState.ASAccessoryStateAuthorized) {
      _log('accessory not authorized, state: ${accessory.state}');
      return;
    }
    connectWithoutScanning(id);
  }

  Future<void> showPicker() async {
    if (!state.canOpenPicker) return;
    emit(state.copyWith(isPickerLoading: true));
    try {
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
        emit(state.copyWith(accessories: _accessorySetup.accessories));
      }
    } catch (e) {
      _log('remove error: $e');
      _messages.add('Remove failed: $e');
    }
  }

  Future<void> connectWithoutScanning(String id) async {
    _log('connecting to $id');
    if (await FlutterBlueUltra.isSupported == false) {
      _log('Bluetooth not supported');
      _messages.add('Bluetooth not supported');
      return;
    }
    if (FlutterBlueUltra.adapterStateNow == BluetoothAdapterState.on) {
      await _connectDevice(id);
      return;
    }

    await _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBlueUltra.adapterState.listen((state) async {
      if (state == BluetoothAdapterState.on) {
        await _adapterStateSubscription?.cancel();
        _adapterStateSubscription = null;
        await _connectDevice(id);
      }
    });
  }

  Future<void> _connectDevice(String id) async {
    try {
      final device = BluetoothDevice.fromId(id);
      await device.connect();
      if (!isClosed) {
        emit(state.copyWith(connectedId: id));
      }
      _log('connected to $id');
    } catch (e) {
      _log('connect error: $e');
      _messages.add('Connection failed: $e');
    }
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
