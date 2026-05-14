import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/permission_cubit.dart';
import '../theme/app_theme.dart';
import '../widgets/atoms.dart';

const _iosLabels = [
  ('BLUETOOTH', 'Scan, connect & exchange GATT data'),
];

const _macosLabels = [
  ('CORE BLUETOOTH', 'Handled by macOS Bluetooth entitlement'),
];

const _webLabels = [
  ('WEB BLUETOOTH', 'Browser will prompt when scanning/connecting'),
];

const _androidLabels = [
  ('BLUETOOTH_SCAN', 'Discover advertising peripherals'),
  ('BLUETOOTH_CONNECT', 'Connect & exchange GATT data'),
];

const _androidLocationLabel = (
  'ACCESS_FINE_LOCATION',
  'Required on Android 11 and below',
);

Future<List<(String, String)>> _permissionLabels() async {
  if (kIsWeb) return _webLabels;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    return _iosLabels;
  }
  if (defaultTargetPlatform == TargetPlatform.macOS) return _macosLabels;
  if (defaultTargetPlatform == TargetPlatform.android &&
      await androidNeedsLocationPermission()) {
    return [..._androidLabels, _androidLocationLabel];
  }
  return _androidLabels;
}

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key, required this.onGranted});
  final VoidCallback onGranted;

  Future<void> _onGrantTap(BuildContext context) async {
    final cubit = context.read<PermissionCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final granted = await cubit.requestPermissions();
      if (granted) {
        onGranted();
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
                'Some permissions were denied. BLE may not work correctly.'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Permission request failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final it = IntentTheme.of(context);

    return BlocProvider(
      create: (_) => PermissionCubit(),
      child: BlocBuilder<PermissionCubit, PermissionState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: it.bg,
            body: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Opacity(
                    opacity: 0.6,
                    child: ConcentricDecor(
                      size: 320,
                      strokeOpacity: it.isDark ? 0.18 : 0.22,
                      dot: true,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -100,
                  child: Opacity(
                    opacity: 0.5,
                    child: ConcentricDecor(
                      size: 300,
                      strokeOpacity: it.isDark ? 0.12 : 0.15,
                      dot: false,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IntentMark(height: 20),
                        const SizedBox(height: 60),
                        Text(
                          '· STEP 01 / 03',
                          style: IntentTextStyles.monoLabel(12, it.accent),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: IntentTextStyles.serifDisplay(
                                38, it.textPrimary,
                                letterSpacing: -1),
                            children: [
                              const TextSpan(text: 'Permission to '),
                              TextSpan(
                                text: 'discover',
                                style: TextStyle(
                                    color: it.accent,
                                    fontStyle: FontStyle.italic),
                              ),
                              const TextSpan(text: " what's near."),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "We'll scan for nearby Bluetooth Low Energy peripherals so you can connect, inspect, and exchange data.",
                          style: IntentTextStyles.sans(14, it.textDim),
                        ),
                        const SizedBox(height: 36),
                        FutureBuilder<List<(String, String)>>(
                          future: _permissionLabels(),
                          builder: (context, snapshot) {
                            final labels = snapshot.data ??
                                (kIsWeb
                                    ? _webLabels
                                    : defaultTargetPlatform ==
                                            TargetPlatform.iOS
                                        ? _iosLabels
                                        : defaultTargetPlatform ==
                                                TargetPlatform.macOS
                                            ? _macosLabels
                                            : [
                                                ..._androidLabels,
                                                _androidLocationLabel
                                              ]);
                            return Container(
                              decoration: BoxDecoration(
                                border:
                                    Border(top: BorderSide(color: it.border)),
                              ),
                              child: Column(
                                children: labels.asMap().entries.map((e) {
                                  final i = e.key;
                                  final (perm, desc) = e.value;
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: i < labels.length - 1
                                          ? Border(
                                              bottom:
                                                  BorderSide(color: it.border))
                                          : null,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '0${i + 1}',
                                          style: IntentTextStyles.mono(
                                              11, it.textFaint),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(perm,
                                                  style: IntentTextStyles.mono(
                                                      11.5, it.textPrimary)),
                                              const SizedBox(height: 3),
                                              Text(desc,
                                                  style: IntentTextStyles.sans(
                                                      12.5, it.textDim)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(top: 6),
                                          decoration: BoxDecoration(
                                            color: it.accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        IntentButton(
                          label: state.requesting
                              ? 'Requesting…'
                              : 'Grant & continue',
                          onTap: state.requesting
                              ? null
                              : () => _onGrantTap(context),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            'REVOCABLE IN SYSTEM SETTINGS',
                            style: IntentTextStyles.mono(11, it.textFaint,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
