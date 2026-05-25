# flutter_blue_ultra example

A reference app for [`flutter_blue_ultra`](../). Walks the full BLE flow —
permission → scan → connect → discover services → read / write / subscribe to
characteristics — in roughly 1500 lines of code.

## Running

From this directory:

```bash
flutter pub get
flutter run
```

Android needs a physical device or an emulator with a Bluetooth radio.
iOS needs the Bluetooth usage strings in `ios/Runner/Info.plist` and the
`PERMISSION_BLUETOOTH=1` permission_handler macro in `ios/Podfile`.
macOS uses the Bluetooth entitlement already present in
`macos/Runner/DebugProfile.entitlements`.

## App flow

1. **Startup** — On iOS, if the installed app declares AccessorySetupKit
   Bluetooth keys in `Info.plist`, the example opens the setup picker screen.
   Otherwise it uses the regular permission → scan flow.
2. **Permission** — Android requests `bluetoothScan`, `bluetoothConnect`, and
   `locationWhenInUse`; iOS requests `bluetooth`; macOS uses its entitlement.
3. **Scan** — auto-starts on `BluetoothAdapterState.on`; runs for 12 s and
   dedupes results by `remoteId`.
4. **Device** — connect, discover services, request MTU, poll RSSI every 2 s.
5. **Characteristic** — Read / Write / Notify tabs. Notify keeps a ring
   buffer of the last 40 packets with multiple format renderers (hex, UTF-8,
   dec, bin).

## Accessory Setup Testing

The **Accessory Setup** screen is for testing iOS AccessorySetupKit with a
real BLE accessory. Before running that flow, replace the example service UUID
with the UUID advertised by your test accessory.

AccessorySetupKit changes iOS Bluetooth authorization behavior: when the
installed app declares the AccessorySetupKit Bluetooth keys, iOS uses
per-accessory authorization and does not show the broad Bluetooth permission
dialog. Remove those keys to test the regular permission-handler scan flow.

Update the UUID in both places:

- `example/lib/screens/accessory_setup_screen.dart`, in the
  `showPickerForDevice` call.
- `example/ios/Runner/Info.plist`, under
  `NSAccessorySetupBluetoothServices`.

Those values must match. The Dart value configures the runtime picker filter,
while the `Info.plist` value is Apple's install-time allowlist for the app.
After changing `Info.plist`, rebuild and reinstall the iOS app before testing.

For a quick test, nRF Connect on Android can advertise a connectable BLE
peripheral with your chosen service UUID.

## Architecture


State management is [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
`9.1.1` — `Cubit` only, no events. Each screen is a thin view; everything
stateful lives in `lib/cubits/`:

| Cubit | Owns |
|---|---|
| `AppShellCubit` | Which shell to show — permission or scan. |
| `PermissionCubit` | The "request now" call and the requesting flag. |
| `ScanCubit` | Scan lifecycle, dedupe, elapsed timer, adapter-on auto-start. |
| `DeviceCubit` | Connection state, service discovery, MTU, RSSI poll. |
| `CharacteristicCubit` | Read/write/notify, notify ring buffer, format. |

Plumbing patterns the cubits all share:
- One-shot UI messages (snackbars) go through a `Stream<String>` exposed by
  the cubit, **not** through state. State equality would swallow back-to-back
  identical messages.
- All `StreamSubscription`s are cancelled in `Cubit.close()`. No `dispose()`
  bookkeeping in the widget.
- BLE awaits guard against post-close emit with `if (isClosed) return;`.

## Where to read first

If you're trying to understand the package, read in this order:

1. **[`lib/cubits/scan_cubit.dart`](lib/cubits/scan_cubit.dart)** — shortest
   cubit; shows the stream-lifecycle pattern.
2. **[`lib/cubits/device_cubit.dart`](lib/cubits/device_cubit.dart)** —
   connect → discover → MTU → RSSI sequence.
3. **[`lib/cubits/characteristic_cubit.dart`](lib/cubits/characteristic_cubit.dart)** —
   read / write / notify, plus the ring-buffer pattern for the live stream.

The corresponding screens in `lib/screens/` then read top-to-bottom as plain
UI — every state mutation routes through `context.read<…Cubit>()`.

## Notes

- Log level is `LogLevel.info` in [`lib/main.dart`](lib/main.dart). Bump to
  `LogLevel.debug` or `LogLevel.verbose` to see plugin internals.
- BlocSelector is used for RSSI (DeviceScreen) and elapsed-timer (ScanScreen)
  so the high-frequency tick doesn't rebuild the whole tree — see the
  `buildWhen` comments in those screens.
- Typography is provided by the [`google_fonts`](https://pub.dev/packages/google_fonts) package
  (`Crimson Pro` for serif, `Inter` for sans, `JetBrains Mono` for mono).
  Theme tokens live in [`lib/theme/app_theme.dart`](lib/theme/app_theme.dart).
