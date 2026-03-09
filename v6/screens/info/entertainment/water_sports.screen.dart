import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 수상스포츠 정보 아이템 데이터 클래스 (Water Sports Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _InfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 지역별 수상스포츠 개요 데이터 클래스 (Region Overview Data Class)
///
/// 지역별 대표 종목, 주 이용 구역, 당일 이용 가능 여부, 예약 방법을 담습니다.
/// Contains region name, representative sports, main area, availability, and booking info.
class _RegionOverview {
  /// 지역명 (Region name)
  final String region;

  /// 대표 종목 (Representative sports)
  final String sports;

  /// 주 이용 구역 (Main area)
  final String area;

  /// 당일 이용 (Day use availability)
  final String dayUse;

  /// 예약 방법 (Booking method)
  final String booking;

  const _RegionOverview({
    required this.region,
    required this.sports,
    required this.area,
    required this.dayUse,
    required this.booking,
  });
}

/// 종목 상세 데이터 클래스 (Sport Detail Data Class)
///
/// 각 종목의 위치, 시간, 참고가, 포인트를 담습니다.
/// Contains sport name, location, duration, price reference, and key points.
class _SportDetail {
  /// 종목명 (Sport name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 시간 (Duration)
  final String duration;

  /// 참고가 (Price reference)
  final String price;

  /// 포인트 (Key points)
  final String point;

  const _SportDetail({
    required this.name,
    required this.location,
    required this.duration,
    required this.price,
    required this.point,
  });
}

/// 절차 아이템 데이터 클래스 (Procedure Item Data Class)
///
/// 이용 절차의 단계, 내용을 담습니다.
/// Contains step number and content for each procedure item.
class _ProcedureItem {
  /// 단계 (Step)
  final String step;

  /// 내용 (Content)
  final String content;

  const _ProcedureItem({
    required this.step,
    required this.content,
  });
}

/// 참고 URL 데이터 클래스 (Reference URL Data Class)
class _ReferenceUrl {
  /// 제목 (Title)
  final String title;

  /// URL
  final String url;

  const _ReferenceUrl({
    required this.title,
    required this.url,
  });
}

/// 수상스포츠 정보 화면 (Water Sports Screen)
///
/// 필리핀 수상스포츠 관련 정보를 제공합니다.
/// Provides information about water sports in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// WaterSportsScreen.push(context);
/// ```
class WaterSportsScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/WaterSports';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const WaterSportsScreen({super.key});

  @override
  State<WaterSportsScreen> createState() => _WaterSportsScreenState();
}

class _WaterSportsScreenState extends State<WaterSportsScreen> {
  /// 지역별 개요 데이터 (Region overview data)
  static const List<_RegionOverview> _regionOverviews = [
    _RegionOverview(
      region: '보라카이',
      sports: '패러세일·제트스키·바나나보트·헬멧다이빙·카이트서핑',
      area: 'White Beach / Bulabog',
      dayUse: '가능',
      booking: '숙소·현장·온라인',
    ),
    _RegionOverview(
      region: '세부(막탄)',
      sports: '패러세일·제트스키·바나나보트·헬멧다이빙',
      area: '막탄(라푸라푸) 해역',
      dayUse: '가능',
      booking: '숙소·현장·온라인',
    ),
    _RegionOverview(
      region: '수빅',
      sports: '난파선 스쿠버(렉다이빙)·스노클·해양레저',
      area: 'Subic Bay',
      dayUse: '가능',
      booking: '다이브샵 직접',
    ),
    _RegionOverview(
      region: '팔라완(엘니도)',
      sports: '아일랜드호핑·스노클·카약(라군)',
      area: 'Bacuit Bay',
      dayUse: '가능',
      booking: '숙소·현장·온라인',
    ),
    _RegionOverview(
      region: '팔라완(코론)',
      sports: '난파선 다이빙·스노클·라군/호수 투어',
      area: 'Coron Bay',
      dayUse: '가능',
      booking: '다이브샵·투어사',
    ),
    _RegionOverview(
      region: '시아르가오',
      sports: '서핑',
      area: 'General Luna(Cloud 9 등)',
      dayUse: '가능',
      booking: '서프스쿨',
    ),
    _RegionOverview(
      region: '라우니온',
      sports: '서핑(입문 강습)',
      area: 'San Juan',
      dayUse: '가능',
      booking: '서프스쿨',
    ),
    _RegionOverview(
      region: '카마리네스 수르',
      sports: '케이블 웨이크보드',
      area: 'Pili(CWC)',
      dayUse: '가능',
      booking: '현장/온라인',
    ),
  ];

