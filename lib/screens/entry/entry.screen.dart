import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/entry/entry.login.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/services/currency/currency.service.dart';
import 'package:philgo/services/weather/weather.model.dart';
import 'package:philgo/services/weather/weather.service.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo_api/philgo_api.dart';

/// Entry 화면 (Entry Screen)
///
/// 앱 시작 시 표시되는 로그인/시작 화면입니다.
/// 오늘의 환율, 날씨, 회원 수, 글 수 정보를 4열 레이아웃으로 표시합니다.
class EntryScreen extends StatefulWidget {
  static const String routeName = '/entry';
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  /// 환율 서비스 인스턴스 (Currency service instance)
  final _currencyService = CurrencyService.instance;

  /// 날씨 서비스 인스턴스 (Weather service instance)
  final _weatherService = WeatherService.instance;

  /// PhilGo 서비스 인스턴스 (PhilGo service instance)
  final _philgoService = PhilgoService.instance;

  /// PHP→KRW 환율 (소수점 2자리) (PHP to KRW exchange rate)
  double? _phpToKrwRate;

  /// 환율 로딩 상태 (Exchange rate loading state)
  bool _isLoadingRate = true;

  /// 마닐라 현재 날씨 (Manila current weather)
  HourlyWeather? _manilaWeather;

  /// 날씨 로딩 상태 (Weather loading state)
  bool _isLoadingWeather = true;

  /// 홈페이지 통계 데이터 (Homepage stats data)
  HomepageStats? _homepageStats;

  /// 통계 로딩 상태 (Stats loading state)
  bool _isLoadingStats = true;

  /// 공지사항 목록 (Notice list)
  List<Notice> _notices = [];

