import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';

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

  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
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

          /// 중간 여백
          /// Spacer
          const Spacer(),

          /// "더보기" 버튼 (TextButton + 아이콘)
          /// "More" button (TextButton + icon)
          if (onMoreTap != null)
            TextButton(
              onPressed: onMoreTap,
              style: TextButton.styleFrom(
                /// 패딩 최소화
                /// Minimize padding
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s8,
                  vertical: sp.s4,
                ),

                /// Flat Design (elevation 0)
                elevation: 0,
              ),
              child: Row(
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
                  SizedBox(width: sp.s4),

                  /// 오른쪽 화살표 아이콘 (Font Awesome Light)
                  /// Right chevron icon (Font Awesome Light)
                  FaIcon(
                    FontAwesomeIcons.lightChevronRight,
                    size: 12,
                    color: scheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
