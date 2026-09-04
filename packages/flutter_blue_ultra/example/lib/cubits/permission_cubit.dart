import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

/// Android BLE permissions. Shared with [AppShellCubit] so the
/// "already-granted" check and the "request now" call stay in lockstep.
const kAndroidBlePermissions = <Permission>[
  Permission.bluetoothScan,
  Permission.bluetoothConnect,
];

const kAndroidBlePermissionsWithLocation = <Permission>[
  ...kAndroidBlePermissions,
  Permission.locationWhenInUse,
];

const kIosBlePermissions = <Permission>[
  Permission.bluetooth,
];

Future<List<Permission>> blePermissionsForCurrentPlatform() async {
  if (kIsWeb) {
    return const <Permission>[];
  }
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => await androidNeedsLocationPermission()
        ? kAndroidBlePermissionsWithLocation
        : kAndroidBlePermissions,
    TargetPlatform.iOS => kIosBlePermissions,
    _ => const <Permission>[],
  };
}

Future<bool> androidNeedsLocationPermission() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
    return false;
  }
  try {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt <= 30;
  } catch (_) {
    // Unknown SDK: keep broader compatibility path.
    return true;
  }
}

bool isGrantedOrLimited(PermissionStatus status) {
  return status == PermissionStatus.granted ||
      status == PermissionStatus.limited;
}

bool isBlocked(PermissionStatus status) {
  return status == PermissionStatus.permanentlyDenied ||
      status == PermissionStatus.restricted;
}

enum PermissionPhase { initial, requesting, deniedRetryable, deniedBlocked }

class PermissionItem extends Equatable {
  const PermissionItem({
    required this.label,
    required this.description,
    this.permission,
    this.denied = false,
  });

  final String label;
  final String description;
  final Permission? permission;
  final bool denied;

  PermissionItem copyWith({bool? denied}) => PermissionItem(
        label: label,
        description: description,
        permission: permission,
        denied: denied ?? this.denied,
      );

  @override
  List<Object?> get props => [label, description, permission, denied];
}

const _iosItems = <PermissionItem>[
  PermissionItem(
    label: 'BLUETOOTH',
    description: 'Scan, connect & exchange GATT data',
    permission: Permission.bluetooth,
  ),
];

const _macosItems = <PermissionItem>[
  PermissionItem(
    label: 'CORE BLUETOOTH',
    description: 'Handled by the macOS Bluetooth entitlement',
  ),
];

const _webItems = <PermissionItem>[
  PermissionItem(
    label: 'WEB BLUETOOTH',
    description: 'The browser prompts when scanning or connecting',
  ),
];

const _androidItems = <PermissionItem>[
  PermissionItem(
    label: 'BLUETOOTH_SCAN',
    description: 'Discover advertising peripherals',
    permission: Permission.bluetoothScan,
  ),
  PermissionItem(
    label: 'BLUETOOTH_CONNECT',
    description: 'Connect & exchange GATT data',
    permission: Permission.bluetoothConnect,
  ),
];

const _androidLocationItem = PermissionItem(
  label: 'ACCESS_FINE_LOCATION',
  description: 'Required on Android 11 and below',
  permission: Permission.locationWhenInUse,
);

Future<List<PermissionItem>> permissionItemsForCurrentPlatform() async {
  if (kIsWeb) return _webItems;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => await androidNeedsLocationPermission()
        ? [..._androidItems, _androidLocationItem]
        : _androidItems,
    TargetPlatform.iOS => _iosItems,
    TargetPlatform.macOS => _macosItems,
    _ => _webItems,
  };
}

class PermissionState extends Equatable {
  const PermissionState({
    this.phase = PermissionPhase.initial,
    this.items = const [],
  });

  final PermissionPhase phase;
  final List<PermissionItem> items;

  bool get requesting => phase == PermissionPhase.requesting;

  bool get denied =>
      phase == PermissionPhase.deniedRetryable ||
      phase == PermissionPhase.deniedBlocked;

  bool get blocked => phase == PermissionPhase.deniedBlocked;

  PermissionState copyWith({
    PermissionPhase? phase,
    List<PermissionItem>? items,
  }) =>
      PermissionState(
        phase: phase ?? this.phase,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [phase, items];
}

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionState()) {
    _load();
  }

  Future<void> _load() async {
    final items = await permissionItemsForCurrentPlatform();
    if (isClosed) return;
    emit(state.copyWith(items: items));
  }

  /// Returns `true` when every BLE permission is granted (or doesn't need to
  /// be requested on this platform). Returns `false` when the user denied any
  /// of them, leaving [state] on a denied phase describing whether another
  /// in-app prompt is still possible. Throws if the request itself fails —
  /// callers should catch and surface to the UI.
  Future<bool> requestPermissions() async {
    emit(state.copyWith(phase: PermissionPhase.requesting));
    try {
      final permissions = await blePermissionsForCurrentPlatform();
      if (permissions.isEmpty) {
        if (!isClosed) emit(state.copyWith(phase: PermissionPhase.initial));
        return true;
      }

      final statuses = await permissions.request();
      if (statuses.values.every(isGrantedOrLimited)) {
        if (!isClosed) emit(state.copyWith(phase: PermissionPhase.initial));
        return true;
      }

      if (!isClosed) {
        emit(state.copyWith(
          phase: statuses.values.any(isBlocked)
              ? PermissionPhase.deniedBlocked
              : PermissionPhase.deniedRetryable,
          items: [
            for (final item in state.items)
              item.copyWith(
                denied: !isGrantedOrLimited(
                  statuses[item.permission] ?? PermissionStatus.granted,
                ),
              ),
          ],
        ));
      }
      return false;
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(phase: PermissionPhase.deniedRetryable));
      }
      rethrow;
    }
  }

  Future<void> openSettings() => openAppSettings();
}
