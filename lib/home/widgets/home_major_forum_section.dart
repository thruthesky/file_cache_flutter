import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/globals.dart';

/// 홈 주요 게시판 섹션 - Wrap 레이아웃 포럼 칩
///
/// 주요 게시판을 칩 형태로 표시하고, 탭하면 해당 게시판으로 이동한다.
class HomeMajorForumSection extends StatelessWidget {
  const HomeMajorForumSection({super.key});

  static const _forums = <(String, String?, String, IconData)>[
    ('freetalk', null, '자유게시판', FontAwesomeIcons.commentDots),
    ('qna', null, '질문답변', FontAwesomeIcons.circleQuestion),
    ('buyandsell', null, '사고팔기', FontAwesomeIcons.cartShopping),
    ('wanted', null, '구인구직', FontAwesomeIcons.briefcase),
    ('travel', null, '여행', FontAwesomeIcons.plane),
    ('buyandsell', 'real_estate', '부동산', FontAwesomeIcons.building),
    ('freetalk', '이민', '이민', FontAwesomeIcons.earthAsia),
    ('freetalk', '경험담', '경험담', FontAwesomeIcons.bookOpen),
    ('freetalk', '뉴스', '뉴스', FontAwesomeIcons.newspaper),
    ('greeting', null, '인사', FontAwesomeIcons.handshake),
    ('massage', null, '마사지', FontAwesomeIcons.spa),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주요 게시판'.tr(),
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _forums.map((forum) {
              final (postId, category, label, icon) = forum;
              return ActionChip(
                avatar: FaIcon(icon, size: 14, color: color.primary),
                label: Text(label.tr(), style: text.labelMedium),
                backgroundColor: color.surfaceContainerLow,
                side: BorderSide(color: color.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onPressed: () {
                  AppNavigationState.of(
                    context,
                  ).openForumScreen(postId: postId, category: category);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