  /// 보라카이 종목 상세 데이터 (Boracay sports detail data)
  static const List<_SportDetail> _boracaySports = [
    _SportDetail(
      name: '패러세일(2인)',
      location: 'White Beach 인근',
      duration: '약 10~15분',
      price: 'US\$30대~',
      point: '바람 강하면 취소 가능',
    ),
    _SportDetail(
      name: '제트스키',
      location: 'White Beach 인근',
      duration: '15~30분',
      price: 'US\$30~60대',
      point: '면허 불요(가이드 포함 상품 다수)',
    ),
    _SportDetail(
      name: '바나나보트/UFO',
      location: 'White Beach 인근',
      duration: '약 10~15분',
      price: 'US\$7~15대',
      point: '최소 인원 조건 존재 가능',
    ),
    _SportDetail(
      name: '헬멧다이빙(Sea Walk)',
      location: 'White Beach 인근',
      duration: '약 15~20분',
      price: 'US\$10~20대',
      point: '수중 보행(산소 공급 헬멧)',
    ),
    _SportDetail(
      name: '카이트서핑',
      location: 'Bulabog Beach',
      duration: '1회/강습 단위',
      price: '시즌형',
      point: '11~4월 바람 시즌',
    ),
  ];

  /// 보라카이 당일 이용 절차 (Boracay day use procedure)
  static const List<_ProcedureItem> _boracayProcedure = [
    _ProcedureItem(step: '1', content: '숙소 데스크에서 가능 종목·픽업 지점·시간 확인'),
    _ProcedureItem(step: '2', content: 'DOT 인증 업체/공식 채널로 예약 진행'),
    _ProcedureItem(step: '3', content: '현장 안전 브리핑 후 탑승/이용(구명조끼 등 장비 수령)'),
    _ProcedureItem(step: '4', content: '기상 악화 시 일정 변경/환불 규정 확인'),
  ];

  /// 막탄 종목 상세 데이터 (Mactan sports detail data)
  static const List<_SportDetail> _mactanSports = [
    _SportDetail(
      name: '3-in-1 패키지',
      location: 'Punta Engaño 등',
      duration: '반나절 내',
      price: '상품별 상이',
      point: '패러세일+제트스키+바나나',
    ),
    _SportDetail(
      name: '헬멧다이빙(Sea Walk)',
      location: '막탄 해역',
      duration: '약 15~30분',
      price: '상품별 상이',
      point: '단독 또는 패키지 결합',
    ),
    _SportDetail(
      name: '웨이크보드(선택형)',
      location: '막탄 해역',
      duration: '30분~',
      price: '상품별 상이',
      point: '온라인/현지 예약',
    ),
  ];

  /// 수빅 종목 상세 데이터 (Subic sports detail data)
  static const List<_SportDetail> _subicSports = [
    _SportDetail(
      name: '펀다이빙(난파선)',
      location: 'Subic Bay',
      duration: '2탱크 기준 반일~',
      price: '센터별 상이',
      point: '난파선 수심·조류 확인',
    ),
    _SportDetail(
      name: '자격증 코스(PADI)',
      location: 'Subic Bay',
      duration: '2~3일~',
      price: '센터별 상이',
      point: '일정·교재 포함 여부 확인',
    ),
    _SportDetail(
      name: '스노클/비치다이브',
      location: '인근 해역',
      duration: '반일~',
      price: '센터별 상이',
      point: '초보 가능 프로그램 확인',
    ),
  ];

  /// 공통 체크리스트 데이터 (Common checklist data)
  static const List<_InfoItem> _checklist = [
    _InfoItem(
      icon: FontAwesomeIcons.lightLifeRing,
      title: '안전',
      description: '구명조끼/헬멧 등 장비 제공 여부, 안전 브리핑',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCloudSunRain,
      title: '기상',
      description: '바람·파도에 따른 취소/연기 규정',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBoxOpen,
      title: '포함',
      description: '픽업, 사진/영상, 장비 대여(마스크/핀/카약 등)',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '결제',
      description: '카드/현금 가능 여부(현장 결제 시 현금 요구 가능)',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBadgeCheck,
      title: '인증',
      description: 'DOT 인증 업체/공식 채널 우선',
    ),
  ];

