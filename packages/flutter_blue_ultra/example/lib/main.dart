// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import 'screens/accessory_setup_screen.dart';
import 'screens/bluetooth_off_screen.dart';
import 'screens/scan_screen.dart';
import 'utils/ble_manager.dart';

void main() {
  FlutterBlueUltra.setLogLevel(LogLevel.verbose, color: true);
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      debugShowCheckedModeBanner: false,
      home: const LaunchScreen(),
      navigatorObservers: [BluetoothAdapterStateObserver()],
    );
  }
}

// Initial screen shown before any FlutterBlueUltra initialization.
// Choosing "Accessory Setup" keeps CBCentralManager inactive so that
// the AccessorySetupKit picker can open without error 550.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Blue Ultra')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LaunchButton(
              icon: Icons.bluetooth_searching,
              label: 'BLE Scanner',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BleScannerFlow()),
              ),
            ),
            const SizedBox(height: 16),
            _LaunchButton(
              icon: Icons.settings_remote_outlined,
              label: 'Accessory Setup',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccessorySetupScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaunchButton extends StatelessWidget {
  const _LaunchButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 56,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}

// Entered only when the user explicitly taps "BLE Scanner".
// FlutterBlueUltra.adapterState is accessed here, which creates the
// CBCentralManager. Do not navigate here before using AccessorySetupKit.
class BleScannerFlow extends StatefulWidget {
  const BleScannerFlow({super.key});

  @override
  State<BleScannerFlow> createState() => _BleScannerFlowState();
}

class _BleScannerFlowState extends State<BleScannerFlow> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  @override
  void initState() {
    super.initState();
    _adapterStateSubscription = FlutterBlueUltra.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription.cancel();
    tearDownBleManager();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _adapterState == BluetoothAdapterState.on
        ? const ScanScreen()
        : BluetoothOffScreen(adapterState: _adapterState);
  }
}

// Listens for Bluetooth Off and dismisses the DeviceScreen.
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      _adapterStateSubscription ??= FlutterBlueUltra.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}
