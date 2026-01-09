import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 휴일 정보 아이템 데이터 클래스 (Holiday Info Item Data Class)
///
/// 각 휴일의 날짜, 요일, 명칭을 담습니다.
/// Contains date, day of week, and name for each holiday.
class _HolidayItem {
  /// 날짜 (Date)
  final String date;

  /// 요일 (Day of week)
  final String day;

  /// 명칭 (Name)
  final String name;

  const _HolidayItem({
    required this.date,
    required this.day,
    required this.name,
  });
}

/// 정보 아이템 데이터 클래스 (Info Item Data Class)
class _InfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 필리핀 휴일 정보 화면 (Philippine Holiday Screen)
///
/// 필리핀의 정규 휴일 및 특별 휴일 정보를 제공합니다.
/// Provides information about regular and special holidays in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// HolidayScreen.push(context);
/// ```
class HolidayScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Holiday';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const HolidayScreen({super.key});

  @override
  State<HolidayScreen> createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  /// 2026년 정규 공휴일 목록 (Regular Holidays 2026)
  static const List<_HolidayItem> _regularHolidays = [
    _HolidayItem(date: '1월 1일', day: '목', name: 'New Year\'s Day (신년)'),
    _HolidayItem(date: '4월 2일', day: '목', name: 'Maundy Thursday'),
    _HolidayItem(date: '4월 3일', day: '금', name: 'Good Friday'),
    _HolidayItem(date: '4월 9일', day: '목', name: 'Araw ng Kagitingan (용사의 날)'),
    _HolidayItem(date: '5월 1일', day: '금', name: 'Labor Day (노동절)'),
    _HolidayItem(date: '6월 12일', day: '금', name: 'Independence Day (독립기념일)'),
    _HolidayItem(date: '8월 31일', day: '월', name: 'National Heroes Day (국가 영웅의 날)'),
    _HolidayItem(date: '11월 30일', day: '월', name: 'Bonifacio Day (보니파시오의 날)'),
    _HolidayItem(date: '12월 25일', day: '금', name: 'Christmas Day (크리스마스)'),
    _HolidayItem(date: '12월 30일', day: '수', name: 'Rizal Day (리잘의 날)'),
  ];

  /// 2026년 특별 비근무일 목록 (Special Non-Working Days 2026)
  static const List<_HolidayItem> _specialNonWorkingDays = [
    _HolidayItem(date: '2월 17일', day: '화', name: 'Chinese New Year (중국 설)'),
    _HolidayItem(date: '4월 4일', day: '토', name: 'Black Saturday (성 사토요일)'),
    _HolidayItem(date: '8월 21일', day: '금', name: 'Ninoy Aquino Day'),
    _HolidayItem(date: '11월 1일', day: '일', name: 'All Saints\' Day (모든 성인 축일)'),
    _HolidayItem(date: '11월 2일', day: '월', name: 'All Souls\' Day (모든 영혼의 날)'),
    _HolidayItem(date: '12월 8일', day: '화', name: 'Feast of the Immaculate Conception (무염시태 축일)'),
    _HolidayItem(date: '12월 24일', day: '목', name: 'Christmas Eve (크리스마스 전야)'),
    _HolidayItem(date: '12월 31일', day: '목', name: 'Last Day of the Year (연말)'),
  ];

  /// 2026년 특별 근무일 목록 (Special Working Days 2026)
  static const List<_HolidayItem> _specialWorkingDays = [
    _HolidayItem(date: '2월 25일', day: '수', name: 'EDSA People Power Revolution Anniversary'),
  ];

  /// 행정기관 운영 정보 (Administrative Operations Info)
  static const List<_InfoItem> _adminOperations = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '정규 공휴일',
      description: '정부기관, 은행, 우체국, 공공기관은 대부분 전면 휴무입니다.\n민간 기업도 법정 휴일로 간주되며 대부분 업무가 중단됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightStore,
      title: '특별 비근무일',
      description: '법정 비근무일이지만 회사별 재량으로 운영 여부가 달라집니다.\n소매업, 쇼핑몰, 관광시설은 정상 영업하는 경우가 많습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBriefcase,
      title: '특별 근무일',
      description: '정상 근무일로 간주되어 공공기관 및 기업은 통상 근무합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '급여/근무 기준',
      description: '정규 공휴일 근무 시 법적 추가 급여가 적용되며,\n특별 비근무일도 회사 정책에 따라 추가 수당이 적용될 수 있습니다.',
    ),
  ];

  /// 한국인을 위한 팁 (Tips for Koreans)
  static const List<_InfoItem> _tipsForKoreans = [
    _InfoItem(
      icon: FontAwesomeIcons.lightPlane,
      title: '장기 연휴 기간 활용',
      description: '5월 1일(금), 6월 12일(금) 등은 긴 주말 여행 기회로 적합합니다.\nHoly Week(4월 초)는 필리핀 내 최대 이동/관광 성수기입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightLandmark,
      title: '비자·은행·행정기관',
      description: '공휴일 전후에는 은행 및 정부 서비스가 완전 중단됩니다.\n필수 업무는 미리 처리하는 것이 필요합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '교통·숙박',
      description: '주요 휴일(크리스마스·Holy Week)은 항공권·숙소 예약이 조기 매진되므로\n사전 예약이 필수입니다.',
    ),
  ];

  /// 주요 행사 정보 (Major Events)
  static const List<_InfoItem> _majorEvents = [
    _InfoItem(
      icon: FontAwesomeIcons.lightChampagneGlasses,
      title: 'New Year\'s Day',
      description: '전야 카운트다운 이벤트, 도시별 퍼레이드',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightChurch,
      title: 'Holy Week',
      description: '성찰 기간/선교 행사, 교회 중심 행사',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFlag,
      title: 'Independence Day',
      description: '국기 게양식, 공식 국가 기념식',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightGifts,
      title: 'Christmas Season',
      description: '파티, 쇼핑 세일, 가족 모임',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCross,
      title: 'All Saints/Souls Day',
      description: '묘지 방문 및 추모 행사',
    ),
  ];

  /// URL 실행 함수 (Launch URL function)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            FaIcon(FontAwesomeIcons.lightCalendarCheck, size: 20, color: scheme.primary),
            SizedBox(width: sp.s8),
            const Text('🇵🇭 2026 필리핀 공휴일'),
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
            /// 공휴일 정보 출처 안내
            _buildNoticeCard(context),
            SizedBox(height: sp.s24),

            /// [정규 공휴일 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCalendarStar,
              title: '정규 공휴일 (Regular Holidays)',
              color: Colors.red,
            ),
            SizedBox(height: sp.s12),
            _buildHolidayTable(context, _regularHolidays, Colors.red),
            SizedBox(height: sp.s8),
            _buildIslamicHolidayNote(context),

            SizedBox(height: sp.s24),

            /// [특별 비근무일 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCalendarMinus,
              title: '특별 비근무일 (Special Non-Working Days)',
              color: Colors.orange,
            ),
            SizedBox(height: sp.s12),
            _buildHolidayTable(context, _specialNonWorkingDays, Colors.orange),

            SizedBox(height: sp.s24),

            /// [특별 근무일 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCalendarPlus,
              title: '특별 근무일 (Special Working Day)',
              color: Colors.blue,
            ),
            SizedBox(height: sp.s12),
            _buildHolidayTable(context, _specialWorkingDays, Colors.blue),

            SizedBox(height: sp.s24),

            /// [행정기관 운영 안내 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuildingColumns,
              title: '휴일별 행정기관·사업장 운영',
              color: scheme.primary,
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _adminOperations, scheme.primaryContainer, scheme.onPrimaryContainer),

            SizedBox(height: sp.s24),

            /// [종교 및 지역별 휴일 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightGlobe,
              title: '종교 및 지역별 휴일',
              color: scheme.tertiary,
            ),
            SizedBox(height: sp.s12),
            _buildReligionAndRegionInfo(context),

            SizedBox(height: sp.s24),

            /// [주요 행사 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPartyHorn,
              title: '주요 문화·행사 정보',
              color: Colors.purple,
            ),
            SizedBox(height: sp.s12),
            _buildEventChips(context),

            SizedBox(height: sp.s24),

            /// [한국인 팁 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLightbulb,
              title: '한국인에게 유용한 휴일 팁',
              color: Colors.green,
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _tipsForKoreans, Colors.green.withValues(alpha: 0.15), Colors.green.shade700),

            SizedBox(height: sp.s24),

            /// [참고 URL 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLink,
              title: '참고 URL',
              color: scheme.secondary,
            ),
            SizedBox(height: sp.s12),
            _buildReferenceLinks(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 공지 카드 빌드 (Build notice card)
  Widget _buildNoticeCard(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(FontAwesomeIcons.lightCircleInfo, size: 20, color: scheme.primary),
          SizedBox(width: sp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '공식 발표 기준',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  '필리핀 정부가 2025년 9월 3일 Proclamation No. 1006을 통해 발표한 2026년 공식 공휴일 목록을 기반으로 작성되었습니다.',
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
  }

  /// 섹션 헤더 빌드 (Build section header)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: color),
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

  /// 휴일 테이블 빌드 (Build holiday table)
  Widget _buildHolidayTable(BuildContext context, List<_HolidayItem> holidays, Color accentColor) {
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
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    '날짜',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '요일',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '공휴일 명칭',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 본문 (Table body)
          ...holidays.asMap().entries.map((entry) {
            final index = entry.key;
            final holiday = entry.value;
            final isLast = index == holidays.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      holiday.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: sp.s4, vertical: sp.s4),
                      decoration: BoxDecoration(
                        color: _getDayColor(holiday.day),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        holiday.day,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      holiday.name,
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

  /// 요일별 색상 반환 (Get color by day)
  Color _getDayColor(String day) {
    switch (day) {
      case '일':
        return Colors.red;
      case '토':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// 이슬람 휴일 안내 (Islamic holiday note)
  Widget _buildIslamicHolidayNote(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(FontAwesomeIcons.lightMosque, size: 16, color: Colors.amber.shade700),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              '이슬람력에 따라 변동하는 Eid ul-Fitr 및 Eid ul-Adha는 추후 정부 발표 예정입니다.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_InfoItem> items,
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

  /// 종교 및 지역별 휴일 정보 빌드 (Build religion and region info)
  Widget _buildReligionAndRegionInfo(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 종교 관련 휴일 (Religious holidays)
        Container(
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
                  FaIcon(FontAwesomeIcons.lightChurch, size: 16, color: scheme.tertiary),
                  SizedBox(width: sp.s8),
                  Text(
                    '종교 관련 휴일',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                '• 가톨릭 기반 공휴일(Holy Week, 성사월 축일)은 전국적으로 중요성을 지닙니다.\n• 이슬람 공휴일(Eid ul-Fitr, Eid ul-Adha)의 2026년 정확한 날짜는 이슬람력 기준 발표 예정입니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s8),

        /// 지역별 휴일 (Regional holidays)
        Container(
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
                  FaIcon(FontAwesomeIcons.lightMapLocationDot, size: 16, color: scheme.tertiary),
                  SizedBox(width: sp.s8),
                  Text(
                    '지역별 휴일',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                '일부 지역 단위 공휴일(도시/성립 기념일)은 해당 지역 주민에게만 유효합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: sp.s8),
              _buildRegionalHolidayChip(context, 'Cebu City', 'Charter Day', '2월 24일'),
              SizedBox(height: sp.s4),
              _buildRegionalHolidayChip(context, 'Davao City', 'City Day', '3월 16일'),
            ],
          ),
        ),
      ],
    );
  }

  /// 지역 휴일 칩 빌드 (Build regional holiday chip)
  Widget _buildRegionalHolidayChip(BuildContext context, String city, String name, String date) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            city,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
        SizedBox(width: sp.s8),
        Text(
          '$name - $date (추정)',
          style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }

  /// 행사 칩 빌드 (Build event chips)
  Widget _buildEventChips(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _majorEvents.map((event) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: FaIcon(event.icon, size: 18, color: Colors.purple)),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      event.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

  /// 참고 링크 빌드 (Build reference links)
  Widget _buildReferenceLinks(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final links = [
      {'title': 'Philippine News Agency', 'url': 'https://www.pna.gov.ph/articles/1258046'},
      {'title': 'INQUIRER.net', 'url': 'https://newsinfo.inquirer.net/2104754/list-2026-regular-holidays-special-non-working-days'},
      {'title': 'Time and Date', 'url': 'https://www.timeanddate.com/holidays/philippines/2026'},
    ];

    return Column(
      children: links.map((link) {
        return GestureDetector(
          onTap: () => _launchUrl(link['url']!),
          child: Container(
            margin: EdgeInsets.only(bottom: sp.s8),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.lightArrowUpRightFromSquare, size: 16, color: scheme.primary),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Text(
                    link['title']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                FaIcon(FontAwesomeIcons.lightChevronRight, size: 14, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
