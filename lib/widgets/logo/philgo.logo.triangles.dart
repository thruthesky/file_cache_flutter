import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'philgo.logo.triangle.dart';

/// PhilGo 로고의 세 개 삼각형 조합 위젯 (포개진 레이아웃)
///
/// 세 개의 삼각형이 겹쳐진 로고를 표시합니다.
/// - animated: 등장 애니메이션 활성화
/// - rotating: 각 삼각형의 회전 애니메이션 활성화
/// - pulsing: 각 삼각형의 크기 펄스 애니메이션 활성화 (커졌다 작아졌다)
class PhilGoLogoTriangles extends StatelessWidget {
  /// 전체 로고의 외곽 크기 (정사각)
  final double size;

  /// 개별 삼각형의 애니메이션 여부 (기본 false)
  final bool animated;

  /// 개별 삼각형의 회전 애니메이션 여부 (기본 false)
  final bool rotating;

  /// 개별 삼각형의 크기 펄스 애니메이션 여부 (기본 false)
  /// 활성화하면 각 삼각형이 약간 커졌다 작아졌다 하는 효과
  final bool pulsing;

  /// 겹침 표현을 위한 색상 불투명도 (0~1)
  final double opacity;

  const PhilGoLogoTriangles({
    super.key,
    this.size = 160,
    this.animated = false,
    this.rotating = false,
    this.pulsing = false,
    this.opacity = 0.85,
  });

  /// 개별 삼각형 위젯을 생성하고 펄스 애니메이션을 적용
  ///
  /// [triangle] - PhilGoLogoTriangle 위젯
  /// [pulseDuration] - 펄스 애니메이션 주기 (각 삼각형마다 다르게 설정하여 자연스러운 효과)
  /// [pulseScale] - 펄스 최대 크기 배율 (1.0 = 원본 크기)
  Widget _buildPulsingTriangle({
    required Widget triangle,
    required Duration pulseDuration,
    double pulseScale = 1.08,
  }) {
    if (!pulsing) return triangle;

    // flutter_animate를 사용하여 크기 펄스 애니메이션 적용
    // reverse: true로 설정하여 커졌다 작아졌다 반복
    return triangle
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: Offset(pulseScale, pulseScale),
          duration: pulseDuration,
          curve: Curves.easeInOut,
        );
  }

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

    // 주황색 삼각형 (펄스 주기: 3.5초)
    Widget orangeTriangle = Transform.translate(
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
    );
    orangeTriangle = _buildPulsingTriangle(
      triangle: orangeTriangle,
      pulseDuration: const Duration(milliseconds: 3500),
      pulseScale: 1.06, // 6% 크기 변화
    );

    // 빨간색 삼각형 (펄스 주기: 4.0초)
    Widget redTriangle = Transform.translate(
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
    );
    redTriangle = _buildPulsingTriangle(
      triangle: redTriangle,
      pulseDuration: const Duration(milliseconds: 4000),
      pulseScale: 1.08, // 8% 크기 변화
    );

    // 파란색 삼각형 (펄스 주기: 3.2초)
    Widget blueTriangle = Transform.translate(
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
    );
    blueTriangle = _buildPulsingTriangle(
      triangle: blueTriangle,
      pulseDuration: const Duration(milliseconds: 3200),
      pulseScale: 1.07, // 7% 크기 변화
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 레이어 순서: 주황 -> 빨강 -> 파랑 (이미지와 동일한 순서)
          orangeTriangle,
          redTriangle,
          blueTriangle,
        ],
      ),
    );
  }
}
