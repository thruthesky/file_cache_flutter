import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 알라방 정보 아이템 데이터 클래스 (Alabang Info Item Data Class)
///
/// 각 알라방 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each Alabang info item.
class _AlabangInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _AlabangInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 주거 비용 아이템 데이터 클래스 (Housing Cost Item Data Class)
class _HousingCostItem {
  /// 주거 유형 (Housing type)
  final String type;

  /// 월세 범위 (Monthly rent range)
  final String rentRange;

  /// 특징 (Features)
  final String features;

  const _HousingCostItem({
    required this.type,
    required this.rentRange,
    required this.features,
  });
}

/// 지역 비교 아이템 데이터 클래스 (Area Comparison Item Data Class)
class _AreaComparisonItem {
  /// 항목 (Category)
  final String category;

  /// 알라방 (Alabang)
  final String alabang;

  /// 마카티 (Makati)
  final String makati;

  /// BGC
  final String bgc;

  const _AreaComparisonItem({
    required this.category,
    required this.alabang,
    required this.makati,
    required this.bgc,
  });
}

/// 알라방 정보 화면 (Alabang Screen)
///
/// 필리핀 알라방 거주 정보를 제공합니다.
/// Provides information about living in Alabang in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// AlabangScreen.push(context);
/// ```
class AlabangScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Alabang';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const AlabangScreen({super.key});

  @override
  State<AlabangScreen> createState() => _AlabangScreenState();
}

