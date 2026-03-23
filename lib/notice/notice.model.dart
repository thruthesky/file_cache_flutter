/// 외교부 공지사항 모델 (MOFA Notice Model)
///
/// 외교부 공지사항 API 응답 데이터를 담는 모델 클래스.
/// API: http://apis.data.go.kr/1262000/NoticeService2/getNoticeList2
class MofaNotice {
  final String id;
  final String title;
  final String content;
  final String writtenDate;
  final String fileUrl;

  const MofaNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.writtenDate,
    required this.fileUrl,
  });

  factory MofaNotice.fromJson(Map<String, dynamic> json) {
    return MofaNotice(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['txt_origin_cn'] as String? ?? '',
      writtenDate: json['written_dt'] as String? ?? '',
      fileUrl: (json['file_download_url'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'txt_origin_cn': content,
      'written_dt': writtenDate,
      'file_download_url': fileUrl,
    };
  }

  /// HTML 엔티티를 디코딩한 내용 반환
  String get decodedContent {
    String decoded = content;
    decoded = decoded.replaceAll('&nbsp;', ' ');
    decoded = decoded.replaceAll('&amp;', '&');
    decoded = decoded.replaceAll('&lt;', '<');
    decoded = decoded.replaceAll('&gt;', '>');
    decoded = decoded.replaceAll('&quot;', '"');
    decoded = decoded.replaceAll('&#39;', "'");
    decoded = decoded.replaceAll('&apos;', "'");
    decoded = decoded.replaceAll('&middot;', '·');
    decoded = decoded.replaceAll(RegExp(r'<[^>]*>'), '');
    decoded = decoded.replaceAll(RegExp(r'\s+'), ' ');
    return decoded.trim();
  }

  /// HTML 엔티티를 디코딩한 제목 반환
  String get decodedTitle {
    String decoded = title;
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
}

/// 외교부 공지사항 목록 응답 모델
class MofaNoticeResponse {
  final String resultCode;
  final String resultMsg;
  final int totalCount;
  final int numOfRows;
  final int pageNo;
  final List<MofaNotice> notices;
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

  factory MofaNoticeResponse.fromApiJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>?;

    if (response == null) {
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

    final header = response['header'] as Map<String, dynamic>?;
    final resultCode = header?['resultCode']?.toString() ?? '-1';
    final resultMsg = header?['resultMsg']?.toString() ?? 'Unknown error';

    final body = response['body'] as Map<String, dynamic>?;
    final totalCount = _parseIntSafe(body?['totalCount']);
    final numOfRows = _parseIntSafe(body?['numOfRows']);
    final pageNo = _parseIntSafe(body?['pageNo']);

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

  bool get isSuccess => resultCode == '0';

  static int _parseIntSafe(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
