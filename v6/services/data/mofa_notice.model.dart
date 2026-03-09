/// 외교부 공지사항 모델 (MOFA Notice Model)
///
/// 외교부 공지사항 API의 응답 데이터를 담는 모델 클래스입니다.
/// Model class for storing MOFA notice API response data.
///
/// ### API 엔드포인트:
/// `http://apis.data.go.kr/1262000/NoticeService2/getNoticeList2`
///
/// ### 실제 응답 구조 (Actual Response Structure):
/// ```json
/// {
///   "response": {
///     "body": {
///       "items": { "item": [...] },
///       "numOfRows": 5,
///       "pageNo": 1,
///       "totalCount": 1085
///     },
///     "header": {
///       "resultCode": "0",
///       "resultMsg": "정상"
///     }
///   }
/// }
/// ```
class MofaNotice {
  /// 공지사항 고유 ID (Unique notice ID)
  ///
  /// 예: "ATC0000000007730"
  final String id;

  /// 공지사항 제목 (Notice title)
  final String title;

  /// 공지사항 내용 (Notice content)
  ///
  /// HTML 엔티티(&nbsp; 등)가 포함될 수 있으므로
  /// 표시 전에 디코딩이 필요합니다.
  /// May contain HTML entities (&nbsp; etc.),
  /// needs decoding before display.
  final String content;

  /// 작성일 (Written date)
  ///
  /// 형식: "2020-08-26" 또는 "2020.03.12"
  final String writtenDate;

  /// 첨부파일 다운로드 URL (Attachment download URL)
  ///
  /// 첨부파일이 없으면 빈 문자열
  /// Empty string if no attachment
  final String fileUrl;

  const MofaNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.writtenDate,
    required this.fileUrl,
  });

  /// JSON에서 MofaNotice 객체 생성 (Create from JSON)
  ///
  /// API 응답의 `response.body.items.item[]` 배열 내 각 항목을 파싱합니다.
  factory MofaNotice.fromJson(Map<String, dynamic> json) {
    return MofaNotice(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['txt_origin_cn'] as String? ?? '',
      writtenDate: json['written_dt'] as String? ?? '',
      /// file_download_url이 null일 수 있음 (can be null)
      fileUrl: (json['file_download_url'] as String?) ?? '',
    );
  }

  /// MofaNotice를 JSON으로 변환 (Convert to JSON)
  ///
  /// 캐싱을 위한 직렬화에 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'txt_origin_cn': content,
      'written_dt': writtenDate,
      'file_download_url': fileUrl,
    };
  }

  /// HTML 엔티티를 디코딩한 내용 반환 (Get decoded content)
  ///
  /// `&nbsp;`, `&amp;`, `&lt;`, `&gt;`, `&#39;`, `&quot;`, `&middot;` 등의
  /// HTML 엔티티를 일반 문자로 변환합니다.
  String get decodedContent {
    String decoded = content;

    /// HTML 엔티티 디코딩 (Decode HTML entities)
    decoded = decoded.replaceAll('&nbsp;', ' ');
    decoded = decoded.replaceAll('&amp;', '&');
    decoded = decoded.replaceAll('&lt;', '<');
    decoded = decoded.replaceAll('&gt;', '>');
    decoded = decoded.replaceAll('&quot;', '"');
    decoded = decoded.replaceAll('&#39;', "'");
    decoded = decoded.replaceAll('&apos;', "'");
    decoded = decoded.replaceAll('&middot;', '·');

    /// HTML 태그 제거 (Remove HTML tags)
    decoded = decoded.replaceAll(RegExp(r'<[^>]*>'), '');

    /// 연속된 공백 정리 (Normalize whitespace)
    decoded = decoded.replaceAll(RegExp(r'\s+'), ' ');

    return decoded.trim();
  }

  /// HTML 엔티티를 디코딩한 제목 반환 (Get decoded title)
  String get decodedTitle {
    String decoded = title;

    /// HTML 엔티티 디코딩 (Decode HTML entities)
    decoded = decoded.replaceAll('&nbsp;', ' ');
    decoded = decoded.replaceAll('&amp;', '&');
    decoded = decoded.replaceAll('&lt;', '<');
    decoded = decoded.replaceAll('&gt;', '>');
    decoded = decoded.replaceAll('&quot;', '"');
    decoded = decoded.replaceAll('&#39;', "'");
    decoded = decoded.replaceAll('&apos;', "'");
    decoded = decoded.replaceAll('&middot;', '·');

    return decoded.trim();
  }

  @override
  String toString() {
    return 'MofaNotice(id: $id, title: $title, writtenDate: $writtenDate)';
  }
}

