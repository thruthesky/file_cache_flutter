import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/currency/currency.service.dart';
import 'package:philgo/globals.dart';

/// 환율 정보 화면
///
/// 실시간 환율 정보와 환율 계산기를 제공한다.
/// - USD, PHP, KRW 환율 표시
/// - 환율 계산기
/// - 25분 캐시 (CurrencyService)
class ExchangeRateScreen extends StatefulWidget {
  static const String routeName = '/exchange-rate';
  static Future push(BuildContext context) => context.push(routeName);

  const ExchangeRateScreen({super.key});

  @override
  State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
}

class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
  final _currencyService = CurrencyService.instance;

  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _amountController = TextEditingController(
    text: '1',
  );

  /// 기본값: PHP (필리핀 페소) - 필고 앱 사용자에게 가장 유용한 통화
  String _selectedCurrency = 'PHP';

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

  Future<void> _loadExchangeRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _currencyService.loadExchangeRates();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '환율 정보를 불러올 수 없습니다.\n네트워크 연결을 확인해주세요.';
        _isLoading = false;
      });
    }
  }

  Map<String, double> _calculateConversion() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _currencyService.calculateConversion(amount, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: color.surface,
        appBar: AppBar(
          backgroundColor: color.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: FaIcon(FontAwesomeIcons.lightXmark, color: color.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            '환율 정보',
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
                      await _currencyService.clearCache();
                      await _loadExchangeRates();
                    },
              tooltip: '환율 새로고침',
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildContent(),
      ),
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
            '환율 정보를 불러오는 중...',
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
              onPressed: _loadExchangeRates,
              icon: const FaIcon(FontAwesomeIcons.lightArrowsRotate, size: 16),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRateCards(),
          const SizedBox(height: 24),
          _buildCalculator(),
          const SizedBox(height: 16),
          _buildFooter(),
        ],
      ),
    );
  }

  /// 환율 정보 카드들
  Widget _buildRateCards() {
    final exchangeData = _currencyService.exchangeData;
    if (exchangeData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.lightChartLine,
                  size: 16,
                  color: color.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '오늘의 환율',
                style: text.titleMedium?.copyWith(
                  color: color.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exchangeData.date,
                  style: text.labelMedium?.copyWith(
                    color: color.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        /// PHP 카드
        _buildRateCard(
          flag: '🇵🇭',
          baseCurrency: 'PHP',
          baseCurrencyName: '필리핀 페소',
          baseAmount: 1,
          rates: exchangeData.phpRates,
          cardColor: color.primaryContainer.withValues(alpha: 0.3),
          accentColor: color.primary,
        ),
        const SizedBox(height: 8),

        /// USD 카드
        _buildRateCard(
          flag: '🇺🇸',
          baseCurrency: 'USD',
          baseCurrencyName: '미국 달러',
          baseAmount: 1,
          rates: exchangeData.usdRates,
          cardColor: color.secondaryContainer.withValues(alpha: 0.3),
          accentColor: color.secondary,
        ),
        const SizedBox(height: 8),

        /// KRW 카드 (1,000원 기준)
        _buildRateCard(
          flag: '🇰🇷',
          baseCurrency: 'KRW',
          baseCurrencyName: '한국 원',
          baseAmount: 1000,
          rates: exchangeData.krwRates,
          cardColor: color.tertiaryContainer.withValues(alpha: 0.3),
          accentColor: color.tertiary,
        ),
      ],
    );
  }

  /// 개별 환율 카드
  Widget _buildRateCard({
    required String flag,
    required String baseCurrency,
    required String baseCurrencyName,
    required int baseAmount,
    required Map<String, double> rates,
    required Color cardColor,
    required Color accentColor,
  }) {
    final baseAmountText = baseAmount == 1
        ? '1 $baseCurrency'
        : '${_currencyService.formatAmount(baseAmount.toDouble(), 'KRW')} $baseCurrency';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 왼쪽: 기준 통화 정보
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        baseAmountText,
                        style: text.titleMedium?.copyWith(
                          color: color.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        baseCurrencyName,
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 가운데: 세로 구분선
          Container(
            width: 1,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: accentColor.withValues(alpha: 0.3),
          ),

          /// 오른쪽: 환율 결과들
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: rates.entries.map((entry) {
                final targetCurrency = entry.key;
                final rate = entry.value * baseAmount;
                final targetFlag =
                    CurrencyService.currencyFlags[targetCurrency] ?? '';
                final targetName =
                    CurrencyService.currencyNames[targetCurrency] ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          targetFlag,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Text(
                          _currencyService.formatAmount(rate, targetCurrency),
                          style: text.titleSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 3,
                        child: Text(
                          targetName,
                          style: text.bodyMedium?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  /// 환율 계산기
  Widget _buildCalculator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCalculator,
                size: 18,
                color: color.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '환율 계산기',
                style: text.titleMedium?.copyWith(
                  color: color.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// 입력 영역
          Row(
            children: [
              /// 금액 입력
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: color.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: '금액 입력',
                    hintStyle: TextStyle(color: color.onSurfaceVariant),
                  ),
                  style: text.bodyLarge?.copyWith(
                    color: color.onSurface,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),

              /// 통화 선택
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      icon: FaIcon(
                        FontAwesomeIcons.lightChevronDown,
                        size: 14,
                        color: color.onSurfaceVariant,
                      ),
                      items: CurrencyService.currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency,
                          child: Row(
                            children: [
                              Text(
                                CurrencyService.currencyFlags[currency] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currency,
                                style: text.bodyMedium?.copyWith(
                                  color: color.onSurface,
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
          const SizedBox(height: 16),

          /// 변환 결과
          _buildConversionResults(),
        ],
      ),
    );
  }

  /// 변환 결과
  Widget _buildConversionResults() {
    final conversions = _calculateConversion();

    if (conversions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: conversions.entries.map((entry) {
          final currency = entry.key;
          final amount = entry.value;
          final flag = CurrencyService.currencyFlags[currency] ?? '';
          final name = CurrencyService.currencyNames[currency] ?? '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency,
                          style: text.bodyMedium?.copyWith(
                            color: color.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          name,
                          style: text.bodyMedium?.copyWith(
                            color: color.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _currencyService.formatAmount(amount, currency),
                  style: text.titleMedium?.copyWith(
                    color: color.primary,
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

  /// 푸터 (데이터 출처)
  Widget _buildFooter() {
    return Center(
      child: Text(
        '데이터 출처: Frankfurter API (유럽중앙은행)',
        style: text.bodyMedium?.copyWith(
          color: color.onSurfaceVariant,
        ),
      ),
    );
  }
}
