Here is the adapted and fixed markdown text:

## ✅ TODO

- [x] Update the documentation to note all required steps and limitations of the AccessorySetupKit.

- [x] Introduce customization for the device discovery:
  - Name
  - Image
  - Custom services UUID

- [x] Find a way to work with the Flutter BLE package (setup kit gives the Peripheral ID which the app BLE should work with):
  - There are 2 libraries: 
    - [flutter_reactive_ble](https://pub.dev/packages/flutter_reactive_ble)
    - [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus)

- [x] Introduce unit tests.

- [ ] Implement WiFi setup.

- [ ] Use Pigeon for the cross-platform messages [Pigeon documentation](https://docs.flutter.dev/platform-integration/platform-channels?tab=type-mappings-kotlin-tab#pigeon).

- [ ] Check the migration sequence and implementation in Flutter (for example app).

- [ ] Add a single-source setup for AccessorySetupKit service UUIDs so example
  apps can generate or sync the Dart `showPickerForDevice` service ID with the
  iOS `NSAccessorySetupBluetoothServices` allowlist instead of updating both
  places manually.

