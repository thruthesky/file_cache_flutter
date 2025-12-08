import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 홈 화면 섹션 헤더 위젯 (Home Section Header Widget)
///
/// 타이틀과 "더보기" 버튼을 포함한 섹션 헤더입니다.
/// 메인 홈 화면에서 각 게시판 섹션의 상단에 표시됩니다.
///
/// Section header with title and "More" button.
/// Displayed at the top of each forum section on the main home screen.
///
/// [title]: 섹션 타이틀 (예: "자유게시판", "질문과 답변")
/// [onMoreTap]: "더보기" 버튼 클릭 시 콜백
class HomeSectionHeader extends StatelessWidget {
  /// 섹션 타이틀
  /// Section title
  final String title;

  /// "더보기" 버튼 클릭 콜백
  /// "More" button tap callback
  final VoidCallback? onMoreTap;

  const HomeSectionHeader({super.key, required this.title, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 전체 Row를 GestureDetector로 감싸서 어디를 탭해도 게시판으로 이동
    /// Wrap the entire Row with GestureDetector so tapping anywhere navigates to the forum
    return GestureDetector(
      onTap: onMoreTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          /// 섹션 타이틀
          /// Section title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),

          /// 중간 여백 (타이틀과 "더보기" 텍스트 사이)
          /// Spacer between title and "More" text
          const Spacer(),

          /// "더보기" 텍스트 + 아이콘
          /// "More" text + icon
          if (onMoreTap != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// "더보기" 텍스트
                /// "More" text
                Text(
                  '더보기',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),

                /// 오른쪽 화살표 아이콘 (Font Awesome Light)
                /// Right chevron icon (Font Awesome Light)
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 12,
                  color: scheme.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
