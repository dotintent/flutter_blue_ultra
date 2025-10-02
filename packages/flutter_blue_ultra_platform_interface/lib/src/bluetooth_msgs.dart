import 'dart:typed_data';

import 'device_identifier.dart';
import 'guid.dart';
import 'log_level.dart';

class BmBluetoothAdapterStateRequest {
  BmBluetoothAdapterStateRequest();
}

enum BmAdapterStateEnum {
  unknown, // 0
  unavailable, // 1
  unauthorized, // 2
  turningOn, // 3
  on, // 4
  turningOff, // 5
  off, // 6
}

class BmBluetoothAdapterState {
  BmAdapterStateEnum adapterState;

  BmBluetoothAdapterState({required this.adapterState});

  factory BmBluetoothAdapterState.fromMap(Map<String, dynamic> json) {
    return BmBluetoothAdapterState(
      adapterState: BmAdapterStateEnum.values[json['adapter_state'] as int],
    );
  }
}

class BmBluetoothAdapterNameRequest {
  BmBluetoothAdapterNameRequest();
}

class BmBluetoothAdapterName {
  String adapterName;

  BmBluetoothAdapterName({required this.adapterName});
}

class BmMsdFilter {
  int manufacturerId;
  List<int>? data;
  List<int>? mask;
  BmMsdFilter(this.manufacturerId, this.data, this.mask);
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    map['manufacturer_id'] = manufacturerId;
    map['data'] = Uint8List.fromList(data ?? []);
    map['mask'] = Uint8List.fromList(mask ?? []);
    return map;
  }
}

class BmServiceDataFilter {
  Guid service;
  List<int> data;
  List<int> mask;
  BmServiceDataFilter(this.service, this.data, this.mask);
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};
    map['service'] = service.str;
    map['data'] = Uint8List.fromList(data);
    map['mask'] = Uint8List.fromList(mask);
    return map;
  }
}

class BmScanSettings {
  final List<Guid> withServices;
  final List<String> withRemoteIds;
  final List<String> withNames;
  final List<String> withKeywords;
  final List<BmMsdFilter> withMsd;
  final List<BmServiceDataFilter> withServiceData;
  final bool continuousUpdates;
  final int continuousDivisor;
  final bool androidLegacy;
  final int androidScanMode;
  final bool androidUsesFineLocation;
  final bool androidCheckLocationServices;
  final List<Guid> webOptionalServices;

  BmScanSettings({
    required this.withServices,
    required this.withRemoteIds,
    required this.withNames,
    required this.withKeywords,
    required this.withMsd,
    required this.withServiceData,
    required this.continuousUpdates,
    required this.continuousDivisor,
    required this.androidLegacy,
    required this.androidScanMode,
    required this.androidUsesFineLocation,
    this.androidCheckLocationServices = true,
    required this.webOptionalServices,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {};
    data['with_services'] = withServices.map((s) => s.str).toList();
    data['with_remote_ids'] = withRemoteIds;
    data['with_names'] = withNames;
    data['with_keywords'] = withKeywords;
    data['with_msd'] = withMsd.map((d) => d.toMap()).toList();
    data['with_service_data'] = withServiceData.map((d) => d.toMap()).toList();
    data['continuous_updates'] = continuousUpdates;
    data['continuous_divisor'] = continuousDivisor;
    data['android_legacy'] = androidLegacy;
    data['android_scan_mode'] = androidScanMode;
    data['android_uses_fine_location'] = androidUsesFineLocation;
    data['android_check_location_services'] = androidCheckLocationServices;
    data['web_optional_services'] = webOptionalServices.map((s) => s.str).toList();
    return data;
  }
}

class BmStopScanRequest {
  BmStopScanRequest();
}

class BmScanAdvertisement {
  final DeviceIdentifier remoteId;
  final String? platformName;
  final String? advName;
  final bool connectable;
  final int? txPowerLevel;
  final int? appearance; // not supported on iOS / macOS
  final Map<int, List<int>> manufacturerData;
  final Map<Guid, List<int>> serviceData;
  final List<Guid> serviceUuids;
  final int rssi;