  /// 공지사항 로딩 상태 (Notice loading state)
  bool _isLoadingNotices = true;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    _fetchManilaWeather();
    _fetchHomepageStats();
    _fetchLatestNotices();
  }

  /// CurrencyService를 사용하여 PHP→KRW 환율 조회 (Fetch PHP to KRW rate using CurrencyService)
  ///
  /// API 호출 실패 시에도 UI는 정상 표시됩니다 (rate는 null로 표시).
  /// 서비스의 25분 캐시를 활용하여 불필요한 API 호출을 방지합니다.
  Future<void> _fetchExchangeRate() async {
    try {
      final data = await _currencyService.loadExchangeRates();
      final krwRate = data.phpRates['KRW'];

      if (mounted) {
        setState(() {
          _phpToKrwRate = krwRate;
          _isLoadingRate = false;
        });
      }
    } catch (e) {
      // API 호출 실패 시 로딩 상태만 해제
      if (mounted) {
        setState(() => _isLoadingRate = false);
      }
    }
  }

  /// WeatherService를 사용하여 마닐라 현재 날씨 조회 (Fetch Manila weather using WeatherService)
  ///
  /// API 호출 실패 시에도 UI는 정상 표시됩니다 (weather는 null로 표시).
  /// 서비스의 20분 캐시를 활용하여 불필요한 API 호출을 방지합니다.
  Future<void> _fetchManilaWeather() async {
    try {
      final weather = await _weatherService.loadManilaCurrentWeather();

      if (mounted) {
        setState(() {
          _manilaWeather = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      // API 호출 실패 시 로딩 상태만 해제
      if (mounted) {
        setState(() => _isLoadingWeather = false);
      }
    }
  }

  /// PhilgoService를 사용하여 최신 공지사항 조회 (Fetch latest notices using PhilgoService)
  ///
  /// freetalk 게시판의 '공지사항' 카테고리에서 최신 10개를 가져옵니다.
  /// API 호출 실패 시에도 UI는 정상 표시됩니다 (notices는 빈 배열로 표시).
  Future<void> _fetchLatestNotices() async {
    try {
      debugPrint('[EntryScreen] _fetchLatestNotices 시작');
      final notices = await _philgoService.loadLatestNotices(limit: 10);
      debugPrint('[EntryScreen] _fetchLatestNotices 성공: ${notices.length}개');

      if (mounted) {
        setState(() {
          _notices = notices;
          _isLoadingNotices = false;
        });
      }
    } catch (e, stackTrace) {
      // API 호출 실패 시 로딩 상태만 해제
      debugPrint('[EntryScreen] _fetchLatestNotices 에러: $e');
      debugPrint('[EntryScreen] 스택 트레이스: $stackTrace');
      if (mounted) {
        setState(() => _isLoadingNotices = false);
      }
    }
  }

  /// PhilgoService를 사용하여 홈페이지 통계 조회 (Fetch homepage stats using PhilgoService)
  ///
  /// API 호출 실패 시에도 UI는 정상 표시됩니다 (stats는 null로 표시).
  /// 서버에서 1시간 동안 캐시됩니다.
  Future<void> _fetchHomepageStats() async {
    try {
      debugPrint('[EntryScreen] _fetchHomepageStats 시작');
      final stats = await _philgoService.getHomepageStats();
      debugPrint(
        '[EntryScreen] _fetchHomepageStats 성공: '
        'totalUserCount=${stats.totalUserCount}, '
        'totalPostCount=${stats.totalPostCount}',
      );

      if (mounted) {
        setState(() {
          _homepageStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e, stackTrace) {
      // API 호출 실패 시 로딩 상태만 해제
      debugPrint('[EntryScreen] _fetchHomepageStats 에러: $e');
      debugPrint('[EntryScreen] 스택 트레이스: $stackTrace');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  /// 숫자 포맷팅 (Format number with comma separator)
  ///
  /// 예: 123456 → "123,456"
  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// 숫자를 축약 형식으로 포맷팅 (Format number in compact form)
  ///
  /// 한글 로케일: "6.9백만", "1.2천"
  /// 기타 로케일: "6.9M", "1.2K"
  ///
  /// - 1,000 미만: 그대로 표시 (예: "999")
  /// - 1,000 ~ 999,999: 천 단위 (예: "1.2K" / "1.2천")
  /// - 1,000,000 이상: 백만 단위 (예: "6.9M" / "6.9백만")
  String _formatCompactNumber(int number, BuildContext context) {
    // 현재 로케일이 한글인지 확인 (Check if current locale is Korean)
    final locale = Localizations.localeOf(context);
    final isKorean = locale.languageCode == 'ko';

    if (number >= 1000000) {
      // 백만 단위 (Million unit)
      final value = number / 1000000;
      final formatted = value.toStringAsFixed(1);
      // 소수점이 .0이면 제거 (Remove .0 if present)
      final display = formatted.endsWith('.0')
          ? formatted.substring(0, formatted.length - 2)
          : formatted;
      return isKorean ? '$display백만' : '${display}M';
    } else if (number >= 1000) {
      // 천 단위 (Thousand unit)
      final value = number / 1000;
      final formatted = value.toStringAsFixed(1);
      // 소수점이 .0이면 제거 (Remove .0 if present)
      final display = formatted.endsWith('.0')
          ? formatted.substring(0, formatted.length - 2)
          : formatted;
      return isKorean ? '$display천' : '${display}K';
    } else {
      // 1,000 미만은 그대로 표시 (Display as is if less than 1,000)
      return number.toString();
    }
  }

  /// 최근 1개월 이내 공지사항 개수 계산 (Count notices within 30 days)
  ///
  /// 최근 30일 이내에 작성된 공지사항 개수를 반환합니다.
  /// 만약 1개월 내의 공지 글이 없으면 최소 1개를 표시합니다.
  int _getRecentNoticeCount() {
    if (_notices.isEmpty) return 1; // 최소 1개 표시

    // 최근 30일 이내 공지사항 필터링
    final recentNotices = _notices.where((notice) => notice.isWithinDays(30));
    final count = recentNotices.length;

    // 1개월 내의 공지가 없으면 최소 1개 표시
    return count > 0 ? count : 1;
  }

  /// 공지사항 다이얼로그 표시 (Show notices dialog)
  ///
  /// 공지사항 목록을 다이얼로그로 표시합니다.
  /// 각 공지사항의 제목, 날짜, 내용을 보여줍니다.
  /// 최근 7일 이내 글에는 NEW 뱃지를 표시합니다.
  void _showNoticesDialog(
    BuildContext context,
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: scheme.scrim.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Center(
          // Material 위젯으로 감싸서 InkWell의 ripple 효과 지원
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 - 공지사항 타이틀 (Header - Notice title)
                  // 그라데이션 배경과 함께 표시
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 아이콘 컨테이너 (Icon container)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.bullhorn,
                            size: 18,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 타이틀과 공지 개수 (Title and notice count)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.quickMenuNotice,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '총 ${_notices.length}개의 공지사항',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 닫기 버튼 (Close button)
                        IconButton(
                          onPressed: () => Navigator.of(buildContext).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                scheme.onSurface.withValues(alpha: 0.05),
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 공지사항 목록 (Notice list)
                  Flexible(
                    child: _notices.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.folderOpen,
                                  size: 48,
                                  color: scheme.outlineVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '공지사항이 없습니다.',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: _notices.length,
                            itemBuilder: (context, index) {
                              final notice = _notices[index];
                              return _buildNoticeItem(
                                notice,
                                theme,
                                scheme,
                                isLast: index == _notices.length - 1,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  /// 공지사항 아이템 빌드 (Build notice item)
  ///
  /// 각 공지사항의 제목, 날짜, 내용을 표시합니다.
  /// 최근 7일 이내 글에는 NEW 뱃지를 표시합니다.
  /// [isLast]: 마지막 아이템 여부 - 구분선 표시에 사용
  Widget _buildNoticeItem(
    Notice notice,
    ThemeData theme,
    ColorScheme scheme, {
    bool isLast = false,
  }) {
    // 날짜 포맷팅 (Date formatting)
    final dateFormat = DateFormat('yyyy.MM.dd');
    final dateString = dateFormat.format(notice.createdAt);
    // 최근 7일 이내 여부 확인 (Check if within 7 days)
    final isNew = notice.isWithinDays(7);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => _showNoticeDetailDialog(notice, theme, scheme),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 공지 아이콘 (Notice icon)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.fileLines,
                    size: 14,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                // 공지 내용 영역 (Notice content area)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목과 NEW 뱃지 (Subject and NEW badge)
                      Row(
                        children: [
                          // NEW 뱃지 - 최근 7일 이내 (NEW badge - within 7 days)
                          if (isNew) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NEW',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onError,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          // 제목 (Subject)
                          Expanded(
                            child: Text(
                              notice.subject,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 내용 미리보기 (Content preview)
                      if (notice.content.isNotEmpty) ...[
                        Text(
                          notice.content.replaceAll(RegExp(r'\s+'), ' ').trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                      ],
                      // 날짜와 통계 (Date and stats)
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.calendar,
                            size: 11,
                            color: scheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FaIcon(
                            FontAwesomeIcons.eye,
                            size: 11,
                            color: scheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${notice.noOfView}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                          if (notice.noOfComment > 0) ...[
                            const SizedBox(width: 12),
                            FaIcon(
                              FontAwesomeIcons.comment,
                              size: 11,
                              color: scheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${notice.noOfComment}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // 화살표 아이콘 (Arrow icon)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: FaIcon(
                    FontAwesomeIcons.chevronRight,
                    size: 12,
                    color: scheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 구분선 - 마지막 아이템 제외 (Divider - except last item)
        if (!isLast)
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  /// 회원 수 다이얼로그 표시 (Show member count dialog)
  ///
  /// 회원 수와 함께 필고 서비스 소개를 표시합니다.
  /// 현재 날짜와 함께 "xxxx년 xx월 xx일 현재" 형식으로 표시합니다.
  /// COT/TOT 분석을 통해 시각적으로 개선된 디자인 적용
  void _showMemberCountDialog(
    BuildContext context,
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    final memberCount = _homepageStats?.totalUserCount ?? 0;
    // 현재 날짜 포맷팅 (Current date formatting)
    final now = DateTime.now();
    final dateString = '${now.year}년 ${now.month}월 ${now.day}일 현재';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: scheme.scrim.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 - primaryContainer 배경으로 강조 (Header with background)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 아이콘 컨테이너 (Icon container)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.users,
                            size: 18,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 제목과 서브타이틀 (Title and subtitle)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '필고 회원 수',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateString,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 닫기 버튼 (Close button)
                        IconButton(
                          onPressed: () => Navigator.of(buildContext).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                scheme.onSurface.withValues(alpha: 0.05),
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 내용 (Content)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // 회원 수 영역 - 강조된 배경 (Member count area with emphasis)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // 회원 수 숫자 (Member count number)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatNumber(memberCount),
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      '명',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 설명 영역 - 아이콘과 함께 (Description with icon)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // 트로피 아이콘 (Trophy icon)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.tertiary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.trophy,
                                  size: 16,
                                  color: scheme.tertiary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 설명 텍스트 (Description text)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '2008년에 시작된',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      'No. 1 필리핀 한인 커뮤니티',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  /// 글 수 다이얼로그 표시 (Show post count dialog)
  ///
  /// 글 수와 함께 필고 서비스 소개를 표시합니다.
  /// 현재 날짜와 함께 "xxxx년 xx월 xx일 현재" 형식으로 표시합니다.
  /// COT/TOT 분석을 통해 시각적으로 개선된 디자인 적용
  void _showPostCountDialog(
    BuildContext context,
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    final postCount = _homepageStats?.totalPostCount ?? 0;
    // 현재 날짜 포맷팅 (Current date formatting)
    final now = DateTime.now();
    final dateString = '${now.year}년 ${now.month}월 ${now.day}일 현재';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: scheme.scrim.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더 - primaryContainer 배경으로 강조 (Header with background)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        // 아이콘 컨테이너 (Icon container)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.fileLines,
                            size: 18,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 제목과 서브타이틀 (Title and subtitle)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '필고 글 & 댓글 수',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dateString,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 닫기 버튼 (Close button)
                        IconButton(
                          onPressed: () => Navigator.of(buildContext).pop(),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                scheme.onSurface.withValues(alpha: 0.05),
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.xmark,
                            size: 18,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 내용 (Content)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // 글 수 영역 - 강조된 배경 (Post count area with emphasis)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // 글 수 숫자 (Post count number)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _formatNumber(postCount),
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 4,
                                      bottom: 6,
                                    ),
                                    child: Text(
                                      '개',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // 설명 영역 - 아이콘과 함께 (Description with icon)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // 지구 아이콘 (Globe icon)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.secondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.earthAsia,
                                  size: 16,
                                  color: scheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // 설명 텍스트 (Description text)
                              Expanded(
                                child: Text(
                                  '필리핀의 모든 것을 담았습니다.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  /// 공지사항 상세 다이얼로그 표시 (Show notice detail dialog)
  ///
  /// 선택한 공지사항의 전체 내용을 다이얼로그로 표시합니다.
  void _showNoticeDetailDialog(
    Notice notice,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    // 날짜 포맷팅 (Date formatting)
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    final dateString = dateFormat.format(notice.createdAt);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: scheme.scrim.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (
        BuildContext buildContext,
        Animation animation,
        Animation secondaryAnimation,
      ) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 - 닫기 버튼 (Header - Close button)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // 뒤로가기 버튼 (Back button)
                      IconButton(
                        onPressed: () => Navigator.of(buildContext).pop(),
                        icon: FaIcon(
                          FontAwesomeIcons.arrowLeft,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      // 닫기 버튼 - 자식 다이얼로그만 닫기 (Close button - close only this dialog)
                      IconButton(
                        onPressed: () => Navigator.of(buildContext).pop(),
                        icon: FaIcon(
                          FontAwesomeIcons.xmark,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // 제목 (Title)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    notice.subject,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 날짜 (Date)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    dateString,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 구분선 (Divider)
                Divider(height: 1, color: scheme.outlineVariant),
                // 내용 (Content)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      notice.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PhilGo 로고 (세 개의 삼각형)
              // rotating: 회전 애니메이션, pulsing: 크기 펄스 애니메이션
              const PhilGoLogoTriangles(
                size: 180,
                animated: true,
                rotating: true,
                pulsing: true,
              ),
              // 로고와 앱 타이틀 사이 간격
              const SizedBox(height: 24),
              // App title - 앱 이름 (다국어 지원)
              // headlineMedium 사용하여 1.2배 정도 크기 증가
              Text(l10n.appName, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              // App description - 앱 슬로건 (다국어 지원)
              // bodyMedium 사용하여 1.2배 정도 크기 증가
              Text(
                l10n.appSlogan,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // === 4열 정보 섹션 (4-Column Info Section) ===
              // 오늘 환율, 오늘 날씨, 회원 수, 글 수를 한 줄로 표시
              _buildInfoSection(context, l10n, theme, scheme),

              const SizedBox(height: 48),

              // 로그인 버튼 - Comic 스타일 디자인 (large 텍스트, pill 형태)
              // ComicButton 위젯을 사용하여 재사용 가능한 Comic 스타일 버튼 적용
              // customPadding: 좌우 패딩을 더 넓게 (48), 상하는 large 기준 유지 (20)
              ComicButton(
                rounded: ComicButtonRounded.full,
                textSize: ComicButtonTextSize.large,
                customPadding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(
                      context,
                    ).modalBarrierDismissLabel,
                    barrierColor: scheme.scrim.withValues(alpha: 0.5),
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder:
                        (
                          BuildContext buildContext,
                          Animation animation,
                          Animation secondaryAnimation,
                        ) {
                          return const EntryLoginScreen();
                        },
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                            child: ScaleTransition(
                              scale: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                              child: child,
                            ),
                          );
                        },
                  );
                },
                child: Text(l10n.login),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5열 정보 섹션 빌드 (Build 5-column info section)
  ///
  /// 공지 | 오늘 환율 | 오늘 날씨 | 회원 수 | 글 수
  Widget _buildInfoSection(
    BuildContext context,
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 공지 - 최근 1개월 이내 공지 개수 표시 (Notice count within 30 days)
        // 클릭 시 공지사항 다이얼로그 표시
        // behavior: opaque로 설정하여 자식 위젯 사이의 빈 공간도 터치 감지
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showNoticesDialog(context, l10n, theme, scheme),
          child: _buildInfoColumn(
            label: l10n.quickMenuNotice,
            value: _isLoadingNotices ? '...' : '${_getRecentNoticeCount()}개',
            theme: theme,
            scheme: scheme,
          ),
        ),
        // 오늘 환율 - 클릭 시 환율 정보 화면 열기 (Tap to open exchange rate screen)
        // behavior: opaque로 설정하여 자식 위젯 사이의 빈 공간도 터치 감지
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showFullScreen(
            context,
            child: const ExchangeRateScreen(),
            barrierLabel: '환율 정보 닫기',
          ),
          child: _buildInfoColumn(
            label: l10n.entryTodayExchangeRate,
            value: _isLoadingRate
                ? '...'
                : (_phpToKrwRate?.toStringAsFixed(2) ?? '-'),
            theme: theme,
            scheme: scheme,
          ),
        ),
        // 오늘 날씨 - 클릭 시 날씨 화면 열기 (Tap to open weather screen)
        // 아이콘 + 설명 형태로 마닐라 현재 날씨 표시
        // behavior: opaque로 설정하여 자식 위젯 사이의 빈 공간도 터치 감지
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showFullScreen(
            context,
            child: const WeatherScreen(),
            barrierLabel: '날씨 정보 닫기',
          ),
          child: _buildWeatherColumn(l10n, theme, scheme),
        ),
        // 회원 수 - API에서 조회, 클릭 시 다이얼로그 (Member count from API, tap for dialog)
        // behavior: opaque로 설정하여 자식 위젯 사이의 빈 공간도 터치 감지
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showMemberCountDialog(context, l10n, theme, scheme),
          child: _buildInfoColumn(
            label: l10n.entryMemberCount,
            value: _isLoadingStats
                ? '...'
                : (_homepageStats != null
                      ? _formatNumber(_homepageStats!.totalUserCount)
                      : '-'),
            theme: theme,
            scheme: scheme,
          ),
        ),
        // 글 수 - API에서 조회, 클릭 시 다이얼로그 (Post count from API, tap for dialog)
        // behavior: opaque로 설정하여 자식 위젯 사이의 빈 공간도 터치 감지
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showPostCountDialog(context, l10n, theme, scheme),
          child: _buildInfoColumn(
            label: l10n.entryPostCount,
            value: _isLoadingStats
                ? '...'
                : (_homepageStats != null
                      ? _formatCompactNumber(_homepageStats!.totalPostCount, context)
                      : '-'),
            theme: theme,
            scheme: scheme,
          ),
        ),
      ],
    );
  }

  /// 단일 정보 열 빌드 (Build single info column)
  ///
  /// 상단: 레이블 (labelMedium, onSurfaceVariant)
  /// 하단: 값 (titleMedium, primary)
  Widget _buildInfoColumn({
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme scheme,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 레이블 - 중간 텍스트, 연한 색상
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        // 값 - 중간 크기 텍스트, 강조 색상
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
        ),
      ],
    );
  }

  /// 날씨 정보 열 빌드 (Build weather info column)
  ///
  /// 상단: 레이블 (labelMedium, onSurfaceVariant)
  /// 하단: 아이콘 + 설명 (primary 색상)
  Widget _buildWeatherColumn(Lo l10n, ThemeData theme, ColorScheme scheme) {
    // 로딩 중이거나 데이터가 없으면 기본 표시
    if (_isLoadingWeather) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.entryTodayWeather,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '...',
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
          ),
        ],
      );
    }

    // 날씨 데이터가 없으면 기본 표시
    if (_manilaWeather == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.entryTodayWeather,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '-',
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
          ),
        ],
      );
    }

    // 날씨 아이콘과 설명 가져오기 (Get weather icon and description)
    final icon = WeatherCodeHelper.getIcon(_manilaWeather!.weatherCode);
    final color = WeatherCodeHelper.getColor(_manilaWeather!.weatherCode);
    final description = WeatherCodeHelper.getDescription(
      _manilaWeather!.weatherCode,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 레이블 - 중간 텍스트, 연한 색상
        Text(
          l10n.entryTodayWeather,
          style: theme.textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        // 아이콘 + 설명 (Icon + Description)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              description,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
