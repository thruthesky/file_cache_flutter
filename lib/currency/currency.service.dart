import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:philgo/currency/currency.model.dart';

/// 환율 서비스
///
/// Frankfurter API를 사용하여 환율 데이터를 가져오고 캐시한다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용한다.
///
/// 캐시 관리:
/// - 메모리 캐시 + 파일 캐시 이중 캐싱
/// - TTL: 25분
class CurrencyService {
  /// 싱글톤 인스턴스
  static CurrencyService? _instance;

  /// 싱글톤 인스턴스 접근자
  static CurrencyService get instance => _instance ??= CurrencyService._();

  /// 비공개 생성자
  CurrencyService._();

  /// 지원 통화 목록
  static const List<String> currencies = ['USD', 'PHP', 'KRW'];

  /// 통화 플래그 이모지
  static const Map<String, String> currencyFlags = {
    'USD': '🇺🇸',
    'PHP': '🇵🇭',
    'KRW': '🇰🇷',
  };

  /// 통화 이름
  static const Map<String, String> currencyNames = {
    'USD': '미국 달러',
    'PHP': '필리핀 페소',
    'KRW': '한국 원',
  };

  /// 캐시 TTL (25분)
  static const Duration cacheTtl = Duration(minutes: 25);

  /// 캐시 파일명
  static const String _cacheFileName = 'exchange_rate_cache.json';

  /// Frankfurter API 기본 URL
  static const String _apiBaseUrl = 'https://api.frankfurter.dev/v1';

  /// 현재 환율 데이터 (메모리 캐시)
  ExchangeRateData? _exchangeData;

  /// 메모리 캐시 저장 시간
  DateTime? _cachedAt;

  /// 환율 데이터 접근자
  ExchangeRateData? get exchangeData => _exchangeData;

  /// 캐시 파일 경로 반환
  Future<File> get _cacheFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  /// 파일 캐시에서 데이터 로드
  Future<ExchangeRateData?> _loadFromFileCache() async {
    try {
      final file = await _cacheFile;
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      /// TTL 확인
      final cachedAtStr = json['cachedAt'] as String?;
      if (cachedAtStr == null) return null;

      final cachedAt = DateTime.parse(cachedAtStr);
      if (DateTime.now().difference(cachedAt) > cacheTtl) {
        return null;
      }

      _cachedAt = cachedAt;
      return ExchangeRateData.fromJson(json['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// 파일 캐시에 데이터 저장
  Future<void> _saveToFileCache(ExchangeRateData data) async {
    try {
      final file = await _cacheFile;
      final json = {
        'cachedAt': DateTime.now().toIso8601String(),
        'data': data.toJson(),
      };
      await file.writeAsString(jsonEncode(json));
    } catch (_) {
      // 파일 캐시 저장 실패는 무시
    }
  }

  /// 메모리 캐시가 유효한지 확인
  bool get _isMemoryCacheValid {
    if (_exchangeData == null || _cachedAt == null) return false;
    return DateTime.now().difference(_cachedAt!) <= cacheTtl;
  }

  /// Frankfurter API에서 환율 데이터 가져오기
  Future<Map<String, double>> _fetchRatesFromApi(
    String base,
    String symbols,
  ) async {
    final url = Uri.parse('$_apiBaseUrl/latest?base=$base&symbols=$symbols');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = json['rates'] as Map<String, dynamic>;
      return rates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } else {
      throw Exception('환율 데이터를 가져오는데 실패했습니다.');
    }
  }

  /// API에서 모든 환율 데이터 가져오기
  Future<ExchangeRateData> _fetchFromApi() async {
    final usdRates = await _fetchRatesFromApi('USD', 'KRW,PHP');
    final phpRates = await _fetchRatesFromApi('PHP', 'KRW,USD');
    final krwRates = await _fetchRatesFromApi('KRW', 'PHP,USD');

    return ExchangeRateData(
      usdRates: usdRates,
      phpRates: phpRates,
      krwRates: krwRates,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
  }

  /// 환율 데이터 로드
  ///
  /// 1. 메모리 캐시에서 먼저 로드 시도
  /// 2. 파일 캐시에서 로드 시도
  /// 3. 캐시가 없거나 만료되면 API 호출
  /// 4. 새 데이터를 캐시에 저장
  Future<ExchangeRateData> loadExchangeRates() async {
    /// 1. 메모리 캐시 확인
    if (_isMemoryCacheValid) {
      return _exchangeData!;
    }

    /// 2. 파일 캐시 확인
    final fileCached = await _loadFromFileCache();
    if (fileCached != null) {
      _exchangeData = fileCached;
      return fileCached;
    }

    /// 3. API 호출
    final data = await _fetchFromApi();

    /// 4. 캐시 저장
    _exchangeData = data;
    _cachedAt = DateTime.now();
    await _saveToFileCache(data);

    return data;
  }

  /// 선택된 통화 기준 환율 가져오기
  Map<String, double> getRatesForCurrency(String currency) {
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

  /// 금액 포맷팅 (소수점 2자리)
  String formatAmount(double amount, String currency) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  /// 환율 변환 계산
  Map<String, double> calculateConversion(double amount, String fromCurrency) {
    final rates = getRatesForCurrency(fromCurrency);
    final result = <String, double>{};

    for (final currency in currencies) {
      if (currency == fromCurrency) continue;
      final rate = rates[currency] ?? 0;
      result[currency] = amount * rate;
    }

    return result;
  }

  /// 캐시 초기화
  Future<void> clearCache() async {
    _exchangeData = null;
    _cachedAt = null;
    try {
      final file = await _cacheFile;
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 파일 삭제 실패는 무시
    }
  }

  /// 캐시 남은 시간 조회
  Duration? get cacheRemainingTime {
    if (_cachedAt == null) return null;
    final elapsed = DateTime.now().difference(_cachedAt!);
    if (elapsed > cacheTtl) return null;
    return cacheTtl - elapsed;
  }
}
