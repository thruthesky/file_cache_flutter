import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';

/// 스피닝 휠 섹션 데이터 모델
///
/// [weight] 로 섹션의 상대적 크기(영역 비율)를 지정.
/// [icon] 으로 라벨 위에 FontAwesome 아이콘을 표시.
/// [iconCount] 로 아이콘 반복 횟수를 지정 (예: 별 2개).
class WheelSection {
  /// 표시할 텍스트
  final String label;

  /// 섹션 배경색
  final Color color;

  /// 포인트 값 (0이면 꽝, -1이면 쿠폰 등 특별 당첨)
  final int points;

  /// 섹션의 상대적 크기 비중 (기본 1.0)
  final double weight;

  /// 섹션에 표시할 아이콘 (선택적)
  final IconData? icon;

  /// 아이콘 반복 횟수 (기본 1)
  final int iconCount;

  const WheelSection({
    required this.label,
    required this.color,
    required this.points,
    this.weight = 1.0,
    this.icon,
    this.iconCount = 1,
  });
}

/// 연속 돌리기 옵션
class AutoSpinOption {
  final String label;

  /// 반복 횟수. -1이면 stopCondition 충족까지.
  final int count;

  const AutoSpinOption({required this.label, required this.count});
}

/// 스피닝 휠 위젯
///
/// CustomPainter 기반의 원판 돌리기 게임 위젯.
/// [onSpinRequested] 로 서버에서 미리 결정된 당첨 섹션 인덱스를 받아,
/// 해당 섹션에 정확히 멈추도록 회전함.
///
/// 보안 목적: 결과값을 서버에서 미리 결정하여 클라이언트 조작 방지.
class SpinningWheel extends StatefulWidget {
  /// 원판 섹션 목록
  final List<WheelSection> sections;

  /// 스핀 요청 시 호출되는 콜백. 서버 당첨 인덱스를 반환. null이면 스핀 취소.
  final Future<int?> Function()? onSpinRequested;

  /// 회전 완료 시 당첨 섹션을 전달하는 콜백
  final ValueChanged<WheelSection>? onResult;

  /// 결과 인라인 표시용 빌더
  final Widget Function(WheelSection section)? resultBuilder;

  /// 안내 텍스트
  final String instructionText;

  /// 부가 설명 (선택적)
  final String? disclaimerText;

  /// 포인트 소진 안내 (선택적)
  final String? costNoticeText;

  /// 돌리기 버튼 텍스트
  final String spinButtonText;

  /// 연속 돌리기 버튼 텍스트
  final String? autoSpinButtonText;

  /// 연속 돌리기 중지 텍스트
  final String? autoSpinStopText;

  /// 연속 돌리기 옵션 목록. null이면 연속 돌리기 버튼 미표시.
  final List<AutoSpinOption>? autoSpinOptions;

  /// 연속 돌리기 count == -1일 때, 결과마다 호출.
  /// true 반환 시 연속 돌리기 중지.
  final bool Function(WheelSection)? autoSpinStopCondition;

  /// 원판 활동 상태 변경 콜백 (회전 중 또는 연속 돌리기 중)
  final ValueChanged<bool>? onBusyChanged;

  const SpinningWheel({
    super.key,
    required this.sections,
    this.onSpinRequested,
    this.onResult,
    this.resultBuilder,
    required this.instructionText,
    this.disclaimerText,
    this.costNoticeText,
    required this.spinButtonText,
    this.autoSpinButtonText,
    this.autoSpinStopText,
    this.autoSpinOptions,
    this.autoSpinStopCondition,
    this.onBusyChanged,
  });

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// 현재 원판 회전 각도 (라디안)
  double _currentAngle = 0;

  /// 회전 중 여부
  bool _isSpinning = false;

  /// API 호출 대기 중 여부 (로딩 오버레이 표시용)
  bool _isLoading = false;

  /// 마지막 당첨 결과 섹션 (인라인 표시용)
  WheelSection? _lastResult;

