import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra_platform_interface/flutter_blue_ultra_platform_interface.dart';

final class FlutterBlueUltraDarwin extends FlutterBlueUltraPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_blue_ultra/methods');

  var _didRestart = false;
  var _logLevel = LogLevel.none;
  var _logColor = true;

  final _onAdapterStateChangedController = StreamController<BmBluetoothAdapterState>.broadcast();
  final _onCharacteristicReceivedController = StreamController<BmCharacteristicData>.broadcast();
  final _onCharacteristicWrittenController = StreamController<BmCharacteristicData>.broadcast();
  final _onConnectionStateChangedController = StreamController<BmConnectionStateResponse>.broadcast();
  final _onDescriptorReadController = StreamController<BmDescriptorData>.broadcast();
  final _onDescriptorWrittenController = StreamController<BmDescriptorData>.broadcast();
  final _onDiscoveredServicesController = StreamController<BmDiscoverServicesResult>.broadcast();
  final _onMtuChangedController = StreamController<BmMtuChangedResponse>.broadcast();
  final _onNameChangedController = StreamController<BmNameChanged>.broadcast();
  final _onReadRssiController = StreamController<BmReadRssiResult>.broadcast();
  final _onScanResponseController = StreamController<BmScanResponse>.broadcast();
  final _onServicesResetController = StreamController<BmBluetoothDevice>.broadcast();

  @override
  Stream<BmBluetoothAdapterState> get onAdapterStateChanged {
    return _onAdapterStateChangedController.stream;
  }

  @override
  Stream<BmCharacteristicData> get onCharacteristicReceived {
    return _onCharacteristicReceivedController.stream;
  }

  @override
  Stream<BmCharacteristicData> get onCharacteristicWritten {
    return _onCharacteristicWrittenController.stream;
  }

  @override
  Stream<BmConnectionStateResponse> get onConnectionStateChanged {
    return _onConnectionStateChangedController.stream;
  }

  @override
  Stream<BmDescriptorData> get onDescriptorRead {
    return _onDescriptorReadController.stream;
  }

  @override
  Stream<BmDescriptorData> get onDescriptorWritten {
    return _onDescriptorWrittenController.stream;
  }

  @override
  Stream<BmDiscoverServicesResult> get onDiscoveredServices {
    return _onDiscoveredServicesController.stream;
  }

  @override
  Stream<BmMtuChangedResponse> get onMtuChanged {
    return _onMtuChangedController.stream;
  }

  @override
  Stream<BmNameChanged> get onNameChanged {
    return _onNameChangedController.stream;
  }

  @override
  Stream<BmReadRssiResult> get onReadRssi {
    return _onReadRssiController.stream;
  }

  @override
  Stream<BmScanResponse> get onScanResponse {
    return _onScanResponseController.stream;
  }

  @override
  Stream<BmBluetoothDevice> get onServicesReset {
    return _onServicesResetController.stream;
  }

  static void registerWith() {
    FlutterBlueUltraPlatform.instance = FlutterBlueUltraDarwin();
  }

  @override
  Future<bool> connect(
    BmConnectRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'connect',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> disconnect(
    BmDisconnectRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'disconnect',
          request.remoteId.str,
        ) ==
        true;
  }

  @override
  Future<bool> discoverServices(
    BmDiscoverServicesRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'discoverServices',
          request.remoteId.str,
        ) ==
        true;
  }

  @override
  Future<BmBluetoothAdapterName> getAdapterName(
    BmBluetoothAdapterNameRequest request,
  ) async {
    return BmBluetoothAdapterName(
      adapterName: await _callDarwinMethod<String>(
            'getAdapterName',
          ) ??
          '',
    );
  }

  @override
  Future<BmBluetoothAdapterState> getAdapterState(
    BmBluetoothAdapterStateRequest request,
  ) async {
    final result = await _callDarwinMethod<Map<String, dynamic>>(
      'getAdapterState',
    );
    if (result == null) {
      throw Exception('Failed to get adapter state');
    }
    return BmBluetoothAdapterState.fromMap(result);
  }

  @override
  Future<BmDevicesList> getSystemDevices(
    BmSystemDevicesRequest request,
  ) async {
    final result = await _callDarwinMethod<Map<String, dynamic>>(
      'getSystemDevices',
      request.toMap(),
    );
    if (result == null) {
      throw Exception('Failed to get system devices');
    }
    return BmDevicesList.fromMap(result);
  }

  @override
  Future<bool> isSupported(
    BmIsSupportedRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'isSupported',
        ) ==
        true;
  }

  @override
  Future<bool> readCharacteristic(
    BmReadCharacteristicRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'readCharacteristic',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> readDescriptor(
    BmReadDescriptorRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'readDescriptor',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> readRssi(
    BmReadRssiRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'readRssi',
          request.remoteId.str,
        ) ==
        true;
  }

  @override
  Future<bool> setLogLevel(
    BmSetLogLevelRequest request,
  ) async {
    _logLevel = request.logLevel;
    _logColor = request.logColor;

    return await _callDarwinMethod<bool>(
          'setLogLevel',
          request.logLevel.index,
        ) ==
        true;
  }

  @override
  Future<bool> setNotifyValue(
    BmSetNotifyValueRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'setNotifyValue',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> setOptions(
    BmSetOptionsRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'setOptions',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> startScan(
    BmScanSettings request,
  ) async {
    return await _callDarwinMethod<bool>(
          'startScan',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> stopScan(
    BmStopScanRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'stopScan',
        ) ==
        true;
  }

  @override
  Future<bool> writeCharacteristic(
    BmWriteCharacteristicRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'writeCharacteristic',
          request.toMap(),
        ) ==
        true;
  }

  @override
  Future<bool> writeDescriptor(
    BmWriteDescriptorRequest request,
  ) async {
    return await _callDarwinMethod<bool>(
          'writeDescriptor',
          request.toMap(),
        ) ==
        true;
  }

  Future<T?> _callDarwinMethod<T>(
    String method, [
    dynamic arguments,
  ]) async {
    // restart platform
    if (!_didRestart && method != "setOptions" && method != "setLogLevel") {
      await _flutterRestart();
    }

    // set platform method handler
    methodChannel.setMethodCallHandler(_methodCallHandler);

    // log args
    if (_logLevel == LogLevel.verbose) {
      var func = '<$method>';
      var args = arguments.toString();
      func = _logColor ? '\x1B[1;30m$func\x1B[0m' : func;
      args = _logColor ? '\x1B[1;35m$args\x1B[0m' : args;
      FlutterBlueUltraPlatform.log('[FBU] $func args: $args');
    }

    // invoke
    final result = await methodChannel.invokeMethod(method, arguments);

    // log result
    if (_logLevel == LogLevel.verbose) {
      var func = '($method)';
      var resultStr = result.toString();
      func = _logColor ? '\x1B[1;30m$func\x1B[0m' : func;
      resultStr = _logColor ? '\x1B[1;33m$resultStr\x1B[0m' : resultStr;
      FlutterBlueUltraPlatform.log('[FBU] $func result: $resultStr');
    }

    // Convert Map types properly
    if (result is Map && T.toString().contains('Map<String, dynamic>')) {
      return Map<String, dynamic>.from(result) as T;
    }

    return result as T?;
  }

  Future<void> _flutterRestart() async {
    // wait for all devices to disconnect
    if ((await methodChannel.invokeMethod('flutterRestart')) != 0) {
      await Future.delayed(const Duration(milliseconds: 50), () {});
      while ((await methodChannel.invokeMethod('connectedCount')) != 0) {
        await Future.delayed(const Duration(milliseconds: 50), () {});
      }
    }
    _didRestart = true;
  }

  Future<void> _methodCallHandler(
    MethodCall call,
  ) async {
    // log result
    if (_logLevel == LogLevel.verbose) {
      var func = '[[ ${call.method} ]]';
      var result = switch (call.method) {
        'OnDiscoveredServices' => _prettyPrint(call.arguments),
        _ => call.arguments.toString(),
      };
      func = _logColor ? '\x1B[1;30m$func\x1B[0m' : func;
      result = _logColor ? '\x1B[1;33m$result\x1B[0m' : result;
      FlutterBlueUltraPlatform.log('[FBU] $func result: $result');
    }

    // Convert arguments to Map<String, dynamic>
    final Map<String, dynamic> args = call.arguments is Map ? Map<String, dynamic>.from(call.arguments as Map) : {};

    // handle method call
    switch (call.method) {
      case 'OnAdapterStateChanged':
        return _onAdapterStateChangedController.add(
          BmBluetoothAdapterState.fromMap(args),
        );
      case 'OnCharacteristicReceived':
        return _onCharacteristicReceivedController.add(
          BmCharacteristicData.fromMap(args),
        );
      case 'OnCharacteristicWritten':
        return _onCharacteristicWrittenController.add(
          BmCharacteristicData.fromMap(args),
        );
      case 'OnConnectionStateChanged':
        return _onConnectionStateChangedController.add(
          BmConnectionStateResponse.fromMap(args),
        );
      case 'OnDescriptorRead':
        return _onDescriptorReadController.add(
          BmDescriptorData.fromMap(args),
        );
      case 'OnDescriptorWritten':
        return _onDescriptorWrittenController.add(
          BmDescriptorData.fromMap(args),
        );
      case 'OnDiscoveredServices':
        return _onDiscoveredServicesController.add(
          BmDiscoverServicesResult.fromMap(args),
        );
      case 'OnMtuChanged':
        return _onMtuChangedController.add(
          BmMtuChangedResponse.fromMap(args),
        );
      case 'OnNameChanged':
        return _onNameChangedController.add(
          BmNameChanged.fromMap(args),
        );
      case 'OnReadRssi':
        return _onReadRssiController.add(
          BmReadRssiResult.fromMap(args),
        );
      case 'OnScanResponse':
        try {
          return _onScanResponseController.add(
            BmScanResponse.fromMap(args),
          );
        } catch (e, stackTrace) {
          FlutterBlueUltraPlatform.log('[FBU] Error parsing OnScanResponse: $e');
          FlutterBlueUltraPlatform.log('[FBU] Args: $args');
          FlutterBlueUltraPlatform.log('[FBU] StackTrace: $stackTrace');
          rethrow;
        }
      case 'OnServicesReset':
        return _onServicesResetController.add(
          BmBluetoothDevice.fromMap(args),
        );
    }
  }

  String _prettyPrint(
    dynamic data,
  ) {
    if (data is Map || data is List) {
      return const JsonEncoder.withIndent('  ').convert(data);
    } else {
      return data.toString();
    }
  }
}
