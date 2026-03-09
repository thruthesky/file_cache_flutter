import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 필수 정보 아이템 데이터 클래스 (Essential Info Item Data Class)
///
/// 각 필수 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each essential info item.
class _EssentialInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _EssentialInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 체크리스트 아이템 데이터 클래스 (Checklist Item Data Class)
class _ChecklistItem {
  final IconData icon;
  final String title;
  final String description;
  final bool isWarning;

  const _ChecklistItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isWarning = false,
  });
}

/// 실수 아이템 데이터 클래스 (Mistake Item Data Class)
class _MistakeItem {
  final int rank;
  final String title;
  final String description;

  const _MistakeItem({
    required this.rank,
    required this.title,
    required this.description,
  });
}

/// 필리핀 필수 정보 화면 (Philippines Essential Info Screen)
///
/// 필리핀 생활에 필요한 필수 정보를 제공합니다.
/// Provides essential information for living in the Philippines.
class EssentialInfoScreen extends StatefulWidget {
  static const String routeName = '/EssentialInfo';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const EssentialInfoScreen({super.key});

  @override
  State<EssentialInfoScreen> createState() => _EssentialInfoScreenState();
}

class _EssentialInfoScreenState extends State<EssentialInfoScreen> {
  /// 출국 전 준비 (Pre-departure checklist)
  static const List<_ChecklistItem> _preDeparture = [
    _ChecklistItem(
      icon: FontAwesomeIcons.lightPassport,
      title: '여권',
      description: '유효기간 6개월 이상 필수\n훼손·찢김·낙서 시 탑승 거절\n여권 사본 + 휴대폰 사진 준비',
    ),
    _ChecklistItem(
      icon: FontAwesomeIcons.lightPlaneArrival,
      title: '항공권',
      description: '편도 입국 불가!\n관광비자는 출국 항공권 필수\n입국 심사 시 실제 확인함',
      isWarning: true,
    ),
    _ChecklistItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '여행자 보험',
      description: '의무 아님, 강력 추천\n병원비 외국인에게 매우 비쌈\n해외 의료·사고·코로나 포함 확인',
    ),
    _ChecklistItem(
      icon: FontAwesomeIcons.lightQrcode,
      title: 'eTravel 등록',
      description: '출발 전 필수 등록!\nQR 코드 발급 → 입국 시 제시\n체크인 + 입국 심사 시 요구',
      isWarning: true,
    ),
  ];

  /// 입국 심사 (Immigration)
  static const List<_EssentialInfoItem> _immigration = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightComments,
      title: '자주 묻는 질문',
      description: '방문 목적: "Tourism"\n체류 기간: "2주 / 1달"\n숙소: 호텔명 or 콘도명',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '주의사항',
      description: '말 길게 하지 말 것\n농담, 애매한 답변 금지\n단문으로 차분히 대답',
    ),
  ];

  /// 비자 제도 (Visa system)
  static const List<_EssentialInfoItem> _visa = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '무비자 입국',
      description: '한국 여권: 30일 무비자\n입국 시 자동 부여\n출국 항공권 필수',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightCalendarPlus,
      title: '관광비자 연장',
      description:
          '현지에서 연장 가능!\n이민국(BI) 방문\n30일 → +29일 → 이후 1~2개월 단위\n최대 36개월 가능',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '이민국 방문 팁',
      description: '오전 방문 추천 (대기시간 ↓)\n반바지·슬리퍼 금지\n여권 원본 + 현금 필수',
    ),
  ];

  /// 교통 정보 (Transportation)
  static const List<_EssentialInfoItem> _transportation = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightMobileScreenButton,
      title: 'Grab (필수 앱)',
      description: '필리핀판 카카오택시\n가격 사전 확정 → 안전\n공항, 시내 모두 사용 가능',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightTaxi,
      title: '택시',
      description: '미터기 켜는지 반드시 확인!\n공항 택시 바가지 빈번\n가능하면 Grab 사용',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightVanShuttle,
      title: '지프니·버스',
      description: '저렴하지만 초보자 비추천\n노선 복잡 + 소매치기 위험',
    ),
  ];

  /// 숙소 정보 (Accommodation)
  static const List<_EssentialInfoItem> _accommodation = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '단기 숙소',
      description: '호텔 / 에어비앤비\n보안·위치 최우선',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightBuildingUser,
      title: '장기 숙소 (콘도)',
      description:
          '수영장, 헬스장, 24시간 경비\n단점: 전기요금 비쌈 (에어컨 폭탄)\n처음엔 1~2주 단기 → 현지 보고 계약',
    ),
  ];

  /// 생활 필수 정보 (Daily life essentials)
  static const List<_EssentialInfoItem> _dailyLife = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightSimCard,
      title: '유심 / 인터넷',
      description: '공항 유심: 비쌈\n시내 통신사: Globe, Smart\n선불 유심 + 데이터 충전 방식',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightBolt,
      title: '전기·물',
      description: '정전 잦은 지역 있음\n수압 약한 곳 많음\n콘도는 비교적 안정적',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightShieldExclamation,
      title: '치안',
      description: '총기 보유 합법 국가\n밤에 골목 금지\n휴대폰 길에서 사용 주의\n"괜찮아 보여도 방심 금물"',
    ),
  ];

  /// 돈 관리 (Money management)
  static const List<_EssentialInfoItem> _money = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금',
      description: '현금 사회\n소액권 필수 (100, 200페소)\n큰 지폐 거절당하는 경우 잦음',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: 'ATM / 카드',
      description: '국제 카드 가능 (수수료 있음)\n1회 출금 한도 낮음\nVisa / Master 권장',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightLandmarkDome,
      title: '현지 은행',
      description: '관광비자로 개설 매우 어려움\n장기체류 + 추가 서류 필요',
    ),
  ];

  /// 문화 포인트 (Cultural points)
  static const List<_EssentialInfoItem> _culture = [
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '필리핀 타임',
      description: '시간 개념 느림\n약속 지연 흔함',
    ),
    _EssentialInfoItem(
      icon: FontAwesomeIcons.lightFaceSmile,
      title: '완곡한 표현',
      description: '웃으면서 거절 = 사실상 거절\n직접적 표현보다 완곡한 표현 선호',
    ),
  ];

  /// 초보자 실수 TOP 5 (Top 5 beginner mistakes)
  static const List<_MistakeItem> _mistakes = [
    _MistakeItem(
      rank: 1,
      title: '편도 항공권으로 입국 시도',
      description: '출국 항공권 없으면 입국 거절!',
    ),
    _MistakeItem(
      rank: 2,
      title: 'eTravel 미등록',
      description: '체크인 불가, 입국 지연 발생',
    ),
    _MistakeItem(rank: 3, title: '택시 바가지', description: 'Grab 사용으로 예방 가능'),
    _MistakeItem(rank: 4, title: '전기요금 폭탄', description: '에어컨 사용량 주의!'),
    _MistakeItem(rank: 5, title: '"필리핀은 싸다" 착각', description: '외국인에게는 비쌈'),
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
              FontAwesomeIcons.lightCircleInfo,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            const Text('🇵🇭 필리핀 초간단: 초보 필독 정보'),
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
            /// [출국 전 준비 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardCheck,
              title: '출국 전 준비',
            ),
            SizedBox(height: sp.s12),
            _buildChecklistCards(context, _preDeparture),

            SizedBox(height: sp.s24),

            /// [입국 심사 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPassport,
              title: '입국 심사',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _immigration,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [비자 제도 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightIdCard,
              title: '비자 제도',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _visa,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [교통 정보 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCar,
              title: '교통',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _transportation,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [숙소 정보 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHouse,
              title: '숙소',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _accommodation,
              scheme.surfaceContainerHighest,
              scheme.onSurface,
            ),

            SizedBox(height: sp.s24),

            /// [생활 필수 정보 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHouseUser,
              title: '생활 필수',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _dailyLife,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [돈 관리 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightWallet,
              title: '돈 관리',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _money,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [문화 포인트 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHeart,
              title: '문화 포인트',
            ),
            SizedBox(height: sp.s12),
            _buildCultureCards(context),

            SizedBox(height: sp.s24),

            /// [초보자 실수 TOP 5]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTriangleExclamation,
              title: '초보자 실수 TOP 5',
            ),
            SizedBox(height: sp.s12),
            _buildMistakesSection(context),

            SizedBox(height: sp.s24),

            /// [마무리 요약]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드
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

  /// 체크리스트 카드 빌드
  Widget _buildChecklistCards(
    BuildContext context,
    List<_ChecklistItem> items,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: items.map((item) {
        /// 경고 아이템은 다른 색상 사용
        final bgColor = item.isWarning
            ? scheme.errorContainer
            : scheme.surfaceContainerLow;
        final iconBgColor = item.isWarning
            ? scheme.error
            : scheme.primaryContainer;
        final iconColor = item.isWarning
            ? scheme.onError
            : scheme.onPrimaryContainer;

        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: bgColor,
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
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: item.isWarning
                                ? scheme.onErrorContainer
                                : scheme.onSurface,
                          ),
                        ),
                        if (item.isWarning) ...[
                          SizedBox(width: sp.s4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sp.s4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '필수',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onError,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.isWarning
                            ? scheme.onErrorContainer
                            : scheme.onSurfaceVariant,
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

  /// 정보 카드 빌드
  Widget _buildInfoCards(
    BuildContext context,
    List<_EssentialInfoItem> items,
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

  /// 문화 카드 빌드 (가로 2개 배치)
  Widget _buildCultureCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: _culture.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: item == _culture.first ? sp.s8 : 0),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(item.icon, size: 16, color: Colors.purple),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),
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
        );
      }).toList(),
    );
  }

  /// 실수 TOP 5 섹션 빌드
  Widget _buildMistakesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _mistakes.map((mistake) {
          final isLast = mistake == _mistakes.last;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 순위 원형 배지
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: scheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${mistake.rank}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mistake.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onErrorContainer,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        mistake.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onErrorContainer.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 마무리 요약 섹션 빌드
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '필리핀은 초보자도 살기 쉽지만, 준비 없으면 손해 보기 쉬움',
      '비자 연장 자유로움 → 장기체류 가능',
      '교통·치안·전기요금 반드시 주의',
      'Grab, 유심, 보험은 거의 필수',
    ];

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.5),
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
                FontAwesomeIcons.lightLightbulb,
                size: 18,
                color: scheme.onPrimaryContainer,
              ),
              SizedBox(width: sp.s8),
              Text(
                '마무리 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ...summaryItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCheck,
                    size: 14,
                    color: scheme.onPrimaryContainer,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
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
}
