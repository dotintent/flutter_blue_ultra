import 'package:flutter/material.dart';

import '../tokens/dimension_tokens.dart';

class DsBluetoothGlyph extends StatelessWidget {
  const DsBluetoothGlyph({
    super.key,
    this.size = DsSize.iconXLarge,
    this.color,
    this.strokeWidth,
  });

  final double size;
  final Color? color;

  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BluetoothPainter(
        color: color ?? IconTheme.of(context).color ?? Colors.white,
        strokeWidth: strokeWidth ?? size / 10,
      ),
    );
  }
}

class _BluetoothPainter extends CustomPainter {
  _BluetoothPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = strokeWidth / 2;
    final height = size.height - strokeWidth;
    final scale = height / 22;
    final cx = size.width / 2;
    final top = inset;

    final path = Path()
      ..moveTo(cx - 5 * scale, top + 5 * scale)
      ..lineTo(cx + 5 * scale, top + 13 * scale)
      ..lineTo(cx, top + 22 * scale)
      ..lineTo(cx, top)
      ..lineTo(cx + 5 * scale, top + 8 * scale)
      ..lineTo(cx - 5 * scale, top + 16 * scale);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BluetoothPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
