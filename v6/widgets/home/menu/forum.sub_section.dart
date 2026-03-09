import 'package:flutter/material.dart';

/// Forum Sub Section Widget (게시판 서브 섹션 위젯)
///
/// 현대적이고 깔끔한 디자인의 게시판 서브 섹션 위젯입니다.
/// 3단 카테고리 구조를 위한 서브 섹션입니다.
/// 예: 게시판 (1단) → 커뮤니티 (2단) → 자유게시판, 질문답변... (3단)
/// A modern sub-section widget for 3-tier category structure in forums.
///
/// ### 디자인 특징:
/// - 칩/태그 스타일의 서브 타이틀
/// - 부드러운 배경 구분
/// - 미니멀한 스타일
/// - 테마 기반 색상
class ForumSubSection extends StatelessWidget {
  const ForumSubSection({
    super.key,
    required this.title,
    required this.children,
  });

  /// 서브 섹션 타이틀 - 2단 카테고리 이름 (예: 커뮤니티, 회원장터, 기타)
  /// Sub-section title - 2nd tier category name (e.g., Community, Market, Others)
  final String title;

  /// 메뉴 아이템 리스트 - 3단 카테고리 아이템들
  /// Menu item list - 3rd tier category items
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 서브 섹션 헤더 (Sub-section header)
          /// 현대적 디자인: 칩/태그 스타일 타이틀
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                // 부드러운 primary 배경
                color: scheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          /// 아이템 컨테이너 (Items container)
          /// 현대적 디자인: 미니멀한 배경, 부드러운 모서리
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              // 미세한 배경 구분
              color: scheme.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
            child: Wrap(
              spacing: 0,
              runSpacing: 0,
              alignment: WrapAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
