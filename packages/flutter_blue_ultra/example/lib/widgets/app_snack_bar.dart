import 'package:flutter/material.dart';
import 'package:flutter_blue_ultra_design_system/flutter_blue_ultra_design_system.dart';

enum AppMessageTone { info, success, warning, error }

class AppMessage {
  const AppMessage(this.text, {this.tone = AppMessageTone.info});

  const AppMessage.success(this.text) : tone = AppMessageTone.success;

  const AppMessage.warning(this.text) : tone = AppMessageTone.warning;

  const AppMessage.error(this.text) : tone = AppMessageTone.error;

  final String text;
  final AppMessageTone tone;
}

const Duration _kDedupeWindow = Duration(seconds: 4);

class _LastMessage {
  _LastMessage(this.text, this.at);

  final String text;
  final DateTime at;
}

final Expando<_LastMessage> _lastByMessenger = Expando<_LastMessage>();

void showAppMessage(BuildContext context, AppMessage message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  final now = DateTime.now();
  final last = _lastByMessenger[messenger];
  if (last != null &&
      last.text == message.text &&
      now.difference(last.at) < _kDedupeWindow) {
    return;
  }
  _lastByMessenger[messenger] = _LastMessage(message.text, now);

  messenger
    ..removeCurrentSnackBar()
    ..showSnackBar(_buildSnackBar(context, message));
}

SnackBar _buildSnackBar(BuildContext context, AppMessage message) {
  final colors = DsColors.of(context);
  final (tone, icon) = switch (message.tone) {
    AppMessageTone.success => (colors.success, Icons.check_circle_outline),
    AppMessageTone.warning => (colors.warn, Icons.warning_amber_rounded),
    AppMessageTone.error => (colors.destructive, Icons.error_outline),
    AppMessageTone.info => (colors.accent, Icons.info_outline),
  };

  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: colors.surface,
    elevation: 0,
    margin: const EdgeInsets.all(DsSpace.s16),
    padding: EdgeInsets.zero,
    duration: message.tone == AppMessageTone.error
        ? const Duration(seconds: 6)
        : const Duration(seconds: 3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DsRadius.medium),
      side: BorderSide(color: colors.borderHi),
    ),
    content: Row(
      children: [
        Container(width: DsSpace.s4, height: 44, color: tone),
        const SizedBox(width: DsSpace.s12),
        Icon(icon, size: DsSize.iconMedium, color: tone),
        const SizedBox(width: DsSpace.s12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: DsSpace.s12),
            child: Text(
              message.text,
              style: DsTextStyles.bodySm(color: colors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: DsSpace.s12),
      ],
    ),
  );
}
