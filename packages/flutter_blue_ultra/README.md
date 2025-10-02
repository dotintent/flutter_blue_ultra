 <p align="center">
  <img alt="flutter_blue_ultra" src=".github/flutter_blue_ultra.png" width="360" />
</p>

### 🩵 Flutter Blue Ultra

An open-source, free to use Bluetooth Low Energy (BLE) plugin for Flutter.
Flutter Blue Ultra continues support and maintenance for the legacy 1.x API of `flutter_blue_plus`, while adding new capabilities and keeping pace with the evolution of the underlying native Bluetooth stacks.

### 🙂 Why Flutter Blue Ultra?
- **Legacy 1.x compatibility**: keep using the well-known `flutter_blue_plus` 1.x API surface.
- **Cross‑platform**: iOS, Android, macOS, Linux, and Web (central role).
- **New functionalities**: actively expands features while preserving the familiar API.
- **Tracks native evolution**: maintained to follow Android/iOS/macOS/Linux/Web Bluetooth API changes.

### ⚡ Quick start
1) Add the package in your app (temporary path or git until pub release):
```yaml
dependencies:
  flutter_blue_ultra:
    git:
      url: https://github.com/dotintent/flutter_blue_ultra.git
```

2) Minimal usage example:
```dart
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

void main() async {
  // Ensure bluetooth supported and on before scanning
  if (await FlutterBlueUltra.isSupported == false) return;
  await FlutterBlueUltra.adapterState
      .where((s) => s == BluetoothAdapterState.on)
      .first;

  // Scan briefly
  await FlutterBlueUltra.startScan(timeout: const Duration(seconds: 5));
  await FlutterBlueUltra.isScanning
      .where((v) => v == false)
      .first;
}
```

### 📘 Documentation
- Getting started: `docs/getting_started.md`
- Usage & code samples: `docs/usage.md`
- Background behavior: `docs/background.md`
- API reference: `docs/api_reference.md`
- Common problems: `docs/common_problems.md`
- Versioning: `docs/versioning.md`

### 🚇 Compatibility and Migration

#### Compatibility with flutter_blue_plus
- **Important**: You cannot have both `flutter_blue_plus` and `flutter_blue_ultra` installed in your project as they are mutually exclusive.
- We provide a compatibility layer that allows legacy code using `FlutterBluePlus` to continue working with `flutter_blue_ultra`.
- However, new features and improvements will only be available through the `FlutterBlueUltra` API.

#### Migration Strategy
1. **Immediate Migration (Recommended)**:
   - Use find-and-replace to update all occurrences:
     - `flutter_blue_plus` → `flutter_blue_ultra` (imports)
     - `FlutterBluePlus` → `FlutterBlueUltra` (code)
   - This ensures you get all new features and improvements.

2. **Gradual Migration**:
   - Keep using `FlutterBluePlus` references through our compatibility layer.
   - Gradually migrate to `FlutterBlueUltra` as you work on each file.
   - Note: New features will only be available through `FlutterBlueUltra`.

3. **Legacy Support**:
   - If you're on `flutter_blue_plus` 1.x, you can use this project as a drop-in replacement.
   - For original migration notes from FlutterBlue to Flutter Blue Plus, see:
     - `packages/flutter_blue_plus/MIGRATION.md`

### 🤖 Credits and origins
- This project is a community continuation of `flutter_blue_plus` 1.x.
- Original work: `flutter_blue_plus` (`https://github.com/chipweinberger/flutter_blue_plus`) and `flutter_blue` (`https://github.com/pauldemarco/flutter_blue`).

### 📜 License
Licensed under the BSD 3‑Clause license. See `LICENSE`.