class _AlabangScreenState extends State<AlabangScreen> {
  /// 알라방 개요 (Alabang overview)
  static const List<_AlabangInfoItem> _overview = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치',
      description:
          '메트로 마닐라 남부 문틴루파시티(Muntinlupa City)\n마닐라 국제공항에서 남쪽으로 약 10km',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightGem,
      title: '특징',
      description:
          '필리핀 최상류층이 계획적으로 개발한 부촌\n아얄라 그룹이 미국 비버리힐즈를 모델로 조성한 고급 게이트 커뮤니티',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '거주민',
      description: '전직 대통령, 정·재계 인사, 연예인 등 유명인 거주\n외국인들이 가장 선호하는 거주지 중 하나',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '언어',
      description: '지역 주민 대부분이 영어 사용에 능숙\n외국인이 생활하기에 언어 장벽이 낮음',
    ),
  ];

  /// 주거 환경 및 치안 (Housing environment and security)
  static const List<_AlabangInfoItem> _securityEnvironment = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '24시간 보안',
      description: '빌리지 단지 출입구에 24시간 경비 배치\n외부인 출입 통제 및 주택 주변 순찰',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightMoon,
      title: '야간 치안',
      description: '밤에도 도보로 식당이나 마트 이용 가능\n가족과 산책, 야식거리 구매도 안심',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightTree,
      title: '녹지 환경',
      description:
          '도로 폭이 넓고 녹지율이 높음\n필인베스트 자연공원, 쿠엥카 공원 등\n산책, 운동, 가족 나들이에 활용',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightHouseChimney,
      title: '주거 분위기',
      description: '혼잡한 마닐라 도심과 달리 조용하고 쾌적\n가족 단위 거주지로 인기 높음',
    ),
  ];

  /// 주거 비용 정보 (Housing cost information)
  static const List<_HousingCostItem> _housingCosts = [
    _HousingCostItem(
      type: '🏰 고급 단독주택\n(빌리지 내)',
      rentRange: '₱200,000+',
      features: '대형 정원·풀장 갖춘 저택\n최고 수준 보안',
    ),
    _HousingCostItem(
      type: '🏢 콘도미니엄\n(고층 아파트)',
      rentRange: '₱10,000~50,000+',
      features: '1~3베드룸 규모 다양\n수영장·헬스장 제공',
    ),
    _HousingCostItem(
      type: '🏘️ 타운하우스\n(연립주택)',
      rentRange: '₱50,000~100,000',
      features: '소규모 게이트단지 내\n주택+아파트 절충형',
    ),
  ];

  /// 주거 관련 추가 정보 (Additional housing information)
  static const List<_AlabangInfoItem> _housingTips = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightHouseCircleCheck,
      title: '콘도 가격대',
      description:
          '신축 고급 콘도: 월 50만 페소 이상\n오래된 스튜디오: 월 1만 페소(약 20~25만원)대',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightMagnifyingGlass,
      title: '부동산 정보',
      description:
          'Property24, Lamudi 등 웹사이트\n한인 커뮤니티 부동산 게시판\n현지 부동산 중개인 활용',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightFileContract,
      title: '계약 시 주의사항',
      description:
          '보증금 2~3개월 + 선납금 1개월\n계약 조건과 임대주체 신원 확인 필수\n필리핀 계약 문화 차이 주의',
    ),
  ];

  /// 생활 인프라 - 교육 (Infrastructure - Education)
  static const List<_AlabangInfoItem> _education = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightGraduationCap,
      title: '로컬 명문학교',
      description:
          '데 라 살레 산티아고 조벨(De La Salle Santiago Zobel)\n산베다 칼리지 알라방(San Beda College Alabang)\n파레프 우드로즈(PAREF Woodrose, 여자)\n파레프 사우스리치(PAREF Southridge, 남자)',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightEarthAmericas,
      title: '국제학교',
      description:
          '브렌트 국제학교(Brent International School)\n사우스빌 국제학교(Southville International)\nMIT 국제학교 등',
    ),
  ];

  /// 생활 인프라 - 의료 (Infrastructure - Medical)
  static const List<_AlabangInfoItem> _medical = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightHospital,
      title: '아시안 병원',
      description:
          'Asian Hospital and Medical Center\n필리핀 최고 수준의 사설 종합병원\n남부 마닐라 최초의 3차 의료기관',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightStethoscope,
      title: '기타 의료시설',
      description: '문틴루파 시립병원(Ospital ng Muntinlupa)\n외국인 보험 수용 가능\n응급실 및 전문 클리닉 보유',
    ),
  ];

  /// 생활 인프라 - 쇼핑 (Infrastructure - Shopping)
  static const List<_AlabangInfoItem> _shopping = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightBagShopping,
      title: '대형 쇼핑몰',
      description:
          '알라방 타운 센터(Alabang Town Center)\n페스티벌 몰(Festival Mall)\nSM 센터 문틴루파',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightStore,
      title: '기타 쇼핑시설',
      description: '몰리토 라이프스타일 센터(Molito)\nS&R, 랜더스(Landers) 창고형 매장\n한인마트, 한국 음식점 일부',
    ),
  ];

  /// 여가 및 기타 (Leisure and others)
  static const List<_AlabangInfoItem> _leisure = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightPersonRunning,
      title: '야외 활동',
      description: '공원에서 조깅, 자전거, 피크닉\n가로수 늘어선 조용한 거리 산책',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightGolfBallTee,
      title: '스포츠 시설',
      description:
          '아얄라 알라방 컨트리클럽\nSouthlinks 골프코스 등\n실내 놀이시설, 키즈카페',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightUtensils,
      title: '식당',
      description: '필리핀 현지 음식부터 다양한 국제 요리\n외식 선택지가 풍부',
    ),
  ];

  /// 교통 정보 (Transportation)
  static const List<_AlabangInfoItem> _transportation = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightRoad,
      title: '고속도로 접근성',
      description:
          'South Luzon 고속도로(SLEX)\n스카이웨이(Skyway) 연결\n마카티까지 약 30~40분 (비혼잡 시)\n공항까지 약 20~30분',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightTrain,
      title: '대중교통',
      description: 'PNR 통근열차(알라방역)\n버스, 지프니 운행\n노선 한정적, 환승 복잡',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightTaxi,
      title: '추천 이동수단',
      description: '승용차 또는 Grab 이용 일반적\n출퇴근용 셔틀버스/밴 서비스\n운전기사 고용 가능',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '주의사항',
      description: '출퇴근 시간대 교통정체 심함\n보행자 신호등, 횡단보도 부족\n도로 횡단 시 안전 주의',
    ),
  ];

  /// 한국인 커뮤니티 (Korean community)
  static const List<_AlabangInfoItem> _koreanCommunity = [
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightUsersLine,
      title: '한인 거주 현황',
      description:
          '마카티, 말라테 대비 한인 밀집도 낮음\n안전하고 쾌적한 환경 찾는 가족 증가 추세',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightBowlFood,
      title: '한인 시설',
      description:
          '알라방 내 한국 음식점, 한인 슈퍼마켓 일부\n인접 BF 홈스(파라냐케) 지역에 한인 다수\n아귀레 거리: 한식당, 노래방, 교회',
    ),
    _AlabangInfoItem(
      icon: FontAwesomeIcons.lightComments,
      title: '교민 네트워크',
      description:
          '한인회 지부, 필고(PhilGo) 등 커뮤니티\n국제학교/직장 통한 교민 모임\n카카오톡, SNS 그룹 정보 공유',
    ),
  ];

  /// 지역 비교 데이터 (Area comparison data)
  static const List<_AreaComparisonItem> _areaComparison = [
    _AreaComparisonItem(
      category: '환경',
      alabang: '한적한 전원형 고급 주택지\n녹지 많고 공기 깨끗',
      makati: '대도시 중심 업무지구\n인구 밀집, 혼잡',
      bgc: '계획 개발된 현대적 도시\n깨끗하고 세련됨',
    ),
    _AreaComparisonItem(
      category: '주거 형태',
      alabang: '단독주택 많음 (빌리지)\n콘도도 일부 있음',
      makati: '대부분 콘도 고층아파트\n주택은 극소수',
      bgc: '콘도 고층아파트 중심\n타운하우스 드뭄',
    ),
    _AreaComparisonItem(
      category: '주거비용',
      alabang: '주택 임대료 매우 높음\n콘도는 중간 수준',
      makati: '콘도 임대료 다양\n(중~높음)',
      bgc: '마닐라 최고 수준 임대료\n대부분 고가 신축 콘도',
    ),
    _AreaComparisonItem(
      category: '치안',
      alabang: '매우 우수\n(게이트 커뮤니티)\n밤에도 비교적 안전',
      makati: '업무지구 치안 양호\n일부 지역은 주의 필요',
      bgc: '매우 우수\n(사설 경비, CCTV)\n도보치안도 훌륭',
    ),
    _AreaComparisonItem(
      category: '인프라',
      alabang: '대형몰 (ATC, Festival 등)\n국제학교·병원 밀집',
      makati: '대형몰 (글로리에타 등)\n한식당·한인시설 많음',
      bgc: '고급몰 (SM Aura 등)\n외국계 식당·바 많음',
    ),
    _AreaComparisonItem(
      category: '한인사회',
      alabang: '한인 거주 비교적 적음\n가족 단위 위주',
      makati: '한인 가장 많음\n코리아타운 형성',
      bgc: '한인 거주 증가 추세\n젊은 층 위주',
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightHouseChimneyWindow,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.residenceAlabang),
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
            /// [알라방 개요]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCity,
              title: '알라방 개요',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _overview,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [주거 환경 및 치안]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldHalved,
              title: '주거 환경 및 치안',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _securityEnvironment,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [주거 형태 및 비용]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMoneyBills,
              title: '주거 형태 및 비용',
            ),
            SizedBox(height: sp.s12),
            _buildHousingCostTable(context),
            SizedBox(height: sp.s16),
            _buildInfoCards(
              context,
              _housingTips,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [생활 인프라 - 교육]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightSchool,
              title: '교육',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _education,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [생활 인프라 - 의료]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHospital,
              title: '의료',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _medical,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [생활 인프라 - 쇼핑]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCartShopping,
              title: '쇼핑 및 편의시설',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _shopping,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [여가 및 기타]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMasksTheater,
              title: '여가 및 기타',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _leisure,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [교통]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCar,
              title: '교통',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _transportation,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [한국인 커뮤니티]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFlag,
              title: '한국인 커뮤니티',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _koreanCommunity,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [알라방 vs 마카티 vs BGC 비교]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightScaleBalanced,
              title: '알라방 vs 마카티 vs BGC',
            ),
            SizedBox(height: sp.s12),
            _buildComparisonTable(context),

            SizedBox(height: sp.s24),

            /// [추천 대상]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLightbulb,
              title: '알라방 추천 대상',
            ),
            SizedBox(height: sp.s12),
            _buildRecommendationCard(context),

            SizedBox(height: sp.s32),
          ],
        ),
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
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_AlabangInfoItem> items,
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

  /// 주거 비용 테이블 빌드 (Build housing cost table)
  Widget _buildHousingCostTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 테이블 헤더
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '주거 유형',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '월세 (₱)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '특징',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),

          SizedBox(height: sp.s8),

          /// 구분선
          Container(height: 1, color: scheme.outlineVariant),

          SizedBox(height: sp.s8),

          /// 테이블 데이터
          ..._housingCosts.map((cost) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      cost.type,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      cost.rentRange,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      cost.features,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
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

  /// 지역 비교 테이블 빌드 (Build area comparison table)
  Widget _buildComparisonTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 테이블 헤더
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '항목',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: sp.s4),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '알라방',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: sp.s4),
              Expanded(
                flex: 3,
                child: Text(
                  '마카티',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: sp.s4),
              Expanded(
                flex: 3,
                child: Text(
                  'BGC',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          SizedBox(height: sp.s12),

          /// 구분선
          Container(height: 1, color: scheme.outlineVariant),

          SizedBox(height: sp.s8),

          /// 비교 데이터
          ..._areaComparison.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s12),
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
                    child: Container(
                      padding: EdgeInsets.all(sp.s4),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.alabang,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurface,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s4),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.makati,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: sp.s4),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.bgc,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.3,
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

  /// 추천 대상 카드 빌드 (Build recommendation card)
  Widget _buildRecommendationCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final recommendations = [
      '안전한 주거 환경을 중시하는 분',
      '자녀 교육을 중시하는 가족',
      '조용하고 쾌적한 생활을 원하는 분',
      '고급 단독주택 거주를 선호하는 분',
      '필리핀 상류층 라이프스타일을 경험하고 싶은 분',
    ];

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: recommendations.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: sp.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleCheck,
                  size: 16,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
