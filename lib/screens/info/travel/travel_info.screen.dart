import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 여행 정보 아이템 데이터 클래스 (Travel Info Item Data Class)
///
/// 각 여행 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each travel info item.
class _TravelInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _TravelInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 인기 여행지 데이터 클래스 (Popular Destination Data Class)
///
/// 인기 여행지의 이미지, 이름, 설명을 담습니다.
/// Contains image, name, and description for popular destinations.
class _PopularDestination {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 여행지 이름 (Destination name)
  final String name;

  /// 여행지 설명 (Destination description)
  final String description;

  /// 주요 특징 (Key features)
  final List<String> features;

  const _PopularDestination({
    required this.icon,
    required this.name,
    required this.description,
    required this.features,
  });
}

/// 추천 액티비티 데이터 클래스 (Recommended Activity Data Class)
class _Activity {
  final IconData icon;
  final String name;

  const _Activity({required this.icon, required this.name});
}

/// 필리핀 여행 정보 화면 (Philippines Travel Info Screen)
///
/// 필리핀 여행에 필요한 다양한 정보를 제공합니다.
/// Provides various information needed for traveling to the Philippines.
class TravelInfoScreen extends StatefulWidget {
  static const String routeName = '/TravelInfo';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const TravelInfoScreen({super.key});

  @override
  State<TravelInfoScreen> createState() => _TravelInfoScreenState();
}

