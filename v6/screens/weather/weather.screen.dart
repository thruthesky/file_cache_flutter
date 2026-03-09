import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/weather/weather.model.dart';
import '../../services/weather/weather.service.dart';
import '../../themes/app.spacing.dart';

/// 필리핀 날씨 화면 (Philippines Weather Screen)
///
/// 필리핀 5개 주요 도시의 6일 날씨 예보를 표 형식으로 표시합니다.
///
/// ### 기능 (Features):
/// - 5개 도시 날씨 표시 (마닐라, 세부, 앙헬레스, 보라카이, 바기오)
/// - 6일 예보 (오늘 포함)
/// - 시간별 온도, 날씨 아이콘, 날씨 설명
/// - 20분 캐시 (via WeatherService)
///
/// ### 레이아웃 (Layout):
/// 가로/세로 스크롤 가능한 표 형식
/// - 행: 시간대 (오늘: 2시간 간격, 내일~: 4시간 간격)
/// - 열: 도시 (마닐라, 세부, 앙헬레스, 보라카이, 바기오)
class WeatherScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/weather';

  /// WeatherScreen으로 네비게이션 (Navigate to WeatherScreen)
  static void push(BuildContext context) => context.push(routeName);

  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  /// 날씨 서비스 인스턴스 (Weather service instance)
  final _weatherService = WeatherService.instance;

  /// 로딩 상태 (Loading state)
  bool _isLoading = true;

  /// 에러 메시지 (Error message)
  String? _errorMessage;

  /// 표시할 시간 슬롯 (Time slots to display)
  List<DateTime> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  /// 날씨 데이터 로드 (Load weather data)
  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _weatherService.loadWeatherData();
      _timeSlots = _weatherService.getDisplayTimeSlots();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('WeatherScreen: 데이터 로드 실패 - $e');
      setState(() {
        _errorMessage = '날씨 정보를 불러올 수 없습니다.\n네트워크 연결을 확인해주세요.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>() ?? const AppSpacing();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _buildAppBar(theme, scheme),
      body: _isLoading
          ? _buildLoadingState(scheme)
          : _errorMessage != null
          ? _buildErrorState(scheme, theme, sp)
          : _buildContent(context, theme, scheme, sp),
    );
  }

  /// 앱바 빌드 (Build AppBar)
  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme scheme) {
    return AppBar(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        '필리핀 날씨',
        style: theme.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        /// 새로고침 버튼 (Refresh button)
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.lightArrowsRotate,
            color: scheme.primary,
            size: 20,
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  await _weatherService.clearCache();
                  await _loadWeatherData();
                },
          tooltip: '날씨 새로고침',
        ),
      ],
    );
  }

  /// 로딩 상태 UI (Loading state UI)
  Widget _buildLoadingState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: scheme.primary),
          const SizedBox(height: 16),
          Text(
            '날씨 정보를 불러오는 중...',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// 에러 상태 UI (Error state UI)
  Widget _buildErrorState(ColorScheme scheme, ThemeData theme, AppSpacing sp) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sp.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightTriangleExclamation,
              size: 48,
              color: scheme.error,
            ),
            SizedBox(height: sp.s16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: sp.s24),
            FilledButton.icon(
              onPressed: _loadWeatherData,
              icon: const FaIcon(FontAwesomeIcons.lightArrowsRotate, size: 16),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 컨텐츠 빌드 (Build main content)
  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildWeatherTable(theme, scheme, sp);
  }

  /// 날씨 표 빌드 (Build weather table)
  ///
  /// 가로/세로 스크롤 가능한 표 형식으로 날씨 데이터를 표시합니다.
  /// 행: 시간대, 열: 도시
  Widget _buildWeatherTable(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final cities = PhilippineCity.cities;

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 헤더 행: 도시 이름 (Header row: City names)
            _buildHeaderRow(theme, scheme, sp, cities),

            /// 데이터 행: 시간별 날씨 (Data rows: Hourly weather)
            ..._buildDataRows(theme, scheme, sp, cities),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  /// 헤더 행 빌드 (Build header row)
  Widget _buildHeaderRow(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    List<PhilippineCity> cities,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          /// 시간 열 헤더 (Time column header)
          _buildCell(
            theme: theme,
            scheme: scheme,
            sp: sp,
            width: 80,
            child: Text(
              '시간',
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            isHeader: true,
          ),

          /// 도시 이름 헤더 (City name headers)
          ...cities.map(
            (city) => _buildCell(
              theme: theme,
              scheme: scheme,
              sp: sp,
              width: 80,
              child: Text(
                city.nameKo,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              isHeader: true,
            ),
          ),
        ],
      ),
    );
  }

  /// 데이터 행 빌드 (Build data rows)
  List<Widget> _buildDataRows(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    List<PhilippineCity> cities,
  ) {
    final rows = <Widget>[];
    String? currentDate;

    for (int i = 0; i < _timeSlots.length; i++) {
      final time = _timeSlots[i];
      final dateStr = DateFormat('MM/dd').format(time);

      /// 날짜 구분선 (Date separator)
      if (currentDate != dateStr) {
        currentDate = dateStr;
        rows.add(_buildDateSeparator(theme, scheme, sp, time));
      }

      /// 시간별 날씨 행 (Hourly weather row)
      rows.add(_buildWeatherRow(theme, scheme, sp, time, cities, i));
    }

    return rows;
  }

  /// 날짜 구분선 빌드 (Build date separator)
  Widget _buildDateSeparator(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    DateTime date,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    String dateLabel;
    if (targetDate == today) {
      dateLabel = '오늘';
    } else if (targetDate == today.add(const Duration(days: 1))) {
      dateLabel = '내일';
    } else {
      dateLabel = DateFormat('MM/dd (E)', 'ko').format(date);
    }

    return Padding(
      padding: EdgeInsets.only(top: sp.s16, bottom: sp.s8),
      child: Text(
        dateLabel,
        style: theme.textTheme.titleSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 날씨 행 빌드 (Build weather row)
  Widget _buildWeatherRow(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    DateTime time,
    List<PhilippineCity> cities,
    int index,
  ) {
    final isEven = index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isEven
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          /// 시간 셀 (Time cell)
          _buildCell(
            theme: theme,
            scheme: scheme,
            sp: sp,
            width: 80,
            child: Text(
              DateFormat('HH:mm').format(time),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          /// 각 도시 날씨 셀 (Weather cells for each city)
          ...cities.map((city) {
            final weather = _weatherService.getWeatherAt(city.id, time);
            return _buildWeatherCell(theme, scheme, sp, weather);
          }),
        ],
      ),
    );
  }

  /// 날씨 셀 빌드 (Build weather cell)
  ///
  /// 아이콘 + 온도 + 설명 텍스트를 세로로 표시합니다.
  Widget _buildWeatherCell(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    HourlyWeather? weather,
  ) {
    if (weather == null) {
      return _buildCell(
        theme: theme,
        scheme: scheme,
        sp: sp,
        width: 80,
        child: Text(
          '-',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final icon = WeatherCodeHelper.getIcon(weather.weatherCode);
    final color = WeatherCodeHelper.getColor(weather.weatherCode);
    final description = WeatherCodeHelper.getDescription(weather.weatherCode);
    final temp = weather.temperature.round();

    return _buildCell(
      theme: theme,
      scheme: scheme,
      sp: sp,
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 날씨 아이콘 (Weather icon)
          FaIcon(icon, size: 18, color: color),
          SizedBox(height: sp.s4),

          /// 온도 (Temperature)
          Text(
            '$temp°',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),

          /// 날씨 설명 (Weather description)
          Text(
            description,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 셀 빌드 (Build cell)
  Widget _buildCell({
    required ThemeData theme,
    required ColorScheme scheme,
    required AppSpacing sp,
    required double width,
    required Widget child,
    bool isHeader = false,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: sp.s8,
        vertical: isHeader ? sp.s12 : sp.s8,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
