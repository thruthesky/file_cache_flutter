import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/entry/entry.login.screen.dart';
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
  /// PHP→KRW 환율 (소수점 2자리) (PHP to KRW exchange rate)
  double? _phpToKrwRate;

  /// 환율 로딩 상태 (Exchange rate loading state)
  bool _isLoadingRate = true;

  @override
  void initState() {
    super.initState();
    _fetchExchangeRate();
  }

  /// Frankfurter API에서 PHP→KRW 환율 조회 (Fetch PHP to KRW rate from API)
  ///
  /// API 호출 실패 시에도 UI는 정상 표시됩니다 (rate는 null로 표시).
  Future<void> _fetchExchangeRate() async {
    try {
      final url = Uri.parse(
        'https://api.frankfurter.dev/v1/latest?base=PHP&symbols=KRW',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = json['rates'] as Map<String, dynamic>;
        final krwRate = (rates['KRW'] as num).toDouble();

        if (mounted) {
          setState(() {
            _phpToKrwRate = krwRate;
            _isLoadingRate = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingRate = false);
        }
      }
    } catch (e) {
      // API 호출 실패 시 로딩 상태만 해제
      if (mounted) {
        setState(() => _isLoadingRate = false);
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
                    pageBuilder: (
                      BuildContext buildContext,
                      Animation animation,
                      Animation secondaryAnimation,
                    ) {
                      return const EntryLoginScreen();
                    },
                    transitionBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
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

  /// 4열 정보 섹션 빌드 (Build 4-column info section)
  ///
  /// 오늘 환율 | 오늘 날씨 | 회원 수 | 글 수
  Widget _buildInfoSection(
    BuildContext context,
    Lo l10n,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 오늘 환율 - PHP→KRW (소수점 2자리)
        _buildInfoColumn(
          label: l10n.entryTodayExchangeRate,
          value:
              _isLoadingRate
                  ? '...'
                  : (_phpToKrwRate?.toStringAsFixed(2) ?? '-'),
          theme: theme,
          scheme: scheme,
        ),
        // 오늘 날씨 - 하드코딩 (Sunny)
        _buildInfoColumn(
          label: l10n.entryTodayWeather,
          value: l10n.weatherSunny,
          theme: theme,
          scheme: scheme,
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
  /// 상단: 레이블 (labelSmall, onSurfaceVariant)
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
        // 레이블 - 작은 텍스트, 연한 색상
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
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
}
