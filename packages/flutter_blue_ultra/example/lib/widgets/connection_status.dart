import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../models/ble_models.dart';

class ConnectionStatusIndicator extends StatelessWidget {
  const ConnectionStatusIndicator({super.key, required this.phase});

  final ConnectionPhase phase;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);
    final (color, label) = switch (phase) {
      ConnectionPhase.connecting => (colors.accent, 'CONNECTING'),
      ConnectionPhase.discovering => (colors.accent, 'DISCOVERING'),
      ConnectionPhase.connected => (colors.success, 'CONNECTED'),
      ConnectionPhase.disconnected => (colors.textDim, 'DISCONNECTED'),
    };

    return DsStatusIndicator(
      label: label,
      color: color,
      pulsing: phase == ConnectionPhase.connecting ||
          phase == ConnectionPhase.discovering,
      labelStyle: DsTypography.monoLabel(10.5, color: color),
    );
  }
}
