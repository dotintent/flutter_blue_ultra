import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

import '../cubits/permission_cubit.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/brand_header.dart';
import '../widgets/footer_message.dart';
import '../widgets/permission_row.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key, required this.onGranted});

  final VoidCallback onGranted;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PermissionCubit(),
      child: _PermissionView(onGranted: onGranted),
    );
  }
}

class _PermissionView extends StatefulWidget {
  const _PermissionView({required this.onGranted});

  final VoidCallback onGranted;

  @override
  State<_PermissionView> createState() => _PermissionViewState();
}

class _PermissionViewState extends State<_PermissionView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState != AppLifecycleState.resumed) return;
    _recheck();
  }

  Future<void> _recheck() async {
    final cubit = context.read<PermissionCubit>();
    if (!cubit.state.denied) return;
    final granted = await cubit.refresh();
    if (granted && mounted) widget.onGranted();
  }

  Future<void> _onPrimaryTap() async {
    final cubit = context.read<PermissionCubit>();
    if (cubit.state.blocked) {
      await cubit.openSettings();
      return;
    }

    try {
      final granted = await cubit.requestPermissions();
      if (granted && mounted) widget.onGranted();
    } catch (e) {
      if (!mounted) return;
      showAppMessage(
        context,
        AppMessage.error('Permission request failed: $e'),
      );
    }
  }

  String _buttonLabel(PermissionState state) => switch (state.phase) {
        PermissionPhase.requesting => 'Requesting…',
        PermissionPhase.deniedBlocked => 'Open Settings',
        PermissionPhase.deniedRetryable => 'Try again',
        PermissionPhase.initial => 'Allow Bluetooth access',
      };

  String _footerMessage(PermissionState state) => switch (state.phase) {
        PermissionPhase.deniedBlocked =>
          'Bluetooth is blocked for this app. Enable it in Settings to scan.',
        PermissionPhase.deniedRetryable =>
          'Bluetooth access is needed to scan. Grant it to continue.',
        _ => 'You can change this anytime in Settings.',
      };

  @override
  Widget build(BuildContext context) {
    final colors = DsColors.of(context);

    return BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(DsSpace.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandHeader(),
                  const SizedBox(height: DsSpace.s24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: DsTextStyles.heading2xl(
                                color: colors.textPrimary,
                              ),
                              children: [
                                const TextSpan(text: 'Permission to '),
                                TextSpan(
                                  text: 'discover',
                                  style: DsTextStyles.heading2xl(
                                    color: colors.accent,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const TextSpan(text: ' what’s near.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: DsSpace.s8),
                          Text(
                            "We'll scan for nearby Bluetooth Low Energy "
                            'peripherals so you can connect, inspect, and '
                            'exchange data.',
                            style: DsTextStyles.bodySm(color: colors.textDim),
                          ),
                          const SizedBox(height: DsSpace.s32),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: colors.border),
                              ),
                            ),
                            child: Column(
                              children: [
                                for (final (index, item) in state.items.indexed)
                                  PermissionRow(
                                    index: index + 1,
                                    label: item.label,
                                    description: item.description,
                                    denied: item.denied,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DsSpace.s24),
                  FooterMessage(
                    message: _footerMessage(state),
                    tone: state.denied ? colors.destructive : null,
                  ),
                  const SizedBox(height: DsSpace.s12),
                  DsButton(
                    label: _buttonLabel(state),
                    loading: state.requesting,
                    onPressed: _onPrimaryTap,
                    style: FilledButton.styleFrom(
                      disabledBackgroundColor: colors.brandFill,
                      disabledForegroundColor: colors.onAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
