import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/accessory_setup_cubit.dart';
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Accessory SetupKit'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bug_report_outlined),
                tooltip: 'Print native logs',
                onPressed: cubit.printNativeSessionLogs,
              ),
            ],
          ),
          body: Column(
            children: [
              AccessoryStatusBanner(state: state),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Pair an accessory',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This app exercises the AccessorySetupKit path. '
                      'The picker filters for ${cubit.config.serviceUuid}, '
                      'which must also be listed in ios/Runner/Info.plist.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    AccessorySection(
                      title: 'Paired accessories',
                      child: state.accessories.isEmpty
                          ? const Text('No accessories paired yet.')
                          : Column(
                              children: [
                                for (final accessory in state.accessories)
                                  AccessoryTile(
                                    accessory: accessory,
                                    onRemove: () =>
                                        cubit.removeAccessory(accessory),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),
                    AccessorySection(
                      title: 'Event log',
                      trailing: state.eventLog.isEmpty
                          ? null
                          : TextButton(
                              onPressed: cubit.clearLog,
                              child: const Text('Clear'),
                            ),
                      child: EventLogList(entries: state.eventLog),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: FilledButton.icon(
                    onPressed: state.canOpenPicker ? cubit.showPicker : null,
                    icon: state.isPickerLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline),
                    label: Text(
                      state.isPickerLoading ? 'Opening picker' : 'Show picker',
                    ),
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
