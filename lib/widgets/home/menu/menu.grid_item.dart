import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Menu Grid Item Widget (메뉴 그리드 아이템 위젯)
///
/// 현대적이고 깔끔한 디자인의 메뉴 아이템 위젯입니다.
/// 아이콘 위/레이블 아래 형태로, Wrap 레이아웃 내에서 사용합니다.
/// A modern and clean menu item widget with icon on top and label below.
/// Used within Wrap layout for efficient space usage.
///
/// ### 디자인 특징:
/// - 부드러운 그라데이션 아이콘 배경
/// - 미니멀한 스타일
/// - 터치 피드백 애니메이션
/// - 테마 기반 색상
class MenuGridItem extends StatelessWidget {
  const MenuGridItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
    this.width,
    this.backgroundColor,
    this.iconColor,
  });

  /// 아이콘 (Icon to display)
  final IconData icon;

  /// 타이틀 텍스트 (Title text to display)
  final String title;

  /// 탭 콜백 (Callback when item is tapped)
  final VoidCallback onTap;

  /// 위험 아이템 여부 - error 색상 사용 (Whether this is a danger item)
  final bool isDanger;

  /// 아이템 너비 - null이면 자동 계산 (Item width - auto-calculated if null)
  final double? width;

  /// 아이콘 배경색 (Icon background color)
  /// 기본값: primaryContainer
  final Color? backgroundColor;

  /// 아이콘 색상 (Icon color)
  /// 기본값: onPrimaryContainer
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // 아이템 너비: 화면 너비에 따라 4등분 (패딩 고려)
    // Item width: divided into 4 columns based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth =
        width ?? ((screenWidth - 32 - 16) / 4); // 32: 양쪽 패딩, 16: 섹션 패딩

    // 그라데이션 색상 설정 (Gradient color setup)
    // backgroundColor가 지정되면 gradient 사용 안 함
    // Don't use gradient if backgroundColor is specified
    final useGradient = backgroundColor == null;
    final gradientColors = isDanger
        ? [
            scheme.error.withValues(alpha: 0.15),
            scheme.error.withValues(alpha: 0.05),
          ]
        : [
            scheme.primary.withValues(alpha: 0.12),
            scheme.primary.withValues(alpha: 0.04),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: isDanger
            ? scheme.error.withValues(alpha: 0.1)
            : scheme.primary.withValues(alpha: 0.1),
        highlightColor: isDanger
            ? scheme.error.withValues(alpha: 0.05)
            : scheme.primary.withValues(alpha: 0.05),
        child: Container(
          width: itemWidth,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 아이콘 컨테이너 (Icon container)
              /// 현대적 디자인: 그라데이션 배경 또는 커스텀 배경색
              /// backgroundColor가 지정되면 gradient 대신 해당 색상 사용
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  // backgroundColor가 지정되면 해당 색상 사용, 아니면 null (gradient 사용)
                  color: backgroundColor,
                  // backgroundColor가 없을 때만 gradient 적용
                  gradient: useGradient
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        )
                      : null,
                  // 둥근 원형에 가까운 모서리
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 20,
                    color:
                        iconColor ??
                        (isDanger ? scheme.error : scheme.onPrimaryContainer),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// 타이틀 텍스트 (Title text)
              /// 현대적 디자인: 적절한 폰트 사이즈, 중앙 정렬
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDanger
                      ? scheme.error
                      : scheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
