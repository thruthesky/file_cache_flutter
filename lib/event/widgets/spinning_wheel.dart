import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// 스피닝 휠 섹션 데이터
class WheelSectionData {
  final String label;
  final Color color;

  const WheelSectionData({required this.label, required this.color});
}

/// 스피닝 휠 위젯
///
/// 10개 섹션의 원형 룰렛. spinTo(index)로 지정 섹션까지 회전한다.
class SpinningWheelWidget extends StatefulWidget {
  final List<WheelSectionData> sections;
  final VoidCallback? onSpinComplete;

  const SpinningWheelWidget({
    super.key,
    required this.sections,
    this.onSpinComplete,
  });

  @override
  State<SpinningWheelWidget> createState() => SpinningWheelWidgetState();
}

class SpinningWheelWidgetState extends State<SpinningWheelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _currentAngle = 0;
  bool _isSpinning = false;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get isSpinning => _isSpinning;

  /// 지정된 섹션 인덱스까지 회전
  Future<void> spinTo(int targetIndex) async {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);

    // 회전 사운드 재생
    try {
      await _audioPlayer.play(AssetSource('sound/spinning_wheel.mp3'));
    } catch (_) {}

    final sectionAngle = 2 * pi / widget.sections.length;
    // 상단 화살표(12시) 기준으로 targetIndex 섹션 중앙에 멈추도록 계산
    final targetAngle = targetIndex * sectionAngle + sectionAngle / 2;
    // 현재 각도에서 5바퀴 + 목표까지 회전
    final normalizedCurrent = _currentAngle % (2 * pi);
    final extraRotation = targetAngle - normalizedCurrent;
    final totalRotation =
        5 * 2 * pi + (extraRotation < 0 ? extraRotation + 2 * pi : extraRotation);

    final begin = _currentAngle;
    final end = _currentAngle + totalRotation;

    _controller.reset();

    final animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    animation.addListener(() {
      if (mounted) {
        setState(() => _currentAngle = animation.value);
      }
    });

    await _controller.forward();

    _currentAngle = end % (2 * pi);
    if (mounted) {
      setState(() => _isSpinning = false);
    }
    widget.onSpinComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 회전하는 원판
              Transform.rotate(
                angle: _currentAngle,
                child: CustomPaint(
                  size: Size(size, size),
                  painter: _WheelPainter(sections: widget.sections),
                ),
              ),
              // 상단 화살표 인디케이터
              Positioned(
                top: 4,
                child: CustomPaint(
                  size: const Size(20, 16),
                  painter: _ArrowPainter(color: scheme.error),
                ),
              ),
              // 중앙 원
              Container(
                width: size * 0.14,
                height: size * 0.14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 원판 그리기 (10개 섹션의 파이 차트)
class _WheelPainter extends CustomPainter {
  final List<WheelSectionData> sections;

  _WheelPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    final sectionAngle = 2 * pi / sections.length;

    // 외곽 그림자
    canvas.drawCircle(
      center.translate(0, 2),
      radius + 2,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    for (int i = 0; i < sections.length; i++) {
      // 12시 방향부터 시계방향으로 그림
      final startAngle = -pi / 2 + i * sectionAngle;

      // 섹션 파이 그리기
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        Paint()
          ..color = sections[i].color
          ..style = PaintingStyle.fill,
      );

      // 섹션 구분선
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // 텍스트
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(startAngle + sectionAngle / 2);

      final tp = TextPainter(
        text: TextSpan(
          text: sections[i].label,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.1,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(radius * 0.5, -tp.height / 2));
      canvas.restore();
    }

    // 외곽 테두리
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

/// 상단 화살표 인디케이터
class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      color != oldDelegate.color;
}
