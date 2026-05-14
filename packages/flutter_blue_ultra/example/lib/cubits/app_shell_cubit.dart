import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_cubit.dart'
    show blePermissionsForCurrentPlatform, isGrantedOrLimited;

/// Which top-level shell the user is in. Sealed so the `switch` in
/// `_AppShell.build` is exhaustive and any future shell (e.g. an
/// adapter-off screen) shows up as a compile error until handled.
sealed class AppShellState extends Equatable {
  const AppShellState();

  @override
  List<Object?> get props => const [];
}

final class PermissionShellState extends AppShellState {
  const PermissionShellState();
}

final class ScanShellState extends AppShellState {
  const ScanShellState();
}

class AppShellCubit extends Cubit<AppShellState> {
  AppShellCubit() : super(const PermissionShellState());

  Future<void> checkAlreadyGranted() async {
    final permissions = await blePermissionsForCurrentPlatform();
    if (permissions.isEmpty) {
      if (!isClosed) emit(const ScanShellState());
      return;
    }

    final statuses = await Future.wait(
      permissions.map((p) => p.status),
    );
    final allGranted = statuses.every(isGrantedOrLimited);
    if (allGranted && !isClosed) {
      emit(const ScanShellState());
    }
  }

  void goToScan() {
    if (isClosed) return;
    emit(const ScanShellState());
  }
}