class _TravelInfoScreenState extends State<TravelInfoScreen> {
  /// 국가 개요 정보 (Country overview)
  static const List<_TravelInfoItem> _overview = [
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '국가 특징',
      description: '약 7,000개 이상의 섬으로 이루어진 열대 국가\n백사장 해변, 섬 투어, 다이빙, 활기찬 도시',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightLanguage,
      title: '언어',
      description: '공용어: 영어, 타갈로그어\n대부분 영어 의사소통 가능',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightCoins,
      title: '통화',
      description: '필리핀 페소 (PHP)\n환전: 공항, 쇼핑몰, 환전소',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightPassport,
      title: '입국 정보',
      description: '한국인 30일 무비자 입국 가능\n연장 시 이민국 방문 필요',
    ),
  ];


  /// 자연 & 휴양 여행지 (Nature & Resort destinations)
  static const List<_PopularDestination> _natureDestinations = [
    _PopularDestination(
      icon: FontAwesomeIcons.lightWater,
      name: '팔라완 (Palawan)',
      description: '세계적 수준의 자연 풍광과 석회암 해변',
      features: ['엘니도', '코론', '지하강'],
    ),
    _PopularDestination(
      icon: FontAwesomeIcons.lightAnchor,
      name: '엘니도 & 코론',
      description: '맑은 바다, 라군 투어, 스노클링·다이빙',
      features: ['라군 투어', '난파선 다이빙', '스노클링'],
    ),
    _PopularDestination(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      name: '보라카이 (Boracay)',
      description: '백사장과 선셋으로 유명한 대표 해변',
      features: ['화이트 비치', '수상 스포츠', '나이트라이프'],
    ),
    _PopularDestination(
      icon: FontAwesomeIcons.lightIslandTropical,
      name: '세부 (Cebu)',
      description: '도심 문화 + 자연체험의 종합 여행지',
      features: ['고래상어 투어', '카와산 폭포', '캐년어링'],
    ),
    _PopularDestination(
      icon: FontAwesomeIcons.lightHillRockslide,
      name: '보홀 (Bohol)',
      description: '초콜릿 힐과 타르시어, 다이빙 명소',
      features: ['초콜릿 힐', '타르시어', '알로나 비치'],
    ),
    _PopularDestination(
      icon: FontAwesomeIcons.lightWaveSquare,
      name: '시아르가오 (Siargao)',
      description: '서핑과 자연 중심의 힐링 여행지',
      features: ['서핑', '아일랜드 호핑', 'SNS 명소'],
    ),
  ];

  /// 도시 & 문화 여행지 (City & Culture destinations)
  static const List<_PopularDestination> _cityDestinations = [
    _PopularDestination(
      icon: FontAwesomeIcons.lightCity,
      name: '마닐라 (Manila)',
      description: '필리핀의 수도, 역사와 현대의 공존',
      features: ['인트라무로스', '리잘 공원', '쇼핑몰'],
    ),
    _PopularDestination(
      icon: FontAwesomeIcons.lightMountain,
      name: '바기오 (Baguio)',
      description: '필리핀의 여름 수도, 시원한 고산지대',
      features: ['딸기 농장', '마인스 뷰', '세션 로드'],
    ),
  ];

  /// 추천 액티비티 (Recommended activities)
  static const List<_Activity> _activities = [
    _Activity(icon: FontAwesomeIcons.lightShip, name: '섬 호핑'),
    _Activity(icon: FontAwesomeIcons.lightMaskSnorkel, name: '스노클링'),
    _Activity(icon: FontAwesomeIcons.lightWaterLadder, name: '스쿠버다이빙'),
    _Activity(icon: FontAwesomeIcons.lightPersonSwimming, name: '서핑'),
    _Activity(icon: FontAwesomeIcons.lightPersonHiking, name: '폭포 트레킹'),
    _Activity(icon: FontAwesomeIcons.lightBowlFood, name: '현지 음식'),
    _Activity(icon: FontAwesomeIcons.lightDrumSteelpan, name: '축제 참여'),
    _Activity(icon: FontAwesomeIcons.lightCamera, name: 'SNS 촬영'),
  ];

  /// 교통 정보 (Transportation)
  static const List<_TravelInfoItem> _transportation = [
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightPlane,
      title: '항공',
      description: '인천 → 마닐라: 약 4시간\n국내선으로 섬 간 이동이 가장 빠르고 편리',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightTaxi,
      title: 'Grab (그랩)',
      description: '필리핀 대표 차량 호출 서비스\n앱 설치 필수, 안전하고 편리',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightVanShuttle,
      title: '지프니 & 트라이시클',
      description: '지프니: 저렴한 대중교통 (7~12페소)\n트라이시클: 단거리 이동에 유용',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightFerry,
      title: '페리 & 보트',
      description: '섬 간 이동 시 이용\n2Go, 오션젯 등 운항',
    ),
  ];

  /// 여행 준비물 (Packing list)
  static const List<_TravelInfoItem> _packing = [
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightSunBright,
      title: '필수품',
      description: '선크림 (SPF50+), 선글라스\n모기 퇴치제, 수영복',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightBriefcaseMedical,
      title: '상비약',
      description: '소화제, 진통제, 지사제\n밴드, 소독약',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightPlug,
      title: '전자기기',
      description: '220V / 60Hz\n플러그: A·B 타입 (어댑터 권장)',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightSimCard,
      title: '통신',
      description: 'Globe, Smart 유심 추천\n공항에서 구매 가능 (약 300페소~)',
    ),
  ];

  /// 안전 정보 (Safety)
  static const List<_TravelInfoItem> _safety = [
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightHospital,
      title: '응급 연락처',
      description: '응급: 911\n한국 대사관: +63-2-8856-9210',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '안전 수칙',
      description: '야간 혼자 다니기 주의\n공인 환전소 이용, 귀중품 관리',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightDroplet,
      title: '건강 & 위생',
      description: '생수 음용 권장\n여행자 보험 필수 가입',
    ),
  ];

  /// 추천 일정 (Sample itinerary)
  /// 아이콘은 _buildItinerary에서 인덱스 기반으로 숫자를 표시하므로 calendar 아이콘 사용
  /// Icons use calendar since _buildItinerary displays index-based numbers
  static const List<_TravelInfoItem> _itinerary = [
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightCalendarDay,
      title: 'Day 1',
      description: '마닐라 도착 & 시내 관광\n인트라무로스, 리잘 공원',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightCalendarDay,
      title: 'Day 2',
      description: '팔라완 (엘니도) 이동\n섬 호핑 투어 A',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightCalendarDay,
      title: 'Day 3',
      description: '라군 투어 및 해변 휴양\n빅 라군, 스몰 라군',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightCalendarDay,
      title: 'Day 4',
      description: '스노클링 · 다이빙\n일몰 감상 & 해변 파티',
    ),
    _TravelInfoItem(
      icon: FontAwesomeIcons.lightCalendarDay,
      title: 'Day 5',
      description: '마닐라 경유 귀국\n기념품 쇼핑',
    ),
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
            FaIcon(FontAwesomeIcons.lightPlane, size: 20, color: scheme.primary),
            SizedBox(width: sp.s8),
            const Text('🇵🇭 필리핀 여행 가이드'),
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
            /// [국가 개요 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightGlobe, title: '필리핀 개요'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _overview, scheme.primaryContainer, scheme.onPrimaryContainer),

            SizedBox(height: sp.s24),

            /// [여행 시기 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightCalendarDays, title: '언제 갈까? 여행시기'),
            SizedBox(height: sp.s12),
            _buildSeasonCards(context),

            SizedBox(height: sp.s24),

            /// [자연 & 휴양 여행지]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightIslandTropical, title: '자연 & 휴양'),
            SizedBox(height: sp.s12),
            _buildDestinationsGrid(context, _natureDestinations),

            SizedBox(height: sp.s24),

            /// [도시 & 문화 여행지]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightBuilding, title: '도시 & 문화'),
            SizedBox(height: sp.s12),
            _buildDestinationsGrid(context, _cityDestinations),

            SizedBox(height: sp.s24),

            /// [추천 액티비티]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightPersonSwimming, title: '추천 액티비티'),
            SizedBox(height: sp.s12),
            _buildActivitiesGrid(context),

            SizedBox(height: sp.s24),

            /// [교통 정보]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightCar, title: '교통 정보'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _transportation, scheme.tertiaryContainer, scheme.onTertiaryContainer),

            SizedBox(height: sp.s24),

            /// [여행 준비물]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightSuitcase, title: '여행 준비물'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _packing, scheme.secondaryContainer, scheme.onSecondaryContainer),

            SizedBox(height: sp.s24),

            /// [안전 정보]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightShieldHalved, title: '안전 & 응급'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _safety, scheme.errorContainer, scheme.onErrorContainer),

            SizedBox(height: sp.s24),

            /// [추천 일정]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightRoute, title: '추천 일정 (4박5일)'),
            SizedBox(height: sp.s12),
            _buildItinerary(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드
  Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title}) {
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

  /// 시즌 카드 빌드
  Widget _buildSeasonCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        /// 건기
        Expanded(
          child: Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.lightSun, size: 16, color: Colors.orange),
                    SizedBox(width: sp.s8),
                    Text('건기', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: sp.s8),
                Text('11월 ~ 4월', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: sp.s4),
                Text('☀️ 최적 여행 시기\n맑고 쾌적한 날씨', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        SizedBox(width: sp.s12),

        /// 우기
        Expanded(
          child: Container(
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
                    FaIcon(FontAwesomeIcons.lightCloudRain, size: 16, color: Colors.blue),
                    SizedBox(width: sp.s8),
                    Text('우기', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: sp.s8),
                Text('7월 ~ 10월', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: sp.s4),
                Text('⚠️ 태풍 주의\n날씨 체크 필수', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 여행지 그리드 빌드
  Widget _buildDestinationsGrid(BuildContext context, List<_PopularDestination> destinations) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: destinations.map((destination) {
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
                  child: FaIcon(destination.icon, size: 20, color: scheme.onPrimaryContainer),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: scheme.onSurface),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      destination.description,
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    SizedBox(height: sp.s8),
                    Wrap(
                      spacing: sp.s4,
                      runSpacing: sp.s4,
                      children: destination.features.map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feature,
                            style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSecondaryContainer),
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

  /// 액티비티 그리드 빌드
  Widget _buildActivitiesGrid(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Wrap(
      spacing: sp.s8,
      runSpacing: sp.s8,
      children: _activities.map((activity) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(activity.icon, size: 14, color: scheme.onTertiaryContainer),
              SizedBox(width: sp.s8),
              Text(activity.name, style: theme.textTheme.labelMedium?.copyWith(color: scheme.onTertiaryContainer)),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 정보 카드 빌드
  Widget _buildInfoCards(
    BuildContext context,
    List<_TravelInfoItem> items,
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
                    Text(item.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: scheme.onSurface)),
                    SizedBox(height: sp.s4),
                    Text(item.description, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 추천 일정 빌드
  Widget _buildItinerary(BuildContext context) {
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
        children: _itinerary.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _itinerary.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 타임라인 인디케이터
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(color: scheme.onPrimary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: scheme.outlineVariant,
                    ),
                ],
              ),
              SizedBox(width: sp.s12),

              /// 일정 내용
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: scheme.primary)),
                      SizedBox(height: sp.s4),
                      Text(item.description, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