  BmScanAdvertisement({
    required this.remoteId,
    required this.platformName,
    required this.advName,
    required this.connectable,
    required this.txPowerLevel,
    required this.appearance,
    required this.manufacturerData,
    required this.serviceData,
    required this.serviceUuids,
    required this.rssi,
  });

  factory BmScanAdvertisement.fromMap(Map<String, dynamic> json) {
    // Helper to convert Map with any key type to Map<int, List<int>>
    Map<int, List<int>> parseManufacturerData(dynamic data) {
      if (data == null) return {};
      final Map<dynamic, dynamic> rawMap = data is Map ? Map.from(data) : {};
      final Map<int, List<int>> result = {};
      rawMap.forEach((k, v) {
        // Key can be int or string representation of int
        final int? key = k is int ? k : int.tryParse(k.toString());
        if (key != null && v is List) {
          result[key] = List<int>.from(v);
        }
      });
      return result;
    }

    // Helper to convert Map with any key type to Map<Guid, List<int>>
    Map<Guid, List<int>> parseServiceData(dynamic data) {
      if (data == null) return {};
      final Map<dynamic, dynamic> rawMap = data is Map ? Map.from(data) : {};
      final Map<Guid, List<int>> result = {};
      rawMap.forEach((k, v) {
        if (v is List) {
          result[Guid(k.toString())] = List<int>.from(v);
        }
      });
      return result;
    }

    return BmScanAdvertisement(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      platformName: json['platform_name'] as String?,
      advName: json['adv_name'] as String?,
      connectable: json['connectable'] is int ? json['connectable'] != 0 : (json['connectable'] as bool? ?? false),
      txPowerLevel: json['tx_power_level'] as int?,
      appearance: json['appearance'] as int?,
      manufacturerData: parseManufacturerData(json['manufacturer_data']),
      serviceData: parseServiceData(json['service_data']),
      serviceUuids: (json['service_uuids'] as List<dynamic>? ?? []).map((e) => Guid(e as String)).toList(),
      rssi: json['rssi'] as int? ?? 0,
    );
  }
}

class BmScanResponse {
  final List<BmScanAdvertisement> advertisements;
  final bool success;
  final int errorCode;
  final String errorString;

  BmScanResponse({
    required this.advertisements,
    required this.success,
    required this.errorCode,
    required this.errorString,
  });

  factory BmScanResponse.fromMap(Map<String, dynamic> json) {
    final List<BmScanAdvertisement> advertisements = [];
    final advList = json['advertisements'] as List<dynamic>;
    for (final item in advList) {
      // Convert nested Map to Map<String, dynamic>
      final Map<String, dynamic> itemMap = item is Map ? Map<String, dynamic>.from(item) : item as Map<String, dynamic>;
      advertisements.add(BmScanAdvertisement.fromMap(itemMap));
    }

    final bool success = json['success'] == null || json['success'] as int != 0;

    return BmScanResponse(
      advertisements: advertisements,
      success: success,
      errorCode: !success ? json['error_code'] as int : 0,
      errorString: !success ? json['error_string'] as String : "",
    );
  }
}

class BmConnectRequest {
  DeviceIdentifier remoteId;
  bool autoConnect;

  BmConnectRequest({
    required this.remoteId,
    required this.autoConnect,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['auto_connect'] = autoConnect ? 1 : 0;
    return data;
  }
}

class BmDisconnectRequest {
  DeviceIdentifier remoteId;

  BmDisconnectRequest({
    required this.remoteId,
  });
}

class BmBluetoothDevice {
  DeviceIdentifier remoteId;
  String? platformName;

  BmBluetoothDevice({
    required this.remoteId,
    required this.platformName,
  });

  factory BmBluetoothDevice.fromMap(Map<String, dynamic> json) {
    return BmBluetoothDevice(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      platformName: json['platform_name'] as String?,
    );
  }
}

class BmNameChanged {
  DeviceIdentifier remoteId;
  String name;

  BmNameChanged({
    required this.remoteId,
    required this.name,
  });

  factory BmNameChanged.fromMap(Map<String, dynamic> json) {
    return BmNameChanged(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      name: json['name'] as String,
    );
  }
}

class BmBluetoothService {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  List<BmBluetoothCharacteristic> characteristics;

