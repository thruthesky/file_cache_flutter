import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/weather/weather.model.dart';
import 'package:philgo/weather/weather.service.dart';

/// 필리핀 날씨 화면
///
/// 5개 주요 도시의 6일 날씨 예보를 표 형식으로 표시합니다.
/// - 마닐라, 세부, 앙헬레스, 보라카이, 바기오
/// - 오늘: 2시간 간격, 내일~5일: 4시간 간격
/// - WMO 날씨 코드별 아이콘+색상+한글설명
class WeatherScreen extends StatefulWidget {
  static const String routeName = '/weather';
  static void push(BuildContext context) => context.push(routeName);

  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _weatherService = WeatherService.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<DateTime> _timeSlots = [];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _weatherService.loadWeatherData();
      _timeSlots = _weatherService.getDisplayTimeSlots();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('WeatherScreen: 데이터 로드 실패 - $e');
      setState(() {
        // "Unable to load weather data.\nPlease check your network connection."
        _errorMessage = '날씨 정보를 불러올 수 없습니다.\n네트워크 연결을 확인해주세요.'.tr();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.surface,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: color.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: FaIcon(FontAwesomeIcons.lightXmark, color: color.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        // "Philippines Weather"
        '필리핀 날씨'.tr(),
        style: text.titleLarge?.copyWith(
          color: color.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.lightArrowsRotate,
            color: color.primary,
            size: 20,
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  await _weatherService.clearCache();
                  await _loadWeatherData();
                },
          // "Refresh weather"
          tooltip: '날씨 새로고침'.tr(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: color.primary),
          const SizedBox(height: 16),
          Text(
            // "Loading weather data..."
            '날씨 정보를 불러오는 중...'.tr(),
            style: TextStyle(color: color.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightTriangleExclamation,
              size: 48,
              color: color.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(
                color: color.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadWeatherData,
              icon: const FaIcon(FontAwesomeIcons.lightArrowsRotate, size: 16),
              // "Try Again"
              label: Text('다시 시도'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return _buildWeatherTable();
  }

  Widget _buildWeatherTable() {
    final cities = PhilippineCity.cities;

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(cities),
            ..._buildDataRows(cities),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeaderRow(List<PhilippineCity> cities) {
    return Container(
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildCell(
            width: 80,
            child: Text(
              '시간',
              style: text.labelLarge?.copyWith(
                color: color.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            isHeader: true,
          ),
          ...cities.map(
            (city) => _buildCell(
              width: 80,
              child: Text(
                city.nameKo,
                style: text.labelMedium?.copyWith(
                  color: color.onSurface,
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

  List<Widget> _buildDataRows(List<PhilippineCity> cities) {
    final rows = <Widget>[];
    String? currentDate;

    for (int i = 0; i < _timeSlots.length; i++) {
      final time = _timeSlots[i];
      final dateStr = DateFormat('MM/dd').format(time);

      if (currentDate != dateStr) {
        currentDate = dateStr;
        rows.add(_buildDateSeparator(time));
      }

      rows.add(_buildWeatherRow(time, cities, i));
    }

    return rows;
  }

  Widget _buildDateSeparator(DateTime date) {
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
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        dateLabel,
        style: text.titleSmall?.copyWith(
          color: color.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWeatherRow(
    DateTime time,
    List<PhilippineCity> cities,
    int index,
  ) {
    final isEven = index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isEven
            ? color.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          _buildCell(
            width: 80,
            child: Text(
              DateFormat('HH:mm').format(time),
              style: text.bodyMedium?.copyWith(
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...cities.map((city) {
            final weather = _weatherService.getWeatherAt(city.id, time);
            return _buildWeatherCell(weather);
          }),
        ],
      ),
    );
  }

  Widget _buildWeatherCell(HourlyWeather? weather) {
    if (weather == null) {
      return _buildCell(
        width: 80,
        child: Text(
          '-',
          style: text.bodySmall?.copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
      );
    }

    final icon = WeatherCodeHelper.getIcon(weather.weatherCode);
    final iconColor = WeatherCodeHelper.getColor(weather.weatherCode);
    final description = WeatherCodeHelper.getDescription(weather.weatherCode);
    final temp = weather.temperature.round();

    return _buildCell(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 18, color: iconColor),
          const SizedBox(height: 4),
          Text(
            '$temp°',
            style: text.bodyMedium?.copyWith(
              color: color.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            description,
            style: text.labelSmall?.copyWith(
              color: color.onSurfaceVariant,
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

  Widget _buildCell({
    required double width,
    required Widget child,
    bool isHeader = false,
  }) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: isHeader ? 12 : 8,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
