import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_blue_ultra/flutter_blue_ultra.dart';

const Set<int> _kAndroidRetryableCodes = {8, 22, 62, 133, 147};

const Set<int> _kAppleRetryableCodes = {6, 7, 10};

const Map<int, String> _kAndroidReasons = {
  8: 'The link timed out before the device answered.',
  19: 'The device closed the connection.',
  22: 'The phone dropped the link.',
  62: "The connection couldn't be established.",
  133: 'The Android stack refused the link (GATT error 133).',
  147: 'The device stopped responding during connect.',
};

const Map<int, String> _kAppleReasons = {
  3: 'The connection is no longer valid.',
  6: 'The device stopped responding during connect.',
  7: 'The device disconnected.',
  10: "The connection couldn't be established.",
  14: 'The device is out of range.',
};

bool isRetryableBleError(Object error) {
  if (error is TimeoutException) return true;
  if (error is! FlutterBlueUltraException) return false;
  final code = error.code;
  if (code == null) return false;
  return switch (error.platform) {
    ErrorPlatform.android => _kAndroidRetryableCodes.contains(code),
    ErrorPlatform.apple => _kAppleRetryableCodes.contains(code),
    _ => false,
  };
}

String describeBleError(Object error) {
  if (error is TimeoutException) {
    return 'The device did not respond in time.';
  }
  if (error is FlutterBlueUltraException) {
    final reason = _reasonFor(error);
    if (reason != null) return reason;
    final description = error.description;
    if (description != null && description.isNotEmpty) {
      return _humanize(description);
    }
    return 'The ${error.function} call failed.';
  }
  if (error is PlatformException) {
    final message = error.message;
    if (message != null && message.isNotEmpty) return _humanize(message);
    return 'The platform rejected the request.';
  }
  return _humanize(error.toString());
}

String? _reasonFor(FlutterBlueUltraException error) {
  final code = error.code;
  if (code == null) return null;
  return switch (error.platform) {
    ErrorPlatform.android => _kAndroidReasons[code],
    ErrorPlatform.apple => _kAppleReasons[code],
    _ => null,
  };
}

/// Turns a raw platform string such as `GATT_CONNECTION_TIMEOUT` into
/// `Gatt connection timeout` so it reads as a sentence next to our own copy.
String _humanize(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return trimmed;
  if (!RegExp(r'^[A-Z0-9_]+$').hasMatch(trimmed)) return trimmed;
  final words = trimmed.toLowerCase().replaceAll('_', ' ');
  return words[0].toUpperCase() + words.substring(1);
}
