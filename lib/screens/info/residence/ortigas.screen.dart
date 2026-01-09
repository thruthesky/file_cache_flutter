import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 올티가스 정보 아이템 데이터 클래스 (Ortigas Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _OrtigasInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _OrtigasInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 임대 비용 항목 데이터 클래스 (Rental Cost Item Data Class)
///
/// 면적, 월세, 한화, 유형 정보를 담습니다.
/// Contains area, monthly rent, KRW equivalent, and type information.
class _RentalCostItem {
  /// 면적 (Area in square meters)
  final String area;

  /// 월세 페소 (Monthly rent in PHP)
  final String rentPhp;

  /// 한화 환산 (KRW equivalent)
  final String rentKrw;

  /// 유형 및 조건 (Type and conditions)
  final String type;

  const _RentalCostItem({
    required this.area,
    required this.rentPhp,
    required this.rentKrw,
    required this.type,
  });
}

/// 비교 항목 데이터 클래스 (Comparison Item Data Class)
///
/// 지역 비교 테이블용 데이터입니다.
/// Data for area comparison table.
class _ComparisonItem {
  /// 항목명 (Category name)
  final String category;

  /// 올티가스 정보 (Ortigas info)
  final String ortigas;

  /// 마카티 정보 (Makati info)
  final String makati;

  /// BGC 정보 (BGC info)
  final String bgc;

  const _ComparisonItem({
    required this.category,
    required this.ortigas,
    required this.makati,
    required this.bgc,
  });
}

/// 올티가스 정보 화면 (Ortigas Screen)
///
/// 필리핀 올티가스 거주 정보를 제공합니다.
/// Provides information about living in Ortigas in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// OrtigasScreen.push(context);
/// ```
class OrtigasScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Ortigas';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const OrtigasScreen({super.key});

  @override
  State<OrtigasScreen> createState() => _OrtigasScreenState();
}

