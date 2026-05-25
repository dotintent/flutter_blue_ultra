import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    GoogleFonts.pendingFonts([
      GoogleFonts.crimsonPro(fontWeight: FontWeight.w500),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w400),
      GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600),
      GoogleFonts.inter(fontWeight: FontWeight.w400),
    ]),
  ]);

  // Example apps benefit from a chatty log — switch to LogLevel.debug or
  // LogLevel.verbose when investigating a specific issue.
  FlutterBlueUltra.setLogLevel(LogLevel.info);

  runApp(const FBUApp());
}
