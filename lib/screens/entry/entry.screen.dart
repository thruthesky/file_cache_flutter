import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

  /// PHP→KRW 환율 (소수점 2자리) (PHP to KRW exchange rate)
  double? _phpToKrwRate;

  /// 환율 로딩 상태 (Exchange rate loading state)
  bool _isLoadingRate = true;

  /// 마닐라 현재 날씨 (Manila current weather)
  HourlyWeather? _manilaWeather;

  /// 날씨 로딩 상태 (Weather loading state)
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
    _fetchManilaWeather();
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

              const SizedBox(height: 32),

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
        // 공지 - 하드코딩 (3개)
        // TODO: 실제 공지 개수로 변경 예정
        _buildInfoColumn(
          label: l10n.quickMenuNotice,
          value: '3개',
          theme: theme,
          scheme: scheme,
        ),
        // 오늘 환율 - 클릭 시 환율 정보 화면 열기 (Tap to open exchange rate screen)
        GestureDetector(
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
        GestureDetector(
          onTap: () => showFullScreen(
            context,
            child: const WeatherScreen(),
            barrierLabel: '날씨 정보 닫기',
          ),
          child: _buildWeatherColumn(l10n, theme, scheme),
        ),
        // 회원 수 - 하드코딩 (0)
        _buildInfoColumn(
          label: l10n.entryMemberCount,
          value: '0',
          theme: theme,
          scheme: scheme,
        ),
        // 글 수 - 하드코딩 (0)
        _buildInfoColumn(
          label: l10n.entryPostCount,
          value: '0',
          theme: theme,
          scheme: scheme,
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
    final description =
        WeatherCodeHelper.getDescription(_manilaWeather!.weatherCode);

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
            FaIcon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              description,
              style:
                  theme.textTheme.titleMedium?.copyWith(color: scheme.primary),
            ),
          ],
        ),
      ],
    );
  }
}
