import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/accessory_setup_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms.dart';
import '../widgets/accessory_setup_widgets.dart';

class AccessorySetupScreen extends StatelessWidget {
  const AccessorySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        final it = IntentTheme.of(context);

        return Scaffold(
          backgroundColor: it.bg,
          body: Column(
            children: [
              IntentAppBar(
                title: 'Accessory SetupKit',
                subtitle: 'iOS pairing picker',
                trailing: IntentIconBtn(
                  onTap: cubit.printNativeSessionLogs,
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
                            style: IntentTextStyles.monoLabel(
                              11,
                              it.textFaint,
                            ),
                          ),
                          const SizedBox(height: 14),
                          RichText(
                            text: TextSpan(
                              style: IntentTextStyles.serifDisplay(
                                40,
                                it.textPrimary,
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
                            style: IntentTextStyles.sans(13.5, it.textDim),
                          ),
                          const SizedBox(height: 22),
                          AccessoryStatusPanel(state: state),
                        ],
                      ),
                    ),
                    SectionHeader(
                      label: 'Paired accessories',
                      count: state.accessories.length,
                    ),
                    if (state.accessories.isEmpty)
                      const EmptyState(
                        icon: Icons.bluetooth_searching,
                        title: 'No accessories paired yet.',
                      )
                    else
                      for (final accessory in state.accessories)
                        AccessoryTile(
                          accessory: accessory,
                          onRemove: () => cubit.removeAccessory(accessory),
                        ),
                    SectionHeader(
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
