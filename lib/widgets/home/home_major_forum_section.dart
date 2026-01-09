import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_section_header.dart';

/// 홈 화면 주요 게시판 섹션 위젯 (Home Major Forum Section Widget)
///
/// 주요 게시판 목록을 Wrap 형태로 표시하는 섹션입니다.
/// 각 게시판을 클릭하면 해당 게시판으로 이동합니다.
///
/// Section displaying major forums in a Wrap layout.
/// Navigates to the corresponding forum when tapped.
///
/// [onForumTap]: 게시판 클릭 시 콜백 (postId, category 전달)
class HomeMajorForumSection extends StatelessWidget {
  /// 게시판 클릭 콜백
  /// Forum tap callback
  /// - postId: 게시판 ID (예: 'freetalk', 'qna', 'buyandsell')
  /// - category: 서브카테고리 (예: 'real_estate', '경험담') - 없으면 null
  final void Function(String postId, String? category)? onForumTap;

  const HomeMajorForumSection({super.key, this.onForumTap});

  /// 주요 게시판 목록 데이터
  /// Major forum list data
  /// - (postId, category, label, icon)
  static const List<(String, String?, String, IconData)> _majorForums = [
    ('freetalk', null, '커뮤니티', FontAwesomeIcons.lightComments),
    ('freetalk', 'discussion', '자유토론', FontAwesomeIcons.lightMessageLines),
    ('qna', null, '질문답변', FontAwesomeIcons.lightCircleQuestion),
    ('wanted', null, '구인구직', FontAwesomeIcons.lightBriefcase),
    ('buyandsell', null, '회원장터', FontAwesomeIcons.lightStore),
    ('travel', null, '여행', FontAwesomeIcons.lightPlane),
    ('buyandsell', 'real_estate', '부동산', FontAwesomeIcons.lightBuilding),
    ('freetalk', '이민', '이민', FontAwesomeIcons.lightPassport),
    ('greeting', null, '인사', FontAwesomeIcons.lightHandWave),
    ('freetalk', '경험담', '경험담', FontAwesomeIcons.lightBookOpen),
    ('freetalk', '뉴스', '뉴스', FontAwesomeIcons.lightNewspaper),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 섹션 타이틀: "주요 게시판"
    /// Section title: "Major Forums"
    final sectionTitle = Lo.of(context)!.majorForums;

    return Padding(
      padding: EdgeInsets.only(left: sp.s16, right: sp.s16, top: sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (타이틀만)
          /// Section header (title only)
          HomeSectionHeader(title: sectionTitle),

          SizedBox(height: sp.s12),

          /// 게시판 목록 (Wrap 레이아웃, 예쁜 칩 디자인)
          /// Forum list (Wrap layout, beautiful chip design)
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: _majorForums.map((forum) {
              final (postId, category, label, icon) = forum;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onForumTap?.call(postId, category),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s16,
                      vertical: sp.s8,
                    ),
                    decoration: BoxDecoration(
                      /// Theme 기반 그라데이션 효과
                      /// Theme-based gradient effect
                      gradient: LinearGradient(
                        colors: [
                          scheme.primaryContainer.withValues(alpha: 0.6),
                          scheme.secondaryContainer.withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// 게시판 아이콘 (Font Awesome Light)
                        /// Forum icon (Font Awesome Light)
                        FaIcon(
                          icon,
                          size: 14,
                          color: scheme.primary,
                        ),
                        SizedBox(width: sp.s8),

                        /// 게시판 이름
                        /// Forum name
                        Text(
                          label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
