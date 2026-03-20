import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';

/// 필수 정보 메뉴 아이템
class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}

/// 필수 정보 섹션
class _Section {
  final String title;
  final List<_MenuItem> items;
  const _Section(this.title, this.items);
}

/// 필수 정보 화면
///
/// v6의 MustReadScreen과 100% 동일한 10개 섹션 아이콘 그리드 화면.
/// 클릭 시 세부 페이지는 아직 연결하지 않는다.
class EssentialInfoScreen extends StatelessWidget {
  static const String routeName = '/essential-info';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  const EssentialInfoScreen({super.key});

  /// 10개 섹션 데이터 (v6과 100% 동일)
  static const _sections = <_Section>[
    // 1. 긴급 연락처
    _Section('긴급 연락처', [
      _MenuItem(FontAwesomeIcons.landmarkFlag, '대사관'),
      _MenuItem(FontAwesomeIcons.peopleGroup, '한인회'),
      _MenuItem(FontAwesomeIcons.buildingShield, '경찰서'),
      _MenuItem(FontAwesomeIcons.hospital, '병원'),
    ]),
    // 2. 출입국 & 비자 여권
    _Section('출입국 & 비자 여권', [
      _MenuItem(FontAwesomeIcons.mobileScreenButton, 'e트래블'),
      _MenuItem(FontAwesomeIcons.planeDeparture, '여행비자'),
      _MenuItem(FontAwesomeIcons.briefcase, '워킹비자'),
      _MenuItem(FontAwesomeIcons.personCane, '은퇴비자'),
    ]),
    // 3. 교통 수단
    _Section('교통 수단', [
      _MenuItem(FontAwesomeIcons.mobileScreen, '그랩 택시'),
      _MenuItem(FontAwesomeIcons.taxi, '일반 택시'),
      _MenuItem(FontAwesomeIcons.bus, '고속 버스'),
      _MenuItem(FontAwesomeIcons.car, '렌트카'),
    ]),
    // 4. 콘도/주택 임대
    _Section('콘도/주택 임대', [
      _MenuItem(FontAwesomeIcons.key, '월세'),
      _MenuItem(FontAwesomeIcons.airbnb, '에어비앤비'),
      _MenuItem(FontAwesomeIcons.hotel, '호텔'),
    ]),
    // 5. 자동차
    _Section('자동차', [
      _MenuItem(FontAwesomeIcons.cartShopping, '구매'),
      _MenuItem(FontAwesomeIcons.shieldHalved, '보험'),
      _MenuItem(FontAwesomeIcons.fileLines, 'OR 리뉴얼'),
    ]),
    // 6. 추천 거주 지역
    _Section('추천 거주 지역', [
      _MenuItem(FontAwesomeIcons.building, 'BGC'),
      _MenuItem(FontAwesomeIcons.city, '올티가스'),
      _MenuItem(FontAwesomeIcons.houseChimney, '알라방'),
    ]),
    // 7. 도우미 & 가정교사
    _Section('도우미 & 가정교사', [
      _MenuItem(FontAwesomeIcons.lightBroom, '하우스헬퍼'),
      _MenuItem(FontAwesomeIcons.lightCarSide, '운전기사'),
      _MenuItem(FontAwesomeIcons.lightChalkboardUser, '가정교사'),
    ]),
    // 8. 필리핀 추천 여행지
    _Section('필리핀 추천 여행지', [
      _MenuItem(FontAwesomeIcons.city, '마닐라'),
      _MenuItem(FontAwesomeIcons.umbrellaBeach, '세부'),
      _MenuItem(FontAwesomeIcons.anchor, '수빅'),
      _MenuItem(FontAwesomeIcons.mountain, '보홀'),
      _MenuItem(FontAwesomeIcons.sun, '보라카이'),
      _MenuItem(FontAwesomeIcons.water, '팔라완'),
      _MenuItem(FontAwesomeIcons.lightIslandTropical, '엘니도'),
    ]),
    // 9. 먹거리, 놀거리, 볼거리
    _Section('먹거리, 놀거리, 볼거리', [
      _MenuItem(FontAwesomeIcons.lightMapLocationDot, '여행 명소'),
      _MenuItem(FontAwesomeIcons.lightGolfBallTee, '골프'),
      _MenuItem(FontAwesomeIcons.lightSpa, '마사지'),
      _MenuItem(FontAwesomeIcons.lightMartiniGlass, '밤문화'),
      _MenuItem(FontAwesomeIcons.lightStore, '시장 투어'),
      _MenuItem(FontAwesomeIcons.lightShrimp, '해산물'),
      _MenuItem(FontAwesomeIcons.lightUtensils, '맛집'),
      _MenuItem(FontAwesomeIcons.lightPersonSwimming, '수상스포츠'),
      _MenuItem(FontAwesomeIcons.lightIslandTropical, '섬투어'),
      _MenuItem(FontAwesomeIcons.lightPartyHorn, '축제'),
    ]),
    // 10. 필리핀 생활 정보
    _Section('필리핀 생활 정보', [
      _MenuItem(FontAwesomeIcons.bullhorn, '공지'),
      _MenuItem(FontAwesomeIcons.coins, '환율'),
      _MenuItem(FontAwesomeIcons.cloudSun, '날씨'),
      _MenuItem(FontAwesomeIcons.phoneVolume, '긴급연락처'),
      _MenuItem(FontAwesomeIcons.circleInfo, '초보 필독'),
      _MenuItem(FontAwesomeIcons.calendarDays, '한달살기'),
      _MenuItem(FontAwesomeIcons.umbrellaBeach, '여행'),
      _MenuItem(FontAwesomeIcons.calendarCheck, '휴일'),
      _MenuItem(FontAwesomeIcons.lightMotorcycle, '음식 배달'),
      _MenuItem(FontAwesomeIcons.lightBowlRice, '배달K'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  /// 아이콘 그리드 아이템 빌드 (v6 MenuGridItem 동일)
  Widget _buildGridItem(BuildContext context, _MenuItem item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 32 - 16) / 4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // 세부 페이지 미구현 - 추후 연결
        },
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
