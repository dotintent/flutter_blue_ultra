import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_cubit.dart'
    show blePermissionsForCurrentPlatform, isGrantedOrLimited;

const Duration _kMinSplashDuration = Duration(milliseconds: 1400);

/// Which top-level shell the user is in. Sealed so the `switch` in
/// `_AppShell.build` is exhaustive and any future shell (e.g. an
/// adapter-off screen) shows up as a compile error until handled.
sealed class AppShellState extends Equatable {
  const AppShellState();

  @override
  List<Object?> get props => const [];
}

final class SplashShellState extends AppShellState {
  const SplashShellState();
}

final class PermissionShellState extends AppShellState {
  const PermissionShellState();
}

final class ScanShellState extends AppShellState {
  const ScanShellState();
}

class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit() : super(const SplashShellState());

  /// Holds the splash for [_kMinSplashDuration] so the brand frame doesn't
  /// flash by on devices where the permission check resolves instantly.
  Future<void> bootstrap() async {
    final started = DateTime.now();
    final granted = await _alreadyGranted();
    final elapsed = DateTime.now().difference(started);
    if (elapsed < _kMinSplashDuration) {
      await Future<void>.delayed(_kMinSplashDuration - elapsed);
    }
    if (isClosed) return;
    emit(granted ? const ScanShellState() : const PermissionShellState());
  }

  Future<bool> _alreadyGranted() async {
    final permissions = await blePermissionsForCurrentPlatform();
    if (permissions.isEmpty) return true;
    final statuses = await Future.wait(permissions.map((p) => p.status));
    return statuses.every(isGrantedOrLimited);
  }

  void goToScan() {
    if (isClosed) return;
    emit(const ScanShellState());
  }
}
