import 'dart:math';
import 'package:flutter/material.dart';

/// PhilGo 로고 위젯 (3개의 삼각형)
///
/// 3개의 둥근 삼각형(물방울 형태)이 중앙에서 겹치며 바깥쪽을 향하는 로고 위젯
/// 프로펠러/바람개비 형태로 배치됩니다.
///
/// Layout: 삼각형 3개가 중앙에서 겹치며 각각 바깥쪽을 향함
///       [주황색 - 상단/우측]
///    [빨간색 - 좌하단]  [파란색 - 우하단]
///
/// Usage:
/// ```dart
/// Logo(
///   size: 64,
///   topColor: Color(0xFFF5A962),    // 주황색
///   leftColor: Color(0xFFE85A4F),   // 빨간색
///   rightColor: Color(0xFF6B7FD7),  // 파란색
/// )
/// ```
class Logo extends StatelessWidget {
  /// 전체 로고 크기
  final double size;

  /// 상단/우측 삼각형 색상 (기본값: 주황색)
  final Color topColor;

  /// 좌하단 삼각형 색상 (기본값: 빨간색)
  final Color leftColor;

  /// 우하단 삼각형 색상 (기본값: 파란색)
  final Color rightColor;

  const Logo({
    super.key,
    this.size = 64,
    this.topColor = const Color(0xFFF5A962), // 주황색
    this.leftColor = const Color(0xFFE85A4F), // 빨간색
    this.rightColor = const Color(0xFF6B7FD7), // 파란색
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LogoPainter(
          topColor: topColor,
          leftColor: leftColor,
          rightColor: rightColor,
        ),
      ),
    );
  }
}

/// 3개의 삼각형을 그리는 CustomPainter
///
/// 중앙에서 겹치며 각각 바깥쪽을 향하는 프로펠러 형태로 배치합니다.
class LogoPainter extends CustomPainter {
  /// 상단/우측 삼각형 색상
  final Color topColor;

  /// 좌하단 삼각형 색상
  final Color leftColor;

  /// 우하단 삼각형 색상
  final Color rightColor;

  LogoPainter({
    required this.topColor,
    required this.leftColor,
    required this.rightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 각 삼각형의 크기 (전체 크기의 40%)
    final triangleSize = size.width * 0.40;

    // === 좌표 기준: 100x100 캔버스 기준 상대적 위치 (%) ===
    // === 각도 기준: 0° = 위(12시), 시계방향 양수 ===
    // === 코드 각도 변환: 코드에서 0 = 오른쪽(3시) 이므로, 사용자 각도 - 90° ===

    // === 그리기 순서: 파란색(맨 아래) → 빨간색(중간) → 주황색(맨 위) ===

    // 1. 파란색 삼각형 (하단 우측) - 맨 아래 레이어
    // 위치: X: 72%, Y: 75%
    // 각도: 155° (시계방향) → 코드 각도: 155 - 90 = 65°
    final blueCenter = Offset(
      size.width * 0.62,
      size.height * 0.8,
    );
    _drawRoundedTriangle(
      canvas,
      blueCenter,
      triangleSize,
      rightColor,
      65 * pi / 120, // 155° - 90° = 65° (아래쪽을 향해 뒤집힘)
    );

    // 2. 빨간색 삼각형 (하단 좌측) - 중간 레이어
    // 위치: X: 30%, Y: 68%
    // 각도: -10° (350°, 시계방향) → 코드 각도: -10 - 90 = -100°
    final redCenter = Offset(
      size.width * 0.30,
      size.height * 0.68,
    );
    _drawRoundedTriangle(
      canvas,
      redCenter,
      triangleSize,
      leftColor,
      -100 * pi / 180, // -10° - 90° = -100° (거의 위를 향함, 살짝 왼쪽 기울임)
    );

    // 3. 주황색 삼각형 (상단) - 맨 위 레이어
    // 위치: X: 35%, Y: 35%
    // 각도: 40° (시계방향) → 코드 각도: 40 - 90 = -50°
    final orangeCenter = Offset(
      size.width * 0.35,
      size.height * 0.35,
    );
    _drawRoundedTriangle(
      canvas,
      orangeCenter,
      triangleSize,
      topColor,
      -50 * pi / 180, // 40° - 90° = -50° (오른쪽 위를 향함)
    );
  }

  /// 물방울 형태의 둥근 삼각형 그리기
  ///
  /// [canvas] - 그릴 캔버스
  /// [center] - 삼각형 중심 위치
  /// [size] - 삼각형 크기
  /// [color] - 삼각형 색상
  /// [angle] - 삼각형 회전 각도 (라디안)
  void _drawRoundedTriangle(
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

    final path = Path();

    // 모서리 둥글기 계수 (0.82로 설정하여 부드러운 물방울 형태)
    const t = 0.82;

    // 선형 보간 함수
    Offset lerp(Offset a, Offset b, double t) =>
        Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);

    // 삼각형의 세 꼭짓점 계산
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

    // 각 변의 중점 계산 (베지어 컨트롤 포인트)
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

    // 부드러운 물방울 형태 경로 생성
    final start = lerp(points[0], midPoints[2], t);
    path.moveTo(start.dx, start.dy);

    // 각 모서리를 둥글게 처리
    for (int i = 0; i < 3; i++) {
      final current = points[i];
      final next = (i + 1) % 3;
      final nextPoint = points[next];
      final midPoint = midPoints[i];

      // 중간 지점까지 곡선
      final end1 = lerp(current, midPoint, t);
      path.quadraticBezierTo(current.dx, current.dy, end1.dx, end1.dy);

      // 다음 점으로 곡선
      final end2 = lerp(nextPoint, midPoint, t);
      path.quadraticBezierTo(midPoint.dx, midPoint.dy, end2.dx, end2.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LogoPainter oldDelegate) {
    return oldDelegate.topColor != topColor ||
        oldDelegate.leftColor != leftColor ||
        oldDelegate.rightColor != rightColor;
  }
}