class _OrtigasScreenState extends State<OrtigasScreen> {
  /// 지역 개요 (Area overview)
  static const List<_OrtigasInfoItem> _overview = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치',
      description:
          '메트로 마닐라 파시그(Pasig) 시티에 위치\n마카티와 함께 필리핀 비즈니스의 핵심 축\n한국의 여의도에 비유될 만큼 금융 기능 집중',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightBuildings,
      title: '지역 특징',
      description:
          '금융 기업과 국제기관 본사 밀집\n고층 오피스 빌딩이 집중된 상업 지구\nSM 메가몰, 로빈슨 갤러리아, 포디움 등 대형 쇼핑몰',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightGraduationCap,
      title: '교육 환경',
      description:
          '국제학교와 대학 인접 ("필리핀의 8학군")\n한국인 어학연수생 가족 커뮤니티 형성\n에메랄드 애비뉴 주변 영어 어학원 밀집',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '한인 커뮤니티',
      description:
          '많은 외국인 거주자와 한국인 가족 거주\n한인 마트, 한식당, 제과점 등 편의시설\n팍차두 콘도 등 한인 거주 비율 높은 단지',
    ),
  ];

  /// 올티가스 거주 장점 (Advantages of living in Ortigas)
  static const List<_OrtigasInfoItem> _advantages = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightCartShopping,
      title: '편리한 생활 환경',
      description:
          '도보 거리 내 SM 메가몰, 로빈슨 갤러리아, 더 포디움\n음식점, 카페, 헬스장 등 인프라 잘 갖춤\n한인 마트, 한식당, 제과점 등 한국인 친숙 생활권',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightSchool,
      title: '학원가 및 교육시설',
      description:
          '에메랄드 애비뉴 주변 영어 어학원 밀집\n연수생 가족 다수 거주\n국제학교와 명문 대학 인접',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightTree,
      title: '쾌적한 주거 환경',
      description:
          '야간과 주말에는 비교적 한산하고 조용\n올티가스 파크 및 산책로 이용 가능\n경비 배치로 치안 양호, 야간 도보 이동 가능',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightLocationArrow,
      title: '높은 접근성',
      description:
          '메트로 마닐라 중심부 위치\nEDSA, C5 간선도로 인접\nMRT 3호선 올티가스역·쇼역 가까움\n버스, UV 익스프레스 정류장 다수',
    ),
  ];

  /// 올티가스 거주 단점 (Disadvantages of living in Ortigas)
  static const List<_OrtigasInfoItem> _disadvantages = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightCarBurst,
      title: '극심한 교통 체증',
      description:
          '러시아워 EDSA 방면 정체 매우 심각\nGrab/택시가 도보보다 느린 경우 발생\n출퇴근 시간대 지하철 이용 권장',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightMoneyBillTrendUp,
      title: '비교적 높은 물가',
      description:
          '생활비와 임대료 수준 높은 편\n마카티, BGC와 유사한 소비자물가지수\n부동산 임대 및 외식비 부담',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightBusSimple,
      title: '교통수단 제한',
      description:
          '올티가스 센터 내부 지프니 출입 제한\n지하철역·버스 정류장이 지구 가장자리\n무더위나 우천 시 이동 불편\n내부 셔틀 노선 한정적',
    ),
  ];

  /// 주거 환경 정보 (Housing environment)
  static const List<_OrtigasInfoItem> _housing = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '주거 형태',
      description:
          '대부분 고층 콘도미니엄\n에메랄드 애비뉴 중심 다양한 연식 콘도\n24시간 경비 및 CCTV 관리\n수영장, 피트니스센터 등 부대시설',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightStore,
      title: '한인 편의시설',
      description:
          '팍차두 콘도 1층 한인마트 등\n한인 거주 비율 높은 단지 커뮤니티 활성화\n관리사무소 입주자 대상 서비스 제공',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightFileContract,
      title: '임대 계약',
      description:
          '통상 6~12개월 장기 임대 계약\n관리비 포함 여부 계약 전 확인 필수\n"inclusive of dues" 확인\n별도 관리비 시 세입자가 매달 납부',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightReceipt,
      title: '관리비 참고',
      description:
          '에메랄드 애비뉴 인근 평균 ₱70/㎡\n115㎡ 유닛 약 ₱7,500/월\n전기·수도 공과금 별도 고려 필요',
    ),
  ];

  /// 임대 비용 예시 (Rental cost examples)
  static const List<_RentalCostItem> _rentalCosts = [
    _RentalCostItem(
      area: '23㎡',
      rentPhp: '₱9,000~13,000',
      rentKrw: '약 21~30만원',
      type: '스튜디오 (비가구)',
    ),
    _RentalCostItem(
      area: '50㎡',
      rentPhp: '₱30,000',
      rentKrw: '약 70만원',
      type: '1베드룸 (풀퍼니시드)',
    ),
    _RentalCostItem(
      area: '115㎡',
      rentPhp: '₱50,000',
      rentKrw: '약 116만원',
      type: '3베드룸 (가구 포함)',
    ),
  ];

  /// 단기 임대 정보 (Short-term rental)
  static const List<_OrtigasInfoItem> _shortTermRental = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '레지던스 호텔',
      description:
          '1~2개월 단기 체류 시 서비스드 레지던스 고려\n시타딘스 밀레니엄, 말라얀 플라자, BSA 트윈타워 등\n올티가스 내 콘도형 레지던스 호텔 5곳',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightBellConcierge,
      title: '서비스 포함',
      description:
          '가구·집기 완비\n청소 서비스 제공\n유틸리티(전기·수도·인터넷) 포함\n안정적인 인터넷 환경',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightCircleInfo,
      title: '유의사항',
      description:
          '일반 콘도보다 임대료 높음\n큰 평형 선택지 제한적\n장기 임대 번거로움 줄여줌',
    ),
  ];

  /// 보안 및 치안 (Security)
  static const List<_OrtigasInfoItem> _security = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '치안 수준',
      description:
          '메트로 마닐라 내 비교적 치안 좋은 지역\n마카티, BGC와 함께 안전한 동네로 평가\n외국인·중상층 주민 많아 범죄 발생률 낮음',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightUserShield,
      title: '경비 시스템',
      description:
          '건물마다 사설경비 상주\n올티가스 센터 중앙 경찰서 위치\n쇼핑몰·오피스 빌딩 보안 관리 철저',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightBuildingLock,
      title: '콘도 보안',
      description:
          '24시간 CCTV 모니터링\n철저한 신원 확인\n출입증/지문 인식 통제\n방문객 등록 절차 운영',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '기본 주의사항',
      description:
          '밤늦게 혼자 다니지 않기\n귀중품 노출 삼가기\n기본적인 치안 수칙 준수',
    ),
  ];

  /// 교통 정보 (Transportation)
  static const List<_OrtigasInfoItem> _transportation = [
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightTrainSubway,
      title: 'MRT-3 지하철',
      description:
          '올티가스역, 쇼역 이용 가능\n북쪽 케손시티, 남쪽 마카티 방면 연결\n출퇴근 시간대 지하철이 오히려 시간 절약',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightBus,
      title: '버스',
      description:
          'EDSA 경유 여러 버스 노선\n중앙차로 전용 버스(Bus Carousel) 시스템\n올티가스 몰, 로빈슨 갤러리아 터미널',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightPlane,
      title: '공항 연결',
      description:
          '클락 공항 P2P 버스 이용 가능\n시외버스 터미널 인근\n주변 도시 이동 편리',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightTaxi,
      title: 'Grab/택시',
      description:
          '앱으로 손쉽게 차량 호출\n출퇴근 시간 교통 체증 주의\n내부 전기 지프니 순환 셔틀 운행',
    ),
    _OrtigasInfoItem(
      icon: FontAwesomeIcons.lightSquareParking,
      title: '주차 정보',
      description:
          '대부분 콘도 세대당 1대 주차권\n추가 차량은 인근 유료주차장 이용\n마닐라 차량 2부제(번호판 요일제) 시행',
    ),
  ];

  /// 지역 비교 데이터 (Area comparison)
  static const List<_ComparisonItem> _comparisonItems = [
    _ComparisonItem(
      category: '특징',
      ortigas: '비즈니스 중심\n합리적 가격대',
      makati: '전통적 금융 중심지\n강남 테헤란로 비유',
      bgc: '계획 신도시\n최신 인프라',
    ),
    _ComparisonItem(
      category: '임대료',
      ortigas: '상대적 경쟁력\n동일 면적 대비 저렴',
      makati: '다양한 옵션\n저가~최고급',
      bgc: '가장 높음\n올티가스 대비 20~30%↑',
    ),
    _ComparisonItem(
      category: '편의시설',
      ortigas: 'SM 메가몰\n로빈슨 갤러리아',
      makati: '글로리에타\n그린벨트',
      bgc: '하이 스트리트\n업타운 몰',
    ),
    _ComparisonItem(
      category: '치안',
      ortigas: '양호\n경비 배치',
      makati: '지역별 격차\n중심지 우수',
      bgc: '최고 수준\n경비 철저',
    ),
    _ComparisonItem(
      category: '교통',
      ortigas: 'MRT 연결\n중심부 위치',
      makati: 'MRT 연결\n교통 체증',
      bgc: '철도 미연결\n차량/버스 의존',
    ),
    _ComparisonItem(
      category: '한인',
      ortigas: '커뮤니티 활발\n어학연수 중심',
      makati: '다양한 분포\n비즈니스 중심',
      bgc: '젊은 전문직\n국제학교 인접',
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
              FontAwesomeIcons.lightBuildings,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.residenceOrtigas,
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
            /// [인트로 배너]
            _buildIntroBanner(context),

            SizedBox(height: sp.s24),

            /// [위치 및 지역 특징]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMapLocationDot,
              title: '위치 및 지역 특징',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _overview,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [올티가스 거주 장점]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleCheck,
              title: '올티가스 거주의 장점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _advantages,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [올티가스 거주 단점]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleExclamation,
              title: '올티가스 거주의 단점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _disadvantages,
              scheme.errorContainer,
              scheme.onErrorContainer,
            ),

            SizedBox(height: sp.s24),

            /// [주거 환경 및 임대 정보]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHouseBuilding,
              title: '주거 환경 및 임대 정보',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _housing,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s16),

            /// [임대 비용 테이블]
            _buildRentalCostTable(context),

            SizedBox(height: sp.s24),

            /// [단기 임대]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCalendarWeek,
              title: '단기 임대 (레지던스 호텔)',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _shortTermRental,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [보안 및 치안]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldHalved,
              title: '보안 및 치안',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _security,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [교통 및 통근]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightRoute,
              title: '교통 및 통근',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _transportation,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [마카티·BGC와의 비교]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightScaleBalanced,
              title: '마카티·BGC와의 비교',
            ),
            SizedBox(height: sp.s12),
            _buildComparisonTable(context),

            SizedBox(height: sp.s16),

            /// [종합 평가]
            _buildSummaryBox(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 인트로 배너 빌드 (Build intro banner)
  Widget _buildIntroBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.7),
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
                FontAwesomeIcons.lightCity,
                size: 24,
                color: scheme.onPrimaryContainer,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '메트로 마닐라 올티가스 거주 정보',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '올티가스 센터(Ortigas Center)는 메트로 마닐라 파시그(Pasig) 시티에 위치한 '
            '주요 상업 지구로, 마카티와 함께 필리핀 비즈니스의 핵심 축을 이루는 지역입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightLandmark,
                  size: 14,
                  color: scheme.onPrimaryContainer,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '한국의 여의도에 비유될 만큼 금융 기능이 집중된 곳입니다.',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
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

  /// 섹션 헤더 빌드 (Build section header)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
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
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_OrtigasInfoItem> items,
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
                child: Center(
                  child: FaIcon(item.icon, size: 18, color: iconColor),
                ),
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

  /// 임대 비용 테이블 빌드 (Build rental cost table)
  Widget _buildRentalCostTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightMoneyBills,
                  size: 14,
                  color: scheme.onPrimaryContainer,
                ),
                SizedBox(width: sp.s8),
                Text(
                  '올티가스 콘도 임대가 예시 (2022년 말 기준)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 컬럼 헤더
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '면적',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '월세(페소)',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '한화',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '유형',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 행 (Table rows)
          ..._rentalCosts.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == _rentalCosts.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.area,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.rentPhp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.rentKrw,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.type,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          /// 참고 사항 (Note)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 12,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '월 기준 금액 / 6~12개월 장기 임대 계약 전제',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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

  /// 지역 비교 테이블 빌드 (Build comparison table)
  Widget _buildComparisonTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '구분',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '올티가스',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '마카티',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'BGC',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 행 (Table rows)
          ..._comparisonItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == _comparisonItems.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.ortigas,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.makati,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.bgc,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
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

  /// 종합 평가 박스 빌드 (Build summary box)
  Widget _buildSummaryBox(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryPoints = [
      '주거비용 면에서 마카티·BGC 대비 경쟁력',
      '지리적으로 세 지역의 중간에 위치해 양방향 이동 용이',
      '균형 잡힌 생활환경과 한국인 커뮤니티 형성',
      '개인의 우선순위(예산, 직장 위치, 생활양식)에 따라 선택',
    ];

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.secondaryContainer,
            scheme.secondaryContainer.withValues(alpha: 0.7),
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
                FontAwesomeIcons.lightStar,
                size: 16,
                color: scheme.onSecondaryContainer,
              ),
              SizedBox(width: sp.s8),
              Text(
                '올티가스 종합 평가',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ...summaryPoints.map((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCheck,
                    size: 12,
                    color: scheme.onSecondaryContainer,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'BGC처럼 최신 개발지의 세련됨이나 마카티의 전통적인 상징성에서는 다소 떨어지지만, '
              '균형 잡힌 생활환경과 한국인에게 친숙한 커뮤니티가 형성되어 있다는 점에서 '
              '올티가스만의 매력이 있습니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
