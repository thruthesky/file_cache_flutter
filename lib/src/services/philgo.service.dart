import 'dart:convert';
import 'dart:io';

import 'package:philgo_api/philgo_api.dart';

/// 공지사항 데이터 모델 (Notice Data Model)
///
/// get_posts API 응답에서 공지사항 데이터를 담는 모델입니다.
/// Holds notice data from get_posts API response.
class Notice {
  /// 글 고유 번호 (Post unique ID)
  final int idx;

  /// 작성자 회원 번호 (Author member ID)
  final int idxMember;

  /// 게시판 ID (Board ID)
  final String postId;

  /// 카테고리 (Category)
  final String category;

  /// 글 제목 (Post subject)
  final String subject;

  /// 글 내용 (Post content) - short_content 옵션 사용 시 앞부분만 포함
  final String content;

  /// 작성 시간 Unix timestamp (Created time)
  final int stamp;

  /// 댓글 수 (Comment count)
  final int noOfComment;

  /// 조회 수 (View count)
  final int noOfView;

  /// 좋아요 수 (Like count)
  final int good;

  /// 첨부 파일 목록 (Attached files)
  final List<String> files;

  /// 시간 문자열 (Time string) - 예: "2025-12-17 17:59:30"
  final String? timeString;

  const Notice({
    required this.idx,
    required this.idxMember,
    required this.postId,
    required this.category,
    required this.subject,
    required this.content,
    required this.stamp,
    required this.noOfComment,
    required this.noOfView,
    required this.good,
    required this.files,
    this.timeString,
  });

  /// JSON에서 Notice 객체 생성 (Create from JSON)
  factory Notice.fromJson(Map<String, dynamic> json) {
    // files 필드 처리 - 문자열 배열 또는 빈 배열
    List<String> parseFiles(dynamic filesData) {
      if (filesData == null) return [];
      if (filesData is List) {
        return filesData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return Notice(
      idx: json['idx'] as int? ?? 0,
      idxMember: json['idx_member'] as int? ?? 0,
      postId: json['post_id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      content: json['content'] as String? ?? '',
      stamp: json['stamp'] as int? ?? 0,
      noOfComment: json['no_of_comment'] as int? ?? 0,
      noOfView: json['no_of_view'] as int? ?? 0,
      good: json['good'] as int? ?? 0,
      files: parseFiles(json['files']),
      timeString: json['time_string'] as String?,
    );
  }

  /// Notice를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'idx_member': idxMember,
      'post_id': postId,
      'category': category,
      'subject': subject,
      'content': content,
      'stamp': stamp,
      'no_of_comment': noOfComment,
      'no_of_view': noOfView,
      'good': good,
      'files': files,
      if (timeString != null) 'time_string': timeString,
    };
  }

  /// Unix timestamp를 DateTime으로 변환 (Convert stamp to DateTime)
  DateTime get createdAt => DateTime.fromMillisecondsSinceEpoch(stamp * 1000);

  /// 최근 N일 이내의 글인지 확인 (Check if post is within N days)
  bool isWithinDays(int days) {
    final now = DateTime.now();
    final postDate = createdAt;
    final difference = now.difference(postDate).inDays;
    return difference <= days;
  }
}

/// 홈페이지 통계 데이터 모델 (Homepage Stats Data Model)
///
/// get_homepage_stats API 응답 데이터를 담는 모델입니다.
/// Holds response data from get_homepage_stats API.
class HomepageStats {
  /// 총 회원 수 (Total user count)
  final int totalUserCount;

  /// 총 글 수 (Total post count)
  final int totalPostCount;

  /// 캐시 남은 시간 (초) - 캐시 히트 시에만 포함 (TTL in seconds - only included on cache hit)
  final int? ttl;

  const HomepageStats({
    required this.totalUserCount,
    required this.totalPostCount,
    this.ttl,
  });

  /// JSON에서 HomepageStats 객체 생성 (Create from JSON)
  factory HomepageStats.fromJson(Map<String, dynamic> json) {
    return HomepageStats(
      totalUserCount: json['total_user_count'] as int? ?? 0,
      totalPostCount: json['total_post_count'] as int? ?? 0,
      ttl: json['ttl'] as int?,
    );
  }

  /// HomepageStats를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    return {
      'total_user_count': totalUserCount,
      'total_post_count': totalPostCount,
      if (ttl != null) 'ttl': ttl,
    };
  }
}

class PhilgoService {
  static PhilgoService? _instance;
  static PhilgoService get instance => _instance ??= PhilgoService._();

  PhilgoService._();

  /// PhilGo 설정 정보 로드
  ///
  /// API에서 설정 정보를 가져와 PhilgoSetting 모델로 파싱하여 저장
  Future<PhilgoSetting> loadSetting() async {
    final json = await apiCall('setting', apiServerUrl: PhilgoConfig.phpApiUrl);
    final setting = PhilgoSetting.fromJson(json);

    return setting;
  }

