import 'package:flutter/material.dart';

import '../tokens/dimension_tokens.dart';

class DsBluetoothGlyph extends StatelessWidget {
  const DsBluetoothGlyph({
    super.key,
    this.size = DsSize.iconXLarge,
    this.color,
    this.strokeWidth = 2.2,
  });

  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BluetoothPainter(
        color: color ?? IconTheme.of(context).color ?? Colors.white,
        strokeWidth: strokeWidth,
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
    final scale = size.width / 22;
    final cx = size.width / 2;
    final path = Path()
      ..moveTo(cx - 5 * scale, 5 * scale)
      ..lineTo(cx + 5 * scale, 13 * scale)
      ..lineTo(cx, 22 * scale)
      ..lineTo(cx, 0)
      ..lineTo(cx + 5 * scale, 8 * scale)
      ..lineTo(cx - 5 * scale, 16 * scale);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BluetoothPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
