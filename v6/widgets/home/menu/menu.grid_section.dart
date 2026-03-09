import 'package:flutter/material.dart';

/// Menu Grid Section Widget (메뉴 그리드 섹션 위젯)
///
/// 현대적이고 깔끔한 디자인의 섹션 컨테이너입니다.
/// Wrap 레이아웃으로 MenuGridItem들을 배치합니다.
/// A modern and clean section container using Wrap layout for MenuGridItems.
///
/// ### 디자인 특징:
/// - 미니멀한 테두리 스타일
/// - 부드러운 배경색
/// - 세련된 섹션 헤더
/// - 테마 기반 색상
class MenuGridSection extends StatelessWidget {
  const MenuGridSection({
    super.key,
    required this.title,
    required this.children,
    this.isDanger = false,
  });

  /// 섹션 타이틀 (Section title displayed at the top)
  final String title;

  /// 메뉴 아이템 리스트 (List of menu items to display)
  final List<Widget> children;

  /// 위험 섹션 여부 - error 색상으로 타이틀 표시 (Whether this is a danger section)
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (Section header)
        /// 현대적 디자인: 세련된 타이틀 스타일
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              // 섹션 인디케이터 바 (Section indicator bar)
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: isDanger ? scheme.error : scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              // 섹션 타이틀 (Section title)
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDanger ? scheme.error : scheme.onSurface,
                  // 미니멀 디자인: 일반 폰트 두께 사용
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        /// 메뉴 아이템 컨테이너 (Menu items container)
        /// 현대적 디자인: 부드러운 배경, 미니멀 테두리
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // 부드러운 배경색
            color: scheme.surfaceContainerLowest,
            // 미니멀한 테두리
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.0,
            ),
            // 부드러운 모서리
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            alignment: WrapAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
