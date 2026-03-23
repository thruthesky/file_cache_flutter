import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:philgo/notice/notice.model.dart';

/// 공지사항 서비스
///
/// 외교부(MOFA) 공지사항 API를 호출하고 메모리 캐시를 관리한다.
class NoticeService {
  static NoticeService? _instance;
  static NoticeService get instance => _instance ??= NoticeService._();
  NoticeService._();

  static const String _mofaApiBaseUrl =
      'http://apis.data.go.kr/1262000/NoticeService2/getNoticeList2';

  /// 공공데이터포털 API Key (URL Encoded)
  static const String _apiKey =
      'FAK7%2BJL3rqrFr7Wtn%2FxkKhW8hq1zDsite%2FxQdIwug4pDLD5bsqFJDKzroRXTkY8fm5LXMMMzIaTuvl%2F4iDtQ%2Bw%3D%3D';

  static const int _mofaNumOfRows = 10;
  static const Duration _cacheTtl = Duration(hours: 6);

  MofaNoticeResponse? _cachedResponse;
  DateTime? _cachedAt;

  MofaNoticeResponse? get cachedResponse => _cachedResponse;

  bool get _isCacheValid =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < _cacheTtl;

  /// 외교부 공지사항 로드 (캐시 우선)
  Future<MofaNoticeResponse> loadMofaNotices({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid && _cachedResponse != null) {
      return _cachedResponse!;
    }

    final url = Uri.parse(
      '$_mofaApiBaseUrl?'
      'serviceKey=$_apiKey&'
      'returnType=JSON&'
      'numOfRows=$_mofaNumOfRows&'
      'pageNo=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final json = jsonDecode(decodedBody) as Map<String, dynamic>;
      final data = MofaNoticeResponse.fromApiJson(json);

      _cachedResponse = data;
      _cachedAt = DateTime.now();

      return data;
    }

    debugPrint('MOFA API 호출 실패: HTTP ${response.statusCode}');
    return MofaNoticeResponse(
      resultCode: '-1',
      resultMsg: 'HTTP ${response.statusCode}',
      totalCount: 0,
      numOfRows: 0,
      pageNo: 0,
      notices: [],
      fetchedAt: DateTime.now(),
    );
  }

  /// 캐시 초기화
  void clearCache() {
    _cachedResponse = null;
    _cachedAt = null;
  }
}
