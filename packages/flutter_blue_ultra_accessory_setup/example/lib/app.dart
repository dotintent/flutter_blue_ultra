import 'package:flutter/material.dart';

import 'screens/accessory_setup_screen.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

class AccessorySetupExampleApp extends StatelessWidget {
  const AccessorySetupExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessory Setup Example',
      debugShowCheckedModeBanner: false,
      theme: DsTheme.light(),
      darkTheme: DsTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const AccessorySetupScreen(),
    );
  }
}
