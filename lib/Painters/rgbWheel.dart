import 'dart:math' as math;
import 'package:flutter/material.dart';

class RgbWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // 0 ile 360 derece arasındaki tüm renk tayfını çiziyoruz
    for (double angle = 0; angle < 360; angle += 1) {
      final radians = angle * (math.pi / 180);
      final paint = Paint()
        ..color = HSVColor.fromAHSV(1.0, angle, 1.0, 1.0).toColor()
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      // Merkezden dışa doğru radial çizgiler çekerek çemberi dolduruyoruz
      final x = center.dx + radius * math.cos(radians);
      final y = center.dy + radius * math.sin(radians);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}