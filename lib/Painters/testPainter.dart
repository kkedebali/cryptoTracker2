import 'package:flutter/material.dart';

class TestPaint extends CustomPainter {
  final List<Cizgi> cizgi;
  TestPaint({required this.cizgi});

  @override
  void paint(Canvas canvas, Size size) {
    for (final tekCizgi in cizgi) {
      // 1. KORUMA: Eğer çizginin hiç noktası yoksa bu çizgiyi atla
      if (tekCizgi.points.isEmpty) continue;

      final redPainter = Paint()
        ..color = tekCizgi.color!
        ..strokeWidth = tekCizgi.adjWidth
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      Path path = Path();
      // İlk noktaya odaklan
      path.moveTo(tekCizgi.points.first!.dx, tekCizgi.points.first!.dy);

      // 2. KORUMA: Eğer sadece 1 kere dokunulup çekildiyse nokta olarak çiz
      if (tekCizgi.points.length == 1) {
        path.addOval(
          Rect.fromCircle(
            center: tekCizgi.points.first!,
            radius: tekCizgi.adjWidth / 2,
          ),
        );
      } else {
        for (int i = 0; i < tekCizgi.points.length - 1; i++) {
          final p1 = tekCizgi.points[i]!;
          final p2 = tekCizgi.points[i + 1]!;

          final midX = (p1.dx + p2.dx) / 2;
          final midY = (p1.dy + p2.dy) / 2;

          path.quadraticBezierTo(p1.dx, p1.dy, midX, midY);
        }
      }

      canvas.drawPath(path, redPainter);
    }
  }

  @override
  bool shouldRepaint(covariant TestPaint oldDelegate) {
    return true;
  }
}

class Cizgi {
  final List<Offset?> points;
  final double adjWidth;
  final Color? color;

  Cizgi({required this.points, required this.adjWidth, required this.color});
}
