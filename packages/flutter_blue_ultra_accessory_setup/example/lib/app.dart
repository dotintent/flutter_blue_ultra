import 'package:flutter/material.dart';

import 'screens/accessory_setup_screen.dart';

class AccessorySetupExampleApp extends StatelessWidget {
  const AccessorySetupExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessory Setup Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF3B5C),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AccessorySetupScreen(),
    );
  }
}
