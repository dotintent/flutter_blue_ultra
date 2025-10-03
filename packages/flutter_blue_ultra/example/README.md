# flutter_blue_ultra_example

This example showcases how to use `flutter_blue_ultra` to scan, connect, and interact with BLE devices.

## Quick Start

1. Ensure Bluetooth is enabled on your device. On Android, you may be prompted to turn it on.
2. Run the example:

```bash
flutter run -t packages/flutter_blue_ultra/example/lib/main.dart
```

3. On launch:
   - If Bluetooth is off, you'll see a prompt screen. Turn Bluetooth on to proceed.
   - If Bluetooth is on, you'll land on the Scan screen.

## Using the App

- SCAN: Starts a 15s scan for nearby BLE devices. A spinner shows scan progress.
- STOP: Stops the current scan.
- Connect/Open: Opens the selected device details screen.
- Pull to Refresh: Triggers a new scan if not already scanning.

### Device Screen

- Shows connection state, RSSI, and MTU.
- Get Services: Discovers GATT services and characteristics.
- Interact with Characteristics/Descriptors: Read/Write/Notify using the tiles.

### Notes

- On iOS/Web, optional service IDs improve discovery (Battery, Device Info, Generic Access, Nordic UART).
- Log level is set to verbose in `main.dart` for easier debugging.

## Where to Look in Code

- `example/lib/main.dart`: App entry-point, theming, and adapter state handling.
- `example/lib/screens/scan_screen.dart`: Scanning flow and results list.
- `example/lib/screens/device_screen.dart`: Connected device details and services.
- `example/lib/screens/bluetooth_off_screen.dart`: Turn-on-Bluetooth prompt.

For detailed concepts and API reference, see the package `README.md` and `/docs`.
