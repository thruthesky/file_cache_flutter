import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// PhilGo 로고 위젯
/// 단일 둥근 삼각형(물방울 형태) 로고
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
    this.color = const Color(0xFFF5A962), // 기본 주황색
    this.rotationDuration = const Duration(seconds: 20), // 기본 회전 속도
  });

  @override
  Widget build(BuildContext context) {
    Widget triangle = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: PhilGoLogoTrianglePainter(
          color: color,
        ),
      ),
    );

    // 애니메이션이 비활성화되면 그대로 반환
    if (!animated) return triangle;

    // 등장 애니메이션 적용
    triangle = triangle
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );

    // 회전 애니메이션 (옵션)
    if (rotating) {
      triangle = triangle
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .rotate(
            begin: 0,
            end: 1, // 360도
            duration: rotationDuration,
            curve: Curves.linear,
          );
    }

    // 펄스 애니메이션 추가 (선택적)
    if (animated && !rotating) {
      triangle = triangle
          .animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          )
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

/// PhilGo 로고 페인터
/// 단일 둥근 삼각형을 그리는 CustomPainter
class PhilGoLogoTrianglePainter extends CustomPainter {
  final Color color;

  PhilGoLogoTrianglePainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 단일 도형 크기 및 스타일
    final triangleSize = size.width * 0.35; // 도형 크기
    final triangleRotation = -pi / 2; // 위쪽을 향하도록 기준 회전

    // 단일 둥근 삼각형 그리기
    _drawSuperRoundedTriangle(
      canvas,
      center,
      triangleSize,
      color,
      triangleRotation,
    );
  }

  /// 물방울 형태의 극도로 둥근 삼각형 그리기
  void _drawSuperRoundedTriangle(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    double angle,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 이미지와 동일한 물방울 형태를 위한 경로
    final path = Path();

    // 모서리 둥글기 조절 계수 (0.5 기본 → 값을 높일수록 더 둥글어짐)
    // 이전: 0.5 근처, 지금: 더 둥글게 보이도록 0.82 적용
    const t = 0.82;

    Offset lerp(Offset a, Offset b, double t) =>
        Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);

    // 삼각형의 세 꼭짓점
    final points = <Offset>[];
    for (int i = 0; i < 3; i++) {
      final pointAngle = angle + (i * 2 * pi / 3);
      points.add(
        Offset(
          center.dx + size * cos(pointAngle),
          center.dy + size * sin(pointAngle),
        ),
      );
    }

    // 각 변의 중점 계산 (베지어 컨트롤 포인트로 사용)
    final midPoints = <Offset>[];
    for (int i = 0; i < 3; i++) {
      final next = (i + 1) % 3;
      midPoints.add(
        Offset(
          (points[i].dx + points[next].dx) / 2,
          (points[i].dy + points[next].dy) / 2,
        ),
      );
    }

    // 매우 부드러운 물방울 형태 생성
    // 시작점을 변-중점 방향으로 더 이동시켜 모서리를 부드럽게 시작
    final start = lerp(points[0], midPoints[2], t);
    path.moveTo(start.dx, start.dy);

    // 각 모서리를 매우 둥글게 처리
    for (int i = 0; i < 3; i++) {
      final current = points[i];
      final next = (i + 1) % 3;
      final nextPoint = points[next];
      final midPoint = midPoints[i];

      // 중간 지점까지 곡선 (끝점을 midPoint 쪽으로 더 이동)
      final end1 = lerp(current, midPoint, t);
      path.quadraticBezierTo(current.dx, current.dy, end1.dx, end1.dy);

      // 다음 점으로 곡선 (끝점을 midPoint 쪽으로 더 이동)
      final end2 = lerp(nextPoint, midPoint, t);
      path.quadraticBezierTo(midPoint.dx, midPoint.dy, end2.dx, end2.dy);
    }

    path.close();

    // 도형 그리기
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PhilGoLogoTrianglePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}