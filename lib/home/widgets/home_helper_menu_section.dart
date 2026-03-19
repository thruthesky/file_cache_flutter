import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 헬퍼 메뉴 섹션 - 필리핀 생활 필수 바로가기
///
/// 대사관, 한인회, 환율, 날씨, 긴급연락처 등 필수 정보 링크를
/// 가로 스크롤 원형 아이콘으로 표시한다.
class HomeHelperMenuSection extends StatelessWidget {
  const HomeHelperMenuSection({super.key});

  static const _items = <(String, IconData, Color, String?)>[
    ('내 정보', FontAwesomeIcons.circleUser, Color(0xFF5C6BC0), null),
    ('필수정보', FontAwesomeIcons.circleInfo, Color(0xFFEF5350), null),
    ('공지사항', FontAwesomeIcons.bullhorn, Color(0xFF66BB6A), null),
    ('환율', FontAwesomeIcons.moneyBillTransfer, Color(0xFFAB47BC), null),
    ('날씨', FontAwesomeIcons.cloudSun, Color(0xFF29B6F6), null),
    ('긴급연락처', FontAwesomeIcons.phoneVolume, Color(0xFFFF7043), null),
    ('대사관', FontAwesomeIcons.buildingFlag, Color(0xFF26A69A), 'https://overseas.mofa.go.kr/ph-ko/index.do'),
    ('한인회', FontAwesomeIcons.peopleGroup, Color(0xFF8D6E63), 'https://koreancommunity.ph'),
    ('경찰서', FontAwesomeIcons.shieldHalved, Color(0xFF42A5F5), null),
    ('e트래블', FontAwesomeIcons.passport, Color(0xFFEC407A), 'https://etravel.gov.ph/'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final (label, icon, iconColor, url) = _items[index];
          return GestureDetector(
            onTap: () {
              if (url != null) {
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: SizedBox(
              width: 56,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(icon, size: 18, color: iconColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label.tr(),
                    style: text.labelSmall?.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