  /// 서버에서 반환한 당첨 섹션 인덱스 (시각적 판별 대신 사용)
  ///
  /// _notifyResult()에서 시각적 각도 판별은 jitter로 인해 인접 섹션으로
  /// 오판될 수 있으므로, 서버 결과를 직접 사용하여 정확한 결과를 보장한다.
  int? _serverTargetIndex;

  /// 효과음 플레이어
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// 음소거 상태
  bool _isMuted = false;

  /// 연속 돌리기: 남은 횟수 (0이면 비활성)
  int _autoSpinRemaining = 0;

  /// 연속 돌리기: 조건 충족까지 모드
  bool _autoSpinUntilCondition = false;

  /// 연속 돌리기 진행 중 여부
  bool get _isAutoSpinning =>
      _autoSpinRemaining > 0 || _autoSpinUntilCondition;

  /// 이전 busy 상태 (콜백 중복 방지용)
  bool _wasBusy = false;

  final _random = Random();

  /// 현재 세션 내 총 회전 횟수
  int _totalSpinCount = 0;

  /// 단일 스핀 회전 시간 (밀리초)
  static const _normalDuration = 6000;

  /// 연속 돌리기 시 회전 시간 (밀리초, 빠르게)
  static const _autoSpinDuration = 2500;

  /// 시각적 최소 각도 (라디안). 약 20도.
  /// 작은 섹션(1,000P, 2,000P, 쿠폰 등)의 텍스트를 읽을 수 있도록 확대 표시.
  /// 확률 자체는 변경하지 않고, 화면에 그리는 크기만 조정.
  static const _minDisplayAngle = 0.35;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _normalDuration),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _audioPlayer.stop();
        setState(() => _isSpinning = false);
        _notifyResult();
        _checkAutoSpin();
        _notifyBusyChange();
      }
    });
  }

  @override
  void dispose() {
    /// 위젯 제거 시 busy 상태를 false로 알림.
    if (_wasBusy) {
      widget.onBusyChanged?.call(false);
    }
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// busy 상태 변경 시 콜백 호출 (중복 방지)
  void _notifyBusyChange() {
    final isBusy = _isSpinning || _isAutoSpinning;
    if (isBusy != _wasBusy) {
      _wasBusy = isBusy;
      widget.onBusyChanged?.call(isBusy);
    }
  }

  /// 전체 weight 합계
  double get _totalWeight =>
      widget.sections.fold(0.0, (sum, s) => sum + s.weight);

  /// 시각적 최소 각도를 보장하는 표시용 가중치 목록.
  /// 최소 각도 미만인 섹션은 확대하고, 큰 섹션은 비례 축소.
  List<double> get _displayWeights {
    final total = _totalWeight;
    final sections = widget.sections;
    final rawAngles =
        sections.map((s) => s.weight / total * 2 * pi).toList();

    double deficit = 0;
    double surplusAngleSum = 0;

    for (int i = 0; i < rawAngles.length; i++) {
      if (rawAngles[i] < _minDisplayAngle) {
        deficit += _minDisplayAngle - rawAngles[i];
      } else {
        surplusAngleSum += rawAngles[i];
      }
    }

    /// 부족분이 없으면 원래 weight 반환
    if (deficit <= 0) return sections.map((s) => s.weight).toList();

    /// 큰 섹션의 축소 비율
    final scale = (surplusAngleSum - deficit) / surplusAngleSum;

    return List.generate(sections.length, (i) {
      if (rawAngles[i] < _minDisplayAngle) {
        return _minDisplayAngle / (2 * pi) * total;
      } else {
        return sections[i].weight * scale;
      }
    });
  }

  /// 각 섹션의 시작 각도(라디안) 목록 계산 (시각적 가중치 기반)
  List<double> get _sectionStartAngles {
    final weights = _displayWeights;
    final total = weights.fold(0.0, (sum, w) => sum + w);
    final angles = <double>[];
    double cumulative = 0;
    for (final w in weights) {
      angles.add(cumulative / total * 2 * pi);
      cumulative += w;
    }
    return angles;
  }

  /// 특정 섹션의 각도 크기(라디안) (시각적 가중치 기반)
  double _sectionSweep(int index) {
    final weights = _displayWeights;
    final total = weights.fold(0.0, (sum, w) => sum + w);
    return weights[index] / total * 2 * pi;
  }

  /// 원판 돌리기 실행
  Future<void> _spin() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _isLoading = true;
      _lastResult = null;
    });
    _notifyBusyChange();

    /// 타겟 섹션 인덱스 결정 (서버 API 호출 대기)
    final int? targetIndex;
    if (widget.onSpinRequested != null) {
      targetIndex = await widget.onSpinRequested!();
    } else {
      targetIndex = _random.nextInt(widget.sections.length);
    }

    /// 서버 결과 저장 (_notifyResult에서 시각적 판별 대신 사용)
    _serverTargetIndex = targetIndex;

    /// 로딩 해제
    if (mounted) {
      setState(() => _isLoading = false);
    }

    /// null이면 스핀 취소 (서버 에러, 포인트 부족 등)
    if (targetIndex == null) {
      setState(() => _isSpinning = false);
      if (_isAutoSpinning) _stopAutoSpin();
      _notifyBusyChange();
      return;
    }

    /// 성공적인 스핀: 총 회전 횟수 증가
    _totalSpinCount++;

    /// 타겟 섹션에 포인터가 멈추도록 회전각 계산
    final totalRotation = _calculateRotationForTarget(targetIndex);
    final startAngle = _currentAngle;

    _animation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _animation.addListener(() {
      setState(() {
        _currentAngle = startAngle + _animation.value;
      });
    });

    /// 효과음 재생
    if (!_isMuted) {
      try {
        await _audioPlayer.play(AssetSource('sound/spinning_wheel.mp3'));
      } catch (_) {}
    }

    _controller.reset();
    _controller.forward();
  }

  /// 타겟 섹션에 포인터가 멈추도록 필요한 총 회전각 계산
  double _calculateRotationForTarget(int targetIndex) {
    final startAngles = _sectionStartAngles;
    final sweep = _sectionSweep(targetIndex);
    final targetCenterAngle = startAngles[targetIndex] + sweep / 2;
    final targetNormalized = (2 * pi - targetCenterAngle) % (2 * pi);
    final currentNormalized = _currentAngle % (2 * pi);
    var delta = targetNormalized - currentNormalized;
    if (delta < 0) delta += 2 * pi;

    /// 연속 돌리기 시 2~3바퀴, 일반 시 5~8바퀴
    final extraTurns = _isAutoSpinning
        ? 2 + _random.nextInt(2)
        : 5 + _random.nextInt(4);
    final jitter = (_random.nextDouble() - 0.5) * sweep * 0.6;

    return extraTurns * 2 * pi + delta + jitter;
  }

  /// 연속 돌리기 시작
  void _startAutoSpin(AutoSpinOption option) {
    if (option.count == -1) {
      /// 조건 충족까지 모드
      _autoSpinUntilCondition = true;
      _autoSpinRemaining = 0;
    } else {
      _autoSpinUntilCondition = false;
      _autoSpinRemaining = option.count;
    }

    /// 연속 돌리기 시 회전 속도를 빠르게
    _controller.duration = const Duration(milliseconds: _autoSpinDuration);

    _spin();
  }

  /// 연속 돌리기 중지
  void _stopAutoSpin() {
    setState(() {
      _autoSpinRemaining = 0;
      _autoSpinUntilCondition = false;
    });

    /// 일반 속도로 복원
    _controller.duration = const Duration(milliseconds: _normalDuration);
    _notifyBusyChange();
  }

  /// 회전 완료 후 연속 돌리기 체크
  ///
  /// 횟수 모드/조건 모드 모두 autoSpinStopCondition을 먼저 확인한다.
  /// 스타벅스 쿠폰 당첨(points == -1) 시 남은 횟수와 관계없이 즉시 중단.
  void _checkAutoSpin() {
    /// 모든 연속 모드 공통: stopCondition 충족 시 즉시 중단
    if (_isAutoSpinning &&
        _lastResult != null &&
        widget.autoSpinStopCondition?.call(_lastResult!) == true) {
      _stopAutoSpin();
      return;
    }

    if (_autoSpinUntilCondition) {
      /// 조건 모드: 다음 스핀 (짧은 딜레이)
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _autoSpinUntilCondition) _spin();
      });
    } else if (_autoSpinRemaining > 0) {
      _autoSpinRemaining--;
      if (_autoSpinRemaining > 0) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && _autoSpinRemaining > 0) _spin();
        });
      } else {
        _stopAutoSpin();
      }
    }
  }

  /// 당첨 결과 콜백 호출 (서버 targetIndex 기반)
  ///
  /// 시각적 각도 판별은 jitter로 인해 인접 섹션으로 오판될 수 있으므로,
  /// 서버에서 반환한 _serverTargetIndex를 직접 사용한다.
  /// _serverTargetIndex가 없는 경우에만 시각적 판별로 폴백한다.
  void _notifyResult() {
    final int sectionIndex;
    if (_serverTargetIndex != null &&
        _serverTargetIndex! >= 0 &&
        _serverTargetIndex! < widget.sections.length) {
      /// 서버 결과 직접 사용 (정확한 판별 보장)
      sectionIndex = _serverTargetIndex!;
    } else {
      /// 폴백: 시각적 각도 기반 판별
      final normalizedAngle = (_currentAngle % (2 * pi));
      final pointerAngle = (2 * pi - normalizedAngle) % (2 * pi);
      final startAngles = _sectionStartAngles;
      int fallbackIndex = widget.sections.length - 1;
      for (int i = 0; i < widget.sections.length; i++) {
        final start = startAngles[i];
        final end = start + _sectionSweep(i);
        if (pointerAngle >= start && pointerAngle < end) {
          fallbackIndex = i;
          break;
        }
      }
      sectionIndex = fallbackIndex;
    }
    final result = widget.sections[sectionIndex];
    setState(() {
      _lastResult = result;
    });
    widget.onResult?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 안내 텍스트
        Text(
          widget.instructionText,
          style: text.titleMedium?.copyWith(
            color: color.onSurface,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms),

        /// 부가 안내 문구
        if (widget.disclaimerText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.disclaimerText!,
            style: text.bodySmall?.copyWith(
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        /// 포인트 소진 안내 문구
        if (widget.costNoticeText != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.costNoticeText!,
            style: text.bodySmall?.copyWith(
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),

        /// 원판 + 포인터 + 외곽 장식
        SizedBox(
          width: 310,
          height: 340,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// 외곽 장식 링 (고정, 회전하지 않음)
              Positioned(
                top: 20,
                child: SizedBox(
                  width: 296,
                  height: 296,
                  child: CustomPaint(
                    painter: _OuterRingPainter(
                      ringColor: color.outlineVariant,
                      dotColor: color.primary,
                    ),
                  ),
                ),
              ),

              /// 원판 그림자 (고정, 회전하지 않음)
              Positioned(
                top: 30,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              /// 원판 (회전)
              Positioned(
                top: 28,
                child: Transform.rotate(
                  angle: _currentAngle,
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: CustomPaint(
                      painter: _WheelPainter(
                        sections: widget.sections,
                        displayWeights: _displayWeights,
                      ),
                    ),
                  ),
                ),
              ),

              /// 중앙 장식 원 (총 회전 횟수 표시)
              Positioned(
                top: 136,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.primary.withValues(alpha: 0.9),
                        color.tertiary.withValues(alpha: 0.9),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.surface,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$_totalSpinCount',
                          style: TextStyle(
                            fontSize: _totalSpinCount >= 1000 ? 11 : 14,
                            fontWeight: FontWeight.bold,
                            color: color.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 상단 포인터
              Positioned(
                top: 0,
                child: _buildPointer(),
              ),

              /// API 호출 대기 중 로딩 오버레이
              if (_isLoading)
                Positioned(
                  top: 28,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: color.onPrimary,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        /// 버튼 영역
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 연속 돌리기 중이면 중지 버튼, 아니면 일반 돌리기 버튼
            if (_isAutoSpinning) ...[
              FilledButton.icon(
                onPressed: _stopAutoSpin,
                icon:
                    const FaIcon(FontAwesomeIcons.lightCircleStop, size: 16),
                label: Text(widget.autoSpinStopText ?? '중지'),
                style: FilledButton.styleFrom(
                  backgroundColor: color.error,
                  foregroundColor: color.onError,
                ),
              ),
            ] else ...[
              /// 원판 돌리기 버튼
              FilledButton.icon(
                onPressed: _isSpinning ? null : _spin,
                icon:
                    const FaIcon(FontAwesomeIcons.lightCirclePlay, size: 16),
                label: Text(widget.spinButtonText),
              ),

              /// 연속 돌리기 드롭다운 버튼
              if (widget.autoSpinOptions != null) ...[
                const SizedBox(width: 8),
                _buildAutoSpinButton(),
              ],
            ],
            const SizedBox(width: 8),

            /// 음소거 토글 (강조 스타일)
            Material(
              color: _isMuted
                  ? color.errorContainer
                  : color.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _isMuted = !_isMuted),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: FaIcon(
                    _isMuted
                        ? FontAwesomeIcons.lightVolumeXmark
                        : FontAwesomeIcons.lightVolumeHigh,
                    size: 16,
                    color: _isMuted
                        ? color.onErrorContainer
                        : color.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),

        /// 결과 인라인 표시 (회전 완료 후에만)
        if (_lastResult != null &&
            !_isSpinning &&
            widget.resultBuilder != null) ...[
          const SizedBox(height: 16),
          widget
              .resultBuilder!(_lastResult!)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ],
    );
  }

  /// 연속 돌리기 PopupMenuButton
  Widget _buildAutoSpinButton() {
    return PopupMenuButton<AutoSpinOption>(
      enabled: !_isSpinning,
      onSelected: _startAutoSpin,
      offset: const Offset(0, -200),
      itemBuilder: (_) => widget.autoSpinOptions!
          .map((option) => PopupMenuItem<AutoSpinOption>(
                value: option,
                child: Text(option.label),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isSpinning
              ? color.surfaceContainerHighest
              : color.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightRepeat,
              size: 14,
              color: _isSpinning
                  ? color.onSurfaceVariant
                  : color.onSecondaryContainer,
            ),
            const SizedBox(width: 6),
            Text(
              widget.autoSpinButtonText ?? '연속',
              style: text.labelMedium?.copyWith(
                color: _isSpinning
                    ? color.onSurfaceVariant
                    : color.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 4),
            FaIcon(
              FontAwesomeIcons.lightChevronDown,
              size: 10,
              color: _isSpinning
                  ? color.onSurfaceVariant
                  : color.onSecondaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointer() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color.error.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        size: const Size(28, 28),
        painter: _PointerPainter(color: color.error),
      ),
    );
  }
}

/// 원판 페인터 (시각적 가중치 기반, 귀여운 디자인)
class _WheelPainter extends CustomPainter {
  final List<WheelSection> sections;

  /// 시각적 최소 각도가 적용된 표시용 가중치
  final List<double> displayWeights;

  _WheelPainter({required this.sections, required this.displayWeights});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final totalWeight = displayWeights.fold(0.0, (sum, w) => sum + w);

    double cumulativeAngle = -pi / 2;

    for (int i = 0; i < sections.length; i++) {
      final sweepAngle = displayWeights[i] / totalWeight * 2 * pi;

      /// 섹션 배경
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        cumulativeAngle,
        sweepAngle,
        true,
        Paint()
          ..color = sections[i].color
          ..style = PaintingStyle.fill,
      );

      /// 섹션 구분선 (흰색, 부드럽게)
      final lineEnd = Offset(
        center.dx + radius * cos(cumulativeAngle),
        center.dy + radius * sin(cumulativeAngle),
      );
      canvas.drawLine(
        center,
        lineEnd,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      /// 섹션 라벨 텍스트 + 아이콘
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(cumulativeAngle + sweepAngle / 2);

      final textFontSize = sweepAngle > 0.6 ? 15.0 : 12.0;

      final textPainter = TextPainter(
        text: TextSpan(
          text: sections[i].label,
          style: TextStyle(
            color: Colors.white,
            fontSize: textFontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 3,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      /// 라벨 텍스트 (안쪽, 중앙 근처)
      textPainter.paint(
        canvas,
        Offset(
          radius * 0.55 - textPainter.width / 2,
          -textPainter.height / 2,
        ),
      );

      /// 아이콘 (바깥쪽, 가장자리 근처)
      if (sections[i].icon != null) {
        final icon = sections[i].icon!;
        final count = sections[i].iconCount;
        final iconText = String.fromCharCode(icon.codePoint) * count;

        /// 아이콘 개수에 따라 크기·위치 분기
        final iconFontSize = count == 1 ? 16.0 : 13.0;
        final iconRadius = count == 1 ? 0.88 : 0.82;

        final iconPainter = TextPainter(
          text: TextSpan(
            text: iconText,
            style: TextStyle(
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              fontSize: iconFontSize,
              color: Colors.white,
              letterSpacing: count > 1 ? 2 : 0,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        iconPainter.layout();
        iconPainter.paint(
          canvas,
          Offset(
            radius * iconRadius - iconPainter.width / 2,
            -iconPainter.height / 2,
          ),
        );
      }

      canvas.restore();
      cumulativeAngle += sweepAngle;
    }

    /// 외곽 테두리 (흰색, 부드러운 느낌)
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) => false;
}

/// 외곽 장식 링 페인터 (도트 장식)
class _OuterRingPainter extends CustomPainter {
  final Color ringColor;
  final Color dotColor;

  _OuterRingPainter({required this.ringColor, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    /// 외곽 링 배경 (두께감 있는 링)
    canvas.drawCircle(
      center,
      radius - 6,
      Paint()
        ..color = ringColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );

    /// 외곽 링 테두리 (안쪽/바깥쪽)
    final borderPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, borderPaint);
    canvas.drawCircle(center, radius - 12, borderPaint);

    /// 장식 도트 (20개, 교대 크기)
    const dotCount = 20;
    final dotPaintLarge = Paint()..color = dotColor.withValues(alpha: 0.7);
    final dotPaintSmall = Paint()..color = dotColor.withValues(alpha: 0.35);

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi - pi / 2;
      final dotCenter = Offset(
        center.dx + (radius - 6) * cos(angle),
        center.dy + (radius - 6) * sin(angle),
      );

      /// 짝수: 큰 도트, 홀수: 작은 도트
      final isLarge = i % 2 == 0;
      canvas.drawCircle(
        dotCenter,
        isLarge ? 3.5 : 2.0,
        isLarge ? dotPaintLarge : dotPaintSmall,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OuterRingPainter oldDelegate) =>
      ringColor != oldDelegate.ringColor || dotColor != oldDelegate.dotColor;
}

/// 포인터(역삼각형) 페인터
class _PointerPainter extends CustomPainter {
  final Color color;

  _PointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PointerPainter oldDelegate) =>
      color != oldDelegate.color;
}
