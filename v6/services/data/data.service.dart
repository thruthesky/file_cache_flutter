import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:philgo/config/app.config.dart';
import 'package:file_cache_flutter/file_cache_flutter.dart';

import 'mofa_notice.model.dart';

/// 공공데이터 포털 API 서비스 (Public Data Portal API Service)
///
/// 대한민국 공공데이터포털(data.go.kr) API를 사용하여
/// 다양한 공공 데이터를 가져오고 캐시합니다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용합니다.
///
/// ### 지원 API (Supported APIs):
/// - 외교부 공지사항 (MOFA Notices)
///
/// ### 캐시 관리 (Cache Management):
/// FileCache를 사용하여 캐시를 관리합니다.
/// - 외교부 공지사항 TTL: 48시간
/// - 메모리 + 파일 이중 캐싱
///
/// ### 사용법 (Usage):
/// ```dart
/// // 외교부 공지사항 로드 (최근 5개)
/// final response = await DataService.instance.loadMofaNotices();
///
/// // 공지사항 목록 접근
/// final notices = response.notices;
///
/// // 캐시 초기화
/// await DataService.instance.clearMofaCache();
/// ```
class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();

  /// 공공 데이터 포털 API를 요청할 때 사용하는 encoding 된 Key
  /// (Public Data Portal API key - URL encoded)
  static const String apiKey = AppConfig.dataApiKey;

  /// 디버그 모드 플래그 (Debug mode flag)
  ///
  /// true로 설정하면 API 호출 및 캐시 관련 상세 로그가 출력됩니다.
  /// Set to true to enable detailed logging for API calls and caching.
  ///
  /// ### 사용법 (Usage):
  /// ```dart
  /// // 디버그 모드 활성화
  /// DataService.instance.debug = true;
  ///
  /// // 디버그 모드 비활성화
  /// DataService.instance.debug = false;
  /// ```
  bool debug = false;

  /// 디버그 로그 출력 헬퍼 (Debug log helper)
  ///
  /// [debug]가 true일 때만 로그를 출력합니다.
  /// Only prints log when [debug] is true.
  void _log(String message) {
    if (debug) {
      debugPrint(message);
    }
  }

  DataService._();

  // ============================================================
  // 외교부 공지사항 API (MOFA Notice API)
  // ============================================================

  /// 외교부 공지사항 API 기본 URL (MOFA Notice API base URL)
  static const String _mofaApiBaseUrl =
      'http://apis.data.go.kr/1262000/NoticeService2/getNoticeList2';

  /// 외교부 공지사항 캐시 TTL (48시간) (MOFA Notice cache TTL - 48 hours)
  static const Duration _mofaCacheTtl = Duration(hours: 48);

  /// 외교부 공지사항 캐시 키 (MOFA Notice cache key)
  static const String _mofaCacheKey = 'mofa_notices_2';

  /// 가져올 공지사항 개수 (Number of notices to fetch)
  static const int _mofaNumOfRows = 5;

  /// 외교부 공지사항 전용 캐시 (File cache for MOFA notices)
  ///
  /// FileCache 인스턴스를 사용하여 데이터를 캐시합니다.
  /// 1시간 TTL로 설정되어 있으며, 메모리+파일 이중 캐싱을 사용합니다.
  late final FileCache<MofaNoticeResponse> _mofaCache =
      FileCache<MofaNoticeResponse>(
        cacheName: 'mofa_notices',
        defaultTtl: _mofaCacheTtl,
        fromJson: MofaNoticeResponse.fromJson,
        toJson: (data) => data.toJson(),
        useMemoryCache: true,
      );

  /// 현재 외교부 공지사항 데이터 (Current MOFA notice data)
  /// loadMofaNotices() 호출 후 사용 가능합니다.
  MofaNoticeResponse? _mofaData;

  /// 외교부 공지사항 데이터 접근자 (MOFA notice data accessor)
  MofaNoticeResponse? get mofaData => _mofaData;

  /// 외교부 공지사항 API 호출 (Fetch MOFA notices from API)
  ///
  /// 공공데이터포털의 외교부 공지사항 API를 호출합니다.
  /// - 최근 5개 공지사항을 가져옵니다.
  /// - JSON 형식으로 응답을 받습니다.
  ///
  /// ### API 파라미터:
  /// - serviceKey: 공공데이터포털 발급 인증키 (URL Encoded)
  /// - returnType: JSON
  /// - numOfRows: 5 (최근 5개)
  /// - pageNo: 1 (첫 페이지)
  ///
  /// Returns 외교부 공지사항 응답 데이터
  /// Throws [Exception] if API call fails
  Future<MofaNoticeResponse> _fetchMofaFromApi() async {
    _log('═══════════════════════════════════════════════════════════');
    _log('📡 [MOFA API] 외교부 공지사항 API 호출 시작');
    _log('═══════════════════════════════════════════════════════════');

    /// API URL 구성 (Build API URL)
    /// serviceKey는 이미 URL Encoded 상태이므로 그대로 사용
    /// serviceKey is already URL encoded, use as-is
    final url = Uri.parse(
      '$_mofaApiBaseUrl?'
      'serviceKey=$apiKey&'
      'returnType=JSON&'
      'numOfRows=$_mofaNumOfRows&'
      'pageNo=1',
    );

    _log('🔗 [MOFA API] 요청 URL: $url');
    _log('🔑 [MOFA API] API Key 길이: ${apiKey.length}');
    _log('🔑 [MOFA API] API Key 시작: ${apiKey.substring(0, 10)}...');

    try {
      _log('⏳ [MOFA API] HTTP GET 요청 전송 중...');
      final response = await http.get(url);

      _log('📥 [MOFA API] HTTP 응답 수신');
      _log('📥 [MOFA API] HTTP 상태 코드: ${response.statusCode}');
      _log('📥 [MOFA API] 응답 바이트 크기: ${response.bodyBytes.length}');

      if (response.statusCode == 200) {
        /// UTF-8 디코딩 (한글 깨짐 방지)
        /// UTF-8 decoding to prevent Korean character corruption
        final decodedBody = utf8.decode(response.bodyBytes);
        _log('📄 [MOFA API] UTF-8 디코딩 완료');
        _log(
          '📄 [MOFA API] 응답 본문 (처음 500자):\n${decodedBody.substring(0, decodedBody.length > 500 ? 500 : decodedBody.length)}...',
        );

        final json = jsonDecode(decodedBody) as Map<String, dynamic>;
        _log('🔄 [MOFA API] JSON 파싱 완료');
        _log('🔄 [MOFA API] JSON 최상위 키: ${json.keys.toList()}');

        /// response 객체 확인 (Check response object)
        if (json.containsKey('response')) {
          final responseObj = json['response'] as Map<String, dynamic>?;
          _log('✅ [MOFA API] response 객체 존재');
          _log('✅ [MOFA API] response 키: ${responseObj?.keys.toList()}');

          if (responseObj != null) {
            /// header 확인 (Check header)
            final header = responseObj['header'] as Map<String, dynamic>?;
            _log('📋 [MOFA API] header: $header');

            /// body 확인 (Check body)
            final body = responseObj['body'] as Map<String, dynamic>?;
            _log('📋 [MOFA API] body 키: ${body?.keys.toList()}');
            _log('📋 [MOFA API] totalCount: ${body?['totalCount']}');
            _log('📋 [MOFA API] numOfRows: ${body?['numOfRows']}');
            _log('📋 [MOFA API] pageNo: ${body?['pageNo']}');

            /// items 확인 (Check items)
            final items = body?['items'] as Map<String, dynamic>?;
            _log('📋 [MOFA API] items 키: ${items?.keys.toList()}');

            /// item 배열 확인 (Check item array)
            final itemList = items?['item'];
            _log('📋 [MOFA API] item 타입: ${itemList?.runtimeType}');
            if (itemList is List) {
              _log('📋 [MOFA API] item 개수: ${itemList.length}');
              if (itemList.isNotEmpty) {
                _log('📋 [MOFA API] 첫 번째 item: ${itemList[0]}');
              }
            }
          }
        } else {
          _log('❌ [MOFA API] response 객체가 없습니다!');
          _log('❌ [MOFA API] 전체 JSON: $json');
        }

        /// API 응답 파싱 (Parse API response)
        /// 실제 API 응답 구조: response.header.resultCode, response.body.items.item[]
        _log('🔄 [MOFA API] MofaNoticeResponse.fromApiJson 호출 중...');
        final mofaResponse = MofaNoticeResponse.fromApiJson(json);

        _log('═══════════════════════════════════════════════════════════');
        _log('📊 [MOFA API] 파싱 결과:');
        _log('📊 [MOFA API] - resultCode: ${mofaResponse.resultCode}');
        _log('📊 [MOFA API] - resultMsg: ${mofaResponse.resultMsg}');
        _log('📊 [MOFA API] - isSuccess: ${mofaResponse.isSuccess}');
        _log('📊 [MOFA API] - totalCount: ${mofaResponse.totalCount}');
        _log('📊 [MOFA API] - notices 개수: ${mofaResponse.notices.length}');
        _log('═══════════════════════════════════════════════════════════');

        if (mofaResponse.isSuccess) {
          _log('✅ [MOFA API] API 호출 성공!');
          for (int i = 0; i < mofaResponse.notices.length; i++) {
            final notice = mofaResponse.notices[i];
            _log(
              '  📌 [$i] ${notice.id}: ${notice.title.substring(0, notice.title.length > 30 ? 30 : notice.title.length)}...',
            );
          }
        } else {
          _log(
            '❌ [MOFA API] API 에러: [${mofaResponse.resultCode}] ${mofaResponse.resultMsg}',
          );
        }

        return mofaResponse;
      } else {
        _log('❌ [MOFA API] HTTP 오류: ${response.statusCode}');
        _log('❌ [MOFA API] 응답 본문: ${response.body}');
        throw Exception('외교부 공지사항을 가져오는데 실패했습니다. HTTP ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _log('❌ [MOFA API] 예외 발생: $e');
      _log('❌ [MOFA API] 스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// 외교부 공지사항 로드 (Load MOFA notices)
  ///
  /// 캐시 우선 전략을 사용합니다:
  /// 1. 캐시에서 먼저 로드 시도
  /// 2. 캐시가 없거나 만료되면 API 호출
  /// 3. 새 데이터를 캐시에 저장
  ///
  /// Returns 외교부 공지사항 응답 데이터 (캐시 또는 API에서 가져옴)
  Future<MofaNoticeResponse> loadMofaNotices() async {
    _log('═══════════════════════════════════════════════════════════');
    _log('🚀 [MOFA LOAD] loadMofaNotices() 호출됨');
    _log('═══════════════════════════════════════════════════════════');

    /// 1. 캐시에서 먼저 로드 시도 (Try loading from cache first)
    _log('💾 [MOFA LOAD] 캐시 확인 중... (키: $_mofaCacheKey)');
    final cachedData = await _mofaCache.get(_mofaCacheKey);

    if (cachedData != null) {
      _log('✅ [MOFA LOAD] 캐시 히트! 캐시에서 데이터 로드');
      _log('💾 [MOFA LOAD] 캐시 데이터:');
      _log('   - resultCode: ${cachedData.resultCode}');
      _log('   - isSuccess: ${cachedData.isSuccess}');
      _log('   - notices 개수: ${cachedData.notices.length}');
      _log('   - fetchedAt: ${cachedData.fetchedAt}');
      _mofaData = cachedData;
      return cachedData;
    }

    _log('📭 [MOFA LOAD] 캐시 미스! API에서 데이터 가져오기 시작');

    /// 2. 캐시가 없거나 만료되면 API 호출 (Call API if cache miss)
    try {
      final data = await _fetchMofaFromApi();

      _log('💾 [MOFA LOAD] API 데이터를 캐시에 저장 중...');

      /// 3. 캐시에 저장 (Save to cache)
      await _mofaCache.set(_mofaCacheKey, data);
      _log('✅ [MOFA LOAD] 캐시 저장 완료');

      _mofaData = data;

      _log('═══════════════════════════════════════════════════════════');
      _log('✅ [MOFA LOAD] loadMofaNotices() 완료');
      _log('   - isSuccess: ${data.isSuccess}');
      _log('   - notices 개수: ${data.notices.length}');
      _log('═══════════════════════════════════════════════════════════');

      return data;
    } catch (e, stackTrace) {
      _log('❌ [MOFA LOAD] API 호출 실패: $e');
      _log('❌ [MOFA LOAD] 스택 트레이스: $stackTrace');

      /// API 호출 실패 시 빈 응답 반환 (Return empty response on failure)
      final errorResponse = MofaNoticeResponse(
        resultCode: '-1',
        resultMsg: '공지사항을 불러올 수 없습니다: $e',
        totalCount: 0,
        numOfRows: 0,
        pageNo: 0,
        notices: [],
        fetchedAt: DateTime.now(),
      );

      _log('⚠️ [MOFA LOAD] 에러 응답 반환');
      return errorResponse;
    }
  }

  /// 외교부 공지사항 캐시 초기화 (Clear MOFA notice cache)
  ///
  /// 새로고침 버튼 클릭 시 호출됩니다.
  Future<void> clearMofaCache() async {
    await _mofaCache.clear();
    _mofaData = null;
    _log('🗑️ [MOFA CACHE] 외교부 공지사항 캐시 삭제 완료');
  }

  /// 외교부 공지사항 캐시 남은 시간 조회 (Get remaining MOFA cache time)
  ///
  /// 다음 업데이트까지 남은 시간을 반환합니다.
  /// 캐시가 없으면 null 반환
  Duration? get mofaCacheRemainingTime =>
      _mofaCache.getRemainingTime(_mofaCacheKey);
}
