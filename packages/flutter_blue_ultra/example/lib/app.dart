import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import 'cubits/app_shell_cubit.dart';
import 'screens/permission_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/device_screen.dart';
import 'screens/splash_screen.dart';

class FBUApp extends StatelessWidget {
  const FBUApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blue Ultra',
      debugShowCheckedModeBanner: false,
      theme: DsTheme.light(),
      darkTheme: DsTheme.dark(),
      themeMode: ThemeMode.dark,
      home: BlocProvider(
        create: (_) => AppShellCubit()..bootstrap(),
        child: const _AppShell(),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppShellCubit, AppShellState>(
      builder: (context, state) {
        // Exhaustive switch on the sealed AppShellState — adding a new
        // shell forces a compile error here until it's handled.
        return switch (state) {
          SplashShellState() => const SplashScreen(),
          PermissionShellState() => PermissionScreen(
              onGranted: () => context.read<AppShellCubit>().goToScan(),
            ),
          ScanShellState() => ScanScreen(
              onDeviceSelected: (device, rssi) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DeviceScreen(
                      device: device,
                      rssi: rssi,
                    ),
                  ),
                );
              },
            ),
        };
      },
    );
  }
}