  BmBluetoothService({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristics,
  });

  factory BmBluetoothService.fromMap(Map<String, dynamic> json) {
    // convert characteristics
    final List<BmBluetoothCharacteristic> chrs = [];
    final chrList = json['characteristics'] as List<dynamic>;
    for (final v in chrList) {
      chrs.add(BmBluetoothCharacteristic.fromMap(v as Map<String, dynamic>));
    }

    return BmBluetoothService(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      primaryServiceUuid: Guid.parse(json['primary_service_uuid'] as String?),
      serviceUuid: Guid(json['service_uuid'] as String),
      characteristics: chrs,
    );
  }
}

class BmBluetoothCharacteristic {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  List<BmBluetoothDescriptor> descriptors;
  BmCharacteristicProperties properties;

  BmBluetoothCharacteristic({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.descriptors,
    required this.properties,
  });

  factory BmBluetoothCharacteristic.fromMap(Map<String, dynamic> json) {
    // convert descriptors
    final List<BmBluetoothDescriptor> descs = [];
    final descList = json['descriptors'] as List<dynamic>;
    for (final v in descList) {
      descs.add(BmBluetoothDescriptor.fromMap(v as Map<String, dynamic>));
    }

    return BmBluetoothCharacteristic(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      primaryServiceUuid: Guid.parse(json['primary_service_uuid'] as String?),
      serviceUuid: Guid(json['service_uuid'] as String),
      characteristicUuid: Guid(json['characteristic_uuid'] as String),
      instanceId: json['instance_id'] as int,
      descriptors: descs,
      properties: BmCharacteristicProperties.fromMap(json['properties'] as Map<String, dynamic>),
    );
  }
}

class BmBluetoothDescriptor {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final Guid descriptorUuid;

  BmBluetoothDescriptor({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.descriptorUuid,
  });

  factory BmBluetoothDescriptor.fromMap(Map<String, dynamic> json) {
    return BmBluetoothDescriptor(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      primaryServiceUuid: Guid.parse(json['primary_service_uuid'] as String?),
      serviceUuid: Guid(json['service_uuid'] as String),
      characteristicUuid: Guid(json['characteristic_uuid'] as String),
      instanceId: json['instance_id'] as int,
      descriptorUuid: Guid(json['descriptor_uuid'] as String),
    );
  }
}

class BmCharacteristicProperties {
  bool broadcast;
  bool read;
  bool writeWithoutResponse;
  bool write;
  bool notify;
  bool indicate;
  bool authenticatedSignedWrites;
  bool extendedProperties;
  bool notifyEncryptionRequired;
  bool indicateEncryptionRequired;

  BmCharacteristicProperties({
    required this.broadcast,
    required this.read,
    required this.writeWithoutResponse,
    required this.write,
    required this.notify,
    required this.indicate,
    required this.authenticatedSignedWrites,
    required this.extendedProperties,
    required this.notifyEncryptionRequired,
    required this.indicateEncryptionRequired,
  });

  factory BmCharacteristicProperties.fromMap(Map<String, dynamic> json) {
    return BmCharacteristicProperties(
      broadcast: json['broadcast'] as int != 0,
      read: json['read'] as int != 0,
      writeWithoutResponse: json['write_without_response'] as int != 0,
      write: json['write'] as int != 0,
      notify: json['notify'] as int != 0,
      indicate: json['indicate'] as int != 0,
      authenticatedSignedWrites: json['authenticated_signed_writes'] as int != 0,
      extendedProperties: json['extended_properties'] as int != 0,
      notifyEncryptionRequired: json['notify_encryption_required'] as int != 0,
      indicateEncryptionRequired: json['indicate_encryption_required'] as int != 0,
    );
  }
}

class BmDiscoverServicesRequest {
  DeviceIdentifier remoteId;

  BmDiscoverServicesRequest({
    required this.remoteId,
  });
}

class BmDiscoverServicesResult {
  final DeviceIdentifier remoteId;
  final List<BmBluetoothService> services;
  final bool success;
  final int errorCode;
  final String errorString;

  BmDiscoverServicesResult({
    required this.remoteId,
    required this.services,
    required this.success,
    required this.errorCode,
    required this.errorString,
  });