  /// 예약 경로 정보 데이터 (Booking route info)
  static const List<_InfoItem> _bookingRoutes = [
    _InfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '숙소(호텔/리조트) 데스크',
      description: '가장 안전하고 편리한 방법\n숙소에서 공식 채널로 예약 대행',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightStore,
      title: '현지 정식 업체(현장 카운터)',
      description: 'DOT 인증 여행사 또는 다이브샵\n현장에서 직접 확인 후 예약',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '온라인 예약',
      description: 'Klook/KKday/Traveloka 등\n사전 예약으로 시간 절약',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: 'Visit Boracay - 수상스포츠 가이드',
      url: 'https://visitboracay.com/boracay/travel-guides/activities-adventures/boracay-water-sports-guide-jet-skiing-banana-boats',
    ),
    _ReferenceUrl(
      title: 'ABS-CBN - 보라카이 수상스포츠 예약 안내',
      url: 'https://www.abs-cbn.com/news/11/03/18/boracay-water-sports-activities-must-be-booked-through-hotels-denr-officials',
    ),
    _ReferenceUrl(
      title: 'KKday - 보라카이 패러세일',
      url: 'https://www.kkday.com/en-us/product/12220-watersports-activities-parasailing-boracay',
    ),
    _ReferenceUrl(
      title: 'KKday - 세부 막탄 3-in-1 수상스포츠',
      url: 'https://www.kkday.com/en/product/9493-3-in-1-water-sports-package-in-mactan-cebu-philippines',
    ),
    _ReferenceUrl(
      title: 'Klook - 막탄 워터 액티비티',
      url: 'https://www.klook.com/activity/3849-mactan-water-activities-cebu/',
    ),
    _ReferenceUrl(
      title: 'PADI - 수빅 다이브센터',
      url: 'https://www.padi.com/dive-center/philippines/scubaholics-subic/',
    ),
    _ReferenceUrl(
      title: 'Mangos Dive Center - 수빅 렉다이빙',
      url: 'https://mangosdivecenter.com/subic-bay-wreck-diving/',
    ),
    _ReferenceUrl(
      title: 'GetYourGuide - 엘니도 아일랜드호핑',
      url: 'https://www.getyourguide.com/el-nido-l974/el-nido-island-hopping-tour-a-lagoons-and-beaches-t217227/',
    ),
    _ReferenceUrl(
      title: 'Guide to PH - 코론 다이빙',
      url: 'https://guidetothephilippines.ph/articles/adventure-and-outdoors/coron-palawan-diving',
    ),
    _ReferenceUrl(
      title: 'Guide to PH - 시아르가오 서핑',
      url: 'https://guidetothephilippines.ph/articles/islands-and-beaches/surfing-siargao-guide',
    ),
    _ReferenceUrl(
      title: 'Surf Town La Union - 서핑 강습',
      url: 'https://surftownlaunion.com/surf-lessons/',
    ),
    _ReferenceUrl(
      title: 'CWC Wake - 카마리네스 수르 웨이크보드',
      url: 'https://cwcwake.com/web/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightPersonSwimming,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentWaterSports,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [헤더 배너]
            _buildHeaderBanner(context),
            SizedBox(height: sp.s24),

            /// [1. 핵심 요약]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleCheck,
              title: '핵심 요약(간추림)',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildKeySummary(context),
            SizedBox(height: sp.s24),

            /// [2. 지역별 한눈에 보기]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMap,
              title: '지역별 한눈에 보기',
              emoji: '🗺️',
            ),
            SizedBox(height: sp.s12),
            _buildRegionOverviewTable(context),
            SizedBox(height: sp.s24),

