// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../flutter_blue_ultra.dart';

class BluetoothDescriptor {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final Guid descriptorUuid;

  BluetoothDescriptor({
    required this.remoteId,
    this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    this.instanceId = 0,
    required this.descriptorUuid,
  });

  BluetoothDescriptor.fromProto(BmBluetoothDescriptor p)
      : remoteId = p.remoteId,
        primaryServiceUuid = p.primaryServiceUuid,
        serviceUuid = p.serviceUuid,
        characteristicUuid = p.characteristicUuid,
        instanceId = p.instanceId,
        descriptorUuid = p.descriptorUuid;

  /// convenience accessor
  Guid get uuid => descriptorUuid;

  /// convenience accessor
  BluetoothDevice get device => BluetoothDevice(remoteId: remoteId);

  /// this variable is updated:
  ///   - anytime `read()` is called
  ///   - anytime `write()` is called
  ///   - when the device is disconnected it is cleared
  List<int> get lastValue {
    String key = "${primaryServiceUuid ?? ""}:$serviceUuid:$characteristicUuid:$instanceId:$descriptorUuid";
    return FlutterBlueUltra._lastDescs[remoteId]?[key] ?? [];
  }

  /// this stream emits values:
  ///   - anytime `read()` is called
  ///   - anytime `write()` is called
  ///   - and when first listened to, it re-emits the last value for convenience
  Stream<List<int>> get lastValueStream => _mergeStreams(
          [FlutterBlueUltraPlatform.instance.onDescriptorRead, FlutterBlueUltraPlatform.instance.onDescriptorWritten])
      .where((p) => p.remoteId == remoteId)
      .where((p) => p.primaryServiceUuid == primaryServiceUuid)
      .where((p) => p.serviceUuid == serviceUuid)
      .where((p) => p.characteristicUuid == characteristicUuid)
      .where((p) => p.instanceId == instanceId)
      .where((p) => p.descriptorUuid == descriptorUuid)
      .where((p) => p.success == true)
      .map((p) => p.value)
      .newStreamWithInitialValue(lastValue);

  /// this stream emits values:
  ///   - anytime `read()` is called
  Stream<List<int>> get onValueReceived => FlutterBlueUltraPlatform.instance.onDescriptorRead
      .where((p) => p.remoteId == remoteId)
      .where((p) => p.primaryServiceUuid == primaryServiceUuid)
      .where((p) => p.serviceUuid == serviceUuid)
      .where((p) => p.characteristicUuid == characteristicUuid)
      .where((p) => p.instanceId == instanceId)
      .where((p) => p.descriptorUuid == descriptorUuid)
      .where((p) => p.success == true)
      .map((p) => p.value);

  /// Retrieves the value of a specified descriptor
  Future<List<int>> read({int timeout = 15}) async {
    // check connected
    if (device.isDisconnected) {
      throw FlutterBlueUltraException(
          ErrorPlatform.fbp, "readDescriptor", FbuErrorCode.deviceIsDisconnected.index, "device is not connected");
    }

    // Only allow a single ble operation to be underway at a time
    _Mutex mtx = _MutexFactory.getMutexForKey("global");
    await mtx.take();

    // return value
    List<int> readValue = [];

    try {
      var request = BmReadDescriptorRequest(
        remoteId: remoteId,
        primaryServiceUuid: primaryServiceUuid,
        serviceUuid: serviceUuid,
        characteristicUuid: characteristicUuid,
        instanceId: instanceId,
        descriptorUuid: descriptorUuid,
      );

      Stream<BmDescriptorData> responseStream = FlutterBlueUltraPlatform.instance.onDescriptorRead
          .where((p) => p.remoteId == request.remoteId)
          .where((p) => p.primaryServiceUuid == request.primaryServiceUuid)
          .where((p) => p.serviceUuid == request.serviceUuid)
          .where((p) => p.characteristicUuid == request.characteristicUuid)
          .where((p) => p.instanceId == instanceId)
          .where((p) => p.descriptorUuid == request.descriptorUuid);

      // Start listening now, before invokeMethod, to ensure we don't miss the response
      Future<BmDescriptorData> futureResponse = responseStream.first;

      // invoke
      await FlutterBlueUltra._invokePlatform(() => FlutterBlueUltraPlatform.instance.readDescriptor(request));

      // wait for response
      BmDescriptorData response = await futureResponse
          .fbpEnsureAdapterIsOn("readDescriptor")
          .fbpEnsureDeviceIsConnected(device, "readDescriptor")
          .fbpTimeout(timeout, "readDescriptor");

      // failed?
      if (!response.success) {
        throw FlutterBlueUltraException(_nativeError, "readDescriptor", response.errorCode, response.errorString);
      }

      readValue = response.value;
    } finally {
      mtx.give();
    }

    return readValue;
  }

  /// Writes the value of a descriptor
  Future<void> write(List<int> value, {int timeout = 15}) async {
    // check connected
    if (device.isDisconnected) {
      throw FlutterBlueUltraException(
          ErrorPlatform.fbp, "writeDescriptor", FbuErrorCode.deviceIsDisconnected.index, "device is not connected");
    }

    // Only allow a single ble operation to be underway at a time
    _Mutex mtx = _MutexFactory.getMutexForKey("global");
    await mtx.take();

    try {
      var request = BmWriteDescriptorRequest(
        remoteId: remoteId,
        primaryServiceUuid: primaryServiceUuid,
        serviceUuid: serviceUuid,
        characteristicUuid: characteristicUuid,
        instanceId: instanceId,
        descriptorUuid: descriptorUuid,
        value: value,
      );

      Stream<BmDescriptorData> responseStream = FlutterBlueUltraPlatform.instance.onDescriptorWritten
          .where((p) => p.remoteId == request.remoteId)
          .where((p) => p.primaryServiceUuid == request.primaryServiceUuid)
          .where((p) => p.serviceUuid == request.serviceUuid)
          .where((p) => p.characteristicUuid == request.characteristicUuid)
          .where((p) => p.instanceId == instanceId)
          .where((p) => p.descriptorUuid == request.descriptorUuid);

      // Start listening now, before invokeMethod, to ensure we don't miss the response
      Future<BmDescriptorData> futureResponse = responseStream.first;

      // invoke
      await FlutterBlueUltra._invokePlatform(() => FlutterBlueUltraPlatform.instance.writeDescriptor(request));

      // wait for response
      BmDescriptorData response = await futureResponse
          .fbpEnsureAdapterIsOn("writeDescriptor")
          .fbpEnsureDeviceIsConnected(device, "writeDescriptor")
          .fbpTimeout(timeout, "writeDescriptor");

      // failed?
      if (!response.success) {
        throw FlutterBlueUltraException(_nativeError, "writeDescriptor", response.errorCode, response.errorString);
      }
    } finally {
      mtx.give();
    }

    return Future.value();
  }

  @override
  String toString() {
    return 'BluetoothDescriptor{'
        'remoteId: $remoteId, '
        'primaryServiceUuid: $primaryServiceUuid'
        'serviceUuid: $serviceUuid, '
        'characteristicUuid: $characteristicUuid, '
        'instanceId: $instanceId'
        'descriptorUuid: $descriptorUuid, '
        'lastValue: $lastValue'
        '}';
  }

  @Deprecated('Use onValueReceived instead')
  Stream<List<int>> get value => onValueReceived;

  @Deprecated('Use remoteId instead')
  DeviceIdentifier get deviceId => remoteId;
}
