class AccessorySetupConfig {
  const AccessorySetupConfig({
    required this.serviceUuid,
    required this.serviceName,
    required this.deviceName,
    required this.assetPath,
  });

  final String serviceUuid;
  final String serviceName;
  final String deviceName;
  final String assetPath;
}

const accessorySetupConfig = AccessorySetupConfig(
  serviceUuid: '58C39754-835C-4AAD-9496-5502A4250229',
  serviceName: 'Custom service',
  deviceName: 'My BLE Device',
  assetPath: 'assets/images/ble.png',
);
