import 'package:flutter/material.dart';
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
///   disabled: isLoading || isUploading,
/// )
/// ```
class PointSelectionButton extends StatefulWidget {
  final String postId;
  final String? category;

  /// 광고 일수 선택 시 콜백 (null이면 선택 해제)
  final Function(int? days)? onDaysSelected;

  final bool update;

  /// Disable button during loading/uploading to prevent interaction
  final bool disabled;

  const PointSelectionButton({
    super.key,
    required this.postId,
    required this.category,
    this.update = false,
    this.onDaysSelected,
    this.disabled = false,
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

    if (!isPointAdvertisementAllowed(
      context: context,
      postId: widget.postId,
      category: widget.category,
    )) {
      return const SizedBox.shrink();
    }

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
              ? PhilgoTr.of(
                  context,
                )!.pointAdvertisementAddDays(advertisementDays!)
              : PhilgoTr.of(
                  context,
                )!.pointAdvertisementWithDays(advertisementDays!);
        } else {
          labelText = PhilgoTr.of(context)!.pointAdvertisement;
        }

        return IgnorePointer(
          ignoring: widget.disabled,
          child: Opacity(
            opacity: widget.disabled ? 0.38 : 1.0,
            child: TextButton.icon(
              onPressed: () => _showPointSelectionBottomSheet(context),
              icon: FaIcon(
                FontAwesomeIcons.lightBullhorn,
                size: 16,
                color: scheme.primary,
              ),
              label: Text(
                labelText,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ),
          ),
        );
      },
      selector: (_, state) => state.setting,
    );
  }

  /// 포인트 광고 선택 바텀 시트 표시
  void _showPointSelectionBottomSheet(BuildContext context) {
    final user = PhilgoState.of(context).user;
    final userPoints = user?.point ?? 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      builder: (context) => PointSelectionBottomSheet(
        pointSetting: setting.point,
        userPoints: userPoints,
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
