import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:philgo/common_widgets/philgo_logo_triangle.dart';

/// PhilGo 로고 — 세 개의 둥근 삼각형(물방울 형태)이 겹쳐진 로고
///
/// 사용 예시:
/// ```dart
/// PhilGoLogo(size: 100, animated: true, rotating: true, pulsing: true)
/// ```
class PhilGoLogo extends StatelessWidget {
  final double size;
  final bool animated;
  final bool rotating;
  final bool pulsing;
  final double opacity;

  const PhilGoLogo({
    super.key,
    this.size = 160,
    this.animated = false,
    this.rotating = false,
    this.pulsing = false,
    this.opacity = 0.85,
  });

  Widget _buildPulsingTriangle({
    required Widget triangle,
    required Duration pulseDuration,
    double pulseScale = 1.08,
  }) {
    if (!pulsing) return triangle;
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

    const rotOrange = pi / 1.1;
    const rotRed = -pi / 1.3;
    const rotBlue = pi / 1.15;

    final posOrange = Offset(-size * 0.10, -size * 0.12);
    final posRed = Offset(-size * 0.14, size * 0.12);
    final posBlue = Offset(size * 0.08, size * 0.22);

    final childSize = size * 0.84;

    Widget orangeTriangle = Transform.translate(
      offset: posOrange,
      child: Transform.rotate(
        angle: rotOrange,
        child: PhilGoLogoTriangle(
          size: childSize,
          animated: animated,
          rotating: rotating,
          color: orange.withValues(alpha: opacity),
          rotationDuration: const Duration(seconds: 40),
        ),
      ),
    );
    orangeTriangle = _buildPulsingTriangle(
      triangle: orangeTriangle,
      pulseDuration: const Duration(milliseconds: 3500),
      pulseScale: 1.06,
    );

    Widget redTriangle = Transform.translate(
      offset: posRed,
      child: Transform.rotate(
        angle: rotRed,
        child: PhilGoLogoTriangle(
          size: childSize,
          animated: animated,
          rotating: rotating,
          color: red.withValues(alpha: opacity),
          rotationDuration: const Duration(seconds: 35),
        ),
      ),
    );
    redTriangle = _buildPulsingTriangle(
      triangle: redTriangle,
      pulseDuration: const Duration(milliseconds: 4000),
      pulseScale: 1.08,
    );

    Widget blueTriangle = Transform.translate(
      offset: posBlue,
      child: Transform.rotate(
        angle: rotBlue,
        child: PhilGoLogoTriangle(
          size: childSize,
          animated: animated,
          rotating: rotating,
          color: blue.withValues(alpha: opacity),
          rotationDuration: const Duration(seconds: 32),
        ),
      ),
    );
    blueTriangle = _buildPulsingTriangle(
      triangle: blueTriangle,
      pulseDuration: const Duration(milliseconds: 3200),
      pulseScale: 1.07,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          orangeTriangle,
          redTriangle,
          blueTriangle,
        ],
      ),
    );
  }
}
