import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Example apps benefit from a chatty log — switch to LogLevel.debug or
  // LogLevel.verbose when investigating a specific issue.
  FlutterBlueUltra.setLogLevel(LogLevel.info);

  runApp(const FBUApp());
}
