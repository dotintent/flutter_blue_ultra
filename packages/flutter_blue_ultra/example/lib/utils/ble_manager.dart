import 'dart:io';

import 'package:flutter/services.dart';

// Calls the native tearDown handler added to flutter_blue_ultra_darwin.
// Releases the CBCentralManager so AccessorySetupKit's picker can open
// without error 550 ("CBManagers active with global permissions").
// iOS only — no-op on other platforms.
Future<void> tearDownBleManager() async {
  if (!Platform.isIOS) return;
  const channel = MethodChannel('flutter_blue_ultra/methods');
  await channel.invokeMethod<bool>('tearDown');
}