  /// 홈페이지 통계 조회 (Get homepage stats)
  ///
  /// 총 회원 수, 총 글 수 등의 통계 정보를 반환합니다.
  /// 서버에서 1시간 동안 캐시됩니다.
  ///
  /// Returns statistics including total user count and total post count.
  /// Data is cached on server for 1 hour.
  ///
  /// ### 사용법 (Usage):
  /// ```dart
  /// final stats = await PhilgoService.instance.getHomepageStats();
  /// print('회원 수: ${stats.totalUserCount}');
  /// print('글 수: ${stats.totalPostCount}');
  /// ```
  Future<HomepageStats> getHomepageStats() async {
    // 디버그: API URL 확인 (Debug: Check API URL)
    print('[PhilgoService] getHomepageStats 호출, URL: ${PhilgoConfig.phpApiUrl}');

    final json = await apiCall(
      'get_homepage_stats',
      apiServerUrl: PhilgoConfig.phpApiUrl,
      debug: true, // 디버그 모드 활성화 (Enable debug mode)
    );

    // 디버그: API 응답 확인 (Debug: Check API response)
    print('[PhilgoService] getHomepageStats 응답: $json');

    return HomepageStats.fromJson(json);
  }

  /// 최신 공지사항 조회 (Load latest notices)
  ///
  /// freetalk 게시판의 '공지사항' 카테고리에서 최신 글을 가져옵니다.
  /// `short_content` 옵션을 사용하여 내용의 앞부분만 가져옵니다.
  ///
  /// Fetches latest posts from 'freetalk' board's '공지사항' category.
  /// Uses `short_content` option to get only the beginning of content.
  ///
  /// ### 파라미터 (Parameters):
  /// - [limit]: 가져올 공지사항 개수 (기본값: 10)
  ///
  /// ### 사용법 (Usage):
  /// ```dart
  /// final notices = await PhilgoService.instance.loadLatestNotices();
  /// print('공지사항 개수: ${notices.length}');
  ///
  /// // 최근 30일 이내 공지 필터링
  /// final recentNotices = notices.where((n) => n.isWithinDays(30)).toList();
  /// ```
  Future<List<Notice>> loadLatestNotices({int limit = 10}) async {
    print('[PhilgoService] loadLatestNotices 호출, limit: $limit');

    // get_posts API는 배열을 반환하므로 직접 HTTP 요청 사용
    // URL 인코딩된 카테고리명 사용 (공지사항 → %EA%B3%B5%EC%A7%80%EC%82%AC%ED%95%AD)
    final url =
        '${PhilgoConfig.phpApiUrl}?func=get_posts&post_id=freetalk&category=${Uri.encodeComponent('공지사항')}&limit=$limit&extra_conditions[short_content]=y';

    print('[PhilgoService] loadLatestNotices URL: $url');

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('[PhilgoService] loadLatestNotices 응답: $responseBody');

      // HTTP 상태 코드 검증
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // JSON 파싱 - get_posts API는 배열을 직접 반환
      final decoded = jsonDecode(responseBody);

      if (decoded is List) {
        final List<Notice> notices = [];
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            notices.add(Notice.fromJson(item));
          }
        }
        return notices;
      }

      // 응답이 배열이 아닌 경우 빈 배열 반환
      return [];
    } finally {
      client.close();
    }
  }

  /// 글 하나 가져오기 (Get single post)
  ///
  /// `get_post` API를 사용하여 특정 글의 상세 정보를 가져옵니다.
  /// 댓글, 게시판 목록 등을 포함하지 않아 빠르고 효율적입니다.
  ///
  /// Uses `get_post` API to fetch detailed information of a specific post.
  /// Does not include comments or board list, making it fast and efficient.
  ///
  /// ### 파라미터 (Parameters):
  /// - [idx]: 글 고유 번호 (Post unique ID)
  ///
  /// ### 사용법 (Usage):
  /// ```dart
  /// final post = await PhilgoService.instance.getPost(idx: 12345);
  /// print('제목: ${post.subject}');
  /// print('내용: ${post.content}');
  /// ```
  Future<Notice> getPost({required int idx}) async {
    print('[PhilgoService] getPost 호출, idx: $idx');

    final url = '${PhilgoConfig.phpApiUrl}?func=get_post&idx=$idx';

    print('[PhilgoService] getPost URL: $url');

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      print('[PhilgoService] getPost 응답: $responseBody');

      // HTTP 상태 코드 검증 (HTTP status code verification)
      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      // JSON 파싱 (JSON parsing)
      final decoded = jsonDecode(responseBody);

      // 에러 응답 확인 (Check error response)
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('error')) {
          throw Exception(decoded['message'] ?? decoded['error']);
        }
        // 정상 응답 - Notice로 변환 (Normal response - convert to Notice)
        return Notice.fromJson(decoded);
      }

      throw Exception('Invalid response format');
    } finally {
      client.close();
    }
  }
}
