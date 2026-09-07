import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../cubits/accessory_setup_cubit.dart';

enum SessionPhase { starting, ready, error }

class SessionStatusCard extends StatelessWidget {
  const SessionStatusCard({
    super.key,
    required this.phase,
    required this.accessoryCount,
  });

  final SessionPhase phase;
  final int accessoryCount;

  static SessionPhase phaseOf(AccessorySetupState state) {
    if (state.initError != null) return SessionPhase.error;
    return state.isActivated ? SessionPhase.ready : SessionPhase.starting;
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    final tone = switch (phase) {
      SessionPhase.starting => colors.accent,
      SessionPhase.ready => colors.success,
      SessionPhase.error => colors.destructive,
    };

    final label = switch (phase) {
      SessionPhase.starting => 'SESSION.STARTING',
      SessionPhase.ready => 'SESSION.READY',
      SessionPhase.error => 'SETUP.ERROR',
    };

    final detail = switch (phase) {
      SessionPhase.starting => 'Activating session',
      SessionPhase.ready => 'Session activated',
      SessionPhase.error => 'SetupKit unavailable',
    };

    return DsCard(
      padding: const EdgeInsets.all(DsSpace.s16),
      child: Row(
        children: [
          DsStatusRing(
            tone: tone,
            spinning: phase == SessionPhase.starting,
            child: phase == SessionPhase.starting
                ? const DsSpinner(size: DsSize.iconXXLarge)
                : DsBluetoothGlyph(
                    size: DsSize.iconXXLarge,
                    color: colors.textPrimary,
                  ),
          ),
          const SizedBox(width: DsSpace.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: DsTextStyles.monoLabel(color: tone)),
                const SizedBox(height: DsSpace.s4),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DsTextStyles.bodyXs(color: colors.textDim),
                ),
              ],
            ),
          ),
          const SizedBox(width: DsSpace.s16),
          Text(
            accessoryCount.toString().padLeft(2, '0'),
            style: DsTextStyles.headingXl(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
