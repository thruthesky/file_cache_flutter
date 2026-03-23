import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/api/constants/info_access_codes.dart';
import 'package:philgo/currency/currency.screen.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/info/info_view.screen.dart';
import 'package:philgo/notice/notice.screen.dart';
import 'package:philgo/weather/weather.screen.dart';

/// 필수 정보 메뉴 아이템
class _MenuItem {
  final IconData icon;
  final String label;
  final String? accessCode;
  const _MenuItem(this.icon, this.label, {this.accessCode});
}

/// 필수 정보 섹션
class _Section {
  final String title;
  final List<_MenuItem> items;
  const _Section(this.title, this.items);
}

/// 필수 정보 화면
///
/// 백엔드 InfoAccessCodes.php 기준 17개 access_code만 사용.
class EssentialInfoScreen extends StatelessWidget {
  static const String routeName = '/essential-info';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  const EssentialInfoScreen({super.key});

  /// 섹션 데이터 (백엔드 InfoAccessCodes.php 기준)
  static const _sections = <_Section>[
    // 1. 긴급 연락처
    _Section('긴급 연락처', [
      _MenuItem(FontAwesomeIcons.landmarkFlag, '대사관', accessCode: InfoAccessCodes.embassy),
      _MenuItem(FontAwesomeIcons.phoneVolume, '긴급연락처', accessCode: InfoAccessCodes.emergencyNumbers),
      _MenuItem(FontAwesomeIcons.peopleGroup, '한인회', accessCode: InfoAccessCodes.koreanAssociation),
      _MenuItem(FontAwesomeIcons.buildingShield, '경찰서', accessCode: InfoAccessCodes.policeStations),
      _MenuItem(FontAwesomeIcons.hospital, '병원', accessCode: InfoAccessCodes.hospitals),
      _MenuItem(FontAwesomeIcons.buildingColumns, '기관 연락처', accessCode: InfoAccessCodes.otherAgencies),
    ]),
    // 2. 출입국
    _Section('출입국', [
      _MenuItem(FontAwesomeIcons.mobileScreenButton, 'e트래블', accessCode: InfoAccessCodes.eTravel),
    ]),
    // 3. 세부 여행지
    _Section('세부 여행지', [
      _MenuItem(FontAwesomeIcons.water, '가와산 폭포', accessCode: InfoAccessCodes.kawasanFalls),
      _MenuItem(FontAwesomeIcons.lightFish, '오슬롭 고래상어', accessCode: InfoAccessCodes.oslobWhaleShark),
      _MenuItem(FontAwesomeIcons.lightCross, '마젤란 십자가', accessCode: InfoAccessCodes.magellansCross),
      _MenuItem(FontAwesomeIcons.lightFishFins, '모알보알', accessCode: InfoAccessCodes.moalboalSardineRun),
      _MenuItem(FontAwesomeIcons.lightWaterLadder, '오션 파크', accessCode: InfoAccessCodes.oceanPark),
      _MenuItem(FontAwesomeIcons.lightIslandTropical, '반타얀 섬', accessCode: InfoAccessCodes.bantayanIsland),
    ]),
    // 4. 보홀 · 보라카이
    _Section('보홀 · 보라카이', [
      _MenuItem(FontAwesomeIcons.umbrellaBeach, '알로나 비치', accessCode: InfoAccessCodes.alonaBeach),
      _MenuItem(FontAwesomeIcons.sun, '화이트 비치', accessCode: InfoAccessCodes.whiteBeach),
    ]),
    // 5. 팔라완
    _Section('팔라완', [
      _MenuItem(FontAwesomeIcons.lightShip, '코론', accessCode: InfoAccessCodes.coron),
      _MenuItem(FontAwesomeIcons.lightIslandTropical, '엘니도', accessCode: InfoAccessCodes.elNido),
    ]),
    // 6. 필리핀 생활 정보
    _Section('필리핀 생활 정보', [
      _MenuItem(FontAwesomeIcons.bullhorn, '공지'),
      _MenuItem(FontAwesomeIcons.coins, '환율'),
      _MenuItem(FontAwesomeIcons.cloudSun, '날씨'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Essential Info"
        title: Text('필수 정보'.tr()),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
            onPressed: () {
              // 메뉴 화면 이동 (추후 구현)
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < _sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              _buildSection(context, _sections[i]),
            ],
          ],
        ),
      ),
    );
  }

  /// 섹션 빌드 (v6 MenuGridSection 동일)
  Widget _buildSection(BuildContext context, _Section section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더: 세로선 인디케이터 + 타이틀
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                section.title.tr(),
                style: text.titleSmall?.copyWith(
                  color: color.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        // 아이템 컨테이너
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: color.surfaceContainerLowest,
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Wrap(
            spacing: 0,
            runSpacing: 0,
            alignment: WrapAlignment.start,
            children: section.items.map((item) {
              return _buildGridItem(context, item);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 아이템별 탭 핸들러
  VoidCallback? _getOnTap(BuildContext context, _MenuItem item) {
    // 전용 화면이 있는 항목
    switch (item.label) {
      case '공지':
        return () => NoticeScreen.push(context);
      case '환율':
        return () => ExchangeRateScreen.push(context);
      case '날씨':
        return () => WeatherScreen.push(context);
    }
    // access_code가 있는 항목 → InfoViewScreen
    if (item.accessCode != null) {
      return () => InfoViewScreen.push(context, accessCode: item.accessCode!, title: item.label);
    }
    return null;
  }

  /// 아이콘 그리드 아이템 빌드 (v6 MenuGridItem 동일)
  Widget _buildGridItem(BuildContext context, _MenuItem item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32 - 16) / 5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _getOnTap(context, item),
        borderRadius: BorderRadius.circular(16),
        splashColor: color.primary.withValues(alpha: 0.1),
        highlightColor: color.primary.withValues(alpha: 0.05),
        child: Container(
          width: itemWidth,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘 컨테이너 (48x48, 그라데이션 배경)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.primary.withValues(alpha: 0.12),
                      color.primary.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: FaIcon(
                    item.icon,
                    size: 20,
                    color: color.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 라벨
              Text(
                item.label.tr(),
                style: text.labelSmall?.copyWith(
                  color: color.onSurface.withValues(alpha: 0.85),
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
