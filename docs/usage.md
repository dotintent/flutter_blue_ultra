## Usage

This project preserves the `flutter_blue_plus` 1.x API surface, so most examples remain valid.

### Error handling

Every error returned by the native platform is checked and thrown as an exception where appropriate.

Streams returned by the library never emit errors and never close. The one exception is `FlutterBluePlus.scanResults`, which you should handle `onError`.

### Set log level

```dart
FlutterBluePlus.setLogLevel(LogLevel.verbose, color:false);

FlutterBluePlus.logs.listen((String s) {
  // Forward logs as needed
});
```

### Bluetooth on & off

```dart
if (await FlutterBluePlus.isSupported == false) {
  return;
}

final sub = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
  if (state == BluetoothAdapterState.on) {
    // safe to start scanning/connecting
  }
});

if (!kIsWeb && Platform.isAndroid) {
  await FlutterBluePlus.turnOn();
}

sub.cancel();
```

### Scan for devices

```dart
final sub = FlutterBluePlus.onScanResults.listen((results) {
  if (results.isNotEmpty) {
    final r = results.last;
    print('${r.device.remoteId}: "${r.advertisementData.advName}"');
  }
}, onError: (e) => print(e));

FlutterBluePlus.cancelWhenScanComplete(sub);

await FlutterBluePlus.adapterState
    .where((s) => s == BluetoothAdapterState.on)
    .first;

await FlutterBluePlus.startScan(
  withServices: [Guid('180D')],
  withNames: ['Bluno'],
  timeout: Duration(seconds: 15),
);

await FlutterBluePlus.isScanning.where((v) => v == false).first;
```

### Connect / disconnect

```dart
final sub = device.connectionState.listen((s) {
  if (s == BluetoothConnectionState.disconnected) {
    print("${device.disconnectReason?.code} ${device.disconnectReason?.description}");
  }
});

device.cancelWhenDisconnected(sub, delayed:true, next:true);

await device.connect();
await device.disconnect();

sub.cancel();
```

### Auto connect

```dart
await device.connect(autoConnect:true, mtu:null);
await device.connectionState
    .where((s) => s == BluetoothConnectionState.connected)
    .first;
await device.disconnect();
```

### Save device between restarts

```dart
final String remoteId = await File('/remoteId.txt').readAsString();
final device = BluetoothDevice.fromId(remoteId);
await device.connect(autoConnect:true);
```

### MTU

```dart
final sub = device.mtu.listen((int mtu) {
  print('mtu $mtu');
});
device.cancelWhenDisconnected(sub);

if (!kIsWeb && Platform.isAndroid) {
  await device.requestMtu(512);
}
```

### Discover services

```dart
final services = await device.discoverServices();
```

### Read characteristics

```dart
for (final c in service.characteristics) {
  if (c.properties.read) {
    final value = await c.read();
    print(value);
  }
}
```

### Write characteristic

```dart
await c.write([0x12, 0x34]);
```

### Subscribe to a characteristic

```dart
final sub = characteristic.onValueReceived.listen((value) {
  // handle reads/notifications
});
device.cancelWhenDisconnected(sub);
await characteristic.setNotifyValue(true);
```

### Last value stream

```dart
final sub = characteristic.lastValueStream.listen((value) {
  // emits for read, write and notify
});
device.cancelWhenDisconnected(sub);
await characteristic.setNotifyValue(true);
```

### Descriptors

```dart
for (final d in characteristic.descriptors) {
  final value = await d.read();
  print(value);
  await d.write([0x12, 0x34]);
}
```

### Services changed characteristic

```dart
device.onServicesReset.listen(() async {
  await device.discoverServices();
});
```

### Connected & System devices

```dart
final connected = FlutterBluePlus.connectedDevices;

final withServices = [Guid('180F')];
final system = await FlutterBluePlus.systemDevices(withServices);
```

### Bonding (Android)

```dart
final bs = device.bondState.listen((v) => print(v));
device.cancelWhenDisconnected(bs);
await device.createBond();
await device.removeBond();
```

### Events API (all devices)

```dart
FlutterBluePlus.events.onConnectionStateChanged.listen((event) {
  print('${event.device} ${event.connectionState}');
});
```


