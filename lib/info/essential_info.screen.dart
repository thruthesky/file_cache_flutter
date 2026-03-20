import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';

/// 필수 정보 아이템 데이터 클래스
class _EssentialInfoItem {
  final IconData icon;
  final String title;
  final String description;

  const _EssentialInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 체크리스트 아이템 데이터 클래스
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

/// 실수 아이템 데이터 클래스
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

/// 필리핀 필수 정보 화면
///
/// 필리핀 생활에 필요한 필수 정보를 9개 섹션으로 제공한다.
/// 클릭 시 세부 페이지는 아직 연결하지 않는다.
class EssentialInfoScreen extends StatelessWidget {
  static const String routeName = '/essential-info';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  const EssentialInfoScreen({super.key});

  /// 출국 전 준비
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

  /// 입국 심사
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

  /// 비자 제도
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

  /// 교통
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

  /// 숙소
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

  /// 생활 필수
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

  /// 돈 관리
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

  /// 문화 포인트
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

  /// 초보자 실수 TOP 5
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
    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightCircleInfo,
              size: 20,
              color: color.primary,
            ),
            const SizedBox(width: 8),
            Text('필리핀 초간단: 초보 필독 정보'.tr()),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: color.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 출국 전 준비
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightClipboardCheck,
              title: '출국 전 준비'.tr(),
            ),
            const SizedBox(height: 12),
            _buildChecklistCards(_preDeparture),

            const SizedBox(height: 24),

            /// 입국 심사
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightPassport,
              title: '입국 심사'.tr(),
            ),
            const SizedBox(height: 12),
            _buildInfoCards(
              _immigration,
              color.secondaryContainer,
              color.onSecondaryContainer,
            ),

            const SizedBox(height: 24),

            /// 비자 제도
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightIdCard,
              title: '비자 제도'.tr(),
            ),
            const SizedBox(height: 12),
            _buildInfoCards(
              _visa,
              color.tertiaryContainer,
              color.onTertiaryContainer,
            ),

            const SizedBox(height: 24),

            /// 교통
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightCar,
              title: '교통'.tr(),
            ),
            const SizedBox(height: 12),
            _buildInfoCards(
              _transportation,
              color.primaryContainer,
              color.onPrimaryContainer,
            ),

            const SizedBox(height: 24),

            /// 숙소
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightHouse,
              title: '숙소'.tr(),
            ),
            const SizedBox(height: 12),
            _buildInfoCards(
              _accommodation,
              color.surfaceContainerHighest,
              color.onSurface,
            ),

            const SizedBox(height: 24),

            /// 생활 필수
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightHouseUser,
              title: '생활 필수'.tr(),
            ),
            const SizedBox(height: 12),
            _buildInfoCards(
              _dailyLife,
              color.secondaryContainer,
              color.onSecondaryContainer,
            ),

            const SizedBox(height: 24),

            /// 돈 관리
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightWallet,
              title: '돈 관리'.tr(),
            ),
            const SizedBox(height: 12),
            _buildInfoCards(
              _money,
              color.tertiaryContainer,
              color.onTertiaryContainer,
            ),

            const SizedBox(height: 24),

            /// 문화 포인트
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightHeart,
              title: '문화 포인트'.tr(),
            ),
            const SizedBox(height: 12),
            _buildCultureCards(),

            const SizedBox(height: 24),

            /// 초보자 실수 TOP 5
            _buildSectionHeader(
              icon: FontAwesomeIcons.lightTriangleExclamation,
              title: '초보자 실수 TOP 5'.tr(),
            ),
            const SizedBox(height: 12),
            _buildMistakesSection(),

            const SizedBox(height: 24),

            /// 마무리 요약
            _buildSummarySection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: color.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.onSurface,
          ),
        ),
      ],
    );
  }

  /// 체크리스트 카드 (출국 전 준비용 - 경고 표시 포함)
  Widget _buildChecklistCards(List<_ChecklistItem> items) {
    return Column(
      children: items.map((item) {
        final bgColor = item.isWarning
            ? color.errorContainer
            : color.surfaceContainerLow;
        final iconBgColor = item.isWarning
            ? color.error
            : color.primaryContainer;
        final iconColor = item.isWarning
            ? color.onError
            : color.onPrimaryContainer;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: item.isWarning
                                ? color.onErrorContainer
                                : color.onSurface,
                          ),
                        ),
                        if (item.isWarning) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '필수'.tr(),
                              style: text.labelMedium?.copyWith(
                                color: color.onError,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: text.bodyMedium?.copyWith(
                        color: item.isWarning
                            ? color.onErrorContainer
                            : color.onSurfaceVariant,
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

  /// 정보 카드
  Widget _buildInfoCards(
    List<_EssentialInfoItem> items,
    Color iconBgColor,
    Color iconColor,
  ) {
    return Column(
      children: items.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.surfaceContainerLow,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: text.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant,
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

  /// 문화 카드 (가로 2개 배치)
  Widget _buildCultureCards() {
    return Row(
      children: _culture.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: item == _culture.first ? 8 : 0),
            padding: const EdgeInsets.all(12),
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.title,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: text.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
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

  /// 실수 TOP 5 섹션
  Widget _buildMistakesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _mistakes.map((mistake) {
          final isLast = mistake == _mistakes.last;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 순위 원형 배지
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${mistake.rank}',
                      style: text.labelMedium?.copyWith(
                        color: color.onError,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mistake.title,
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mistake.description,
                        style: text.bodyMedium?.copyWith(
                          color: color.onErrorContainer.withValues(alpha: 0.8),
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

  /// 마무리 요약 섹션
  Widget _buildSummarySection() {
    final summaryItems = [
      '필리핀은 초보자도 살기 쉽지만, 준비 없으면 손해 보기 쉬움',
      '비자 연장 자유로움 → 장기체류 가능',
      '교통·치안·전기요금 반드시 주의',
      'Grab, 유심, 보험은 거의 필수',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.primaryContainer,
            color.primaryContainer.withValues(alpha: 0.5),
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
                color: color.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '마무리 요약'.tr(),
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...summaryItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCheck,
                    size: 14,
                    color: color.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: text.bodyMedium?.copyWith(
                        color: color.onPrimaryContainer,
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
