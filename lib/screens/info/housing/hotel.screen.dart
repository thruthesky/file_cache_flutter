import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 호텔 정보 아이템 데이터 클래스 (Hotel Info Item Data Class)
///
/// 각 호텔 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each hotel info item.
class _HotelInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _HotelInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 숙소 유형 데이터 클래스 (Accommodation Type Data Class)
///
/// 숙소 유형별 이름, 위치, 가격, 특징을 담습니다.
/// Contains name, location, price, and features for each accommodation type.
class _AccommodationType {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 유형 이름 (Type name)
  final String name;

  /// 위치 및 환경 (Location and environment)
  final String location;

  /// 1박 요금 (Price per night)
  final String price;

  /// 특징 및 용도 (Features and usage)
  final String features;

  const _AccommodationType({
    required this.icon,
    required this.name,
    required this.location,
    required this.price,
    required this.features,
  });
}

/// 호텔 정보 화면 (Hotel Screen)
///
/// 필리핀 호텔 예약 및 숙소 선택 가이드를 제공합니다.
/// Provides a comprehensive guide for hotel booking and accommodation selection in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// HotelScreen.push(context);
/// ```
class HotelScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Hotel';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const HotelScreen({super.key});

  @override
  State<HotelScreen> createState() => _HotelScreenState();
}

