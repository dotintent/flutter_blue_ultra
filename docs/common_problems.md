## Common Problems

Many common problems are easily solved.

### "bluetooth must be turned on"

You need to wait for the bluetooth adapter to fully turn on.

`await FlutterBluePlus.adapterState.where((state) => state == BluetoothAdapterState.on).first;`

You can also use `FlutterBluePlus.adapterState.listen(...)`. See Usage.

### adapterState is not 'on' but my Bluetooth is on

For iOS:

`adapterState` always starts as `unknown`. You need to wait longer for the service to initialize:

```
if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.unknown) {
  await Future.delayed(const Duration(seconds: 1));
}
```

If `adapterState` is `unavailable`, you must add access to Bluetooth Hardware in the app's Xcode settings. See Getting Started.

For Android:

Check that your device supports Bluetooth & has permissions.

### adapterState is called multiple times

You are forgetting to cancel the original `FlutterBluePlus.adapterState.listen` resulting in multiple listeners.

```dart
final subscription ??= FlutterBluePlus.adapterState.listen((value) {
  // ...
});

subscription.cancel();
```

### Scanning does not find my device

1. you're using an emulator – use a physical device.
2. try using another ble scanner app
   - iOS: nRF Connect
   - Android: BLE Scanner
3. your device uses bluetooth classic, not BLE
4. your device stopped advertising
5. your scan filters are wrong
6. Android: you're calling startScan too often (5 times per 30s limit)
7. Android: make sure location services are enabled

Try looking through system devices:

```dart
// search system devices. i.e. any device connected to by any app
List<BluetoothDevice> system = await FlutterBluePlus.systemDevices;
for (var d in system) {
  if (d.platformName == "myBleDevice") {
    await d.connect();
  }
}
```

### Scanned device never goes away

This is expected. Set the `removeIfGone` scan option if you want devices removed when no longer available.

### iBeacons Not Showing

On iOS, CoreBluetooth does not support iBeacons. Use CoreLocation. On Android, enable location permissions and pass `androidUsesFineLocation:true` to `startScan`.

### Connection fails

1. Your ble device may be low battery
2. Your ble device may have refused the connection or have a bug
3. You may be on the edge of the Bluetooth range
4. Some phones have an issue connecting while scanning
5. Try restarting your phone

### connectionState is called multiple times

You are forgetting to cancel the original `device.connectionState.listen` resulting in multiple listeners.

```dart
final subscription ??= device.connectionState.listen((value) {
  // ...
});
subscription.cancel();
```

### The remoteId is different on Android versus iOS & macOS

Expected: iOS/macOS use a random UUID that changes periodically; Android uses the MAC address.

### iOS: "[Error] The connection has timed out unexpectedly."

This means your device stopped working. Retry or reboot the peripheral.

### List of Bluetooth GATT Errors

These GATT error codes are part of the BLE Specification and are responses from your device to invalid requests. Check platform docs for iOS and Android error lists.

### characteristic write fails / read fails

1. Device turned off or out of range
2. Device firmware bug
3. Radio interference

### onValueReceived issues

- Never called: ensure you use the correct stream and that the device actually sends data
- Data is split up: verify MTU large enough
- Duplicate data: ensure you cancel previous subscriptions or use `device.cancelWhenDisconnected(subscription)`

### ANDROID_SPECIFIC_ERROR

There is no 100% solution. Catch and retry; Android can fail with this code randomly.

### android pairing popup appears twice

Android bug; call `createBond()` just after connecting to resolve.

### MissingPluginException(No implementation found for method XXXX ...)

After adding the plugin, fully stop and run the app again so native plugins load. Also try `flutter clean`.


