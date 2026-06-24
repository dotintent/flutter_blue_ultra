
# Flutter Accessory Kit

The plugin bridges AccessorySetupKit through [Pigeon](https://pub.dev/packages/pigeon)
platform channels (no `dart:ffi`/`objective_c`). The wire schema lives in
[`pigeons/messages.dart`](pigeons/messages.dart); the native implementation is
hand-written Swift in
[`FlutterAccessorySetupPlugin.swift`](ios/flutter_blue_ultra_accessory_setup/Sources/flutter_blue_ultra_accessory_setup/FlutterAccessorySetupPlugin.swift).

## Regenerating the Pigeon bindings

After editing the schema in `pigeons/messages.dart`:

```sh
fvm dart run pigeon --input pigeons/messages.dart
fvm dart format .   # Pigeon output isn't tall-style formatted; format it so the gate stays green
```

This regenerates both generated files (paths are set via `@ConfigurePigeon`
at the top of the schema):

- `lib/src/messages.g.dart` — Dart side (`AccessorySetupApi`, `AccessorySetupFlutterApi`)
- `ios/.../Sources/flutter_blue_ultra_accessory_setup/Messages.g.swift` — Swift side

Do not hand-edit the generated files. Update the public Dart API in
[`lib/flutter_blue_ultra_accessory_setup.dart`](lib/flutter_blue_ultra_accessory_setup.dart)
and the native behaviour in `FlutterAccessorySetupPlugin.swift`.

## How to verify changes

- Static checks and unit tests (the tests run against a fake `HostApi`, no device needed):

  ```sh
  fvm flutter analyze
  fvm dart format --output=none --set-exit-if-changed .
  fvm flutter test
  ```

- AccessorySetupKit only runs on a **physical iOS 18+ device** (not the
  Simulator). Build and run the example on device:

  ```sh
  cd example
  fvm flutter devices
  fvm flutter run -d DEVICE_ID_FROM_DEVICES_OUTPUT
  cd -
  ```

### CocoaPods vs Swift Package Manager

The plugin ships both a `.podspec` and a `Package.swift`, so it builds on older
Flutter (CocoaPods) and newer Flutter (SwiftPM). Verify both paths:

- **CocoaPods** (default): the command above builds via Pods.
- **Swift Package Manager**:

  ```sh
  cd example
  fvm flutter config --enable-swift-package-manager
  fvm flutter run -d DEVICE_ID_FROM_DEVICES_OUTPUT
  fvm flutter config --no-enable-swift-package-manager
  cd -
  ```

- Lowest supported Flutter is set in `pubspec.yaml` (`flutter: '>=3.3.0'`).
  When changing it, smoke-test a consumer app on that version as well as the
  latest stable.
