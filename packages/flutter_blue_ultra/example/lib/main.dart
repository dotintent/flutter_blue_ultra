import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    DsTypography.pendingFonts(),
  ]);

  // Example apps benefit from a chatty log — switch to LogLevel.debug or
  // LogLevel.verbose when investigating a specific issue.
  FlutterBlueUltra.setLogLevel(LogLevel.info);

  runApp(const FBUApp());
}
