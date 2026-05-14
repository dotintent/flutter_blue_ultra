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

class PermissionState extends Equatable {
  const PermissionState({this.requesting = false});

  final bool requesting;

  PermissionState copyWith({bool? requesting}) =>
      PermissionState(requesting: requesting ?? this.requesting);

  @override
  List<Object?> get props => [requesting];
}

class PermissionCubit extends Cubit<PermissionState> {
  PermissionCubit() : super(const PermissionState());

  /// Returns `true` when every BLE permission is granted (or doesn't need to
  /// be requested on this platform). Returns `false` when the user denied any
  /// of them. Throws if the request itself fails — callers should catch and
  /// surface to the UI.
  Future<bool> requestPermissions() async {
    emit(state.copyWith(requesting: true));
    try {
      final permissions = await blePermissionsForCurrentPlatform();
      if (permissions.isEmpty) {
        return true;
      }

      final statuses = await permissions.request();

      return statuses.values.every(isGrantedOrLimited);
    } finally {
      if (!isClosed) emit(state.copyWith(requesting: false));
    }
  }
}
