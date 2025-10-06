## API Reference (1.x compatible)

Note: When functionality is unsupported on a platform, sensible defaults are returned instead of an error.

Legend: 🌀 Stream, ⚡ Synchronous, 🔥 Can fail

### Top-level

| Function | Android | iOS | Linux | macOS | Web | Description |
|---|---|---|---|---|---|---|
| setLogLevel | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | Configure plugin log level |
| setOptions | ✔️ | ✔️ | ❌ | ✔️ | ❌ | Set configurable bluetooth options |
| isSupported | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Checks whether the device supports Bluetooth |
| turnOn 🔥 | ✔️ | ❌ | ✔️ | ❌ | ❌ | Turns on the bluetooth adapter |
| turnOff 🔥 | ✔️ | ❌ | ✔️ | ❌ | ❌ | Turns off the bluetooth adapter |
| adapterStateNow ⚡ | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | Current adapter state |
| adapterState 🌀 | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | Stream of adapter state changes |
| startScan 🔥 | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Start a BLE scan |
| stopScan 🔥 | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | Stop scanning |
| onScanResults 🌀🔥 | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Live scan results |
| scanResults 🌀🔥 | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Live or previous results |
| lastScanResults ⚡ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Latest scan results |
| isScanning 🌀 | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Current scan state |
| isScanningNow ⚡ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Is scanning now? |
| connectedDevices ⚡ | ✔️ | ✔️ | ✔️ | ✔️ | ✔️ | Devices connected to your app |
| systemDevices 🔥 | ✔️ | ✔️ | ✔️ | ✔️ | ❌ | Devices connected to the system |
| getPhySupport | ✔️ | ❌ | ❌ | ❌ | ❌ | Get supported PHY codings |

### Events API

onConnectionStateChanged 🌀, onMtuChanged 🌀, onReadRssi 🌀, onServicesReset 🌀, onDiscoveredServices 🌀, onCharacteristicReceived 🌀, onCharacteristicWritten 🌀, onDescriptorRead 🌀, onDescriptorWritten 🌀, onNameChanged (iOS) 🌀, onBondStateChanged (Android) 🌀.

### BluetoothDevice

platformName ⚡, advName ⚡, connect 🔥, disconnect 🔥, isConnected ⚡, isDisconnected ⚡, connectionState 🌀, discoverServices 🔥, servicesList ⚡, onServicesReset 🌀, mtu 🌀, mtuNow ⚡, readRssi 🔥, requestMtu 🔥 (Android), requestConnectionPriority 🔥 (Android), bondState 🌀 (Android), createBond 🔥 (Android), removeBond (Android), setPreferredPhy (Android), clearGattCache (Android).

### BluetoothCharacteristic

uuid ⚡, read 🔥, write 🔥, setNotifyValue 🔥, isNotifying ⚡, onValueReceived 🌀, lastValue ⚡, lastValueStream 🌀.

### BluetoothDescriptor

uuid ⚡, read 🔥, write 🔥, onValueReceived 🌀, lastValue ⚡, lastValueStream 🌀.


