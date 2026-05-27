# flutter_blue_ultra_accessory_setup example

Standalone iOS example for AccessorySetupKit.

This app intentionally lives outside the main `flutter_blue_ultra` scanner
example because AccessorySetupKit changes Bluetooth authorization behavior on
iOS. Keeping it in a separate app lets the scanner example use normal BLE
permissions while this app declares the AccessorySetupKit allowlist.

## Running

From this directory:

```bash
fvm flutter pub get
fvm flutter run
```

AccessorySetupKit requires a physical iOS device. It does not work in the
simulator.

## Test Accessory UUID

The example currently filters for:

```text
58C39754-835C-4AAD-9496-5502A4250229
```

If your accessory advertises a different service UUID, update both:

- `lib/models/accessory_setup_config.dart`, in `serviceUuid`
- `ios/Runner/Info.plist`, under `NSAccessorySetupBluetoothServices`

Those values must match. The Dart value configures the picker filter, while the
plist value is Apple's install-time allowlist for the app.

In nRF Connect, check the UUID in the advertising packet, not only the service
list after connecting. AccessorySetupKit filters the picker using the advertised
identifiers declared in `ASDiscoveryDescriptor`; a GATT service that appears
only after connection is not enough for the picker to match the device.

For BLE pairing flows, the example keeps a newly selected accessory out of the
paired list until the post-picker connection succeeds. If your accessory pairs
only when an encrypted GATT characteristic is accessed, set
`pairingValidationServiceUuid` and `pairingValidationCharacteristicUuid` in
`lib/models/accessory_setup_config.dart` to that characteristic. A failed
connection or validation removes the temporary accessory entry so it can be
picked again.

The example declares both `NSAccessorySetupSupports` and the older
`NSAccessorySetupKitSupports` compatibility key. `NSAccessorySetupSupports` is
Apple's current Info.plist key for declaring Bluetooth or Wi-Fi AccessorySetupKit
support.
