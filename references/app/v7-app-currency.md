# 환율 서비스 (Currency Exchange) - Flutter 앱

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
- [3. 파일 구조](#3-파일-구조)
- [4. ExchangeRateData 모델](#4-exchangeratedata-모델)
- [5. CurrencyService](#5-currencyservice)
  - [5.1 싱글톤 패턴](#51-싱글톤-패턴)
  - [5.2 통화 상수](#52-통화-상수)
  - [5.3 캐시 전략](#53-캐시-전략)
  - [5.4 API 호출](#54-api-호출)
  - [5.5 환율 로드 흐름](#55-환율-로드-흐름)
  - [5.6 환율 변환 계산](#56-환율-변환-계산)
  - [5.7 금액 포맷팅](#57-금액-포맷팅)
  - [5.8 캐시 관리](#58-캐시-관리)
- [6. ExchangeRateScreen](#6-exchangeratescreen)
  - [6.1 라우팅](#61-라우팅)
  - [6.2 상태 관리](#62-상태-관리)
  - [6.3 UI 구성](#63-ui-구성)
  - [6.4 환율 카드](#64-환율-카드)
  - [6.5 환율 계산기](#65-환율-계산기)
- [7. 사용 예시](#7-사용-예시)

---

## 1. 개요

환율 서비스는 **Frankfurter API**(유럽중앙은행 데이터 기반)를 사용하여 USD, PHP, KRW 3개 통화의 실시간 환율을 조회하고 변환 계산을 제공한다.

| 항목 | 설명 |
|------|------|
| **외부 API** | Frankfurter API (`https://api.frankfurter.dev/v1`) |
| **v7 API 사용** | 사용하지 않음 (외부 API 직접 호출) |
| **지원 통화** | USD (미국 달러), PHP (필리핀 페소), KRW (한국 원) |
| **캐시** | 메모리 + 파일 이중 캐싱, TTL 25분 |
| **패턴** | 싱글톤 서비스 + StatefulWidget 화면 |

---

## 2. 아키텍처

```
[환율 데이터 흐름]

ExchangeRateScreen (UI)
    │
    ▼ _loadExchangeRates()
    │
CurrencyService.instance.loadExchangeRates()
    │
    ├─ [1순위] 메모리 캐시 확인 (_exchangeData + _cachedAt)
    │   └─ TTL 25분 이내 → 즉시 반환
    │
    ├─ [2순위] 파일 캐시 확인 (exchange_rate_cache.json)
    │   └─ TTL 25분 이내 → 메모리에 로드 후 반환
    │
    └─ [3순위] Frankfurter API 호출
        ├─ GET /latest?base=USD&symbols=KRW,PHP
        ├─ GET /latest?base=PHP&symbols=KRW,USD
        └─ GET /latest?base=KRW&symbols=PHP,USD
            └─ ExchangeRateData 생성 → 메모리/파일 캐시 저장 → 반환
```

---

## 3. 파일 구조

```
lib/currency/
├── currency.model.dart    # ExchangeRateData 모델 (환율 데이터)
├── currency.service.dart  # CurrencyService (싱글톤, 캐시, API)
└── currency.screen.dart   # ExchangeRateScreen (환율 카드 + 계산기)
```

---

## 4. ExchangeRateData 모델

`lib/currency/currency.model.dart`

```dart
class ExchangeRateData {
  /// USD 기준 환율 (예: {'KRW': 1501.61, 'PHP': 60.16})
  final Map<String, double> usdRates;

  /// PHP 기준 환율 (예: {'KRW': 24.96, 'USD': 0.02})
  final Map<String, double> phpRates;

  /// KRW 기준 환율 (예: {'PHP': 0.04, 'USD': 0.00067})
  final Map<String, double> krwRates;

  /// 데이터 조회 날짜 (예: '2026-03-20')
  final String date;

  const ExchangeRateData({
    required this.usdRates,
    required this.phpRates,
    required this.krwRates,
    required this.date,
  });

  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    return ExchangeRateData(
      usdRates: Map<String, double>.from(json['usdRates']),
      phpRates: Map<String, double>.from(json['phpRates']),
      krwRates: Map<String, double>.from(json['krwRates']),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usdRates': usdRates,
      'phpRates': phpRates,
      'krwRates': krwRates,
      'date': date,
    };
  }
}
```

---

## 5. CurrencyService

`lib/currency/currency.service.dart`

### 5.1 싱글톤 패턴

```dart
class CurrencyService {
  static CurrencyService? _instance;
  static CurrencyService get instance => _instance ??= CurrencyService._();
  CurrencyService._();

  ExchangeRateData? _exchangeData;
  DateTime? _cachedAt;

  ExchangeRateData? get exchangeData => _exchangeData;
}
```

### 5.2 통화 상수

```dart
static const List<String> currencies = ['USD', 'PHP', 'KRW'];

static const Map<String, String> currencyFlags = {
  'USD': '🇺🇸',
  'PHP': '🇵🇭',
  'KRW': '🇰🇷',
};

static const Map<String, String> currencyNames = {
  'USD': '미국 달러',
  'PHP': '필리핀 페소',
  'KRW': '한국 원',
};
```

### 5.3 캐시 전략

| 캐시 종류 | 저장 위치 | TTL | 특징 |
|-----------|----------|-----|------|
| **메모리 캐시** | `_exchangeData` + `_cachedAt` | 25분 | 앱 재시작 시 초기화 |
| **파일 캐시** | `exchange_rate_cache.json` (Documents 디렉토리) | 25분 | 앱 재시작 후에도 유지 |

**파일 캐시 JSON 구조:**

```json
{
  "cachedAt": "2026-03-20T13:52:00.000",
  "data": {
    "usdRates": {"KRW": 1501.61, "PHP": 60.16},
    "phpRates": {"KRW": 24.96, "USD": 0.02},
    "krwRates": {"PHP": 0.04, "USD": 0.00067},
    "date": "2026-03-20"
  }
}
```

**파일 캐시 로드 핵심 로직:**

```dart
Future<ExchangeRateData?> _loadFromFileCache() async {
  try {
    final file = await _cacheFile;
    if (!await file.exists()) return null;

    final content = await file.readAsString();
    final json = jsonDecode(content) as Map<String, dynamic>;

    final cachedAtStr = json['cachedAt'] as String?;
    if (cachedAtStr == null) return null;

    final cachedAt = DateTime.parse(cachedAtStr);
    if (DateTime.now().difference(cachedAt) > cacheTtl) {
      return null; // TTL 만료
    }

    _cachedAt = cachedAt;
    return ExchangeRateData.fromJson(json['data'] as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
}
```

**파일 캐시 저장:**

```dart
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
```

### 5.4 API 호출

Frankfurter API에서 각 통화별 환율을 개별 호출한다.

```dart
static const String _apiBaseUrl = 'https://api.frankfurter.dev/v1';

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

/// 3개 통화 각각에 대해 API 호출
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
```

### 5.5 환율 로드 흐름

```dart
Future<ExchangeRateData> loadExchangeRates() async {
  // 1. 메모리 캐시 확인
  if (_isMemoryCacheValid) {
    return _exchangeData!;
  }

  // 2. 파일 캐시 확인
  final fileCached = await _loadFromFileCache();
  if (fileCached != null) {
    _exchangeData = fileCached;
    return fileCached;
  }

  // 3. API 호출
  final data = await _fetchFromApi();

  // 4. 캐시 저장
  _exchangeData = data;
  _cachedAt = DateTime.now();
  await _saveToFileCache(data);

  return data;
}
```

### 5.6 환율 변환 계산

```dart
/// 특정 통화 기준 환율 맵 반환
Map<String, double> getRatesForCurrency(String currency) {
  if (_exchangeData == null) return {};
  switch (currency) {
    case 'USD': return _exchangeData!.usdRates;
    case 'PHP': return _exchangeData!.phpRates;
    case 'KRW': return _exchangeData!.krwRates;
    default: return {};
  }
}

/// 금액을 다른 통화로 변환
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
```

### 5.7 금액 포맷팅

```dart
/// 모든 통화를 소수점 2자리, 천단위 구분자로 포맷
String formatAmount(double amount, String currency) {
  final formatter = NumberFormat('#,##0.00');
  return formatter.format(amount);
}
```

### 5.8 캐시 관리

```dart
/// 캐시 초기화 (새로고침 시 사용)
Future<void> clearCache() async {
  _exchangeData = null;
  _cachedAt = null;
  try {
    final file = await _cacheFile;
    if (await file.exists()) {
      await file.delete();
    }
  } catch (_) {}
}

/// 캐시 남은 시간 조회
Duration? get cacheRemainingTime {
  if (_cachedAt == null) return null;
  final elapsed = DateTime.now().difference(_cachedAt!);
  if (elapsed > cacheTtl) return null;
  return cacheTtl - elapsed;
}
```

---

## 6. ExchangeRateScreen

`lib/currency/currency.screen.dart`

### 6.1 라우팅

```dart
class ExchangeRateScreen extends StatefulWidget {
  static const String routeName = '/exchange-rate';
  static Future push(BuildContext context) => context.push(routeName);
  const ExchangeRateScreen({super.key});
}
```

**GoRouter 등록** (`lib/router.dart`):

```dart
import 'package:philgo/currency/currency.screen.dart';

GoRoute(
  path: ExchangeRateScreen.routeName,
  name: ExchangeRateScreen.routeName,
  builder: (context, state) => const ExchangeRateScreen(),
),
```

### 6.2 상태 관리

- `_isLoading: bool` — 로딩 상태
- `_errorMessage: String?` — 에러 메시지
- `_amountController: TextEditingController` — 계산기 입력 (기본값 '1')
- `_selectedCurrency: String` — 선택된 기준 통화 (기본값 'PHP')

### 6.3 UI 구성

```
┌────────────────────────────────────┐
│ AppBar: "환율 정보" + 새로고침 버튼   │
├────────────────────────────────────┤
│ 섹션 헤더: "오늘의 환율" + 날짜 배지   │
│                                    │
│ [PHP 환율 카드] (primaryContainer)  │
│  1 PHP → KRW, USD                 │
│                                    │
│ [USD 환율 카드] (secondaryContainer)│
│  1 USD → KRW, PHP                 │
│                                    │
│ [KRW 환율 카드] (tertiaryContainer) │
│  1,000 KRW → PHP, USD             │
│                                    │
│ ─── 환율 계산기 ───                  │
│ [금액 입력] [통화 드롭다운]           │
│ [변환 결과: USD / KRW]              │
│                                    │
│ 데이터 출처: Frankfurter API        │
└────────────────────────────────────┘
```

**3상태 렌더링:** 로딩 → 에러 → 콘텐츠

```dart
body: _isLoading
    ? _buildLoadingState()
    : _errorMessage != null
        ? _buildErrorState()
        : _buildContent(),
```

### 6.4 환율 카드

각 통화별로 색상이 구분된 카드를 표시한다. 레이아웃: 왼쪽(기준 통화 + 플래그) | 세로 구분선 | 오른쪽(환율 결과 목록)

| 통화 | 기준 금액 | 카드 색상 | 악센트 색상 |
|------|----------|----------|-----------|
| PHP | 1 | `primaryContainer (0.3)` | `primary` |
| USD | 1 | `secondaryContainer (0.3)` | `secondary` |
| KRW | 1,000 | `tertiaryContainer (0.3)` | `tertiary` |

**카드 핵심 코드:**

```dart
_buildRateCard(
  flag: '🇵🇭',
  baseCurrency: 'PHP',
  baseCurrencyName: '필리핀 페소',
  baseAmount: 1,
  rates: exchangeData.phpRates,
  cardColor: color.primaryContainer.withValues(alpha: 0.3),
  accentColor: color.primary,
),
```

### 6.5 환율 계산기

- **입력**: TextField (숫자+소수점) + DropdownButton (USD/PHP/KRW)
- **기본 통화**: PHP (필고 앱 사용자에게 가장 유용)
- **변환 결과**: 나머지 2개 통화의 변환 금액 표시
- **실시간 계산**: `onChanged: (_) => setState(() {})` — 입력 변경 시 즉시 재계산

```dart
Map<String, double> _calculateConversion() {
  final amount = double.tryParse(_amountController.text) ?? 0;
  return _currencyService.calculateConversion(amount, _selectedCurrency);
}
```

---

## 7. 사용 예시

### 환율 화면 열기

```dart
// push로 열기
ExchangeRateScreen.push(context);

// 또는 직접 라우트 push
context.push('/exchange-rate');
```

### 서비스 직접 사용

```dart
import 'package:philgo/currency/currency.service.dart';

// 환율 데이터 로드
final data = await CurrencyService.instance.loadExchangeRates();

// PHP → KRW 환율 조회
final phpToKrw = data.phpRates['KRW']; // 예: 24.96

// USD → KRW 환율 조회
final usdToKrw = data.usdRates['KRW']; // 예: 1501.61

// 100 USD를 다른 통화로 변환
final result = CurrencyService.instance.calculateConversion(100, 'USD');
// result: {'KRW': 150161.0, 'PHP': 6016.0}

// 금액 포맷팅
final formatted = CurrencyService.instance.formatAmount(150161.0, 'KRW');
// formatted: '150,161.00'

// 캐시 초기화 (강제 새로고침)
await CurrencyService.instance.clearCache();
```

### 의존 패키지

```yaml
# pubspec.yaml
dependencies:
  http: ^1.x         # Frankfurter API 호출
  intl: ^0.x         # NumberFormat (금액 포맷팅)
  path_provider: ^2.x # 파일 캐시 경로
```
