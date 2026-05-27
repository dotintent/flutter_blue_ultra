import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  FlutterBlueUltra.setLogLevel(LogLevel.info);
  runApp(const AccessorySetupExampleApp());
}
