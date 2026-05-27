class AccessorySetupConfig {
  const AccessorySetupConfig({
    required this.serviceUuid,
    required this.deviceName,
    required this.assetPath,
    this.pairingValidationServiceUuid,
    this.pairingValidationCharacteristicUuid,
  });

  final String serviceUuid;
  final String deviceName;
  final String assetPath;
  final String? pairingValidationServiceUuid;
  final String? pairingValidationCharacteristicUuid;

  bool get hasPairingValidationCharacteristic =>
      pairingValidationServiceUuid != null &&
      pairingValidationCharacteristicUuid != null;
}

const accessorySetupConfig = AccessorySetupConfig(
  serviceUuid: '58C39754-835C-4AAD-9496-5502A4250229',
  deviceName: 'My BLE Device',
  assetPath: 'assets/images/ble.png',
  // Optional: set these to an encrypted characteristic on your accessory. The
  // example reads it after connecting, so canceling the native pairing prompt
  // keeps the accessory out of the paired list.
  pairingValidationServiceUuid: null,
  pairingValidationCharacteristicUuid: null,
);
