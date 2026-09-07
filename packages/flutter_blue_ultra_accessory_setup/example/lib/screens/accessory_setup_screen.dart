import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../cubits/accessory_setup_cubit.dart';
import '../widgets/accessory_row.dart';
import '../widgets/event_console.dart';
import '../widgets/session_status_card.dart';
import '../widgets/setup_nav.dart';

class AccessorySetupScreen extends StatelessWidget {
  const AccessorySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AccessorySetupKit is iOS-only. The plugin talks to ASAccessorySession
    // through Pigeon and has nothing to bind to on any other platform.
    final isIOS = !kIsWeb && Platform.isIOS;
    if (!isIOS) return const _UnsupportedPlatformView();

    return BlocProvider(
      create: (_) => AccessorySetupCubit()..initialize(),
      child: const _AccessorySetupView(),
    );
  }
}

class _UnsupportedPlatformView extends StatelessWidget {
  const _UnsupportedPlatformView();

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: DsEmptyState(
            icon: Icons.block,
            title: 'AccessorySetupKit is only available on iOS',
            description: 'This screen uses Apple’s AccessorySetupKit, which '
                'has no Android/web equivalent.',
          ),
        ),
      ),
    );
  }
}

class _AccessorySetupView extends StatefulWidget {
  const _AccessorySetupView();

  @override
  State<_AccessorySetupView> createState() => _AccessorySetupViewState();
}

class _AccessorySetupViewState extends State<_AccessorySetupView> {
  StreamSubscription<String>? _messageSub;

  @override
  void initState() {
    super.initState();
    _messageSub = context.read<AccessorySetupCubit>().messages.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return BlocBuilder<AccessorySetupCubit, AccessorySetupState>(
      builder: (context, state) {
        final cubit = context.read<AccessorySetupCubit>();
        final config = cubit.config;
        final phase = SessionStatusCard.phaseOf(state);

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              children: [
                SetupNav(
                  title: 'Accessory SetupKit',
                  subtitle: 'iOS pairing picker',
                  trailing: SetupNavButton(
                    icon: Icons.bug_report_outlined,
                    tooltip: 'Print native session logs',
                    onPressed: cubit.printNativeSessionLogs,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(DsSpace.s20),
                    children: [
                      Text(
                        config.serviceName.toUpperCase(),
                        style: DsTextStyles.monoLabelLoud(
                          color: colors.textDim,
                        ),
                      ),
                      const SizedBox(height: DsSpace.s8),
                      RichText(
                        text: TextSpan(
                          style: DsTextStyles.heading2xl(
                            color: colors.textPrimary,
                          ),
                          children: [
                            const TextSpan(text: 'Pairing, '),
                            TextSpan(
                              text: 'by service.',
                              style: DsTextStyles.heading2xl(
                                color: colors.accent,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DsSpace.s8),
                      Text(
                        'The picker filters for ${config.serviceUuid}.',
                        style: DsTextStyles.bodySm(color: colors.textDim),
                      ),
                      const SizedBox(height: DsSpace.s24),
                      SessionStatusCard(
                        phase: phase,
                        accessoryCount: state.accessories.length,
                      ),
                      if (phase == SessionPhase.error) ...[
                        const SizedBox(height: DsSpace.s12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error,
                              size: DsSize.iconXSmall,
                              color: colors.destructive,
                            ),
                            const SizedBox(width: DsSpace.s4),
                            Expanded(
                              child: Text(
                                'Couldn’t start the pairing session — retry '
                                'below.',
                                style: DsTextStyles.bodyXs(
                                  color: colors.destructive,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: DsSpace.s24),
                      DsSectionHeader(
                        label: 'Paired accessories',
                        count: state.accessories.length,
                        showRule: state.accessories.isNotEmpty,
                      ),
                      const SizedBox(height: DsSpace.s8),
                      if (state.accessories.isEmpty)
                        DsEmptyState(
                          icon: Icons.bluetooth_disabled,
                          title: 'No accessories paired yet.',
                          titleStyle: DsTextStyles.monoMd(
                            color: colors.textDim,
                          ),
                        )
                      else
                        for (final accessory in state.accessories)
                          AccessoryRow(
                            accessory: accessory,
                            onRemove: () => cubit.removeAccessory(accessory),
                          ),
                      const SizedBox(height: DsSpace.s24),
                      DsSectionHeader(
                        label: 'Event log',
                        trailing: state.eventLog.isEmpty
                            ? null
                            : _ClearButton(onPressed: cubit.clearLog),
                      ),
                      const SizedBox(height: DsSpace.s8),
                      if (state.eventLog.isEmpty)
                        DsEmptyState(
                          icon: Icons.subject,
                          title: 'No events yet.',
                          titleStyle: DsTextStyles.monoMd(
                            color: colors.textDim,
                          ),
                        )
                      else
                        EventConsole(entries: state.eventLog),
                    ],
                  ),
                ),
                _PickerBar(
                  enabled: state.canOpenPicker,
                  loading: state.isPickerLoading,
                  onPressed: cubit.showPicker,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return GestureDetector(
      onTap: onPressed,
      child: Text(
        'CLEAR',
        style: DsTextStyles.monoLabel(color: colors.accent),
      ),
    );
  }
}

class _PickerBar extends StatelessWidget {
  const _PickerBar({
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderHi)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DsSpace.s20,
          DsSpace.s16,
          DsSpace.s20,
          DsSpace.s16,
        ),
        child: DsButton(
          label: loading ? 'Opening picker' : 'Show picker',
          icon: Icons.add_circle_outline,
          loading: loading,
          onPressed: enabled ? onPressed : null,
        ),
      ),
    );
  }
}
