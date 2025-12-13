import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/unfocus_on_tap.dart';
import 'package:intl/intl.dart';

/// 환율 데이터 모델 (Exchange Rate Data Model)
///
/// Frankfurter API에서 가져온 환율 데이터를 저장합니다.
/// Stores exchange rate data fetched from Frankfurter API.
class ExchangeRateData {
  /// USD 기준 환율 (USD base rates)
  final Map<String, double> usdRates;

  /// PHP 기준 환율 (PHP base rates)
  final Map<String, double> phpRates;

  /// KRW 기준 환율 (KRW base rates)
  final Map<String, double> krwRates;

  /// 데이터 조회 날짜 (Data fetch date)
  final String date;

  /// 캐시 만료 시간 (Cache expiry time)
  final DateTime expiresAt;

  const ExchangeRateData({
    required this.usdRates,
    required this.phpRates,
    required this.krwRates,
    required this.date,
    required this.expiresAt,
  });

  /// JSON에서 ExchangeRateData 객체 생성 (Create from JSON)
  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    return ExchangeRateData(
      usdRates: Map<String, double>.from(json['usdRates']),
      phpRates: Map<String, double>.from(json['phpRates']),
      krwRates: Map<String, double>.from(json['krwRates']),
      date: json['date'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// ExchangeRateData를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    return {
      'usdRates': usdRates,
      'phpRates': phpRates,
      'krwRates': krwRates,
      'date': date,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// 캐시가 만료되었는지 확인 (Check if cache is expired)
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// 환율 정보 화면 (Exchange Rate Screen)
///
/// 실시간 환율 정보와 환율 계산기를 제공합니다.
/// Provides real-time exchange rate information and currency calculator.
///
/// ### 기능 (Features):
/// - USD, PHP, KRW 환율 표시 (Display USD, PHP, KRW exchange rates)
/// - 환율 계산기 (Currency calculator)
/// - 10분 캐시 (10-minute cache)
///
/// ### 사용법 (Usage):
/// ```dart
/// showFullScreen(
///   context,
///   child: const ExchangeRateScreen(),
///   barrierLabel: '환율 정보 닫기',
/// );
/// ```
class ExchangeRateScreen extends StatefulWidget {
  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  /// 환율 데이터 (Exchange rate data)
  ExchangeRateData? _exchangeData;

  /// 로딩 상태 (Loading state)
  bool _isLoading = true;

  /// 에러 메시지 (Error message)
  String? _errorMessage;

  /// 계산기 입력 금액 (Calculator input amount)
  final TextEditingController _amountController =
      TextEditingController(text: '1');

  /// 선택된 기준 통화 (Selected base currency)
  /// 기본값: PHP (필리핀 페소) - 필고 앱 사용자에게 가장 유용한 통화
  /// Default: PHP (Philippine Peso) - most useful for Philgo app users
  String _selectedCurrency = 'PHP';

  /// 지원 통화 목록 (Supported currencies)
  static const List<String> _currencies = ['USD', 'PHP', 'KRW'];

  /// 통화 플래그 이모지 (Currency flag emojis)
  static const Map<String, String> _currencyFlags = {
    'USD': '🇺🇸',
    'PHP': '🇵🇭',
    'KRW': '🇰🇷',
  };

  /// 통화 이름 (Currency names)
  static const Map<String, String> _currencyNames = {
    'USD': '미국 달러',
    'PHP': '필리핀 페소',
    'KRW': '한국 원',
  };

  /// 캐시 파일명 (Cache filename)
  static const String _cacheFileName = 'exchange_rate_cache.json';

  /// 캐시 TTL (10분) (Cache TTL - 10 minutes)
  static const Duration _cacheTtl = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _loadExchangeRates();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// 캐시 파일 경로 가져오기 (Get cache file path)
  Future<File> _getCacheFile() async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/$_cacheFileName');
  }

  /// 캐시에서 환율 데이터 로드 (Load exchange rate data from cache)
  Future<ExchangeRateData?> _loadFromCache() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        final data = ExchangeRateData.fromJson(json);

        /// 캐시가 만료되지 않았으면 반환 (Return if cache is not expired)
        if (!data.isExpired) {
          return data;
        }
      }
    } catch (e) {
      /// 캐시 로드 실패 시 무시 (Ignore cache load failure)
      debugPrint('캐시 로드 실패: $e');
    }
    return null;
  }

  /// 캐시에 환율 데이터 저장 (Save exchange rate data to cache)
  Future<void> _saveToCache(ExchangeRateData data) async {
    try {
      final file = await _getCacheFile();
      await file.writeAsString(jsonEncode(data.toJson()));
    } catch (e) {
      /// 캐시 저장 실패 시 무시 (Ignore cache save failure)
      debugPrint('캐시 저장 실패: $e');
    }
  }

  /// Frankfurter API에서 환율 데이터 가져오기 (Fetch exchange rates from Frankfurter API)
  Future<Map<String, double>> _fetchRatesFromApi(
    String base,
    String symbols,
  ) async {
    final url = Uri.parse(
      'https://api.frankfurter.dev/v1/latest?base=$base&symbols=$symbols',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = json['rates'] as Map<String, dynamic>;
      return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
    } else {
      throw Exception('환율 데이터를 가져오는데 실패했습니다. (Failed to fetch exchange rates)');
    }
  }

  /// 환율 데이터 로드 (Load exchange rates)
  Future<void> _loadExchangeRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      /// 1. 캐시에서 먼저 로드 시도 (Try loading from cache first)
      final cachedData = await _loadFromCache();
      if (cachedData != null) {
        setState(() {
          _exchangeData = cachedData;
          _isLoading = false;
        });
        return;
      }

      /// 2. 캐시가 없거나 만료되면 API 호출 (Call API if cache is missing or expired)
      final usdRates = await _fetchRatesFromApi('USD', 'KRW,PHP');
      final phpRates = await _fetchRatesFromApi('PHP', 'KRW,USD');
      final krwRates = await _fetchRatesFromApi('KRW', 'PHP,USD');

      final data = ExchangeRateData(
        usdRates: usdRates,
        phpRates: phpRates,
        krwRates: krwRates,
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        expiresAt: DateTime.now().add(_cacheTtl),
      );

      /// 3. 캐시에 저장 (Save to cache)
      await _saveToCache(data);

      setState(() {
        _exchangeData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '환율 정보를 불러올 수 없습니다.\n네트워크 연결을 확인해주세요.';
        _isLoading = false;
      });
    }
  }

  /// 선택된 통화 기준 환율 가져오기 (Get rates for selected currency)
  Map<String, double> _getRatesForCurrency(String currency) {
    if (_exchangeData == null) return {};

    switch (currency) {
      case 'USD':
        return _exchangeData!.usdRates;
      case 'PHP':
        return _exchangeData!.phpRates;
      case 'KRW':
        return _exchangeData!.krwRates;
      default:
        return {};
    }
  }

  /// 금액 포맷팅 (Format amount)
  String _formatAmount(double amount, String currency) {
    final formatter = NumberFormat('#,##0.00');
    if (currency == 'KRW') {
      /// KRW는 소수점 없이 표시 (KRW displays without decimals)
      return NumberFormat('#,##0').format(amount);
    }
    return formatter.format(amount);
  }

  /// 환율 계산 (Calculate exchange rate)
  Map<String, double> _calculateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final rates = _getRatesForCurrency(_selectedCurrency);
    final result = <String, double>{};

    for (final currency in _currencies) {
      if (currency == _selectedCurrency) continue;
      final rate = rates[currency] ?? 0;
      result[currency] = amount * rate;
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// UnfocusOnTap: 화면 빈 영역 탭 시 키보드 dismiss
    /// Dismiss keyboard when tapping on empty area
    return UnfocusOnTap(
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: FaIcon(
              FontAwesomeIcons.lightXmark,
              color: scheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '환율 정보',
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
              onPressed: _isLoading ? null : _loadExchangeRates,
              tooltip: '환율 새로고침',
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState(scheme)
            : _errorMessage != null
                ? _buildErrorState(scheme, theme, sp)
                : _buildContent(context, theme, scheme, sp),
      ),
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
            '환율 정보를 불러오는 중...',
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
              onPressed: _loadExchangeRates,
              icon: const FaIcon(FontAwesomeIcons.lightArrowsRotate, size: 16),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 컨텐츠 (Main content)
  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return SingleChildScrollView(
      /// 드래그 시 키보드 자동 dismiss (Auto dismiss keyboard on drag)
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.all(sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 환율 정보 카드 (Exchange rate info cards)
          _buildRateCards(theme, scheme, sp),
          SizedBox(height: sp.s24),

          /// 환율 계산기 (Currency calculator)
          _buildCalculator(theme, scheme, sp),
          SizedBox(height: sp.s16),

          /// 데이터 출처 및 날짜 (Data source and date)
          _buildFooter(theme, scheme, sp),
        ],
      ),
    );
  }

  /// 환율 정보 카드 빌드 (Build exchange rate cards)
  ///
  /// 각 통화별로 개별 카드를 사용하여 시각적으로 구분합니다.
  /// Uses individual cards for each currency for visual distinction.
  Widget _buildRateCards(ThemeData theme, ColorScheme scheme, AppSpacing sp) {
    if (_exchangeData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (Section header)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sp.s4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.lightChartLine,
                  size: 16,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: sp.s12),
              Text(
                '오늘의 환율',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_exchangeData != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s8,
                    vertical: sp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _exchangeData!.date,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 환율 카드들 (Exchange rate cards)
        /// 순서: PHP → USD → KRW (1,000)
        /// Order: PHP → USD → KRW (1,000)
        _buildRateCard(
          theme: theme,
          scheme: scheme,
          sp: sp,
          flag: '🇵🇭',
          baseCurrency: 'PHP',
          baseCurrencyName: '필리핀 페소',
          baseAmount: 1,
          rates: _exchangeData!.phpRates,
          cardColor: scheme.primaryContainer.withValues(alpha: 0.3),
          accentColor: scheme.primary,
        ),
        SizedBox(height: sp.s8),
        _buildRateCard(
          theme: theme,
          scheme: scheme,
          sp: sp,
          flag: '🇺🇸',
          baseCurrency: 'USD',
          baseCurrencyName: '미국 달러',
          baseAmount: 1,
          rates: _exchangeData!.usdRates,
          cardColor: scheme.secondaryContainer.withValues(alpha: 0.3),
          accentColor: scheme.secondary,
        ),
        SizedBox(height: sp.s8),
        _buildRateCard(
          theme: theme,
          scheme: scheme,
          sp: sp,
          flag: '🇰🇷',
          baseCurrency: 'KRW',
          baseCurrencyName: '한국 원',
          baseAmount: 1000,
          rates: _exchangeData!.krwRates,
          cardColor: scheme.tertiaryContainer.withValues(alpha: 0.3),
          accentColor: scheme.tertiary,
        ),
      ],
    );
  }

  /// 개별 환율 카드 빌드 (Build individual rate card)
  ///
  /// 각 통화별로 시각적으로 구분되는 카드를 생성합니다.
  /// 레이아웃: 왼쪽에 기준 통화, 세로 구분선, 오른쪽에 환율 결과 (세로 나열)
  /// Creates visually distinct cards for each currency.
  /// Layout: Base currency on left, vertical divider, exchange rates on right (vertical)
  Widget _buildRateCard({
    required ThemeData theme,
    required ColorScheme scheme,
    required AppSpacing sp,
    required String flag,
    required String baseCurrency,
    required String baseCurrencyName,
    required int baseAmount,
    required Map<String, double> rates,
    required Color cardColor,
    required Color accentColor,
  }) {
    /// 기준 금액 포맷팅 (Format base amount)
    final baseAmountText = baseAmount == 1
        ? '1 $baseCurrency'
        : '${NumberFormat('#,###').format(baseAmount)} $baseCurrency';

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 왼쪽: 기준 통화 정보 (Left: Base currency info)
          Expanded(
            flex: 2,
            child: Row(
              children: [
                /// 플래그 (Flag)
                Text(flag, style: const TextStyle(fontSize: 28)),
                SizedBox(width: sp.s12),

                /// 통화 정보 (Currency info)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        baseAmountText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        baseCurrencyName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 가운데: 세로 구분선 (Center: Vertical divider)
          Container(
            width: 1,
            height: 60,
            margin: EdgeInsets.symmetric(horizontal: sp.s16),
            color: accentColor.withValues(alpha: 0.3),
          ),

          /// 오른쪽: 환율 결과들 (Right: Exchange rate results)
          /// 한 줄로 표시: [아이콘] [환율] [통화명]
          /// Single line display: [icon] [rate] [currency name]
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: rates.entries.map((entry) {
                final targetCurrency = entry.key;

                /// baseAmount를 곱하여 환율 계산 (Multiply by baseAmount)
                final rate = entry.value * baseAmount;
                final targetFlag = _currencyFlags[targetCurrency] ?? '';
                final targetName = _currencyNames[targetCurrency] ?? '';

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: sp.s4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      /// 대상 통화 플래그 (Target currency flag)
                      /// 고정 너비로 세로 정렬 (Fixed width for vertical alignment)
                      SizedBox(
                        width: 28,
                        child: Text(
                          targetFlag,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),

                      /// 환율 값 (Rate value)
                      /// 고정 너비로 세로 정렬 (Fixed width for vertical alignment)
                      SizedBox(
                        width: 70,
                        child: Text(
                          _formatAmount(rate, targetCurrency),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),

                      SizedBox(width: sp.s8),

                      /// 통화명 (Currency name)
                      /// 고정 너비로 세로 정렬 (Fixed width for vertical alignment)
                      SizedBox(
                        width: 56,
                        child: Text(
                          targetName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 환율 계산기 빌드 (Build currency calculator)
  Widget _buildCalculator(ThemeData theme, ColorScheme scheme, AppSpacing sp) {
    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (Section header)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCalculator,
                size: 18,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '환율 계산기',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 입력 영역 (Input area)
          Row(
            children: [
              /// 금액 입력 (Amount input)
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: sp.s16,
                      vertical: sp.s12,
                    ),
                    hintText: '금액 입력',
                    hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: sp.s8),

              /// 통화 선택 (Currency selection)
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      icon: FaIcon(
                        FontAwesomeIcons.lightChevronDown,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      items: _currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Row(
                            children: [
                              Text(
                                _currencyFlags[currency] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              SizedBox(width: sp.s4),
                              Text(
                                currency,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCurrency = value);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 변환 결과 (Conversion results)
          _buildConversionResults(theme, scheme, sp),
        ],
      ),
    );
  }

  /// 변환 결과 빌드 (Build conversion results)
  Widget _buildConversionResults(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final conversions = _calculateConversion();

    if (conversions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: conversions.entries.map((entry) {
          final currency = entry.key;
          final amount = entry.value;
          final flag = _currencyFlags[currency] ?? '';
          final name = _currencyNames[currency] ?? '';

          return Padding(
            padding: EdgeInsets.symmetric(vertical: sp.s4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    SizedBox(width: sp.s8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _formatAmount(amount, currency),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 푸터 빌드 (Build footer)
  ///
  /// 데이터 출처만 표시 (날짜는 헤더에 표시됨)
  /// Only shows data source (date is shown in header)
  Widget _buildFooter(ThemeData theme, ColorScheme scheme, AppSpacing sp) {
    return Center(
      child: Text(
        '데이터 출처: Frankfurter API (유럽중앙은행)',
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
