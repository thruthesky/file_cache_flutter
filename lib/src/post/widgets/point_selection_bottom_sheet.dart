import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../philgo_api.dart';

/// 포인트 광고 선택 바텀 시트
///
/// 광고 가능 일수 목록을 그리드 형태로 표시하고,
/// 각 항목에 필요 포인트를 함께 표시합니다.
class PointSelectionBottomSheet extends StatefulWidget {
  /// 포인트 설정 (광고 일수 목록, 시간당 비용 등)
  final PhilgoSettingPoint pointSetting;

  /// 사용자의 현재 포인트
  final int userPoints;

  /// 일수 선택 시 콜백
  final Function(int days) onDaysSelected;

  /// 초기 선택된 일수 (이전에 선택한 값이 있으면 전달)
  final int? initialSelectedDays;

  const PointSelectionBottomSheet({
    super.key,
    required this.pointSetting,
    required this.userPoints,
    required this.onDaysSelected,
    this.initialSelectedDays,
  });

  @override
  State<PointSelectionBottomSheet> createState() =>
      _PointSelectionBottomSheetState();
}

class _PointSelectionBottomSheetState extends State<PointSelectionBottomSheet> {
  /// 현재 선택된 광고 일수 (null이면 선택 안됨)
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    // 이전에 선택한 일수가 있으면 기본값으로 설정
    _selectedDays = widget.initialSelectedDays;
  }

  /// 포인트 숫자 포맷팅 (천 단위 콤마)
  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final advertisementDays = widget.pointSetting.advertisementDays;

    return Container(
      // Flat 2.0 스타일: 둥근 모서리
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // 드래그 핸들 인디케이터
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            PointAdUserInfoCard(
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0),
            const SizedBox(height: 20),

            // 구분선
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 16),

            // 광고 일수 선택 그리드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: advertisementDays.length,
                itemBuilder: (context, index) {
                  final days = advertisementDays[index];
                  final points = calculatePointCost(
                    days,
                    widget.pointSetting.advCostPerHour,
                  );
                  final isSelected = _selectedDays == days;
                  final isDisabled = widget.userPoints < points;

                  return _buildDaysCard(
                    context,
                    days: days,
                    points: points,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
                    index: index,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 확인 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: _selectedDays != null
                    ? () => widget.onDaysSelected(_selectedDays!)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedDays != null
                      ? PhilgoTr.of(context)!.confirmSelection
                      : PhilgoTr.of(context)!.selectAdvertisementDays,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 광고 일수 선택 카드 위젯
  Widget _buildDaysCard(
    BuildContext context, {
    required int days,
    required int points,
    required bool isSelected,
    required bool isDisabled,
    required int index,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final disabledBackground = scheme.surfaceContainerHighest.withValues(
      alpha: 0.45,
    );
    final disabledBorder = scheme.outline.withValues(alpha: 0.25);
    final disabledPrimaryContent = scheme.onSurface.withValues(alpha: 0.35);
    final disabledSecondaryContent = scheme.onSurfaceVariant.withValues(
      alpha: 0.35,
    );

    final primaryContentColor = isDisabled
        ? disabledPrimaryContent
        : isSelected
        ? scheme.primary
        : scheme.onSurface;
    final secondaryContentColor = isDisabled
        ? disabledSecondaryContent
        : isSelected
        ? scheme.primary
        : scheme.onSurfaceVariant;

    // 카드 위젯을 Widget 타입으로 명시하여 .animate() 확장 메서드 사용 가능
    final Widget cardWidget = GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedDays = days;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // 선택 상태와 비활성화 상태에 따른 배경색
          color: isDisabled
              ? disabledBackground
              : isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          // 선택 상태에 따른 테두리
          border: Border.all(
            color: isDisabled
                ? disabledBorder
                : isSelected
                ? scheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 포인트 표시 with icon (larger, primary focus)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCoins,
                    size: 14,
                    color: primaryContentColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: AutoSizeText(
                      _formatPoints(points),
                      maxLines: 1,
                      minFontSize: 10,
                      stepGranularity: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryContentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 일수 표시 (smaller, secondary info)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryContentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    PhilgoTr.of(context)!.days,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryContentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // .animate() 확장 메서드를 사용하여 페이드인 + 스케일 애니메이션 적용
    // index에 따라 순차적으로 애니메이션 시작 (staggered animation)
    return cardWidget
        .animate(delay: (50 * index).ms)
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 200.ms);
  }
}
