import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/accessory_setup_cubit.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';
import '../widgets/accessory_setup_widgets.dart';

class AccessorySetupScreen extends StatelessWidget {
  const AccessorySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AccessorySetupKit is iOS-only. The plugin uses Objective-C FFI bindings
    // and will crash on any other platform when constructed.
    final isIOS = !kIsWeb && Platform.isIOS;
    if (!isIOS) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'AccessorySetupKit is only available on iOS.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => AccessorySetupCubit()..initialize(),
      child: const _AccessorySetupView(),
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
    return BlocBuilder<AccessorySetupCubit, AccessorySetupState>(
      builder: (context, state) {
        final cubit = context.read<AccessorySetupCubit>();
        final it = DsColors.of(context);

        return Scaffold(
          backgroundColor: it.background,
          body: Column(
            children: [
              DsAppBar(
                title: 'Accessory SetupKit',
                subtitle: 'iOS pairing picker',
                trailing: DsIconButton(
                  onPressed: cubit.printNativeSessionLogs,
                  child: Icon(
                    Icons.bug_report_outlined,
                    color: it.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '· ACCESSORY SETUPKIT',
                            style: DsTypography.monoLabel(11, color: it.textFaint,
                            ),
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: TextSpan(
                              style: DsTypography.serifDisplay(40, color: it.textPrimary,
                                letterSpacing: -1.5,
                              ),
                              children: [
                                const TextSpan(text: 'Pairing,\n'),
                                TextSpan(
                                  text: 'by service.',
                                  style: TextStyle(
                                    color: it.accent,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The picker filters for ${cubit.config.serviceUuid}.',
                            style: DsTypography.sans(13.5, color: it.textDim),
                          ),
                          const SizedBox(height: 22),
                          AccessoryStatusPanel(state: state),
                        ],
                      ),
                    ),
                    DsSectionHeader(
                      label: 'Paired accessories',
                      count: state.accessories.length,
                    ),
                    if (state.accessories.isEmpty)
                      const DsEmptyState(
                        icon: Icons.bluetooth_searching,
                        title: 'No accessories paired yet.',
                      )
                    else
                      for (final accessory in state.accessories)
                        AccessoryTile(
                          accessory: accessory,
                          onRemove: () => cubit.removeAccessory(accessory),
                        ),
                    DsSectionHeader(
                      label: 'Event log',
                      trailing: state.eventLog.isEmpty
                          ? null
                          : TextButton(
                              onPressed: cubit.clearLog,
                              child: const Text('Clear'),
                            ),
                    ),
                    EventLogList(entries: state.eventLog),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: AccessoryPickerButton(
                    enabled: state.canOpenPicker,
                    loading: state.isPickerLoading,
                    onPressed: cubit.showPicker,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
