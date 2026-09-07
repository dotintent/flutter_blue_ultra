import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../models/ble_models.dart';

class ConnectionDot extends StatelessWidget {
  const ConnectionDot({super.key, required this.phase, this.failure});

  final ConnectionPhase phase;
  final DeviceFailure? failure;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    final (color, label) = switch (phase) {
      ConnectionPhase.connecting => (colors.accent, 'CONNECTING…'),
      ConnectionPhase.discovering => (colors.accent, 'DISCOVERING…'),
      ConnectionPhase.connected => (colors.success, 'CONNECTED'),
      ConnectionPhase.disconnected => switch (failure) {
          DeviceFailure.connectFailed => (
              colors.destructive,
              "COULDN'T CONNECT",
            ),
          DeviceFailure.discoveryFailed => (
              colors.destructive,
              'DISCOVERY FAILED',
            ),
          DeviceFailure.connectionLost => (
              colors.destructive,
              'CONNECTION LOST',
            ),
          _ => (colors.textDim, 'DISCONNECTED'),
        },
    };

    return DsStatusIndicator(
      label: label,
      color: color,
      pulsing: phase == ConnectionPhase.connecting ||
          phase == ConnectionPhase.discovering,
      labelStyle: DsTextStyles.monoLabelLoud(color: color),
    );
  }
}
