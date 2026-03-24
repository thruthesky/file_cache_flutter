import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/point/point_advertisement.service.dart';

/// 포인트 광고 기간 선택 바텀시트
///
/// 광고 가능한 일수 목록을 그리드로 표시하고,
/// 각 항목에 필요 포인트를 함께 표시한다.
class PointAdSelectionBottomSheet extends StatefulWidget {
  final PointAdvertisementConfig config;
  final int userPoints;
  final int? initialSelectedDays;
  final void Function(int? days) onDaysSelected;

  const PointAdSelectionBottomSheet({
    super.key,
    required this.config,
    required this.userPoints,
    required this.onDaysSelected,
    this.initialSelectedDays,
  });

  @override
  State<PointAdSelectionBottomSheet> createState() =>
      _PointAdSelectionBottomSheetState();
}

class _PointAdSelectionBottomSheetState
    extends State<PointAdSelectionBottomSheet> {
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialSelectedDays;
  }

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
    final dayOptions = widget.config.dayOptions;

    return Container(
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
            // 드래그 핸들
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
            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightBullhorn,
                    size: 16,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // "Point Ad"
                    '포인트 광고'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    // "Current Points"
                    '${'보유 포인트'.tr()}: ${_formatPoints(widget.userPoints)}P',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: scheme.outlineVariant),
            const SizedBox(height: 16),
            // 기간 선택 그리드
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
                itemCount: dayOptions.length,
                itemBuilder: (context, index) {
                  final option = dayOptions[index];
                  final isSelected = _selectedDays == option.days;
                  final isDisabled = widget.userPoints < option.points;

                  return _buildDaysCard(
                    context,
                    days: option.days,
                    points: option.points,
                    isSelected: isSelected,
                    isDisabled: isDisabled,
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
                    ? () {
                        if (_selectedDays == widget.initialSelectedDays) {
                          widget.onDaysSelected(null);
                        } else {
                          widget.onDaysSelected(_selectedDays);
                        }
                      }
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedDays != null
                      ? (_selectedDays == widget.initialSelectedDays
                              ? '선택 해제'
                              : '선택 확인')
                          .tr()
                      // "[NO TRANSLATION: 광고 기간을 선택하세요]"
                      : '광고 기간을 선택하세요'.tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysCard(
    BuildContext context, {
    required int days,
    required int points,
    required bool isSelected,
    required bool isDisabled,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final primaryColor = isDisabled
        ? scheme.onSurface.withValues(alpha: 0.35)
        : isSelected
            ? scheme.primary
            : scheme.onSurface;
    final secondaryColor = isDisabled
        ? scheme.onSurfaceVariant.withValues(alpha: 0.35)
        : isSelected
            ? scheme.primary
            : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _selectedDays = days),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDisabled
              ? scheme.surfaceContainerHighest.withValues(alpha: 0.45)
              : isSelected
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? scheme.outline.withValues(alpha: 0.25)
                : isSelected
                    ? scheme.primary
                    : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCoins,
                    size: 12,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _formatPoints(points),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                // "[NO TRANSLATION: 일]"
                '$days${'일'.tr()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
