## Using BLE in App Background

This is an advanced use case. Not all functionality is supported on all platforms.

### iOS

Apple docs: https://developer.apple.com/library/archive/documentation/NetworkingInternetWeb/Conceptual/CoreBluetooth_concepts/CoreBluetoothBackgroundProcessingForIOSApps/PerformingTasksWhileYourAppIsInTheBackground.html

`Info.plist`:

```
<key>UIBackgroundModes</key>
<array>
  <string>bluetooth-central</string>
  <!-- Add others as needed -->
  
</array>
```

To wake up your app after the OS kills it, set before any BLE work:

```
FlutterBluePlus.setOptions(restoreState: true);
```

Note: iOS gives limited background execution time (~10 seconds) per wake.

### Android

Consider a foreground service or background task framework:

- `flutter_foreground_task`
- `workmanager`


