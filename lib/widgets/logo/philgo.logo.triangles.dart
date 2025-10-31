import 'dart:math';
import 'package:flutter/material.dart';

import 'philgo.logo.triangle.dart';

/// PhilGo 로고의 세 개 삼각형 조합 위젯 (포개진 레이아웃)
class PhilGoLogoTriangles extends StatelessWidget {
  /// 전체 로고의 외곽 크기 (정사각)
  final double size;

  /// 개별 삼각형의 애니메이션 여부 (기본 false)
  final bool animated;

  /// 개별 삼각형의 회전 애니메이션 여부 (기본 false)
  final bool rotating;

  /// 겹침 표현을 위한 색상 불투명도 (0~1)
  final double opacity;

  const PhilGoLogoTriangles({
    super.key,
    this.size = 160,
    this.animated = false,
    this.rotating = false,
    this.opacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF5A962);
    const red = Color(0xFFEE4540);
    const blue = Color(0xFF5B6FED);

    // 이미지와 동일한 배치를 위한 파라미터
    // 삼각형들이 서로 겹치도록 위치 조정

    // 각 삼각형의 회전 각도
    // PhilGoLogoTriangle 내부 기본 방향은 위(-pi/2) 기준
    const rotOrange = pi / 1.1; // 아래쪽을 향하도록 180도 회전
    const rotRed = -pi / 1.3; // 오른쪽 위를 향하도록 -60도 회전
    const rotBlue = pi / 1.15; // 왼쪽을 향하도록 90도 회전

    // 위치: 이미지와 동일하게 배치 - 더 가깝게 모이도록 조정
    // 주황색: 왼쪽 위
    final posOrange = Offset(-size * 0.10, -size * 0.12);
    // 빨간색: 왼쪽 아래
    final posRed = Offset(-size * 0.14, size * 0.12);
    // 파란색: 오른쪽 (훨씬 더 아래로)
    final posBlue = Offset(size * 0.08, size * 0.22);

    // 개별 삼각형 크기 (조금 더 크게 해서 겹침 효과 증대)
    final childSize = size * 0.84;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 레이어 순서: 주황 -> 빨강 -> 파랑 (이미지와 동일한 순서)
          Transform.translate(
            offset: posOrange,
            child: Transform.rotate(
              angle: rotOrange,
              child: PhilGoLogoTriangle(
                size: childSize,
                animated: animated,
                rotating: rotating,
                color: orange.withValues(alpha: opacity),
                rotationDuration: const Duration(seconds: 40), // 주황색: 40초
              ),
            ),
          ),
          Transform.translate(
            offset: posRed,
            child: Transform.rotate(
              angle: rotRed,
              child: PhilGoLogoTriangle(
                size: childSize,
                animated: animated,
                rotating: rotating,
                color: red.withValues(alpha: opacity),
                rotationDuration: const Duration(seconds: 35), // 빨간색: 35초
              ),
            ),
          ),
          Transform.translate(
            offset: posBlue,
            child: Transform.rotate(
              angle: rotBlue,
              child: PhilGoLogoTriangle(
                size: childSize,
                animated: animated,
                rotating: rotating,
                color: blue.withValues(alpha: opacity),
                rotationDuration: const Duration(seconds: 32), // 파란색: 32초
              ),
            ),
          ),
        ],
      ),
    );
  }
}
