import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/event/company_event.screen.dart';
import 'package:philgo/event/event_entry.screen.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:provider/provider.dart';
import 'package:philgo/api/constants/info_access_codes.dart';
import 'package:philgo/currency/currency.screen.dart';
import 'package:philgo/info/essential_info.screen.dart';
import 'package:philgo/info/info_view.screen.dart';
import 'package:philgo/notice/notice.screen.dart';
import 'package:philgo/home/widgets/home_profile_menu_item.dart';
import 'package:philgo/weather/weather.screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 헬퍼 메뉴 섹션 - 필리핀 생활 필수 바로가기
///
/// 대사관, 한인회, 환율, 날씨, 긴급연락처 등 필수 정보 링크를
/// 둥근 사각형 아이콘 그리드로 표시한다 (스크롤 없이 한 번에 표시).
/// 업소이벤트/이벤트응모는 서버 설정에 따라 조건부로 표시한다.
class HomeHelperMenuSection extends StatelessWidget {
  const HomeHelperMenuSection({super.key});

  /// 기본 메뉴 항목 (항상 표시)
  static const _items = <(String, IconData, Color, String?)>[
    ('내 정보', FontAwesomeIcons.circleUser, Color(0xFF5C6BC0), null),
    ('필수정보', FontAwesomeIcons.lightCircleInfo, Color(0xFFEF5350), null),
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
    return Selector<SettingsState, ({bool qr, bool event})>(
      selector: (_, state) => (
        qr: state.settings?.companyQrEventEnabled ?? false,
        event: state.settings?.eventEntryEnabled ?? false,
      ),
      builder: (context, flags, _) => _buildContent(context, flags),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ({bool qr, bool event}) flags,
  ) {
    const columns = 6;

    final items = <Widget>[
      // 내 정보 (항상 첫 번째 — 프로필 사진 표시)
      const HomeProfileMenuItem(),

      // 업소이벤트 (설정 활성화 시 표시)
      if (flags.qr)
        _buildEventItem(
          context,
          '업소이벤트',
          FontAwesomeIcons.lightStore,
          color.secondaryContainer,
          color.onSecondaryContainer,
          () => CompanyEventScreen.push(context),
        ),

      // 이벤트응모 (설정 활성화 시 표시)
      if (flags.event)
        _buildEventItem(
          context,
          '이벤트응모',
          FontAwesomeIcons.lightGift,
          color.errorContainer,
          color.onErrorContainer,
          () => EventEntryScreen.push(context),
        ),

      // 필수정보
      _buildItem(
        context,
        '필수정보',
        FontAwesomeIcons.lightCircleInfo,
        const Color(0xFFEF5350),
        null,
        onTap: () => EssentialInfoScreen.push(context),
      ),

      // 나머지 메뉴 (내 정보, 필수정보 제외)
      ..._items.skip(2).map((item) {
        final (label, icon, iconColor, url) = item;
        final VoidCallback? itemOnTap = switch (label) {
          '공지사항' => () => NoticeScreen.push(context),
          '환율' => () => ExchangeRateScreen.push(context),
          '날씨' => () => WeatherScreen.push(context),
          '긴급연락처' => () => InfoViewScreen.push(context, accessCode: InfoAccessCodes.emergencyNumbers, title: '긴급연락처'),
          '경찰서' => () => InfoViewScreen.push(context, accessCode: InfoAccessCodes.policeStations, title: '경찰서'),
          _ => null,
        };
        return _buildItem(context, label, icon, iconColor, url,
            onTap: itemOnTap);
      }),
    ];

    // 6열 그리드: Row + Expanded로 완벽한 정렬 보장
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += columns) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < columns; j++) {
        final idx = i + j;
        if (idx < items.length) {
          rowChildren.add(Expanded(child: items[idx]));
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }
      rows.add(Row(children: rowChildren));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(spacing: 8, children: rows),
    );
  }

  /// 일반 메뉴 아이템
  Widget _buildItem(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
    String? url, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (url != null) {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, size: 18, color: iconColor),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.tr(),
            style: text.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 이벤트 메뉴 아이템 (강조색 배경)
  Widget _buildEventItem(
    BuildContext context,
    String label,
    IconData icon,
    Color bgColor,
    Color fgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(icon, size: 18, color: fgColor),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label.tr(),
            style: text.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
