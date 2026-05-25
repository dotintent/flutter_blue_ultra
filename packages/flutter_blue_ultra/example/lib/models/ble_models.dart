import 'dart:convert';

import 'package:equatable/equatable.dart';

enum ValueFormat { hex, utf8, dec, bin }

extension ValueFormatExt on ValueFormat {
  String label() {
    switch (this) {
      case ValueFormat.hex:
        return 'HEX';
      case ValueFormat.utf8:
        return 'UTF-8';
      case ValueFormat.dec:
        return 'DEC';
      case ValueFormat.bin:
        return 'BIN';
    }
  }

  String format(List<int> bytes) {
    if (bytes.isEmpty) return '—';
    switch (this) {
      case ValueFormat.hex:
        return '0x ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ')}';
      case ValueFormat.utf8:
        try {
          final s = utf8.decode(bytes);
          // Hide control chars / unexpected bytes so binary payloads don't
          // render as a wall of replacement glyphs.
          final printable = s.runes.every((c) => c >= 0x20 && c != 0x7f);
          return printable ? s : '(non-printable)';
        } on FormatException {
          return '(invalid UTF-8)';
        }
      case ValueFormat.dec:
        if (bytes.length == 1) return bytes.first.toString();
        if (bytes.length > 8) {
          return bytes.map((b) => b.toString()).join(', ');
        }
        int v = 0;
        for (int i = bytes.length - 1; i >= 0; i--) {
          v = (v << 8) | bytes[i];
        }
        return v.toString();
      case ValueFormat.bin:
        return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join(' ');
    }
  }
}

class NotifyPacket extends Equatable {
  const NotifyPacket({
    required this.timestamp,
    required this.bytes,
    this.parsed,
  });

  final DateTime timestamp;
  final List<int> bytes;
  final String? parsed;

  @override
  List<Object?> get props => [timestamp, bytes, parsed];
}
