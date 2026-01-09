import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 한달살기 정보 아이템 데이터 클래스 (Monthly Living Info Item Data Class)
///
/// 각 한달살기 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each monthly living info item.
class _MonthlyLivingItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _MonthlyLivingItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 추천 지역 데이터 클래스 (Recommended Area Data Class)
///
/// 추천 거주 지역의 이름, 설명, 특징을 담습니다.
/// Contains name, description, and features for recommended areas.
class _RecommendedArea {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 지역 이름 (Area name)
  final String name;

  /// 지역 설명 (Area description)
  final String description;

  /// 주요 특징 (Key features)
  final List<String> features;

  const _RecommendedArea({
    required this.icon,
    required this.name,
    required this.description,
    required this.features,
  });
}

/// 생활비 항목 데이터 클래스 (Living Cost Item Data Class)
class _CostItem {
  final String category;
  final String range;
  final String description;

  const _CostItem({
    required this.category,
    required this.range,
    required this.description,
  });
}

/// 마닐라 한달살기 정보 화면 (Manila Monthly Living Info Screen)
///
/// 마닐라에서 한달 살기에 필요한 다양한 정보를 제공합니다.
/// Provides various information needed for monthly living in Manila.
class MonthlyLivingScreen extends StatefulWidget {
  static const String routeName = '/MonthlyLiving';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const MonthlyLivingScreen({super.key});

  @override
  State<MonthlyLivingScreen> createState() => _MonthlyLivingScreenState();
}

