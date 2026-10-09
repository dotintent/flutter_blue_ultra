# Running the Wear OS app

1. Run the watch app with `cd android && ./gradlew :wear:installDebug`, or pick the `wear` run configuration in Android Studio (a shared one is generated at .run/wear.run.xml).
2. Do not use `flutter run` for the watch: the phone and Wear apps share an applicationId, so it replaces the Wear app with the phone app.
3. If install fails with INSTALL_FAILED_VERSION_DOWNGRADE, remove the installed copy: `adb uninstall com.lib.flutter_blue_ultra_example` (add `-s <serial>` when several devices are connected), then install again.
4. On the watch, enable Developer options (Settings > System > About > tap Build number 7 times), then turn on ADB debugging and Debug over Wi-Fi.
5. Pair over Wi-Fi: `adb pair <ip>:<pairing-port>` (enter the pairing code shown on the watch), then `adb connect <ip>:<debug-port>`. Confirm with `adb devices`.
6. After Gradle changes, use "Sync Project with Gradle Files" in Android Studio so the `wear` module shows up.
7. Check that the SDK path in Android Studio (Settings > Languages & Frameworks > Android SDK) matches `sdk.dir` in android/local.properties; a mismatch causes "SDK location not found" or stale tooling.
