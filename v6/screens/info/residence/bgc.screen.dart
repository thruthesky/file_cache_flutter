import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// BGC 정보 아이템 데이터 클래스 (BGC Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _BgcInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _BgcInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 주거비용 항목 데이터 클래스 (Housing Cost Item Data Class)
class _HousingCostItem {
  /// 유형 (Type)
  final String type;

  /// 월세 PHP (Monthly rent in PHP)
  final String rentPhp;

  /// 월세 원화 (Monthly rent in KRW)
  final String rentKrw;

  /// 특징 (Features)
  final String features;

  const _HousingCostItem({
    required this.type,
    required this.rentPhp,
    required this.rentKrw,
    required this.features,
  });
}

/// BGC 정보 화면 (BGC Screen)
///
/// 필리핀 BGC(Bonifacio Global City) 거주 정보를 제공합니다.
/// Provides information about living in BGC (Bonifacio Global City) in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// BgcScreen.push(context);
/// ```
class BgcScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Bgc';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const BgcScreen({super.key});

  @override
  State<BgcScreen> createState() => _BgcScreenState();
}

class _BgcScreenState extends State<BgcScreen> {
  /// 주거비용 테이블 데이터 (Housing cost table data)
  static const List<_HousingCostItem> _housingCosts = [
    _HousingCostItem(
      type: '고급 콘도 (1~2BR)',
      rentPhp: '55,000 ~ 80,000',
      rentKrw: '약 130만 ~ 190만',
      features: '헬스장·수영장·보안 포함',
    ),
    _HousingCostItem(
      type: '소형 콘도/쉐어하우스',
      rentPhp: '30,000 ~ 45,000',
      rentKrw: '약 72만 ~ 108만',
      features: '스튜디오 또는 방 공유',
    ),
  ];