            /// [3. 보라카이]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightParachuteBox,
              title: '보라카이(Boracay)',
              emoji: '🪂',
            ),
            SizedBox(height: sp.s8),
            _buildRegionDescription(
              context,
              '해변 접근성이 높아 수상스포츠 현장 판매가 많으나, 환경관리 이후 '
              '무자격 판매자(해변 호객) 대신 숙소/공식 채널 이용이 권고됩니다.',
            ),
            SizedBox(height: sp.s12),
            _buildSportsDetailTable(context, _boracaySports, Colors.cyan),
            SizedBox(height: sp.s16),
            _buildProcedureBox(context, '보라카이 당일 이용 절차', _boracayProcedure, Colors.cyan),
            SizedBox(height: sp.s24),

            /// [4. 세부(막탄)]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightWater,
              title: '세부(막탄, Mactan)',
              emoji: '🏄',
            ),
            SizedBox(height: sp.s8),
            _buildRegionDescription(
              context,
              '막탄(라푸라푸) 해역은 패러세일·제트스키·바나나보트·헬멧다이빙을 묶은 '
              '패키지 상품이 널리 유통됩니다.',
            ),
            SizedBox(height: sp.s12),
            _buildSportsDetailTable(context, _mactanSports, Colors.blue),
            SizedBox(height: sp.s16),
            _buildMactanTips(context),
            SizedBox(height: sp.s24),

            /// [5. 수빅]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightAnchor,
              title: '수빅(Subic Bay)',
              emoji: '🤿',
            ),
            SizedBox(height: sp.s8),
            _buildRegionDescription(
              context,
              '수빅은 다이빙 목적지로 알려져 있으며, 특히 난파선(Shipwreck) 다이빙 안내가 많습니다. '
              'PADI 등록 다이브센터가 다수 존재합니다.',
            ),
            SizedBox(height: sp.s12),
            _buildSportsDetailTable(context, _subicSports, Colors.indigo),
            SizedBox(height: sp.s24),

            /// [6. 팔라완-엘니도]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightIslandTropical,
              title: '팔라완-엘니도(El Nido)',
              emoji: '🛶',
            ),
            SizedBox(height: sp.s8),
            _buildElNidoSection(context),
            SizedBox(height: sp.s24),

            /// [7. 팔라완-코론]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShip,
              title: '팔라완-코론(Coron)',
              emoji: '⚓',
            ),
            SizedBox(height: sp.s8),
            _buildCoronSection(context),
            SizedBox(height: sp.s24),

            /// [8. 시아르가오]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightWaveSquare,
              title: '시아르가오(Siargao)',
              emoji: '🌊',
            ),
            SizedBox(height: sp.s8),
            _buildSiargaoSection(context),
            SizedBox(height: sp.s24),

            /// [9. 라우니온]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightUmbrellaBeach,
              title: '라우니온(La Union)',
              emoji: '🏄‍♂️',
            ),
            SizedBox(height: sp.s8),
            _buildLaUnionSection(context),
            SizedBox(height: sp.s24),

            /// [10. 카마리네스 수르]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFlagCheckered,
              title: '카마리네스 수르(CWC)',
              emoji: '🏁',
            ),
            SizedBox(height: sp.s8),
            _buildCWCSection(context),
            SizedBox(height: sp.s24),

            /// [11. 예약 경로]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCalendarCheck,
              title: '예약 경로 3가지',
              emoji: '📲',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _bookingRoutes,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),
            SizedBox(height: sp.s24),

            /// [12. 공통 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardCheck,
              title: '공통 체크리스트(당일 이용)',
              emoji: '📌',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _checklist,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),
            SizedBox(height: sp.s24),

            /// [13. 참고 URL]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLink,
              title: '참고 URL',
              emoji: '🔗',
            ),
            SizedBox(height: sp.s12),
            _buildReferenceUrls(context),
            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 헤더 배너 빌드 (Header banner build)
  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyan.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightPersonSwimming,
                size: 24,
                color: Colors.cyan,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 수상스포츠(워터액티비티) 안내서',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '지역별 종목·당일 이용·예약 방법을 한눈에 확인하세요. '
            '필리핀 전역의 수상스포츠 정보를 정리했습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 14,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '기상(바람·파도) 악화 시 취소/연기가 발생할 수 있습니다. '
                    '당일 기상 확인은 필수입니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Section header build)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? emoji,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Text(
            emoji != null ? '$emoji $title' : title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 핵심 요약 빌드 (Key summary build)
  Widget _buildKeySummary(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBullet(
            context,
            '당일 이용은 대부분 가능하나, 기상(바람·파도) 악화 시 취소/연기가 발생합니다.',
            FontAwesomeIcons.lightCheck,
          ),
          _buildSummaryBullet(
            context,
            '예약 경로 3가지: ① 숙소 데스크 ② 현지 정식 업체 ③ 온라인 예약(Klook/KKday 등)',
            FontAwesomeIcons.lightCheck,
          ),
          _buildSummaryBullet(
            context,
            '보라카이는 DOT(필리핀 관광부) 인증 여행사를 통해 예약하도록 안내된 바가 있습니다.',
            FontAwesomeIcons.lightCheck,
          ),
          SizedBox(height: sp.s12),
          Text(
            '📌 체크포인트',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: [
              _buildCheckChip(context, '구명조끼/안전장비'),
              _buildCheckChip(context, '보험/안전 브리핑'),
              _buildCheckChip(context, '취소·환불 규정'),
              _buildCheckChip(context, '픽업 위치·시간'),
              _buildCheckChip(context, '사진/영상 포함'),
            ],
          ),
        ],
      ),
    );
  }

  /// 요약 불릿 빌드 (Summary bullet build)
  Widget _buildSummaryBullet(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 14, color: Colors.cyan.shade700),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 체크 칩 빌드 (Check chip build)
  Widget _buildCheckChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 지역별 개요 테이블 빌드 (Region overview table build)
  Widget _buildRegionOverviewTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(scheme.primaryContainer),
          columnSpacing: sp.s12,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 72,
          columns: [
            DataColumn(
              label: Text(
                '지역',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '대표 종목',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '주 이용 구역',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '예약',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
          rows: _regionOverviews.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.region,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 180,
                    child: Text(
                      item.sports,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item.area,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item.booking,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 지역 설명 빌드 (Region description build)
  Widget _buildRegionDescription(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleInfo,
            size: 16,
            color: scheme.primary,
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 종목 상세 테이블 빌드 (Sports detail table build)
  Widget _buildSportsDetailTable(
    BuildContext context,
    List<_SportDetail> sports,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: sports.map((sport) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightWater,
                    size: 18,
                    color: accentColor,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sport.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            sport.price,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      '${sport.location} · ${sport.duration}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      '💡 ${sport.point}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 절차 박스 빌드 (Procedure box build)
  Widget _buildProcedureBox(
    BuildContext context,
    String title,
    List<_ProcedureItem> procedures,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightListCheck,
                size: 16,
                color: accentColor,
              ),
              SizedBox(width: sp.s8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ...procedures.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        item.step,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      item.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 막탄 팁 빌드 (Mactan tips build)
  Widget _buildMactanTips(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.lightLightbulb, size: 16, color: Colors.blue),
              SizedBox(width: sp.s8),
              Text(
                '💡 막탄 당일 이용 팁',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          _buildTipBullet(context, '이동: 세부 시티/막탄 숙소 기준 픽업 포함 상품이 존재합니다(상품별 상이)'),
          _buildTipBullet(context, '결제: 현장 결제 가능하나, 주말·성수기에는 온라인 사전 예약 비중이 높습니다'),
          _buildTipBullet(context, '준비: 수영복·타월·방수팩·아쿠아슈즈 지참이 일반적입니다'),
        ],
      ),
    );
  }

  /// 팁 불릿 빌드 (Tip bullet build)
  Widget _buildTipBullet(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 엘니도 섹션 빌드 (El Nido section build)
  Widget _buildElNidoSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionDescription(
          context,
          '엘니도는 Bacuit Bay를 중심으로 투어 A/B/C/D 형태의 아일랜드호핑이 '
          '일반적으로 안내됩니다. 라군 구간에서 카약 대여를 옵션으로 제공합니다.',
        ),
        SizedBox(height: sp.s12),

        /// 대표 투어 구성 (Tour composition)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏝️ 대표 투어 구성',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildTourItem(context, '아일랜드호핑', '섬·비치 이동', '매우 높음'),
              _buildTourItem(context, '스노클링', '포인트 스노클', '매우 높음'),
              _buildTourItem(context, '라군 카약', 'Big Lagoon 등', '높음(대여 옵션)'),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 예약 루트 (Booking route)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📍 당일 이용 예약 루트',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildRouteItem(context, '숙소', '호텔/리조트에서 투어 A~D 중 선택 후 예약'),
              _buildRouteItem(context, '해변 현장', '출항 지점 인근 정식 투어사 카운터 이용'),
              _buildRouteItem(context, '온라인', '일정·픽업·포함사항을 비교 후 예약'),
            ],
          ),
        ),
        SizedBox(height: sp.s8),
        Text(
          '⛅ 건기(12~5월)가 아일랜드호핑 적기로 안내되기도 합니다.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.primary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  /// 투어 아이템 빌드 (Tour item build)
  Widget _buildTourItem(BuildContext context, String name, String content, String frequency) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              frequency,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.teal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 루트 아이템 빌드 (Route item build)
  Widget _buildRouteItem(BuildContext context, String label, String content) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 코론 섹션 빌드 (Coron section build)
  Widget _buildCoronSection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionDescription(
          context,
          '코론은 난파선(2차대전 침몰선) 다이빙 관련 안내가 많고, '
          '스노클링·섬/호수 투어와 함께 선택되는 경우가 많습니다.',
        ),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚓ 코론 활동 구성',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildActivityItem(context, '난파선 다이빙', '스쿠버', '수심·레벨 다양(센터 확인 필요)'),
              _buildActivityItem(context, '스노클링', '수면 활동', '얕은 포인트 중심'),
              _buildActivityItem(context, '호수/라군 투어', '보트 투어', '일정·입장료 포함 여부 확인'),
            ],
          ),
        ),
      ],
    );
  }

  /// 활동 아이템 빌드 (Activity item build)
  Widget _buildActivityItem(BuildContext context, String name, String type, String point) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(FontAwesomeIcons.lightCircleCheck, size: 14, color: Colors.amber.shade700),
          SizedBox(width: sp.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '($type)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  point,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 시아르가오 섹션 빌드 (Siargao section build)
  Widget _buildSiargaoSection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionDescription(
          context,
          '시아르가오는 필리핀 대표 서핑 지역으로 소개되며, '
          'General Luna와 Cloud 9이 핵심 구역으로 언급됩니다. '
          '서핑은 연중 가능하나, 피크 시즌(너울·스웰 강한 시기) 안내가 존재합니다.',
        ),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🌊 서핑 이용 방식',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildSurfingInfo(context, '예약', '서프스쿨/렌탈숍에서 강습·렌탈 신청'),
              _buildSurfingInfo(context, '구역', '초급/중급/상급 포인트가 구분되어 안내됨'),
              _buildSurfingInfo(context, '시즌', '특정 월에 파도가 커지는 시기 안내 존재'),
            ],
          ),
        ),
      ],
    );
  }

  /// 서핑 정보 빌드 (Surfing info build)
  Widget _buildSurfingInfo(BuildContext context, String label, String content) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 라우니온 섹션 빌드 (La Union section build)
  Widget _buildLaUnionSection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionDescription(
          context,
          '라우니온 San Juan은 서핑 강습·렌탈이 집중된 지역으로 소개됩니다. '
          '마닐라 근교에서 접근 가능한 서핑 입문지입니다.',
        ),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏄‍♂️ 라우니온 서핑(초급 기준)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildSurfingInfo(context, '구성', '강습 + 보드 렌탈(상품/학교별 상이)'),
              _buildSurfingInfo(context, '신청', '서프스쿨 예약 폼/메신저/현장 접수'),
              _buildSurfingInfo(context, '준비', '래시가드·선크림·방수팩 권장'),
            ],
          ),
        ),
      ],
    );
  }

  /// CWC 섹션 빌드 (CWC section build)
  Widget _buildCWCSection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRegionDescription(
          context,
          'Camarines Sur Watersports Complex(CWC)는 케이블 파크 방식의 '
          '웨이크보드/케이블스키 시설로 소개됩니다. 지역 관광 사이트에서도 대표 액티비티로 안내합니다.',
        ),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🏁 CWC 이용 핵심',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildCWCInfo(context, '종목', '케이블 웨이크보드/케이블스키 등'),
              _buildCWCInfo(context, '방식', '보트 견인이 아닌 케이블 시스템 중심'),
              _buildCWCInfo(context, '예약', '현장 또는 판매 채널(상품별)'),
            ],
          ),
        ),
      ],
    );
  }

  /// CWC 정보 빌드 (CWC info build)
  Widget _buildCWCInfo(BuildContext context, String label, String content) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 카드 빌드 (Info cards build)
  Widget _buildInfoCards(
    BuildContext context,
    List<_InfoItem> items,
    Color iconBgColor,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: items.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: FaIcon(item.icon, size: 18, color: iconColor)),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 참고 URL 빌드 (Reference URLs build)
  Widget _buildReferenceUrls(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _referenceUrls.map((ref) {
          return InkWell(
            onTap: () => _launchUrl(ref.url),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sp.s8),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightArrowUpRightFromSquare,
                    size: 14,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      ref.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// URL 실행 함수 (Launch URL function)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
