import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:provider/provider.dart';

/// 포인트 광고 선택 버튼 위젯
///
/// 사용자가 게시글 작성/수정 시 포인트 광고 기간을 선택할 수 있는 버튼입니다.
/// 버튼을 클릭하면 광고 기간 선택 바텀 시트가 표시됩니다.
///
/// ### 주요 기능:
/// - 광고 가능 일수 목록 표시 (API 설정에서 가져옴)
/// - 각 일수별 필요 포인트 계산 및 표시
/// - 선택된 일수를 콜백으로 반환
///
/// ### 포인트 비용 계산:
/// - 비용 = 일수 × 시간당비용 × 24시간
///
/// ### 예시:
/// ```dart
/// PointSelectionButton(
///   onDaysSelected: (days) {
///     setState(() => selectedDays = days);
///   },
/// )
/// ```
class PointSelectionButton extends StatefulWidget {
  /// 광고 일수 선택 시 콜백
  final Function(int days)? onDaysSelected;

  final bool update;

  const PointSelectionButton({
    super.key,
    this.update = false,
    this.onDaysSelected,
  });

  @override
  State<PointSelectionButton> createState() => _PointSelectionButtonState();
}

class _PointSelectionButtonState extends State<PointSelectionButton> {
  PhilgoSetting get setting => PhilgoState.of(context).setting!;

  /// 포인트 광고 기간 ( 일 단위 ) Point advertisementDays
  int? advertisementDays;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Selector<PhilgoState, PhilgoSetting?>(
      builder: (context, setting, _) {
        if (setting == null) {
          return const CircularProgressIndicator.adaptive();
        }
        // 선택된 일수가 있으면 표시, 없으면 기본 "포인트 광고" 텍스트 표시
        // - 수정 모드(update=true): "포인트 광고: +3일" (+ 기호 포함)
        // - 생성 모드(update=false): "포인트 광고: 3일"
        final String labelText;
        if (advertisementDays != null) {
          labelText = widget.update
              ? PhilgoTr.of(context)!.pointAdvertisementAddDays(advertisementDays!)
              : PhilgoTr.of(context)!.pointAdvertisementWithDays(advertisementDays!);
        } else {
          labelText = PhilgoTr.of(context)!.pointAdvertisement;
        }

        return TextButton.icon(
          onPressed: () => _showPointSelectionBottomSheet(context),
          icon: FaIcon(
            FontAwesomeIcons.lightBullhorn,
            size: 16,
            color: scheme.primary,
          ),
          label: Text(
            labelText,
            style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
        );
      },
      selector: (_, state) => state.setting,
    );
  }

  /// 포인트 광고 선택 바텀 시트 표시
  void _showPointSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) => _PointSelectionBottomSheet(
        pointSetting: setting.point,
        // 현재 선택된 일수를 바텀 시트에 전달하여 기본 선택되도록 함
        initialSelectedDays: advertisementDays,
        onDaysSelected: (days) {
          Navigator.pop(context);
          // setState를 호출하여 버튼 레이블이 업데이트되도록 함
          setState(() {
            advertisementDays = days;
          });
          widget.onDaysSelected?.call(days);
        },
      ),
    );
  }
}

/// 포인트 광고 선택 바텀 시트
///
/// 광고 가능 일수 목록을 그리드 형태로 표시하고,
/// 각 항목에 필요 포인트를 함께 표시합니다.
class _PointSelectionBottomSheet extends StatefulWidget {
  /// 포인트 설정 (광고 일수 목록, 시간당 비용 등)
  final PhilgoSettingPoint pointSetting;

  /// 일수 선택 시 콜백
  final Function(int days) onDaysSelected;

  /// 초기 선택된 일수 (이전에 선택한 값이 있으면 전달)
  final int? initialSelectedDays;

  const _PointSelectionBottomSheet({
    required this.pointSetting,
    required this.onDaysSelected,
    this.initialSelectedDays,
  });

  @override
  State<_PointSelectionBottomSheet> createState() =>
      _PointSelectionBottomSheetState();
}

class _PointSelectionBottomSheetState
    extends State<_PointSelectionBottomSheet> {
  /// 현재 선택된 광고 일수 (null이면 선택 안됨)
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    // 이전에 선택한 일수가 있으면 기본값으로 설정
    _selectedDays = widget.initialSelectedDays;
  }

  /// 포인트 비용 계산
  ///
  /// 공식: 일수 × 시간당비용 × 24시간
  int _calculatePoints(int days) {
    return days * widget.pointSetting.advCostPerHour * 24;
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

            // 헤더: 아이콘 + 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // 아이콘 배경
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.lightBullhorn,
                        size: 18,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 제목 + 설명
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          PhilgoTr.of(context)!.pointAdvertisement,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PhilgoTr.of(context)!.pointAdvertisementDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  final points = _calculatePoints(days);
                  final isSelected = _selectedDays == days;

                  return _buildDaysCard(
                    context,
                    days: days,
                    points: points,
                    isSelected: isSelected,
                    index: index,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // 선택된 항목 정보 표시
            if (_selectedDays != null) ...[
              Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightCircleInfo,
                          size: 18,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$_selectedDays',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: PhilgoTr.of(
                                    context,
                                  )!.daysAdvertisementCost(_selectedDays!),
                                ),
                                TextSpan(
                                  text:
                                      ' ${_formatPoints(_calculatePoints(_selectedDays!))}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: scheme.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${PhilgoTr.of(context)!.points}',
                                ),
                              ],
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 16),
            ],

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
    required int index,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // 카드 위젯을 Widget 타입으로 명시하여 .animate() 확장 메서드 사용 가능
    final Widget cardWidget = GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = days;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // 선택 상태에 따른 배경색
          color: isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          // 선택 상태에 따른 테두리
          border: Border.all(
            color: isSelected ? scheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 일수 표시
            Text(
              '$days',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? scheme.primary : scheme.onSurface,
              ),
            ),
            Text(
              PhilgoTr.of(context)!.days,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),

            // 포인트 표시
            Text(
              _formatPoints(points),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
