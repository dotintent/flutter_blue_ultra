import 'package:flutter/material.dart';

import 'screens/accessory_setup_screen.dart';
import 'theme/app_theme.dart';

class AccessorySetupExampleApp extends StatelessWidget {
  const AccessorySetupExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessory Setup Example',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.dark,
      home: const AccessorySetupScreen(),
    );
  }
}