  factory BmDiscoverServicesResult.fromMap(Map<String, dynamic> json) {
    return BmDiscoverServicesResult(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      services: (json['services'] as List<dynamic>)
          .map((e) => BmBluetoothService.fromMap(e as Map<String, dynamic>))
          .toList(),
      success: json['success'] as int != 0,
      errorCode: json['error_code'] as int,
      errorString: json['error_string'] as String,
    );
  }
}

class BmReadCharacteristicRequest {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;

  BmReadCharacteristicRequest({
    required this.remoteId,
    this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['primary_service_uuid'] = primaryServiceUuid?.str;
    data['service_uuid'] = serviceUuid.str;
    data['characteristic_uuid'] = characteristicUuid.str;
    data['instance_id'] = instanceId;
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class BmCharacteristicData {
  final DeviceIdentifier remoteId;
  final Guid serviceUuid;
  final Guid? primaryServiceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final List<int> value;
  final bool success;
  final int errorCode;
  final String errorString;

  BmCharacteristicData({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.value,
    required this.success,
    required this.errorCode,
    required this.errorString,
  });

  factory BmCharacteristicData.fromMap(Map<String, dynamic> json) {
    return BmCharacteristicData(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      primaryServiceUuid: Guid.parse(json['primary_service_uuid'] as String?),
      serviceUuid: Guid(json['service_uuid'] as String),
      characteristicUuid: Guid(json['characteristic_uuid'] as String),
      instanceId: json['instance_id'] as int,
      value: json['value'] as Uint8List,
      success: json['success'] as int != 0,
      errorCode: json['error_code'] as int,
      errorString: json['error_string'] as String,
    );
  }
}

class BmReadDescriptorRequest {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final Guid descriptorUuid;

  BmReadDescriptorRequest({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.descriptorUuid,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['primary_service_uuid'] = primaryServiceUuid?.str;
    data['service_uuid'] = serviceUuid.str;
    data['characteristic_uuid'] = characteristicUuid.str;
    data['instance_id'] = instanceId;
    data['descriptor_uuid'] = descriptorUuid.str;
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

enum BmWriteType {
  withResponse,
  withoutResponse,
}

class BmWriteCharacteristicRequest {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final BmWriteType writeType;
  final bool allowLongWrite;
  final List<int> value;

  BmWriteCharacteristicRequest({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.writeType,
    required this.allowLongWrite,
    required this.value,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['primary_service_uuid'] = primaryServiceUuid?.str;
    data['service_uuid'] = serviceUuid.str;
    data['characteristic_uuid'] = characteristicUuid.str;
    data['instance_id'] = instanceId;
    data['write_type'] = writeType.index;
    data['allow_long_write'] = allowLongWrite ? 1 : 0;
    data['value'] = Uint8List.fromList(value);
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class BmWriteDescriptorRequest {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final Guid descriptorUuid;
  final List<int> value;

  BmWriteDescriptorRequest({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.descriptorUuid,
    required this.value,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['primary_service_uuid'] = primaryServiceUuid?.str;
    data['service_uuid'] = serviceUuid.str;
    data['characteristic_uuid'] = characteristicUuid.str;
    data['instance_id'] = instanceId;
    data['descriptor_uuid'] = descriptorUuid.str;
    data['value'] = Uint8List.fromList(value);
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

class BmDescriptorData {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final Guid descriptorUuid;
  final List<int> value;
  final bool success;
  final int errorCode;
  final String errorString;

  BmDescriptorData({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.descriptorUuid,
    required this.value,
    required this.success,
    required this.errorCode,
    required this.errorString,
  });

  factory BmDescriptorData.fromMap(Map<String, dynamic> json) {
    return BmDescriptorData(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      primaryServiceUuid: Guid.parse(json['primary_service_uuid'] as String?),
      serviceUuid: Guid(json['service_uuid'] as String),
      characteristicUuid: Guid(json['characteristic_uuid'] as String),
      instanceId: json['instance_id'] as int,
      descriptorUuid: Guid(json['descriptor_uuid'] as String),
      value: json['value'] as Uint8List,
      success: json['success'] as int != 0,
      errorCode: json['error_code'] as int,
      errorString: json['error_string'] as String,
    );
  }
}

class BmSetNotifyValueRequest {
  final DeviceIdentifier remoteId;
  final Guid? primaryServiceUuid;
  final Guid serviceUuid;
  final Guid characteristicUuid;
  final int instanceId;
  final bool forceIndications;
  final bool enable;

  BmSetNotifyValueRequest({
    required this.remoteId,
    required this.primaryServiceUuid,
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.instanceId,
    required this.forceIndications,
    required this.enable,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['primary_service_uuid'] = primaryServiceUuid?.str;
    data['service_uuid'] = serviceUuid.str;
    data['characteristic_uuid'] = characteristicUuid.str;
    data['instance_id'] = instanceId;
    data['force_indications'] = forceIndications;
    data['enable'] = enable;
    data.removeWhere((key, value) => value == null);
    return data;
  }
}

enum BmConnectionStateEnum {
  disconnected, // 0
  connected, // 1
}

class BmConnectionStateResponse {
  final DeviceIdentifier remoteId;
  final BmConnectionStateEnum connectionState;
  final int? disconnectReasonCode;
  final String? disconnectReasonString;

  BmConnectionStateResponse({
    required this.remoteId,
    required this.connectionState,
    required this.disconnectReasonCode,
    required this.disconnectReasonString,
  });

  factory BmConnectionStateResponse.fromMap(Map<String, dynamic> json) {
    return BmConnectionStateResponse(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      connectionState: BmConnectionStateEnum.values[json['connection_state'] as int],
      disconnectReasonCode: json['disconnect_reason_code'] as int?,
      disconnectReasonString: json['disconnect_reason_string'] as String?,
    );
  }
}

class BmBondedDevicesRequest {
  BmBondedDevicesRequest();
}

class BmSystemDevicesRequest {
  final List<Guid> withServices;

  BmSystemDevicesRequest({
    required this.withServices,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['with_services'] = withServices.map((s) => s.str).toList();
    return data;
  }
}

class BmDevicesList {
  final List<BmBluetoothDevice> devices;

  BmDevicesList({required this.devices});

  factory BmDevicesList.fromMap(Map<String, dynamic> json) {
    // convert to BmBluetoothDevice
    final List<BmBluetoothDevice> devices = [];
    final deviceList = json['devices'] as List<dynamic>;
    for (final device in deviceList) {
      devices.add(BmBluetoothDevice.fromMap(device as Map<String, dynamic>));
    }
    return BmDevicesList(devices: devices);
  }
}

class BmMtuChangeRequest {
  final DeviceIdentifier remoteId;
  final int mtu;

  BmMtuChangeRequest({required this.remoteId, required this.mtu});

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['mtu'] = mtu;
    return data;
  }
}

class BmMtuChangedResponse {
  final DeviceIdentifier remoteId;
  final int mtu;
  final bool success;
  final int errorCode;
  final String errorString;

  BmMtuChangedResponse({
    required this.remoteId,
    required this.mtu,
    this.success = true,
    this.errorCode = 0,
    this.errorString = "",
  });

  factory BmMtuChangedResponse.fromMap(Map<String, dynamic> json) {
    return BmMtuChangedResponse(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      mtu: json['mtu'] as int,
      success: json['success'] as int != 0,
      errorCode: json['error_code'] as int,
      errorString: json['error_string'] as String,
    );
  }
}

class BmReadRssiRequest {
  DeviceIdentifier remoteId;

  BmReadRssiRequest({
    required this.remoteId,
  });
}

class BmReadRssiResult {
  final DeviceIdentifier remoteId;
  final int rssi;
  final bool success;
  final int errorCode;
  final String errorString;

  BmReadRssiResult({
    required this.remoteId,
    required this.rssi,
    required this.success,
    required this.errorCode,
    required this.errorString,
  });

  factory BmReadRssiResult.fromMap(Map<String, dynamic> json) {
    return BmReadRssiResult(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      rssi: json['rssi'] as int,
      success: json['success'] as int != 0,
      errorCode: json['error_code'] as int,
      errorString: json['error_string'] as String,
    );
  }
}

enum BmConnectionPriorityEnum {
  balanced, // 0
  high, // 1
  lowPower, // 2
}

class BmConnectionPriorityRequest {
  final DeviceIdentifier remoteId;
  final BmConnectionPriorityEnum connectionPriority;

  BmConnectionPriorityRequest({
    required this.remoteId,
    required this.connectionPriority,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['connection_priority'] = connectionPriority.index;
    return data;
  }
}

class BmPreferredPhy {
  final DeviceIdentifier remoteId;
  final int txPhy;
  final int rxPhy;
  final int phyOptions;

  BmPreferredPhy({
    required this.remoteId,
    required this.txPhy,
    required this.rxPhy,
    required this.phyOptions,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['tx_phy'] = txPhy;
    data['rx_phy'] = rxPhy;
    data['phy_options'] = phyOptions;
    return data;
  }
}

class BmBondStateRequest {
  DeviceIdentifier remoteId;

  BmBondStateRequest({
    required this.remoteId,
  });
}

enum BmBondStateEnum {
  none, // 0
  bonding, // 1
  bonded, // 2
}

class BmBondStateResponse {
  final DeviceIdentifier remoteId;
  final BmBondStateEnum bondState;
  final BmBondStateEnum? prevState;

  BmBondStateResponse({
    required this.remoteId,
    required this.bondState,
    required this.prevState,
  });

  factory BmBondStateResponse.fromMap(Map<String, dynamic> json) {
    return BmBondStateResponse(
      remoteId: DeviceIdentifier(json['remote_id'] as String),
      bondState: BmBondStateEnum.values[json['bond_state'] as int],
      prevState: json['prev_state'] != null ? BmBondStateEnum.values[json['prev_state'] as int] : null,
    );
  }
}

class BmCreateBondRequest {
  DeviceIdentifier remoteId;
  Uint8List? pin;

  BmCreateBondRequest({
    required this.remoteId,
    required this.pin,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['remote_id'] = remoteId.str;
    data['pin'] = pin;
    return data;
  }
}

class BmRemoveBondRequest {
  DeviceIdentifier remoteId;

  BmRemoveBondRequest({
    required this.remoteId,
  });
}

class BmClearGattCacheRequest {
  DeviceIdentifier remoteId;

  BmClearGattCacheRequest({
    required this.remoteId,
  });
}

class BmDetachedFromEngineResponse {
  BmDetachedFromEngineResponse();
}

class BmTurnOffRequest {
  BmTurnOffRequest();
}

class BmTurnOnRequest {
  BmTurnOnRequest();
}

class BmTurnOnResponse {
  bool userAccepted;

  BmTurnOnResponse({
    required this.userAccepted,
  });

  factory BmTurnOnResponse.fromMap(Map<String, dynamic> json) {
    return BmTurnOnResponse(
      userAccepted: json['user_accepted'] as bool,
    );
  }
}

class BmSetLogLevelRequest {
  LogLevel logLevel;
  bool logColor;

  BmSetLogLevelRequest({
    this.logLevel = LogLevel.none,
    this.logColor = true,
  });
}

class BmSetOptionsRequest {
  bool showPowerAlert;
  bool restoreState;

  BmSetOptionsRequest({
    required this.showPowerAlert,
    required this.restoreState,
  });

  Map<dynamic, dynamic> toMap() {
    final Map<dynamic, dynamic> data = {};
    data['show_power_alert'] = showPowerAlert;
    data['restore_state'] = restoreState;
    return data;
  }
}

class BmIsSupportedRequest {
  BmIsSupportedRequest();
}

class PhySupportRequest {
  PhySupportRequest();
}

class PhySupport {
  /// High speed (PHY 2M)
  final bool le2M;

  /// Long range (PHY codec)
  final bool leCoded;

  PhySupport({
    required this.le2M,
    required this.leCoded,
  });

  factory PhySupport.fromMap(Map<String, dynamic> json) {
    return PhySupport(
      le2M: json['le_2M'] as bool,
      leCoded: json['le_coded'] as bool,
    );
  }
}

// random number defined by flutter blue plus.
// Ideally it should not conflict with iOS or Android error codes.
int bmUserCanceledErrorCode = 23789258;
