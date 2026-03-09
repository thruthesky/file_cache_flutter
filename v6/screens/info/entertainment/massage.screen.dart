import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 마사지 정보 아이템 데이터 클래스 (Massage Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _MassageInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _MassageInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 스파 정보 데이터 클래스 (Spa Info Data Class)
///
/// 스파 시설의 상세 정보를 담습니다.
/// Contains detailed information about spa facilities.
class _SpaInfo {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 스파 이름 (Spa name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 운영시간 (Operating hours)
  final String hours;

  /// 연락처 (Contact)
  final String contact;

  /// 이메일 (Email)
  final String email;

  /// 요금 정보 (Price info)
  final String priceInfo;

  /// 특징 (Features)
  final List<String> features;

  /// 이용 팁 (Usage tips)
  final List<String> tips;

  const _SpaInfo({
    required this.icon,
    required this.name,
    required this.location,
    required this.hours,
    required this.contact,
    required this.email,
    required this.priceInfo,
    required this.features,
    required this.tips,
  });
}

/// 절차 아이템 데이터 클래스 (Procedure Item Data Class)
///
/// 이용 절차의 순서, 내용, 포인트를 담습니다.
/// Contains order, content, and point for each procedure item.
class _ProcedureItem {
  /// 내용 (Content)
  final String content;

  /// 포인트 (Point)
  final String point;

  const _ProcedureItem({
    required this.content,
    required this.point,
  });
}

/// 서비스 유형 데이터 클래스 (Service Type Data Class)
///
/// 마사지/스파 서비스 형태 정보를 담습니다.
/// Contains massage/spa service type information.
class _ServiceType {
  /// 구분 (Category)
  final String category;

  /// 장소 (Place)
  final String place;

  /// 특징 (Features)
  final String features;

  /// 결제 (Payment)
  final String payment;

  const _ServiceType({
    required this.category,
    required this.place,
    required this.features,
    required this.payment,
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

/// 홈 마사지 채널 데이터 클래스 (Home Massage Channel Data Class)
class _HomeServiceChannel {
  /// 채널명 (Channel name)
  final String channel;

  /// 검색 키워드 (Search keywords)
  final String keywords;

  /// 확인 포인트 (Check points)
  final String checkPoints;

  const _HomeServiceChannel({
    required this.channel,
    required this.keywords,
    required this.checkPoints,
  });
}

/// 마사지 정보 화면 (Massage Screen)
///
/// 필리핀 마사지 관련 정보를 제공합니다.
/// Provides information about massage in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// MassageScreen.push(context);
/// ```
class MassageScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Massage';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const MassageScreen({super.key});

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> {
  /// 서비스 형태 데이터 (Service type data)
  static const List<_ServiceType> _serviceTypes = [
    _ServiceType(
      category: '스파(마사지샵)',
      place: '상가/빌딩',
      features: '마사지 중심, 시간 단위',
      payment: '현장 결제(현금/카드 여부 상이)',
    ),
    _ServiceType(
      category: '사우나·클럽형 스파',
      place: '대형 시설',
      features: '입장권+부대시설(사우나/탕/식음/휴식)',
      payment: '입장권+추가 서비스',
    ),
    _ServiceType(
      category: '홈 마사지(출장)',
      place: '집/콘도/호텔',
      features: '이동 없이 이용, 예약 필수',
      payment: '현금/이체/링크 결제 등 업체별',
    ),
  ];

  /// 당일 이용 절차 데이터 (Day use procedure data)
  static const List<_ProcedureItem> _procedures = [
    _ProcedureItem(content: '찾기', point: 'Google 지도 / Facebook 페이지 / 공식 웹사이트 확인'),
    _ProcedureItem(content: '확인', point: '주소·시간·연락처·요금·예약 방식(전화/메신저) 확인'),
    _ProcedureItem(content: '예약', point: '당일 가능 여부, 인원, 시간, 원하는 마사지(60/90/120분) 전달'),
    _ProcedureItem(content: '방문/체크인', point: '신분증 요구 가능(회원/입장권 타입에 따라 상이)'),
    _ProcedureItem(content: '서비스', point: '강도(약/중/강), 집중 부위, 금기(통증/부상) 전달'),
    _ProcedureItem(content: '결제', point: '입장권/패키지/추가 옵션 정산, 영수증 요청 가능'),
    _ProcedureItem(content: '팁', point: '필수는 아니나, 만족 시 소액 또는 일정 비율을 별도로 제공하는 관행'),
  ];

  /// 라세마 스파 정보 (Lasema Spa info)
  static const _SpaInfo _lasemaSpa = _SpaInfo(
    icon: FontAwesomeIcons.lightHotTubPerson,
    name: 'NEW Lasema Spa (라세마)',
    location: 'Makati, 8846 Sampaloc St. cor. Estrella St. (San Antonio Village)',
    hours: '24시간',
    contact: '0995-783-0094 / 0995-871-7389 / 8830-2222',
    email: 'lasema.reservation@gmail.com',
    priceInfo: '패키지/요일별 상이 (500~1,688페소대 패키지)',
    features: ['한국식 찜질방', '24시간 운영', '자쿠지/사우나', '패키지 포함 마사지'],
    tips: [
      '"입장권만"인지 "마사지 포함 패키지"인지 먼저 구분하여 문의',
      '체류 시간 제한(패키지별 최대 이용 시간) 체크인 시 확인',
      '주말/공휴일은 가격이 달라질 수 있으므로 요일을 명확히 전달',
    ],
  );

  /// 야타이 스파 정보 (Yatai Spa info)
  static const _SpaInfo _yataiSpa = _SpaInfo(
    icon: FontAwesomeIcons.lightBuilding,
    name: 'Yatai Spa (야타이스파)',
    location: 'Pasay, Newport City 권역 (Plaza 66 Building / Manlunas St.)',
    hours: '24시간 운영 안내 사례 있음 (시기별 변동 가능)',
    contact: '+63 936 810 3121',
    email: 'yataispa.marketing@gmail.com',
    priceInfo: '약 1,896~3,500페소 구간 (패키지별 상이)',
    features: ['고급형 스파', '빌딩 내 다층 시설', '개별 룸', '부대시설/식음'],
    tips: [
      '"마사지(시간)"과 "입장(시설 이용)"이 분리되는 구조인지 먼저 확인',
      '예약 필요 여부(특히 커플룸/프라이빗룸/숙박형 룸 포함) 전화 또는 메신저로 확인',
      '위치 표기가 여러 형태로 유통되므로, 정확한 빌딩명/층/출입구를 메시지로 받아두기',
    ],
  );

  /// 루오시티 스파 정보 (Luo City Spa info)
  static const _SpaInfo _luoSpa = _SpaInfo(
    icon: FontAwesomeIcons.lightMoon,
    name: 'Luo City Spa Club (루오시티스파)',
    location: 'Esplanade Seaside Terminal, Seaside Blvd, MOA Complex, Pasay',
    hours: '15:00~04:00 (공식 FAQ 기준)',
    contact: '+63 999 816 8888',
    email: 'info@luospa.com',
    priceInfo: '입장권 3,000페소 (2025년 10월부터)',
    features: ['MOA Complex 위치', '야간 운영', '프로모션 다양', '여성 전용 요일 할인'],
    tips: [
      '"입장권(기본)" + "체험/마사지(추가)" 구조인 경우가 많으므로, 총비용 먼저 확인',
      '운영시간이 야간 중심이므로, 출발 전 마지막 입장 가능 시간 문의',
      '프로모션은 요일·조건이 붙는 경우가 많으므로, "오늘 날짜/요일"을 명시해 적용 가능 여부 확인',
    ],
  );

  /// 홈 마사지 검색 채널 데이터 (Home massage search channel data)
  static const List<_HomeServiceChannel> _homeServiceChannels = [
    _HomeServiceChannel(
      channel: 'Facebook',
      keywords: '"Home Service Massage + 지역(Manila/Makati/BGC/Cebu)"',
      checkPoints: '페이지 생성일/후기/응답 속도/고정 공지',
    ),
    _HomeServiceChannel(
      channel: 'Google 지도',
      keywords: '"Home service massage" / "mobile spa"',
      checkPoints: '사업장 정보·리뷰·연락처 일치 여부',
    ),
    _HomeServiceChannel(
      channel: '웹사이트',
      keywords: '"home service massage"',
      checkPoints: '예약 버튼(메신저/폼), 가격/지역/시간',
    ),
    _HomeServiceChannel(
      channel: '메신저',
      keywords: 'Messenger / Viber / Telegram',
      checkPoints: '공식 계정인지(페이지 연결/고정글) 확인',
    ),
  ];

  /// 홈 마사지 예약 정보 항목 (Home massage booking info items)
  static const List<_MassageInfoItem> _homeBookingItems = [
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치',
      description: '콘도/호텔명 + 동/층/호수 + 출입 방법',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '날짜·시간',
      description: '"오늘 8PM, 90분 2명"',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightHandSparkles,
      title: '서비스',
      description: '스웨디시/딥티슈/아로마/발마사지 등',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightGauge,
      title: '강도/금기',
      description: '약/중/강, 통증 부위, 임신/부상 등',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '결제',
      description: '현금/이체/카드 링크 가능 여부',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightBriefcase,
      title: '장비',
      description: '베드/오일/타월 지참 여부(업체별 상이)',
    ),
  ];

  /// 안전 체크리스트 데이터 (Safety checklist data)
  static const List<_MassageInfoItem> _safetyChecklist = [
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '공식 채널',
      description: '페이지/웹사이트/고정 공지에 있는 연락처로만 예약',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightMoneyBillTransfer,
      title: '선결제',
      description: '과도한 선결제 요구 시 주의(정상 업체는 조건을 명확히 고지)',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '신원 확인',
      description: '도착 시 이름/예약번호 확인, 필요 시 ID 확인 요청',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightCameraSlash,
      title: '촬영/녹음',
      description: '상대 동의 없이 진행 금지(분쟁 소지)',
    ),
    _MassageInfoItem(
      icon: FontAwesomeIcons.lightBan,
      title: '취소 규정',
      description: '당일 취소 수수료 여부를 사전에 확인',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: 'New Lasema Spa 소개(주소/연락처/24시간/패키지)',
      url: 'https://primer.com.ph/beauty-fashion/new-lasema-spa/',
    ),
    _ReferenceUrl(
      title: 'New Lasema Spa 페이스북/연락 정보',
      url: 'https://www.findglocal.com/PH/Makati/749553131897584/New-Lasema-Spa',
    ),
    _ReferenceUrl(
      title: 'Yatai Spa 공식/홍보 사이트',
      url: 'https://yataispamarketing.wixsite.com/website',
    ),
    _ReferenceUrl(
      title: 'Yatai Luxury Spa(주소/연락/공지)',
      url: 'https://www.findhealthclinics.com/PH/Pasay-City/101378381303019/Yatai-Luxury-Spa',
    ),
    _ReferenceUrl(
      title: 'Yatai Spa 정보(가격 범위 등)',
      url: 'https://www.manilatouch.com/spa/yatai-spa/',
    ),
    _ReferenceUrl(
      title: 'Luo City Spa 공식 FAQ',
      url: 'https://www.luospa.com/faq-manila-spa',
    ),
    _ReferenceUrl(
      title: 'Luo City Spa 입장권 공지(2025년 10월)',
      url: 'https://www.luospa.com/dear-customer-luo-city-spa-new-ticket-price-and-exciting-updates-',
    ),
    _ReferenceUrl(
      title: '필리핀 팁 문화(스파 포함)',
      url: 'https://www.newportworldresorts.com/blog-articles/tipping-philippines-guide-travelers',
    ),
    _ReferenceUrl(
      title: 'DOH 마사지 치료사/시설 규정(AO 2010-0034)',
      url: 'https://remnant-institute.com/uploads/2/0/4/0/2040875/ao_2010-0034.pdf',
    ),
    _ReferenceUrl(
      title: '홈 마사지 업체 예시(예약 버튼/안내)',
      url: 'https://healerstouch.ph/home-service-massage/',
    ),
    _ReferenceUrl(
      title: '모바일 스파 준비 팁(수건/침대 등)',
      url: 'https://bluetranquilityspa.com/',
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
              FontAwesomeIcons.lightSpa,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentMassage,
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

            /// [1. 서비스 형태]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListUl,
              title: '필리핀 마사지·SPA 서비스 형태',
              emoji: '💆',
            ),
            SizedBox(height: sp.s12),
            _buildServiceTypeTable(context),
            SizedBox(height: sp.s24),

            /// [2. 당일 이용 절차]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListCheck,
              title: '당일(1회) 이용 절차 요약',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildProcedureTimeline(context),
            SizedBox(height: sp.s16),
            _buildTipInfo(context),
            SizedBox(height: sp.s24),

            /// [3. 제도·면허 관련]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFileContract,
              title: '제도·면허 관련 핵심 (이용자 관점)',
              emoji: '📌',
            ),
            SizedBox(height: sp.s12),
            _buildLicenseInfo(context),
            SizedBox(height: sp.s24),

            /// [4. 라세마 스파]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHotTubPerson,
              title: '라세마 (NEW Lasema Spa)',
              emoji: '♨️',
            ),
            SizedBox(height: sp.s12),
            _buildSpaCard(context, _lasemaSpa, Colors.pink),
            SizedBox(height: sp.s24),

            /// [5. 야타이 스파]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuilding,
              title: '야타이스파 (Yatai Spa)',
              emoji: '🏙️',
            ),
            SizedBox(height: sp.s12),
            _buildSpaCard(context, _yataiSpa, Colors.indigo),
            SizedBox(height: sp.s24),

            /// [6. 루오시티 스파]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMoon,
              title: '루오시티스파 (Luo City Spa)',
              emoji: '🌃',
            ),
            SizedBox(height: sp.s12),
            _buildSpaCard(context, _luoSpa, Colors.purple),
            SizedBox(height: sp.s24),

            /// [7. 홈 마사지 이용 방법]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHouse,
              title: '홈 마사지(출장 마사지) 이용 방법',
              emoji: '🏠',
            ),
            SizedBox(height: sp.s12),
            _buildHomeServiceSection(context),
            SizedBox(height: sp.s24),

            /// [8. 안전·분쟁 예방 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldHalved,
              title: '안전·분쟁 예방 체크리스트',
              emoji: '⚠️',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _safetyChecklist,
              scheme.errorContainer.withValues(alpha: 0.5),
              scheme.error,
            ),
            SizedBox(height: sp.s24),

            /// [9. 한국인용 간추림]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBolt,
              title: "한국인이 '쉽게 이용'하기 위한 간추림",
              emoji: '🧾',
            ),
            SizedBox(height: sp.s12),
            _buildQuickSummary(context),
            SizedBox(height: sp.s24),

            /// [10. 참고 URL]
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
            Colors.purple.withValues(alpha: 0.2),
            Colors.pink.withValues(alpha: 0.1),
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
                FontAwesomeIcons.lightSpa,
                size: 24,
                color: Colors.purple,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 마사지·SPA 이용 가이드',
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
            '필리핀에서 당일/1회 마사지·스파 이용을 원하는 한국어 사용자를 위한 안내입니다. '
            '현장 방문형(스파/사우나) 또는 홈 서비스(출장 마사지)로 구분하여 이용할 수 있습니다.',
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
                    '요금·시간은 공지/프로모션에 따라 변동될 수 있으므로, 방문 전 연락으로 재확인이 필요합니다.',
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

  /// 서비스 형태 테이블 빌드 (Service type table build)
  Widget _buildServiceTypeTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
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
                  flex: 2,
                  child: Text(
                    '장소',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '특징',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 바디 (Table body)
          ...List.generate(_serviceTypes.length, (index) {
            final item = _serviceTypes[index];
            final isLast = index == _serviceTypes.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.place,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.features,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

  /// 이용 절차 타임라인 빌드 (Procedure timeline build)
  Widget _buildProcedureTimeline(BuildContext context) {
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
        children: _procedures.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _procedures.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 타임라인 인디케이터 (Timeline indicator)
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: scheme.outlineVariant,
                    ),
                ],
              ),
              SizedBox(width: sp.s12),

              /// 절차 내용 (Procedure content)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${item.content}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        item.point,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
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

  /// 팁 정보 빌드 (Tip info build)
  Widget _buildTipInfo(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCoins,
                size: 16,
                color: Colors.amber.shade700,
              ),
              SizedBox(width: sp.s8),
              Text(
                '💵 팁(Gratuity) 기준 (실무형)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          _buildTipBullet(context, '서비스 차지(예: 10%)가 이미 포함된 경우 추가 팁이 필요하지 않은 경우가 있음'),
          _buildTipBullet(context, '스파/살롱 분야는 만족 시 50~100페소 또는 총액의 약 10%를 별도로 제공하는 안내가 널리 사용됨'),
          _buildTipBullet(context, '팁은 조용히, 직접 전달하는 방식이 일반적'),
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

  /// 면허 정보 빌드 (License info build)
  Widget _buildLicenseInfo(BuildContext context) {
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
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  'DOH(필리핀 보건당국) 마사지 치료사 제도',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Text(
            'Licensed Massage Therapist(LMT)는 면허와 등록증(COR)을 보유한 자로 정의됩니다. '
            '또한 시설 위생·건강검진(Health Certificate) 등 위생 기준을 규정으로 두고 있습니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Text(
            '이용자가 확인하면 좋은 항목',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildCheckItem(context, '(가능하면) 테라피스트 자격/교육 여부, 또는 업체가 면허/위생 기준을 준수하는지 문의'),
          _buildCheckItem(context, '시설형 스파는 대체로 지방정부(LGU) 사업 허가(비즈니스 퍼밋) 체계 아래 운영됨(도시별 절차 상이)'),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💡 위 내용은 "이용자가 직접 면허를 신청"하는 절차가 아니라, 합법·정상 영업 여부를 확인하기 위한 최소 체크포인트로 이해하면 됩니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 체크 아이템 빌드 (Check item build)
  Widget _buildCheckItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleCheck,
            size: 12,
            color: scheme.primary,
          ),
          SizedBox(width: sp.s8),
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

  /// 스파 카드 빌드 (Spa card build)
  Widget _buildSpaCard(BuildContext context, _SpaInfo spa, Color accentColor) {
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
        children: [
          /// 스파 헤더 (Spa header)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(spa.icon, size: 20, color: accentColor),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spa.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Wrap(
                      spacing: sp.s4,
                      runSpacing: sp.s4,
                      children: spa.features.map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            feature,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accentColor,
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
          SizedBox(height: sp.s16),

          /// 스파 상세 정보 (Spa details)
          _buildSpaInfoRow(context, FontAwesomeIcons.lightLocationDot, '위치', spa.location),
          _buildSpaInfoRow(context, FontAwesomeIcons.lightClock, '시간', spa.hours),
          _buildSpaInfoRow(context, FontAwesomeIcons.lightPhone, '연락처', spa.contact),
          _buildSpaInfoRow(context, FontAwesomeIcons.lightEnvelope, '이메일', spa.email),
          _buildSpaInfoRow(context, FontAwesomeIcons.lightMoneyBill, '요금', spa.priceInfo),
          SizedBox(height: sp.s12),

          /// 당일 이용 팁 (Day use tips)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightLightbulb,
                      size: 14,
                      color: accentColor,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '💡 당일 이용 팁',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),
                ...spa.tips.map((tip) => Padding(
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
                              tip,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 스파 정보 행 빌드 (Spa info row build)
  Widget _buildSpaInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 14, color: scheme.primary),
          SizedBox(width: sp.s8),
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 홈 서비스 섹션 빌드 (Home service section build)
  Widget _buildHomeServiceSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 소개 (Introduction)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '필리핀 홈 마사지(Home Service Massage)는 Facebook 페이지(메신저), 공식 웹사이트 예약, '
            '또는 메신저/전화를 통해 접수되는 경우가 많습니다. 일부 업체는 "필요 장비를 지참해 방문"한다고 안내합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: sp.s16),

        /// 찾는 방법 (Search methods)
        Text(
          '📱 찾는 방법 (인터넷·페이스북 중심)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: sp.s8),
        _buildHomeServiceChannelTable(context),
        SizedBox(height: sp.s16),

        /// 예약 시 전달해야 할 정보 (Booking info)
        Text(
          '📝 예약 시 전달해야 할 정보 (필수)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: sp.s8),
        _buildInfoCards(
          context,
          _homeBookingItems,
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
        SizedBox(height: sp.s16),

        /// 예약 메시지 예시 (Sample message)
        _buildSampleMessage(context),
        SizedBox(height: sp.s16),

        /// 이용 준비 (Preparation)
        Text(
          '🛁 이용 준비 (현장 품질을 좌우하는 항목)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: sp.s8),
        _buildPreparationInfo(context),
      ],
    );
  }

  /// 홈 서비스 채널 테이블 빌드 (Home service channel table build)
  Widget _buildHomeServiceChannelTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '채널',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '검색 키워드',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '확인 포인트',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 바디 (Table body)
          ...List.generate(_homeServiceChannels.length, (index) {
            final item = _homeServiceChannels[index];
            final isLast = index == _homeServiceChannels.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.channel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.tertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.keywords,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.checkPoints,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
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

  /// 예약 메시지 샘플 빌드 (Sample message build)
  Widget _buildSampleMessage(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightEnvelope,
                size: 16,
                color: scheme.tertiary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '📧 메시지 예시 (영문, 복사 용도)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              'Hi. I\'d like to book a home service massage today.\n'
              'Location: (condo/hotel, room)\n'
              'Time: 8:00 PM\n'
              'Duration: 90 minutes\n'
              'Number of persons: 1\n'
              'Preferred massage: Swedish\n'
              'Please confirm the total price and payment method.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 이용 준비 정보 빌드 (Preparation info build)
  Widget _buildPreparationInfo(BuildContext context) {
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
        children: [
          _buildPrepBullet(context, '샤워 후 이용을 권장하는 안내가 있으며, 수건(세탁 가능한 큰 타월) 준비를 안내하는 업체도 있음'),
          _buildPrepBullet(context, '침대/매트리스가 지나치게 푹신하면 압이 분산될 수 있어, 비교적 단단한 면에서 진행하는 것이 좋다는 안내가 있음'),
          _buildPrepBullet(context, '콘도/호텔의 보안 규정상 방문객 등록이 필요한 경우가 있으므로, 프런트/가드 정책을 사전에 확인'),
        ],
      ),
    );
  }

  /// 준비 불릿 빌드 (Prep bullet build)
  Widget _buildPrepBullet(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleCheck,
            size: 12,
            color: scheme.primary,
          ),
          SizedBox(width: sp.s8),
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

  /// 정보 카드 빌드 (Info cards build)
  Widget _buildInfoCards(
    BuildContext context,
    List<_MassageInfoItem> items,
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

  /// 빠른 요약 빌드 (Quick summary build)
  Widget _buildQuickSummary(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 당일 스파(방문형) 요약 (Day spa summary)
        Container(
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
                  FaIcon(
                    FontAwesomeIcons.lightSpa,
                    size: 16,
                    color: Colors.purple,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '🏢 당일 스파(방문형) 3줄 요약',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              _buildQuickStep(context, '1', 'Google 지도 + Facebook에서 주소·시간·연락처를 먼저 확정'),
              _buildQuickStep(context, '2', '오늘 가능한 시간/인원/패키지(입장 vs 마사지 포함)를 메시지로 확인'),
              _buildQuickStep(context, '3', '결제 전 총액(입장+추가)과 프로모 적용 조건을 문장으로 받아두기'),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 홈 마사지 요약 (Home massage summary)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightHouse,
                    size: 16,
                    color: Colors.teal,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '🏠 홈 마사지 3줄 요약',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              _buildQuickStep(context, '1', 'Facebook에서 "Home Service Massage + 지역"으로 찾고, 공식 페이지/웹사이트로 이동'),
              _buildQuickStep(context, '2', '위치·시간·인원·코스·결제를 한 번에 보내고, 총액/도착 시간 확인'),
              _buildQuickStep(context, '3', '방문자 등록(콘도/호텔)과 수건·샤워 등 현장 준비 마치기'),
            ],
          ),
        ),
      ],
    );
  }

  /// 빠른 단계 빌드 (Quick step build)
  Widget _buildQuickStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