/// 외교부 공지사항 목록 응답 모델 (MOFA Notice List Response Model)
///
/// API 응답 전체를 담는 래퍼 클래스입니다.
/// Wrapper class for the entire API response.
///
/// ### 실제 API 응답 구조:
/// ```json
/// {
///   "response": {
///     "body": {
///       "dataType": "JSON",
///       "items": { "item": [...] },
///       "numOfRows": 5,
///       "pageNo": 1,
///       "totalCount": 1085
///     },
///     "header": {
///       "resultCode": "0",
///       "resultMsg": "정상"
///     }
///   }
/// }
/// ```
class MofaNoticeResponse {
  /// 결과 코드 (Result code)
  ///
  /// "0": 정상 (success)
  /// 그 외: 에러 (error)
  final String resultCode;

  /// 결과 메시지 (Result message)
  final String resultMsg;

  /// 전체 결과 수 (Total count)
  final int totalCount;

  /// 현재 페이지 결과 수 (Current page count)
  final int numOfRows;

  /// 페이지 번호 (Page number)
  final int pageNo;

  /// 공지사항 목록 (Notice list)
  final List<MofaNotice> notices;

  /// 데이터 조회 시간 (Fetched at timestamp)
  final DateTime fetchedAt;

  const MofaNoticeResponse({
    required this.resultCode,
    required this.resultMsg,
    required this.totalCount,
    required this.numOfRows,
    required this.pageNo,
    required this.notices,
    required this.fetchedAt,
  });

  /// API 원본 JSON에서 MofaNoticeResponse 객체 생성 (Create from API JSON)
  ///
  /// 실제 API 응답 구조에 맞게 파싱합니다.
  factory MofaNoticeResponse.fromApiJson(Map<String, dynamic> json) {
    /// response 객체 추출 (Extract response object)
    final response = json['response'] as Map<String, dynamic>?;

    if (response == null) {
      /// 응답 구조가 예상과 다른 경우 에러 응답 반환
      /// Return error response if structure is unexpected
      return MofaNoticeResponse(
        resultCode: '-1',
        resultMsg: 'Invalid response structure',
        totalCount: 0,
        numOfRows: 0,
        pageNo: 0,
        notices: [],
        fetchedAt: DateTime.now(),
      );
    }

    /// header에서 결과 코드/메시지 추출 (Extract result from header)
    final header = response['header'] as Map<String, dynamic>?;
    final resultCode = header?['resultCode']?.toString() ?? '-1';
    final resultMsg = header?['resultMsg']?.toString() ?? 'Unknown error';

    /// body에서 데이터 추출 (Extract data from body)
    final body = response['body'] as Map<String, dynamic>?;
    final totalCount = _parseIntSafe(body?['totalCount']);
    final numOfRows = _parseIntSafe(body?['numOfRows']);
    final pageNo = _parseIntSafe(body?['pageNo']);

    /// items.item 배열에서 공지사항 목록 추출 (Extract notices from items.item)
    final items = body?['items'] as Map<String, dynamic>?;
    final itemList = items?['item'] as List<dynamic>? ?? [];
    final notices = itemList
        .map((e) => MofaNotice.fromJson(e as Map<String, dynamic>))
        .toList();

    return MofaNoticeResponse(
      resultCode: resultCode,
      resultMsg: resultMsg,
      totalCount: totalCount,
      numOfRows: numOfRows,
      pageNo: pageNo,
      notices: notices,
      fetchedAt: DateTime.now(),
    );
  }

  /// 캐시 JSON에서 MofaNoticeResponse 객체 생성 (Create from cache JSON)
  ///
  /// 캐시에 저장된 단순화된 구조에서 복원합니다.
  factory MofaNoticeResponse.fromJson(Map<String, dynamic> json) {
    final noticeList = json['notices'] as List<dynamic>? ?? [];
    final notices = noticeList
        .map((e) => MofaNotice.fromJson(e as Map<String, dynamic>))
        .toList();

    return MofaNoticeResponse(
      resultCode: json['resultCode']?.toString() ?? '-1',
      resultMsg: json['resultMsg'] as String? ?? '',
      totalCount: _parseIntSafe(json['totalCount']),
      numOfRows: _parseIntSafe(json['numOfRows']),
      pageNo: _parseIntSafe(json['pageNo']),
      notices: notices,
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'] as String)
          : DateTime.now(),
    );
  }

  /// MofaNoticeResponse를 JSON으로 변환 (Convert to JSON for caching)
  Map<String, dynamic> toJson() {
    return {
      'resultCode': resultCode,
      'resultMsg': resultMsg,
      'totalCount': totalCount,
      'numOfRows': numOfRows,
      'pageNo': pageNo,
      'notices': notices.map((n) => n.toJson()).toList(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  /// API 응답이 성공인지 확인 (Check if response is successful)
  bool get isSuccess => resultCode == '0';

  /// 안전한 int 파싱 (Safe int parsing)
  ///
  /// API 응답에서 int가 String으로 올 수도 있으므로
  /// 양쪽 모두 처리합니다.
  static int _parseIntSafe(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
