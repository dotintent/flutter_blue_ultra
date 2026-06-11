<p align="center">
  <img alt="Flutter Blue Ultra logo" src="https://raw.githubusercontent.com/dotintent/flutter_blue_ultra/master/.github/flutter_blue_ultra.png" width="360" />
</p>

# 🩵 Flutter Blue Ultra

[![pub package](https://img.shields.io/pub/v/flutter_blue_ultra.svg)](https://pub.dev/packages/flutter_blue_ultra)
[![pub points](https://img.shields.io/pub/points/flutter_blue_ultra)](https://pub.dev/packages/flutter_blue_ultra/score)

[//]: # (TODO add once any likes exist) 
[//]: # ([![likes]&#40;https://img.shields.io/pub/likes/flutter_blue_ultra&#41;]&#40;https://pub.dev/packages/flutter_blue_ultra/score&#41;)
[![CI](https://github.com/dotintent/flutter_blue_ultra/actions/workflows/flutter_blue_ultra.yml/badge.svg)](https://github.com/dotintent/flutter_blue_ultra/actions/workflows/flutter_blue_ultra.yml)
[![license](https://img.shields.io/github/license/dotintent/flutter_blue_ultra)](https://github.com/dotintent/flutter_blue_ultra/blob/master/LICENSE)

An open-source Bluetooth Low Energy (BLE) plugin for Flutter. Scan for nearby devices, connect, discover GATT services and characteristics, read and write, subscribe to notifications, negotiate MTU, and manage bonding — all from a single cross-platform API on iOS, Android, macOS, Linux, and Web (central role).

A community continuation of [`flutter_blue_plus`](https://github.com/chipweinberger/flutter_blue_plus) 1.x — same familiar API, with new capabilities and ongoing platform maintenance.

<p align="center">
  <img alt="Scanning nearby BLE devices" src="https://raw.githubusercontent.com/dotintent/flutter_blue_ultra/master/.github/scan-demo.gif" width="280" />
  &nbsp;&nbsp;
  <img alt="Connecting to a device and reading characteristics" src="https://raw.githubusercontent.com/dotintent/flutter_blue_ultra/master/.github/connect-demo.gif" width="280" />
</p>

## ✨ Features

- **Legacy 1.x compatibility** — keep using the familiar `flutter_blue_plus` 1.x API surface.
- **Cross-platform** — iOS, Android, macOS, Linux, and Web (central role).
- **Actively maintained** — tracks Android/iOS/macOS/Linux/Web Bluetooth API changes.
- **New functionality** — expanded features on top of the legacy API.
- **Accessory Setup Kit** — optional [accessory pairing flow](https://github.com/dotintent/flutter_blue_ultra/tree/master/packages/flutter_blue_ultra_accessory_setup) integration on iOS.

## ⚡ Quick start

Add the package:

```sh
flutter pub add flutter_blue_ultra
```

Or add it manually to `pubspec.yaml`:

```yaml
dependencies:
  flutter_blue_ultra: ^2.2.0
```

Configure platform permissions (Android manifest, iOS `Info.plist`, macOS entitlements, Android `minSdkVersion`) — see [Getting started](https://github.com/dotintent/flutter_blue_ultra/blob/master/docs/getting_started.md). Apps cannot scan or connect without these.

Minimal scan example:

```dart
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

void main() async {
  // Ensure Bluetooth is supported and powered on before scanning.
  if (await FlutterBlueUltra.isSupported == false) return;
  await FlutterBlueUltra.adapterState
      .where((s) => s == BluetoothAdapterState.on)
      .first;

  await FlutterBlueUltra.startScan(timeout: const Duration(seconds: 5));
  await FlutterBlueUltra.isScanning.where((v) => v == false).first;
}
```

A full runnable app lives in [`example/`](https://github.com/dotintent/flutter_blue_ultra/tree/master/packages/flutter_blue_ultra/example).

## 📘 Documentation

- [Getting started](https://github.com/dotintent/flutter_blue_ultra/blob/master/docs/getting_started.md)
- [Usage & code samples](https://github.com/dotintent/flutter_blue_ultra/blob/master/docs/usage.md)
- [Background behavior](https://github.com/dotintent/flutter_blue_ultra/blob/master/docs/background.md)
- [API reference](https://pub.dev/documentation/flutter_blue_ultra/latest/)
- [Common problems](https://github.com/dotintent/flutter_blue_ultra/blob/master/docs/common_problems.md)
- [Versioning](https://github.com/dotintent/flutter_blue_ultra/blob/master/docs/versioning.md)

## 🚇 Compatibility and migration

### Compatibility with `flutter_blue_plus`

- **You cannot install both `flutter_blue_plus` and `flutter_blue_ultra`** in the same project — they are mutually exclusive.
- A compatibility layer keeps legacy code that uses `FlutterBluePlus` working with `flutter_blue_ultra`.
- New features land only on the `FlutterBlueUltra` API.

### Migration strategy

1. **Immediate migration (recommended)** — find-and-replace:
   - `flutter_blue_plus` → `flutter_blue_ultra` (imports)
   - `FlutterBluePlus` → `FlutterBlueUltra` (code)
2. **Gradual migration** — keep using `FlutterBluePlus` via the compatibility layer and migrate file by file.
3. **Legacy support** — on `flutter_blue_plus` 1.x, use this project as a drop-in replacement. Original migration notes are in [`MIGRATION.md`](https://github.com/dotintent/flutter_blue_ultra/blob/master/packages/flutter_blue_ultra/MIGRATION.md).

## 🙋 Where to go next

- **Report a bug or request a feature**: [GitHub issues](https://github.com/dotintent/flutter_blue_ultra/issues)
- **Contribute**: see [CONTRIBUTING.md](https://github.com/dotintent/flutter_blue_ultra/blob/master/CONTRIBUTING.md)
- **Changelog**: [CHANGELOG.md](https://github.com/dotintent/flutter_blue_ultra/blob/master/packages/flutter_blue_ultra/CHANGELOG.md)
- **Testing & mocking**: [MOCKING.md](https://github.com/dotintent/flutter_blue_ultra/blob/master/packages/flutter_blue_ultra/MOCKING.md)

## 🤖 Credits and origins

A community continuation of `flutter_blue_plus` 1.x. Original work:
- [`flutter_blue_plus`](https://github.com/chipweinberger/flutter_blue_plus) by Chip Weinberger
- [`flutter_blue`](https://github.com/pauldemarco/flutter_blue) by Paul DeMarco

## 📜 License

Licensed under the BSD 3-Clause license. See [LICENSE](https://github.com/dotintent/flutter_blue_ultra/blob/master/LICENSE).

---

## 🛠️ Maintained by Intent

<p align="center">
  <a href="https://withintent.com">
    <img alt="Maintained by Intent" src="https://raw.githubusercontent.com/dotintent/flutter_blue_ultra/master/.github/maintained-by-intent.png" width="720" />
  </a>
</p>

Flutter Blue Ultra is built and maintained by [Intent](https://withintent.com) — we design and engineer connected products, including Bluetooth and IoT experiences. Get in touch if you need help with your BLE project.
