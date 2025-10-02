## Getting Started

### Add the package

Until a pub.dev release, add via Git:

```yaml
dependencies:
  flutter_blue_ultra:
    git:
      url: https://github.com/intent-dev/flutter_blue_ultra.git
```

The API is designed to be familiar to users of `flutter_blue_plus` 1.x, with a compatibility layer for legacy code.

### Android minSdkVersion

`minSdkVersion` must be 21 or greater:

```groovy
android {
  defaultConfig {
    minSdkVersion 21
  }
}
```

### Android permissions (no location)

```xml
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- legacy for Android 11 or lower -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30" />

<!-- legacy for Android 9 or lower -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
```

### Android permissions (with fine location)

```xml
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<!-- legacy for Android 11 or lower -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />

<!-- legacy for Android 9 or lower -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
```

Set `androidUsesFineLocation: true` when scanning if needed.

### Android Proguard

Add in `android/app/proguard-rules.pro`:

```
-keep class com.lib.flutter_blue_ultra.* { *; }
```

### iOS permissions

`ios/Runner/Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to function</string>
```

For location-related permissions, see Apple's CoreLocation docs.

### macOS permissions

Enable Bluetooth capability:

Xcode → Runner → Targets → Runner → Signing & Capabilities → App Sandbox → Hardware → Enable Bluetooth