  /// 주거비용 관련 정보 (Housing cost related info)
  static const List<_BgcInfoItem> _housingInfo = [
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '메트로 마닐라 최고 수준',
      description:
          'BGC의 주거비는 메트로 마닐라에서 가장 높은 수준에 속합니다.\n'
          '고급 콘도미니엄의 월세는 약 \$1,000~\$1,500(미화, 한화 약 135만~200만 원)으로, '
          '필리핀 페소로는 약 55,000~82,000페소 선입니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightWaterLadder,
      title: '고급 부대시설 포함',
      description:
          '고급 콘도는 수영장·헬스장 등 부대시설과 24시간 보안 서비스를 포함하며, '
          '장기 거주자에게 안정적인 생활 환경을 제공합니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightPiggyBank,
      title: '예산 절약 방법',
      description:
          '에어비앤비(Airbnb)나 현지 한인 커뮤니티 등을 통해 공유 주택이나 소형 스튜디오를 구하면 '
          '월 \$600~\$800(한화 80만~110만 원, 약 33,000~44,000페소) 수준까지 비용을 낮출 수 있습니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightFileInvoiceDollar,
      title: '추가 비용',
      description:
          '콘도 관리비(maintenance fee)는 면적에 비례해 부과되며, 월 5,000페소 내외가 추가될 수 있습니다.\n'
          '• 전기요금: 에어컨 상시 사용 시 4,000~6,000페소\n'
          '• 인터넷: 광랜 기준 월 2,000페소\n'
          '• 수도: 월 500페소 내외',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightWallet,
      title: '총 생활비',
      description:
          'BGC 거주 시 월 1,200~1,800달러(한화 약 160만~240만 원) 정도면 안정적인 생활이 가능합니다.\n'
          '타 도시의 물가와 비교하면 높은 수준이지만, 도쿄나 싱가포르 등 국제 대도시에 비하면 여전히 합리적인 편입니다.',
    ),
  ];

  /// 생활편의시설 정보 (Amenities info)
  static const List<_BgcInfoItem> _amenitiesInfo = [
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightCartShopping,
      title: '쇼핑',
      description:
          '대형 복합쇼핑몰인 SM Aura Premium와 Market! Market!, 고급 상점가인 보니파시오 하이스트리트를 비롯해 '
          'Uptown Mall, 세렌드라(Serendra) 등 다양한 쇼핑 공간이 밀집해 있습니다.\n\n'
          '슈퍼마켓과 영화관, 패션 매장 등이 입점해 있어 생활 필수품부터 여가 생활까지 한 곳에서 해결할 수 있습니다. '
          '한인 식재료는 인근 한국식품점이나 대형마트의 수입 식품 코너에서 비교적 쉽게 구할 수 있으며, '
          'BGC 내에도 한국 식당과 카페들이 다수 영업 중입니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightHospital,
      title: '의료',
      description:
          '세인트루크스 메디컬 센터(St. Luke\'s Medical Center)가 BGC 내에 위치해 있어 '
          '응급의료 및 국제 수준의 의료 서비스를 이용하기에 편리합니다.\n\n'
          '해당 병원은 외국인 대상 서비스를 잘 갖춘 것으로 유명하며, 영어 의료진이 상주합니다. '
          '다만 의료비는 한 번 방문에 3,000~5,000페소(약 8만~13만 원) 이상 발생할 수 있어 '
          '장기 거주자는 국제 의료보험 가입을 고려하는 것이 좋습니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightGraduationCap,
      title: '교육',
      description:
          'BGC 인근에는 국제학교와 외국인 대상 교육기관이 밀집해 있습니다.\n\n'
          '• International School Manila(ISM)\n'
          '• British School Manila\n'
          '• 필리핀한국국제학교(KISP) - McKinley Hill 인근\n\n'
          '수준 높은 유치원부터 고등학교까지의 국제 교육 환경이 갖춰져 있어 가족 단위 거주자에게 매력적입니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightTree,
      title: '문화·여가',
      description:
          'BGC는 깨끗한 거리 환경과 곳곳의 소공원(예: Track 30th, Terra 28th Park 등)으로 '
          '도심 속 산책과 여가를 즐기기 좋습니다.\n\n'
          '필리핀 내 한국문화원이 BGC에 위치하여 한국 문화 행사, 전시, 도서관 등을 이용할 수 있습니다. '
          '각국 대사관 행사, 스타트업 네트워킹 이벤트, 동호회 활동 등이 활발하여 거주자의 사회적 교류 기회가 풍부합니다.\n\n'
          '한인 모임이나 SNS 커뮤니티(예: 필고 PhilGo)를 통해 현지 정보를 공유받는 것도 쉬워 '
          '한국인 거주자의 정착을 돕습니다.',
    ),
  ];

  /// 치안 및 안전 정보 (Security and safety info)
  static const List<_BgcInfoItem> _securityInfo = [
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '우수한 치안 수준',
      description:
          '필리핀 다른 지역에 비해 BGC의 치안 수준은 매우 양호한 것으로 평가됩니다.\n\n'
          '주요 거리에 민간 경비요원이 상주하고 CCTV 감시와 24시간 순찰이 이루어져 '
          '외국인 여성도 밤길을 비교적 안전하게 다닐 수 있을 정도라는 평가가 있습니다.\n\n'
          'BGC는 계획 도시로서 치안 유지에 많은 투자가 이루어져 왔고, '
          '마닐라의 치안 안전지대라는 이미지가 형성되어 있습니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '주의사항',
      description:
          '완벽한 안전지대는 아니라는 점에 유의해야 합니다.\n\n'
          '2024년 5월 BGC 중심가인 9th Avenue에서 한국인을 대상으로 총기를 이용한 강도 사건이 발생하여 화제가 된 바 있습니다.\n\n'
          '주필리핀 한국대사관은 심야 외출 자제와 현금·귀중품 노출 경계 등을 공지하며 각별한 주의를 당부했습니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightListCheck,
      title: '안전 수칙',
      description:
          '• 늦은 밤 홀로 걷는 상황은 피하고 Grab 등의 공인 호출 차량을 이용\n'
          '• 고가의 가방이나 시계 등 사치품을 공개적으로 휴대하지 않기\n'
          '• BGC 밖 일반 시내 이동 시 소매치기, 택시 바가지요금 등 작은 위험 요소에 대비',
    ),
  ];

  /// 교통 및 접근성 정보 (Transportation and accessibility info)
  static const List<_BgcInfoItem> _transportationInfo = [
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightPersonWalking,
      title: '도보 환경',
      description:
          'BGC는 도시계획 단계부터 보행자를 고려하여 설계되어 인도가 넓고 쾌적합니다.\n\n'
          '거주 지역에서 쇼핑몰, 식당, 공원까지 걸어서 10~15분 이내에 닿을 수 있는 경우가 많아 '
          '일상 생활에서 도보 이동이 충분히 가능합니다.\n\n'
          'BGC 내부에서는 차 없이도 생활이 가능하도록 상업시설이 밀집되어 있으며, '
          '교차로마다 신호등과 횡단보도가 잘 갖춰져 있습니다.',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightBus,
      title: 'BGC 버스',
      description:
          '보니파시오 교통공사(Bonifacio Transport)에서 운영하는 BGC 버스가 BGC와 인근 지역을 연결합니다.\n\n'
          '• 마카티 Ayala 센터와 타귁의 Arca South 등지 및 MRT/LRT 역 운행\n'
          '• Ayala MRT역 ~ BGC, Guadalupe역 ~ BGC 노선 정기 운행\n'
          '• 이용 요금: 구간별 15~50페소\n'
          '• 교통카드(버스 전용 카드 또는 GCash 등 전자결제) 사용',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightTaxi,
      title: '택시·차량',
      description:
          'BGC 내부에는 지프니(jeepney) 같은 일반 대중교통이 진입하지 않도록 제한되어 있습니다.\n\n'
          '택시나 차량 호출 앱(Grab 등)을 이용한 이동이 일반적입니다.\n\n'
          '• Grab을 통한 BGC 내 이동 비용: 대체로 100페소(약 2,500원) 이하\n'
          '• 호출 시 5분 이내 차량 구할 수 있을 만큼 수요와 공급 활발\n'
          '• 자가용 운전 시 BGC 내 유료 주차장 다수 (출퇴근 시간 주변 도로 정체 심각)',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightRoad,
      title: '외부 연결',
      description:
          '• 마카티 중심업무지구(CBD)와 Kalayaan 플라이오버로 직접 연결\n'
          '• 오르티가스(Ortigas) 방면 최근 개통된 브리지로 접근성 향상\n'
          '• EDSA, C5 도로 등 외부 간선도로 연결 구간은 러시아워에 혼잡도 매우 높음',
    ),
    _BgcInfoItem(
      icon: FontAwesomeIcons.lightTrainSubway,
      title: '향후 개발',
      description:
          '2020년대 후반 완공을 목표로 하는 마닐라 지하철(Metro Manila Subway) 프로젝트에 '
          'BGC역(가칭)이 포함되어 있습니다.\n\n'
          '지하철이 개통되면 BGC에서 케손시티, 오르티가스, 공항 방면으로의 대중교통 접근성이 크게 향상될 전망입니다.\n\n'
          'BGC와 인근 마카티를 직접 연결하는 스카이트레인 모노레일 사업도 계획되어 있어, '
          '향후 몇 년 내 대중교통망 확충을 통해 현재의 차량 위주 교통환경이 개선될 가능성이 높습니다.',
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
              FontAwesomeIcons.lightCity,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              '🇵🇭 ${l10n.residenceBgc}',
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

            /// [주거비용 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuilding,
              title: '주거비용 🏢',
            ),
            SizedBox(height: sp.s12),
            _buildHousingCostTable(context),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _housingInfo,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [생활편의시설 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightStore,
              title: '생활편의시설 🛒',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _amenitiesInfo,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [치안 및 안전 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldHalved,
              title: '치안 및 안전 🔒',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _securityInfo,
              scheme.errorContainer,
              scheme.onErrorContainer,
            ),

            SizedBox(height: sp.s24),

            /// [교통 및 접근성 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCar,
              title: '교통 및 접근성 🚍',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _transportationInfo,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [핵심 포인트 요약]
            _buildKeyPointsBox(context),

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
                FontAwesomeIcons.lightBuildingColumns,
                size: 24,
                color: scheme.onPrimaryContainer,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  'Bonifacio Global City (BGC)',
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
            'BGC는 마닐라 도심의 전통적인 이미지와는 다른 현대적인 신도시입니다. '
            '잘 정비된 도로와 고급 쇼핑몰, 국제적 감각의 레스토랑과 카페가 밀집해 있으며 '
            '필리핀의 미래형 도시로 주목받고 있습니다.',
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
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.onPrimaryContainer,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '외국인과 부유층 거주자가 많아 영어 소통이 원활하고, '
                    '처음 필리핀에 정착하는 한국인에게도 진입 장벽이 낮은 편입니다.',
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

  /// 주거비용 테이블 빌드 (Build housing cost table)
  Widget _buildHousingCostTable(BuildContext context) {
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
                Expanded(
                  flex: 3,
                  child: Text(
                    '유형',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '월세 (PHP)',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '월세 (원)',
                    style: theme.textTheme.labelLarge?.copyWith(
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
          ..._housingCosts.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == _housingCosts.length - 1;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.type,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.rentPhp,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.rentKrw,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sp.s4),
                  Text(
                    item.features,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),

          /// 단위 설명 (Unit description)
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
                    '상기 금액은 가구 완비(Fully-furnished) 기준의 평균 임대료 범위이며, '
                    '계약 조건에 따라 관리비 포함 여부가 다를 수 있습니다.',
                    style: theme.textTheme.labelMedium?.copyWith(
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

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_BgcInfoItem> items,
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
                      style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 핵심 포인트 박스 빌드 (Build key points box)
  Widget _buildKeyPointsBox(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final keyPoints = [
      '✅ 메트로 마닐라에서 가장 현대적이고 안전한 지역 중 하나',
      '✅ 월세는 고급 콘도 55,000~80,000페소, 소형은 30,000~45,000페소',
      '✅ 세인트루크스 메디컬 센터 등 국제 수준의 의료시설 접근 용이',
      '✅ 국제학교 밀집으로 가족 단위 거주에 적합',
      '✅ 도보로 생활 가능한 쾌적한 도시 환경',
      '✅ BGC 버스와 Grab으로 편리한 이동 가능',
      '⚠️ 치안이 좋으나 야간 외출 시 주의 필요',
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
                'BGC 거주 핵심 포인트',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ...keyPoints.map((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Text(
                point,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                  height: 1.4,
                ),
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
              'BGC는 필리핀에서 가장 선진화된 도시 환경을 경험할 수 있는 곳으로, '
              '처음 필리핀에 정착하는 한국인에게 추천되는 지역입니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