class _HotelScreenState extends State<HotelScreen> {
  /// 예약 전 정보 확인 (Pre-booking information)
  static const List<_HotelInfoItem> _preBookingInfo = [
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightCalendarDays,
      title: '여행 시기와 지역 선택',
      description:
          '건기(12월~5월): 관광 성수기, 미리 예약 권장\n우기(6월~11월): 숙박비 저렴, 태풍 주의\n\n마닐라: 도시 관광, 쇼핑\n세부 막탄섬: 해양 액티비티\n보라카이: 휴양 리조트',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightMagnifyingGlassDollar,
      title: '가격 비교',
      description:
          '아고다(Agoda), 부킹닷컴(Booking.com), 트립닷컴(Trip.com) 등 OTA 활용\n스카이스캐너(Skyscanner) 비교 사이트에서 최저가 확인\n최종 금액(세금·수수료 포함) 반드시 확인',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightComments,
      title: '이용후기 확인',
      description:
          '실제 투숙객 후기 꼼꼼히 확인\n위생 상태, 소음, 직원 서비스 등 체크\n구글 지도 스트리트 뷰로 호텔 주변 환경 미리 확인',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치 및 교통',
      description:
          '마카티/BGC: 치안 양호, 편의시설 多, 가격↑\n말라테/에르미타: 저렴, 역사 유적지 인접\n파사이: 공항 근접, 대형 리조트 호텔\n\nGrab 앱 이용이 편리한 위치 권장',
    ),
  ];

  /// 호텔 선택 시 고려 사항 (Considerations when choosing a hotel)
  static const List<_HotelInfoItem> _hotelConsiderations = [
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightBed,
      title: '객실 구성과 인원',
      description:
          '침대 종류/개수가 일행 인원에 적합한지 확인\n더블베드, 트윈베드 구성 체크\n엑스트라 베드 추가 가능 여부 확인\n객실 크기, 전망, 층수 등 조건 사전 확인',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightWaterLadder,
      title: '부대시설 및 무료 서비스',
      description:
          '조식 포함 여부, 수영장/헬스장 시설\n와이파이 및 주차 서비스 확인\n공항 픽업/샌딩 셔틀 운영 여부\n리조트: 스노클링 장비 대여, 키즈클럽 등',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightPercent,
      title: '특별 할인 및 혜택',
      description:
          '카드사 해외결제 프로모션 확인\n항공사 제휴 호텔 할인\nOTA 앱 전용 할인쿠폰 활용\n\n필고(PhilGo) 회원 한정 최저가 예약 서비스\n공식 웹사이트 직접예약 혜택(업그레이드, 무료 조식 등)',
    ),
  ];

  /// 숙소 유형별 특징 (Accommodation types)
  static const List<_AccommodationType> _accommodationTypes = [
    _AccommodationType(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      name: '리조트',
      location: '🏖️ 해변 휴양지 또는 도심 리조트 단지',
      price: '약 15만 원 이상 (고급)',
      features: '수영장, 스파 등 부대시설 완비\n전용 해변이나 카지노 보유\n가족여행·휴양에 적합',
    ),
    _AccommodationType(
      icon: FontAwesomeIcons.lightBuilding,
      name: '시티 호텔',
      location: '🏙️ 도심 상업지구 (마카티/BGC 등)',
      price: '약 5~12만 원 (중급)',
      features: '3~5성급 일반 호텔\n교통 접근성 우수, 식당·쇼핑몰 인접\n비즈니스 출장, 도시 관광객에 적합',
    ),
    _AccommodationType(
      icon: FontAwesomeIcons.lightHouseChimney,
      name: '게스트하우스 (호스텔)',
      location: '🏡 도심 주택가, 관광지 인근',
      price: '약 2~5만 원 (저가)',
      features: '다인실 또는 소형 객실\n공용 욕실인 경우 多\n배낭여행객, 단기 체류에 적합',
    ),
  ];

  /// 추가 숙소 정보 (Additional accommodation info)
  static const List<_HotelInfoItem> _additionalAccommodation = [
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '저가 체인 호텔',
      description:
          '레드 플래닛(Red Planet), 홉 인 호텔(Hop Inn)\n고호텔(Go Hotels), 레드도어즈(RedDoorz)\n저렴한 가격에 깔끔한 객실 제공\n\n⚠️ 소고호텔(Hotel Sogo) 등은 시간제 이용 호텔로 가족 여행객에게 부적합',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightHouseBuilding,
      title: '콘도미니엄 임대',
      description:
          '마카티, 케손시티 등에서 Airbnb 이용 가능\n주방 시설과 넓은 공간 활용\n가족이나 장기 투숙객에 적합\n\n일일 청소, 24시간 프런트 서비스 제한적',
    ),
  ];

  /// 예약 및 결제 방법 (Booking and payment methods)
  static const List<_HotelInfoItem> _bookingPayment = [
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightLaptop,
      title: '예약 플랫폼 활용',
      description:
          '가격, 별등급, 후기 평점, 위치 필터링\n한글 지원 OTA 사이트 편리\n호텔스컴바인, 트리바고에서 최저가 재확인',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '공식 홈페이지 vs OTA',
      description:
          '공식 사이트: 무료 변경, 레이트 체크아웃, 공항픽업 등 추가 혜택\n직접예약이 항상 저렴하진 않음\n공식가와 OTA 가격 모두 비교 후 결정\n글로벌 체인: 멤버십 할인/포인트 적립',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '결제 방식',
      description:
          '사전 결제(선결제): 바로 카드 청구, 환율 변동 주의\n현지 결제(후불): 체크인 시 신용카드 제시 필요\n\n고급 호텔: 체크인 시 디포짓(보증금) 요구\n보증금은 퇴실 시 환불',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightRotateLeft,
      title: '취소·환불 규정',
      description:
          '저렴한 프로모션 = 비환불(non-refundable) 多\n일정 유동적이면 무료 취소 옵션 선택\n취소 기한(2~3일 전) 확인 필수\n환불 시 환율/수수료 차이 발생 가능',
    ),
  ];

  /// 입국 및 체크인 유의사항 (Entry and check-in notes)
  static const List<_HotelInfoItem> _entryCheckin = [
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightPassport,
      title: '입국 준비 서류',
      description:
          '한국 여권: 30일 무비자 입국\n여권 잔여 유효기간 6개월 이상 필수\n왕복 항공권 지참\n\n30일 초과 체류: 이민국(BI)에서 연장\neTravel 온라인 등록 필수 (출발 3일 전부터)',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightDoorOpen,
      title: '호텔 체크인 절차',
      description:
          '일반적으로 15시 체크인, 12시 체크아웃\n얼리 체크인/레이트 체크아웃 사전 요청 가능\n프런트에서 여권 제시 및 서류 작성\n\n룸 카드키, 조식 쿠폰 확인\n호텔 시설 이용 시간 안내 받기',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '안전 및 편의 수칙',
      description:
          '귀중품/여권: 객실 금고(세이프티 박스) 보관\n외출 시 많은 현금 소지 X\n관광지/시장: 소매치기 주의\n\n야간 이동: Grab 또는 호텔 공식 택시 이용\n야간 공항 도착: 호텔 픽업 또는 공항 인증 택시',
    ),
    _HotelInfoItem(
      icon: FontAwesomeIcons.lightLightbulb,
      title: '기타 여행 팁',
      description:
          '밤늦게 도착/새벽 출발: 공항 인근 호텔 예약\n도심 관광 목적: 마카티/BGC 숙소 권장\n\n섬 간 이동: 전날 항구/공항 근처 숙박\n긴급 연락처(대사관, 숙소 주소) 메모 필수',
    ),
  ];

  /// 출발 전 체크리스트 (Pre-departure checklist)
  static const List<String> _checklist = [
    '📅 여행 시기 확정 (건기/우기 고려)',
    '🔍 호텔 가격 비교 (최소 3개 사이트)',
    '⭐ 이용후기 및 평점 확인',
    '📍 위치 및 교통 접근성 검토',
    '🛏️ 객실 구성 및 인원 확인',
    '🏊 부대시설 및 서비스 체크',
    '💳 결제 방식 및 취소 규정 확인',
    '📄 eTravel 온라인 등록',
    '🛂 여권 유효기간 확인 (6개월 이상)',
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
            FaIcon(FontAwesomeIcons.lightHotel, size: 20, color: scheme.primary),
            SizedBox(width: sp.s8),
            Text('🇵🇭 ${l10n.housingHotel}'),
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

            /// [예약 전 정보 확인]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardList,
              title: '예약 전 정보 확인',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _preBookingInfo,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [호텔 선택 시 고려 사항]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleCheck,
              title: '호텔 선택 시 고려 사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _hotelConsiderations,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [숙소 유형별 특징]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuildings,
              title: '숙소 유형별 특징',
            ),
            SizedBox(height: sp.s12),
            _buildAccommodationTypes(context),

            SizedBox(height: sp.s16),
            _buildInfoCards(
              context,
              _additionalAccommodation,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [예약 및 결제 방법]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCreditCard,
              title: '예약 및 결제 방법',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _bookingPayment,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [필리핀 입국 및 체크인 유의사항]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPlaneArrival,
              title: '입국 및 체크인 유의사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _entryCheckin,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [호텔 예약 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListCheck,
              title: '호텔 예약 체크리스트',
            ),
            SizedBox(height: sp.s12),
            _buildChecklist(context),

            SizedBox(height: sp.s24),

            /// [도움말 배너]
            _buildHelpBanner(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 헤더 배너 빌드 (Build header banner)
  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightHotel,
                size: 24,
                color: scheme.onPrimaryContainer,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 호텔 예약 가이드',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 여행을 계획할 때 호텔 숙소 예약은 안전하고 편안한 여행의 필수 요소입니다. '
            '여행 목적과 예산에 맞는 최적의 숙소를 찾기 위해 사전 정보 조사가 중요합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Row(
            children: [
              _buildBannerChip(context, '✈️ 건기 12~5월'),
              SizedBox(width: sp.s8),
              _buildBannerChip(context, '🏨 다양한 숙소'),
              SizedBox(width: sp.s8),
              _buildBannerChip(context, '💰 가격 비교'),
            ],
          ),
        ],
      ),
    );
  }

  /// 배너 칩 빌드 (Build banner chip)
  Widget _buildBannerChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
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

  /// 숙소 유형 카드 빌드 (Build accommodation type cards)
  Widget _buildAccommodationTypes(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _accommodationTypes.map((type) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        type.icon,
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
                          type.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(height: sp.s4),
                        Text(
                          type.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer.withValues(alpha: 0.5),
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
                      type.price,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sp.s12),
              Text(
                type.features,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
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
    List<_HotelInfoItem> items,
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
                        height: 1.5,
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
                Text(item.substring(0, 2), style: const TextStyle(fontSize: 16)),
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

  /// 도움말 배너 빌드 (Build help banner)
  Widget _buildHelpBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 18,
                color: scheme.onTertiaryContainer,
              ),
              SizedBox(width: sp.s8),
              Text(
                '필고(PhilGo) 커뮤니티 활용하기',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 한인 커뮤니티 필고에서는 회원 한정으로 인기 호텔의 최저가 예약 서비스를 지원합니다. '
            '현지 정보와 실제 이용 후기를 참고하여 더 나은 숙소 선택이 가능합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onTertiaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Text(
            '✈️🏨🌴 사전 계획과 현지 정보를 활용하여 자신에게 꼭 맞는 호텔을 예약해 보세요!',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