class _MonthlyLivingScreenState extends State<MonthlyLivingScreen> {
  /// 한달살기 개요 (Monthly living overview)
  static const List<_MonthlyLivingItem> _overview = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightCity,
      title: '마닐라 소개',
      description: '필리핀의 수도이자 최대 도시\n현대적 시설과 편의성이 뛰어난 장기 체류 최적지',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightTemperatureHalf,
      title: '기후',
      description: '연평균 27~32°C 열대 기후\n11월~4월: 건기 (추천)\n6월~10월: 우기',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '언어',
      description: '영어 공용어로 의사소통 편리\n한국인 커뮤니티 활발',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightPassport,
      title: '비자',
      description: '30일 무비자 입국 가능\n이민국에서 최대 3년까지 연장 가능',
    ),
  ];

  /// 추천 거주 지역 (Recommended areas)
  static const List<_RecommendedArea> _recommendedAreas = [
    _RecommendedArea(
      icon: FontAwesomeIcons.lightBuildings,
      name: '마카티 (Makati)',
      description: '금융 중심지, 고급 콘도와 쇼핑몰 밀집',
      features: ['그린벨트', '살세도 빌리지', '레가스피 빌리지'],
    ),
    _RecommendedArea(
      icon: FontAwesomeIcons.lightBuildingColumns,
      name: 'BGC (보니파시오)',
      description: '최신 인프라, 안전하고 깨끗한 계획도시',
      features: ['하이 스트리트', '업타운 몰', '마인드 뮤지엄'],
    ),
    _RecommendedArea(
      icon: FontAwesomeIcons.lightHotel,
      name: '오르티가스 (Ortigas)',
      description: '비즈니스 중심지, 합리적인 가격대',
      features: ['SM 메가몰', '로빈슨 갤러리아', '포디움'],
    ),
    _RecommendedArea(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      name: '파사이/MOA (Mall of Asia)',
      description: '해안가 위치, 쇼핑과 엔터테인먼트',
      features: ['MOA 몰', '오션 파크', '선셋 뷰'],
    ),
  ];

  /// 숙소 정보 (Accommodation)
  static const List<_MonthlyLivingItem> _accommodation = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightBed,
      title: '콘도미니엄 (추천)',
      description:
          '월 40,000~100,000페소\n풀퍼니시드, 수영장/헬스장 포함\nAirbnb, Facebook 마켓플레이스 활용',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '호텔/서비스 레지던스',
      description: '월 60,000~150,000페소\n조식 포함, 청소 서비스\n장기 투숙 할인 가능',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightHouseChimney,
      title: '스튜디오/원룸',
      description: '월 15,000~40,000페소\n기본 가구 포함\n보증금 1~2개월 필요',
    ),
  ];

  /// 생활비 정보 (Living costs)
  static const List<_CostItem> _livingCosts = [
    _CostItem(
      category: '🏠 숙소',
      range: '₱40,000~100,000',
      description: '콘도 기준 (위치/시설에 따라 상이)',
    ),
    _CostItem(
      category: '🍽️ 식비',
      range: '₱15,000~30,000',
      description: '현지식 위주 시 절약 가능',
    ),
    _CostItem(
      category: '🚗 교통비',
      range: '₱3,000~8,000',
      description: 'Grab 이용 기준',
    ),
    _CostItem(
      category: '📱 통신비',
      range: '₱1,000~2,000',
      description: '무제한 데이터 유심',
    ),
    _CostItem(
      category: '⚡ 공과금',
      range: '₱3,000~6,000',
      description: '전기/수도/인터넷 (에어컨 사용량에 따라)',
    ),
    _CostItem(
      category: '🎉 여가/기타',
      range: '₱10,000~20,000',
      description: '카페, 쇼핑, 마사지 등',
    ),
  ];

  /// 편의시설 정보 (Amenities)
  static const List<_MonthlyLivingItem> _amenities = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightCartShopping,
      title: '쇼핑몰',
      description: 'SM, 로빈슨, 아얄라 몰\n에어컨 쇼핑몰에서 일상 해결\n한국 식품: 한인마트 다수',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightUtensils,
      title: '음식',
      description: '한식당 풍부 (한인타운 중심)\n현지 음식: 50~150페소/끼\n한식: 300~500페소/끼',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightHospital,
      title: '의료',
      description: '마카티 메디컬, 세인트 룩스 등\n한국어 통역 가능 병원 있음\n여행자 보험 필수 가입',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightDumbbell,
      title: '피트니스',
      description: '콘도 내 헬스장 무료\n외부 헬스장: 월 2,000~5,000페소\n요가, 필라테스 스튜디오 다수',
    ),
  ];

  /// 교통 정보 (Transportation)
  static const List<_MonthlyLivingItem> _transportation = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightTaxi,
      title: 'Grab (추천)',
      description: '앱으로 간편 호출, 가격 미리 확인\n안전하고 편리\n단거리 100~300페소',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightTrainSubway,
      title: 'MRT/LRT',
      description: '마닐라 주요 지역 연결\n출퇴근 시간 혼잡 주의\n15~30페소/회',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightVanShuttle,
      title: '지프니 & UV Express',
      description: '저렴한 대중교통\n지프니: 10~15페소\nUV: 에어컨 밴',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightCar,
      title: '렌터카/장기렌트',
      description: '기사 포함 장기렌트 가능\n월 30,000~50,000페소\n국제면허 필요',
    ),
  ];

  /// 통신 & 인터넷 (Communication)
  static const List<_MonthlyLivingItem> _communication = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightSimCard,
      title: '유심 (추천)',
      description: 'Globe, Smart 유심\n공항/쇼핑몰에서 구매\n무제한 데이터: 월 1,000~2,000페소',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightWifi,
      title: '인터넷',
      description: 'PLDT, Globe 홈 인터넷\n콘도 포함 또는 별도 계약\n월 1,500~3,000페소',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightLaptop,
      title: '코워킹 스페이스',
      description: '위워크, 클럭인 등 다수\n일일 500~1,000페소\n월 8,000~15,000페소',
    ),
  ];

  /// 은행 & 환전 (Banking)
  static const List<_MonthlyLivingItem> _banking = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightMoneyBillTransfer,
      title: '환전',
      description: '쇼핑몰 환전소 추천 (수수료 저렴)\n공항 환전은 피하기\n한인 환전소: 좋은 환율',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '신용카드',
      description: '대부분 Visa/Master 사용 가능\n해외결제 수수료 확인\n로컬 결제 시 현금 필요한 경우 많음',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightBuildingColumns,
      title: '은행 계좌',
      description:
          '장기 체류 시 개설 권장\nBDO, BPI, Metrobank\nACR-I Card 필요 (59일 이상 체류)',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightMobileScreen,
      title: '간편 송금',
      description: 'Wise, 페이팔 활용\nGCash, Maya 등 전자지갑\n편의점 결제 가능',
    ),
  ];

  /// 안전 & 주의사항 (Safety)
  static const List<_MonthlyLivingItem> _safety = [
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '안전 수칙',
      description: '귀중품 관리 철저\n야간 혼자 다니기 주의\n택시보다 Grab 이용 권장',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '주의 지역',
      description: '톤도, 퀴아포 등 일부 지역 주의\n관광객 대상 소매치기 주의\n가짜 경찰/사기 주의',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightHospital,
      title: '응급 연락처',
      description: '응급: 911\n한국 대사관: +63-2-8856-9210\n여행자 보험 필수',
    ),
    _MonthlyLivingItem(
      icon: FontAwesomeIcons.lightCloudBolt,
      title: '자연재해',
      description: '6~10월 태풍 시즌 주의\n지진 가끔 발생\n비상 대피 경로 숙지',
    ),
  ];

  /// 한달살기 체크리스트 (Monthly living checklist)
  static const List<String> _checklist = [
    '✈️ 항공권 예약 (왕복 또는 출국 티켓)',
    '🏠 숙소 예약 (Airbnb, Booking.com)',
    '📱 유심/포켓와이파이 준비',
    '💳 해외결제 가능 카드 확인',
    '🏥 여행자 보험 가입',
    '📄 여권 유효기간 확인 (6개월 이상)',
    '💊 상비약 준비',
    '🔌 어댑터/변환기 (220V, A/B타입)',
  ];

  @override
  Widget build(BuildContext context) {
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
              FontAwesomeIcons.lightCalendarDays,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            const Text('🇵🇭 마닐라 한달살기'),
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
            /// [한달살기 개요]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCity,
              title: '마닐라 한달살기',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _overview,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [예상 생활비]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMoneyBills,
              title: '예상 생활비 (월)',
            ),
            SizedBox(height: sp.s12),
            _buildCostTable(context),

            SizedBox(height: sp.s24),

            /// [추천 거주 지역]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '추천 거주 지역',
            ),
            SizedBox(height: sp.s12),
            _buildAreasGrid(context),

            SizedBox(height: sp.s24),

            /// [숙소]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBed,
              title: '숙소 유형',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _accommodation,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [편의시설]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightStore,
              title: '편의시설 & 생활',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _amenities,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [교통]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCar,
              title: '교통 수단',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _transportation,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [통신 & 인터넷]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightWifi,
              title: '통신 & 인터넷',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _communication,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [은행 & 환전]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCreditCard,
              title: '은행 & 환전',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _banking,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [안전 & 주의사항]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldHalved,
              title: '안전 & 주의사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _safety,
              scheme.errorContainer,
              scheme.onErrorContainer,
            ),

            SizedBox(height: sp.s24),

            /// [출발 전 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListCheck,
              title: '출발 전 체크리스트',
            ),
            SizedBox(height: sp.s12),
            _buildChecklist(context),

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

  /// 생활비 테이블 빌드 (Build cost table)
  Widget _buildCostTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 총 예상 비용 계산 (중간값 기준)
    const totalMin = '₱72,000';
    const totalMax = '₱166,000';

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 비용 항목들
          ..._livingCosts.map((cost) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      cost.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      cost.range,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),

          SizedBox(height: sp.s8),

          /// 구분선
          Container(height: 1, color: scheme.outlineVariant),

          SizedBox(height: sp.s12),

          /// 총 예상 비용
          Row(
            children: [
              Expanded(
                child: Text(
                  '💰 월 총 예상 비용',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Text(
                '$totalMin ~ $totalMax',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: sp.s8),

          /// 원화 환산
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCoins,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Text(
                  '약 180만원 ~ 400만원 (환율에 따라 변동)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 추천 지역 그리드 빌드 (Build recommended areas grid)
  Widget _buildAreasGrid(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _recommendedAreas.map((area) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    area.icon,
                    size: 20,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      area.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    Wrap(
                      spacing: sp.s4,
                      runSpacing: sp.s4,
                      children: area.features.map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feature,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        );
                      }).toList(),
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

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_MonthlyLivingItem> items,
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

  /// 체크리스트 빌드 (Build checklist)
  Widget _buildChecklist(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _checklist.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: sp.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.substring(0, 2),
                  style: const TextStyle(fontSize: 16),
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    item.substring(3),
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
