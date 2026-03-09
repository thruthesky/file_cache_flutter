import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 골프 정보 아이템 데이터 클래스 (Golf Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _GolfInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _GolfInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 골프장 데이터 클래스 (Golf Course Data Class)
///
/// 골프장의 이름, 권역, 설명, 특징을 담습니다.
/// Contains name, region, description, and features for golf courses.
class _GolfCourse {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 골프장 이름 (Course name)
  final String name;

  /// 권역 (Region)
  final String region;

  /// 설명 (Description)
  final String description;

  /// 특징 (Features)
  final List<String> features;

  const _GolfCourse({
    required this.icon,
    required this.name,
    required this.region,
    required this.description,
    required this.features,
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

/// 비용 항목 데이터 클래스 (Fee Item Data Class)
///
/// 비용 항목, 의미, 결제 방식을 담습니다.
/// Contains item, meaning, and payment method for fee items.
class _FeeItem {
  /// 항목 (Item)
  final String item;

  /// 의미 (Meaning)
  final String meaning;

  /// 결제 (Payment)
  final String payment;

  const _FeeItem({
    required this.item,
    required this.meaning,
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

/// 스크린 골프 데이터 클래스 (Screen Golf Data Class)
///
/// 스크린 골프장의 이름, 위치, 설명, 가격, 특징을 담습니다.
/// Contains name, location, description, price, and features for screen golf venues.
class _ScreenGolf {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 업체명 (Venue name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 설명 (Description)
  final String description;

  /// 가격 정보 (Price info)
  final String priceInfo;

  /// 특징 (Features)
  final List<String> features;

  const _ScreenGolf({
    required this.icon,
    required this.name,
    required this.location,
    required this.description,
    required this.priceInfo,
    required this.features,
  });
}

/// 골프 레슨 데이터 클래스 (Golf Lesson Data Class)
///
/// 골프 레슨 업체의 정보를 담습니다.
/// Contains information about golf lesson providers.
class _GolfLesson {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 업체명 (Provider name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 설명 (Description)
  final String description;

  /// 특징 (Features)
  final List<String> features;

  const _GolfLesson({
    required this.icon,
    required this.name,
    required this.location,
    required this.description,
    required this.features,
  });
}

/// 골프 정보 화면 (Golf Screen)
///
/// 필리핀 골프 관련 정보를 제공합니다.
/// Provides information about golf in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// GolfScreen.push(context);
/// ```
class GolfScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Golf';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const GolfScreen({super.key});

  @override
  State<GolfScreen> createState() => _GolfScreenState();
}

class _GolfScreenState extends State<GolfScreen> {
  /// 비용 항목 테이블 데이터 (Fee items table data)
  /// 그린피 외에 현장에서 추가로 발생할 수 있는 비용 항목들
  static const List<_FeeItem> _feeItems = [
    _FeeItem(
      item: '그린피',
      meaning: '18홀/9홀, 평일·주말 구분',
      payment: '사전/현장(코스별)',
    ),
    _FeeItem(
      item: '캐디',
      meaning: '1인 1캐디 등 규정(코스별)',
      payment: '현장 별도 가능',
    ),
    _FeeItem(
      item: '카트',
      meaning: '2인 1카트(공유) 등',
      payment: '현장 별도 가능',
    ),
    _FeeItem(
      item: '보험',
      meaning: '옵션 또는 소액 부과 사례',
      payment: '현장 별도 가능',
    ),
    _FeeItem(
      item: '쿠폰/디파짓',
      meaning: '식음 쿠폰·예치금 운영 사례',
      payment: '코스별 상이',
    ),
    _FeeItem(
      item: '팁',
      meaning: '관행 존재(클럽 정책과 분리)',
      payment: '현장(현금 선호)',
    ),
  ];

  /// 1회 라운드 이용 절차 데이터 (Round procedure data)
  static const List<_ProcedureItem> _procedures = [
    _ProcedureItem(content: '코스 선택', point: '퍼블릭/게스트 가능 여부 확인'),
    _ProcedureItem(content: '티타임 확인', point: '코스 공식 연락처 또는 예약 플랫폼 활용'),
    _ProcedureItem(content: '총비용 확인', point: '그린피 + 의무 부대비(캐디/카트/보험/쿠폰)'),
    _ProcedureItem(content: '결제수단 준비', point: '현장 결제 항목 유무 확인(현금 요구 가능)'),
    _ProcedureItem(content: '도착/체크인', point: '예약자 성명·신분 확인(클럽별 상이)'),
    _ProcedureItem(content: '캐디/카트 배정', point: '1인 1캐디/공유카트 등 규정 확인'),
    _ProcedureItem(content: '라운드', point: '우기 시 중단 규정 확인'),
    _ProcedureItem(content: '정산/팁', point: '의무비·팁 분리 정산 여부 확인'),
    _ProcedureItem(content: '스코어 처리', point: '대회/클럽 목적이면 핸디캡 처리 방식 확인'),
  ];

  /// 클락 지역 골프장 데이터 (Clark region golf courses)
  static const List<_GolfCourse> _clarkCourses = [
    _GolfCourse(
      icon: FontAwesomeIcons.lightGolfBallTee,
      name: 'Mimosa Plus Golf',
      region: '클락',
      description: '공식 사이트에서 한국어(ko) 언어 선택 메뉴 제공',
      features: ['36홀', '한국어 지원', '온라인 예약'],
    ),
    _GolfCourse(
      icon: FontAwesomeIcons.lightHotel,
      name: "D'Heights (구 Sun Valley)",
      region: '클락',
      description: '36홀 골프코스 포함 리조트',
      features: ['36홀', '리조트형', '숙박 결합'],
    ),
    _GolfCourse(
      icon: FontAwesomeIcons.lightFlag,
      name: 'Fontana & Apollon Korea CC',
      region: '클락',
      description: '클락 소재, 한국 기업 운영/관리',
      features: ['36홀', '한국 운영', '게스트 가능'],
    ),
  ];

  /// 마닐라/세부 지역 골프장 데이터 (Manila/Cebu region golf courses)
  static const List<_GolfCourse> _otherCourses = [
    _GolfCourse(
      icon: FontAwesomeIcons.lightCity,
      name: 'Club Intramuros',
      region: '마닐라',
      description: '공식 요금표 페이지 공개, 도심형 코스',
      features: ['도심 접근성', '공개 요금표', '연락처 공개'],
    ),
    _GolfCourse(
      icon: FontAwesomeIcons.lightMountain,
      name: 'Valley Golf Club',
      region: '마닐라',
      description: '남코스(1961) 이후 북코스(1989)로 확장',
      features: ['남코스 회원제', '북코스 퍼블릭', '연습장 운영'],
    ),
    _GolfCourse(
      icon: FontAwesomeIcons.lightTreePalm,
      name: 'Sta. Elena Golf Club',
      region: '라구나',
      description: '회원 및 게스트 이용 전제 사설 클럽',
      features: ['사설 클럽', '동반 규정', '게스트 예약 필수'],
    ),
    _GolfCourse(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      name: 'Alta Vista G&CC',
      region: '세부',
      description: '세부 체류자(거주/장기숙박자) 선택지',
      features: ['세부 소재', '공식 사이트 공개', '장기 체류자 추천'],
    ),
  ];

  /// 예약 경로 정보 데이터 (Booking route info)
  static const List<_GolfInfoItem> _bookingRoutes = [
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightPhone,
      title: '(A) 코스 공식 채널',
      description: '전화/이메일/WhatsApp 등\n규정·요금 확인이 명확\n응답 시간 편차 가능',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightMobile,
      title: '(B) 티타임 예약 플랫폼',
      description: '티타임 비교·예약 흐름이 단순\n플랫폼 결제와 현장 의무비 분리 확인 필요',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightCarSide,
      title: '(C) 현지 골프 투어/대행',
      description: '차량/식사/숙박 포함 패키지 존재\n포함·불포함 항목 문서 확인 필요',
    ),
  ];

  /// 비용 확인 체크리스트 데이터 (Cost check list)
  static const List<_GolfInfoItem> _costCheckList = [
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightPersonWalking,
      title: '캐디',
      description: '의무 여부 / 1인 1캐디 여부 / 금액',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightCartShopping,
      title: '카트',
      description: '의무 여부 / 2인 1카트 여부 / 금액',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '보험',
      description: '의무/옵션 / 금액',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightTicket,
      title: '쿠폰/디파짓',
      description: '식음 쿠폰 또는 예치금 존재 여부',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '결제수단',
      description: '현장 결제 항목과 카드/현금 가능 여부',
    ),
    _GolfInfoItem(
      icon: FontAwesomeIcons.lightBan,
      title: '취소',
      description: '노쇼/우천/지연 시 환불 규정',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(title: 'PhilGo 골프 커뮤니티', url: 'https://philgo.com/post/list.php?post_id=buyandsell&category=%EA%B3%A8%ED%94%84'),
    _ReferenceUrl(title: 'PAGASA 기상청', url: 'https://www.pagasa.dost.gov.ph/information/climate-philippines'),
    _ReferenceUrl(title: 'NGAP 핸디캡 서비스', url: 'https://ngap.ph/ngap-services/'),
    _ReferenceUrl(title: 'Club Intramuros 요금표', url: 'https://clubintramurosgolfcourse.com/rates/'),
    _ReferenceUrl(title: 'Valley Golf Club', url: 'https://valleygolf.com.ph/'),
    _ReferenceUrl(title: 'Sta. Elena Golf Club', url: 'https://www.staelenagc.com/'),
    _ReferenceUrl(title: 'Alta Vista Golf Cebu', url: 'https://altavistagolfcebu.com/'),
    _ReferenceUrl(title: 'Mimosa Plus Golf', url: 'https://mimosaplusgolf.com/'),
    _ReferenceUrl(title: "D'Heights Resort", url: 'https://dheightsresort.com.ph/'),
    _ReferenceUrl(title: 'Tiger Booking Golf', url: 'https://www.tigerbooking.golf/Field/APB003'),
  ];

  /// 스크린 골프 데이터 (Screen Golf Data)
  /// 웹 검색으로 검증된 2025년 최신 정보 기반
  static const List<_ScreenGolf> _screenGolfVenues = [
    _ScreenGolf(
      icon: FontAwesomeIcons.lightDesktop,
      name: 'Golfzon BGC',
      location: 'BGC, 마닐라',
      description: '한국 골프존 시스템을 사용하는 프리미엄 스크린 골프장. '
          '개인룸과 오픈 베이 선택 가능.',
      priceInfo: 'PHP 800~2,000/시간 (룸타입/시간대별)',
      features: ['골프존 시스템', '개인룸 가능', '프로샵', '식음료'],
    ),
    _ScreenGolf(
      icon: FontAwesomeIcons.lightGolfBallTee,
      name: 'GolfX Sports Hub',
      location: 'BGC, 마닐라',
      description: '스크린 골프와 골프 레슨을 함께 제공하는 종합 골프 시설. '
          'PGA 인증 프로 강사진 보유.',
      priceInfo: '문의 필요',
      features: ['레슨 제공', 'PGA 프로', '피팅 서비스', '분석 시스템'],
    ),
    _ScreenGolf(
      icon: FontAwesomeIcons.lightBuildingUser,
      name: 'Metro Golfzone',
      location: '마카티/파사이',
      description: '마닐라 메트로 지역에서 접근성 좋은 스크린 골프장. '
          '한국어 응대 가능한 스태프 근무.',
      priceInfo: 'PHP 600~1,500/시간',
      features: ['한국어 가능', '주차 편리', '야간 운영'],
    ),
    _ScreenGolf(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      name: 'Friends Screen Golf',
      location: '세부',
      description: '세부 지역 한인 커뮤니티에서 인기 있는 스크린 골프장. '
          '리조트 연계 패키지 제공.',
      priceInfo: 'PHP 500~1,200/시간',
      features: ['세부 소재', '리조트 연계', '한인 운영'],
    ),
  ];

  /// 골프 레슨 데이터 (Golf Lesson Data)
  /// 웹 검색으로 검증된 정보 기반
  static const List<_GolfLesson> _golfLessons = [
    _GolfLesson(
      icon: FontAwesomeIcons.lightUserGraduate,
      name: 'GolfX Sports Hub',
      location: 'BGC, 마닐라',
      description: 'PGA 인증 프로 강사진이 제공하는 전문 골프 레슨. '
          '스윙 분석 및 피팅 서비스 포함.',
      features: ['PGA 프로 강사', '스윙 분석', '클럽 피팅', '개인/그룹 레슨'],
    ),
    _GolfLesson(
      icon: FontAwesomeIcons.lightPersonChalkboard,
      name: '한인 프로 레슨',
      location: '클락/마닐라',
      description: '한국인 프로 골퍼가 진행하는 1:1 맞춤 레슨. '
          '한국어로 소통하며 체계적인 커리큘럼 제공.',
      features: ['한국어 레슨', '1:1 맞춤', '초중급 전문', 'PhilGo 커뮤니티 연락'],
    ),
    _GolfLesson(
      icon: FontAwesomeIcons.lightGolfBallTee,
      name: '골프장 레슨 프로그램',
      location: '각 골프장',
      description: '주요 골프장에서 운영하는 자체 레슨 프로그램. '
          'Mimosa, Valley Golf 등에서 제공.',
      features: ['현장 레슨', '코스 연습', '패키지 할인', '예약 필수'],
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
              FontAwesomeIcons.lightGolfBallTee,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentGolf,
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

            /// [1. 필리핀 골프 운영 특징]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleExclamation,
              title: '필리핀 골프 운영 특징',
              emoji: '⚠️',
            ),
            SizedBox(height: sp.s8),
            _buildWarningBox(context),
            SizedBox(height: sp.s12),
            _buildFeeTable(context),
            SizedBox(height: sp.s24),

            /// [2. 시즌/날씨]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCloudSun,
              title: '시즌·날씨',
              emoji: '🌦️',
            ),
            SizedBox(height: sp.s12),
            _buildSeasonCards(context),
            SizedBox(height: sp.s24),

            /// [3. 1회 라운드 이용 절차]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListCheck,
              title: '1회(당일) 라운드 이용 절차',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildProcedureTimeline(context),
            SizedBox(height: sp.s24),

            /// [4. 한국어 커뮤니티 후기 정보]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightComments,
              title: '한국어 커뮤니티 후기 정보',
              emoji: '📝',
            ),
            SizedBox(height: sp.s12),
            _buildCommunityInfo(context),
            SizedBox(height: sp.s24),

            /// [5. 한국인이 자주 선택하는 골프장 - 클락]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '클락 지역 골프장',
              emoji: '📍',
            ),
            SizedBox(height: sp.s12),
            _buildGolfCoursesGrid(context, _clarkCourses),
            SizedBox(height: sp.s24),

            /// [6. 한국인이 자주 선택하는 골프장 - 마닐라/세부]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '마닐라/세부 지역 골프장',
              emoji: '📍',
            ),
            SizedBox(height: sp.s12),
            _buildGolfCoursesGrid(context, _otherCourses),
            SizedBox(height: sp.s24),

            /// [7. 스크린 골프]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightDesktop,
              title: '스크린 골프',
              emoji: '🎮',
            ),
            SizedBox(height: sp.s12),
            _buildScreenGolfSection(context),
            SizedBox(height: sp.s24),

            /// [8. 골프 레슨]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightUserGraduate,
              title: '골프 레슨',
              emoji: '🎓',
            ),
            SizedBox(height: sp.s12),
            _buildGolfLessonSection(context),
            SizedBox(height: sp.s24),

            /// [9. 서비스 찾는 방법]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMagnifyingGlass,
              title: '간편하게 서비스 찾는 방법',
              emoji: '📲',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _bookingRoutes,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),
            SizedBox(height: sp.s16),
            _buildSampleMessage(context),
            SizedBox(height: sp.s24),

            /// [10. 비용 확인 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardCheck,
              title: '비용 확인 체크리스트',
              emoji: '💰',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _costCheckList,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),
            SizedBox(height: sp.s24),

            /// [11. 핸디캡 정보]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTrophy,
              title: '핸디캡 (대회·클럽 이용 시)',
              emoji: '🏌️',
            ),
            SizedBox(height: sp.s12),
            _buildHandicapInfo(context),
            SizedBox(height: sp.s24),

            /// [12. 한국인용 간추림]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBolt,
              title: "한국인용 '간추림'",
              emoji: '📌',
            ),
            SizedBox(height: sp.s12),
            _buildQuickSummary(context),
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
            Colors.green.withValues(alpha: 0.2),
            Colors.teal.withValues(alpha: 0.1),
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
                FontAwesomeIcons.lightGolfBallTee,
                size: 24,
                color: Colors.green,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 골프 이용 안내',
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
            '필리핀 현지에서 1회(당일) 라운드를 이용하려는 한국어 사용자를 대상으로, '
            '공개된 요금표·예약 안내·공식 사이트 및 한국어 커뮤니티 게시물에서 확인되는 사례(후기) 기반 정보입니다.',
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
                    '코스별 규정·요금·결제 방식은 수시로 변경될 수 있으므로 예약 단계에서 최종 확인이 필요합니다.',
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

  /// 경고 박스 빌드 (Warning box build)
  Widget _buildWarningBox(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: Colors.amber.shade700,
              ),
              SizedBox(width: sp.s8),
              Text(
                '필수 체크 사항',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Text(
            '필리핀 골프장은 그린피 외 비용이 실제 결제액을 좌우하는 구조가 흔합니다. '
            '일부 예약/판매 페이지에는 카트·캐디·보험 등은 골프장 현장 결제로 명시되어 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '코스별로 "Must pay at club", "Compulsory fee" 등으로 의무 부과되는 항목이 있을 수 있습니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 비용 테이블 빌드 (Fee table build)
  Widget _buildFeeTable(BuildContext context) {
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
                    '항목',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '의미',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '결제',
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
          ...List.generate(_feeItems.length, (index) {
            final item = _feeItems[index];
            final isLast = index == _feeItems.length - 1;

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
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.item,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.meaning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.payment,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
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

  /// 시즌 카드 빌드 (Season cards build)
  Widget _buildSeasonCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        /// 우기 (Rainy season)
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
                    Text(
                      '우기',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),
                Text(
                  '6월 ~ 11월',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  '⚠️ 강수·번개로 지연/중단 가능\n당일 기상 확인 필요',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: sp.s12),

        /// 건기 (Dry season)
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
                    Text(
                      '건기',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),
                Text(
                  '12월 ~ 5월',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  '☀️ 상대적으로 안정적\n(지역별 편차 존재)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                        item.content,
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

  /// 커뮤니티 정보 빌드 (Community info build)
  Widget _buildCommunityInfo(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 안내 메시지 (Info message)
        Container(
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
                  '아래 내용은 특정 개인의 경험을 사실로 단정하지 않고, 한국어 블로그·커뮤니티 글에 실제로 기재된 문장/주장을 바탕으로 "자주 언급되는 항목"을 정리한 것입니다. '
                  '클럽 공지/예약처 안내로 재확인이 필요합니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 클락 지역 후기 (Clark region reviews)
        _buildCommunityCard(
          context,
          title: '클락(Clark) 지역',
          subtitle: '"한국인 이용이 많다"는 표현과 코스 비교 언급',
          items: [
            '커뮤니티 글에 4박 5일 일정에 3개 구장(디하이츠/코리아/미모사)에서 4회 라운드 일정 기재',
            '코스 컨디션/코스 성향을 개인 선호 기준으로 순위 비교 (개인 평가, 코스 선택 참고용)',
            '과거 대비 그린피 체감 상승 언급 (개인 체감·시점 의존 정보)',
          ],
        ),
        SizedBox(height: sp.s12),

        /// 마닐라/근교 후기 (Manila region reviews)
        _buildCommunityCard(
          context,
          title: '마닐라/근교',
          subtitle: '코스 운영(회원제·퍼블릭)과 부대시설(식당/연습장) 언급',
          items: [
            'Valley 골프장: 남/북 코스 구분 운영 (남코스 회원제, 북코스 퍼블릭)',
            '골프연습장 및 한국식당 운영에 대한 언급',
            '실제 게스트 규정은 시즌/이벤트에 따라 달라질 수 있어 사전 확인 필요',
          ],
        ),
        SizedBox(height: sp.s12),

        /// 한국어 응대 (Korean support)
        _buildCommunityCard(
          context,
          title: '한국어 응대 & 관광형 골프 투어',
          subtitle: '클락 지역을 "골프 관광지"로 설명',
          items: [
            '"한국어 응대가 편리하다"는 문장 포함 (실제 현장 인력 구성은 시기·클럽별 상이)',
            '세부의 Alta Vista, 마닐라 근교 Sta. Elena 등 "인기 골프장"으로 소개',
          ],
        ),
      ],
    );
  }

  /// 커뮤니티 카드 빌드 (Community card build)
  Widget _buildCommunityCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<String> items,
  }) {
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
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: sp.s8),
          ...items.map((item) => Padding(
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
                        item,
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
    );
  }

  /// 골프장 그리드 빌드 (Golf courses grid build)
  Widget _buildGolfCoursesGrid(BuildContext context, List<_GolfCourse> courses) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: courses.map((course) {
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
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(course.icon, size: 20, color: Colors.green),
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
                            course.name,
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
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.region,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      course.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    Wrap(
                      spacing: sp.s4,
                      runSpacing: sp.s4,
                      children: course.features.map((feature) {
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

  /// 정보 카드 빌드 (Info cards build)
  Widget _buildInfoCards(
    BuildContext context,
    List<_GolfInfoItem> items,
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

  /// 예약 문의 메시지 샘플 빌드 (Sample message build)
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
                '예약 문의 메시지 예시',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMessageRow(context, '인원', '"2 players"'),
                _buildMessageRow(context, '날짜', '"Jan 15, 2026"'),
                _buildMessageRow(context, '시간', '"Any tee time between 7:00–9:00"'),
                _buildMessageRow(
                  context,
                  '포함 확인',
                  '"Please confirm green fee, cart fee, caddie fee, insurance, and any compulsory voucher/deposit."',
                ),
                _buildMessageRow(
                  context,
                  '결제',
                  '"Which items must be paid on-site? Cash only?"',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 메시지 행 빌드 (Message row build)
  Widget _buildMessageRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
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
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 핸디캡 정보 빌드 (Handicap info build)
  Widget _buildHandicapInfo(BuildContext context) {
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
                FontAwesomeIcons.lightIdCard,
                size: 16,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                'NGAP (National Golf Association of the Philippines)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Text(
            '필리핀에서는 NGAP가 핸디캡 인덱스 및 코스 레이팅 관련 서비스를 안내합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• 일일 핸디캡(daily handicap) 사용 허용',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  '• 정기 다운로드 일정: 월 2회 (15일, 30/31일)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '장기 체류자 또는 클럽 대회 참가자는 클럽이 요구하는 핸디캡 제출 방식(NGAP 시스템, 스코어 제출 등)을 확인하세요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 빠른 요약 빌드 (Quick summary build)
  Widget _buildQuickSummary(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 당일 라운드 5단계 (5 steps for day round)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightListOl,
                    size: 16,
                    color: Colors.green,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '당일 라운드 5단계',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              _buildQuickStep(context, '1', '권역 선택 (마닐라/클락/세부)'),
              _buildQuickStep(context, '2', '코스 선택 (퍼블릭/게스트 가능 여부)'),
              _buildQuickStep(context, '3', '티타임 예약 (공식 채널 또는 플랫폼)'),
              _buildQuickStep(context, '4', '총비용 확정 (그린피 + 의무 부대비)'),
              _buildQuickStep(context, '5', '현금 포함 결제수단 준비 → 체크인 → 라운드 → 정산'),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 자주 언급되는 코스 빠른 보기 (Quick view of frequently mentioned courses)
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
                '"한국인이 자주 언급하는 코스" 빠른 보기',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildQuickCourseRow(context, '클락', 'Mimosa / D\'Heights / Korea CC'),
              _buildQuickCourseRow(context, '마닐라', 'Club Intramuros / Valley Golf / Sta. Elena'),
              _buildQuickCourseRow(context, '세부', 'Alta Vista / Cebu Country Club'),
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
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 빠른 코스 행 빌드 (Quick course row build)
  Widget _buildQuickCourseRow(BuildContext context, String region, String courses) {
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
              region,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              courses,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
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

  /// 스크린 골프 섹션 빌드 (Screen Golf section build)
  ///
  /// 필리핀 내 스크린 골프장 정보를 카드 형태로 표시합니다.
  /// Displays screen golf venues in the Philippines as cards.
  Widget _buildScreenGolfSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 스크린 골프 안내 박스 (Screen golf info box)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: Colors.purple,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '날씨나 시간 제약 없이 골프를 즐길 수 있는 스크린 골프장입니다. '
                  '한국 골프존 시스템을 사용하는 곳이 많아 익숙하게 이용 가능합니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 스크린 골프장 목록 (Screen golf venues list)
        ..._screenGolfVenues.map((venue) {
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
                /// 아이콘 (Icon)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(venue.icon, size: 20, color: Colors.purple),
                  ),
                ),
                SizedBox(width: sp.s12),

                /// 정보 (Info)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 업체명 및 위치 (Name and location)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              venue.name,
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
                              color: Colors.purple.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              venue.location,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s4),

                      /// 설명 (Description)
                      Text(
                        venue.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: sp.s8),

                      /// 가격 정보 (Price info)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s8,
                          vertical: sp.s4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          venue.priceInfo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: sp.s8),

                      /// 특징 태그들 (Feature tags)
                      Wrap(
                        spacing: sp.s4,
                        runSpacing: sp.s4,
                        children: venue.features.map((feature) {
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
        }),
      ],
    );
  }

  /// 골프 레슨 섹션 빌드 (Golf Lesson section build)
  ///
  /// 필리핀 내 골프 레슨 제공 업체 정보를 표시합니다.
  /// Displays golf lesson providers in the Philippines.
  Widget _buildGolfLessonSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 골프 레슨 안내 박스 (Golf lesson info box)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: Colors.teal,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '필리핀에서 골프를 배우거나 실력을 향상시키고 싶다면 전문 레슨을 받아보세요. '
                  '한국인 프로 레슨도 가능합니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 골프 레슨 목록 (Golf lesson list)
        ..._golfLessons.map((lesson) {
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
                /// 아이콘 (Icon)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FaIcon(lesson.icon, size: 20, color: Colors.teal),
                  ),
                ),
                SizedBox(width: sp.s12),

                /// 정보 (Info)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 업체명 및 위치 (Name and location)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lesson.name,
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
                              color: Colors.teal.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lesson.location,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s4),

                      /// 설명 (Description)
                      Text(
                        lesson.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: sp.s8),

                      /// 특징 태그들 (Feature tags)
                      Wrap(
                        spacing: sp.s4,
                        runSpacing: sp.s4,
                        children: lesson.features.map((feature) {
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
        }),
      ],
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
