/// 환율 데이터 모델
///
/// Frankfurter API에서 가져온 환율 데이터를 저장한다.
/// 캐시 만료 시간은 FileCache의 CacheEntry가 관리한다.
class ExchangeRateData {
  /// USD 기준 환율
  final Map<String, double> usdRates;

  /// PHP 기준 환율
  final Map<String, double> phpRates;

  /// KRW 기준 환율
  final Map<String, double> krwRates;

  /// 데이터 조회 날짜
  final String date;

  const ExchangeRateData({
    required this.usdRates,
    required this.phpRates,
    required this.krwRates,
    required this.date,
  });

  /// JSON에서 ExchangeRateData 객체 생성
  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    return ExchangeRateData(
      usdRates: Map<String, double>.from(json['usdRates']),
      phpRates: Map<String, double>.from(json['phpRates']),
      krwRates: Map<String, double>.from(json['krwRates']),
      date: json['date'] as String,
    );
  }

  /// ExchangeRateData를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'usdRates': usdRates,
      'phpRates': phpRates,
      'krwRates': krwRates,
      'date': date,
    };
  }
}
