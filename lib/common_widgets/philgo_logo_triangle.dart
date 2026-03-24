import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// PhilGo 단일 둥근 삼각형(물방울 형태) 로고 위젯
class PhilGoLogoTriangle extends StatelessWidget {
  final double size;
  final bool animated;
  final bool rotating;
  final Color color;
  final Duration rotationDuration;

  const PhilGoLogoTriangle({
    super.key,
    this.size = 120,
    this.animated = false,
    this.rotating = false,
    this.color = const Color(0xFFF5A962),
    this.rotationDuration = const Duration(seconds: 20),
  });

  @override
  Widget build(BuildContext context) {
    Widget triangle = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TrianglePainter(color: color)),
    );

    if (!animated) return triangle;

    triangle = triangle
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );

    if (rotating) {
      triangle = triangle
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(begin: 0, end: 1, duration: rotationDuration, curve: Curves.linear);
    }

    if (animated && !rotating) {
      triangle = triangle
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.05, 1.05),
            duration: 2.seconds,
            curve: Curves.easeInOut,
          );
    }

    return triangle;
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final triangleSize = size.width * 0.35;
    const triangleRotation = -pi / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    const t = 0.82;

    Offset lerp(Offset a, Offset b, double t) =>
        Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);

    final points = <Offset>[];
    for (int i = 0; i < 3; i++) {
      final pointAngle = triangleRotation + (i * 2 * pi / 3);
      points.add(Offset(
        center.dx + triangleSize * cos(pointAngle),
        center.dy + triangleSize * sin(pointAngle),
      ));
    }

    final midPoints = <Offset>[];
    for (int i = 0; i < 3; i++) {
      final next = (i + 1) % 3;
      midPoints.add(Offset(
        (points[i].dx + points[next].dx) / 2,
        (points[i].dy + points[next].dy) / 2,
      ));
    }

    final start = lerp(points[0], midPoints[2], t);
    path.moveTo(start.dx, start.dy);

    for (int i = 0; i < 3; i++) {
      final current = points[i];
      final next = (i + 1) % 3;
      final nextPoint = points[next];
      final midPoint = midPoints[i];

      final end1 = lerp(current, midPoint, t);
      path.quadraticBezierTo(current.dx, current.dy, end1.dx, end1.dy);

      final end2 = lerp(nextPoint, midPoint, t);
      path.quadraticBezierTo(midPoint.dx, midPoint.dy, end2.dx, end2.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => oldDelegate.color != color;
}
