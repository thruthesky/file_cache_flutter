import 'package:philgo_api/philgo_api.dart';

/// v7 업로드 파일 범용 모델
///
/// v7 Upload API 응답 데이터를 타입 안전하게 다루기 위한 모델 클래스.
/// 업로드 직후 응답뿐 아니라, 글/코멘트/사용자 정보 등에서
/// 서버가 반환하는 업로드 파일 정보를 파싱할 때에도 사용한다.
///
/// 서버가 반환하는 상대 경로 URL을 full URL로 자동 변환한다.
///
/// 사용 예시:
/// ```dart
/// // 업로드 직후
/// final result = await v7apiFileUpload(...);
/// print(result.url); // https://philgo.com/uploads/123/abc.webp
///
/// // 서버 API 응답의 업로드 정보 파싱
/// final photos = (json['photos'] as List)
///     .map((e) => V7UploadModel.fromJson(e))
///     .toList();
/// ```
class V7UploadModel {
  /// 업로드 파일 고유 식별자
  final int idx;

  /// 업로더 회원번호
  final int idxMember;

  /// 생성 시간 (Unix timestamp)
  final int createdAt;

  /// 수정 시간 (Unix timestamp)
  final int updatedAt;

  /// 원본 파일명
  final String name;

  /// 파일 크기 (bytes)
  final int size;

  /// MIME 타입 (예: image/webp, image/jpeg)
  final String type;

  /// 사용 모듈 (예: visit_review, post, profile)
  final String module;

  /// 모듈 내 세부 분류
  final String code;

  /// 파일 다운로드 full URL
  final String url;

  /// 400x400 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail400x400Url;

  /// 800x800 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail800x800Url;

  /// 1000px 너비 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail1000Url;

  /// 첨부 대상 (0=미사용, 글/코멘트/회원 번호)
  final int attachedTo;

  /// MIME 타입 기반 이미지 여부
  bool get isImage => type.startsWith('image/');

  /// MIME 타입 기반 영상 여부
  bool get isVideo => type.startsWith('video/');

  V7UploadModel({
    required this.idx,
    required this.idxMember,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    required this.size,
    required this.type,
    required this.module,
    required this.code,
    required this.url,
    required this.thumbnail400x400Url,
    required this.thumbnail800x800Url,
    required this.thumbnail1000Url,
    required this.attachedTo,
  });

  /// JSON Map에서 V7UploadModel 생성
  ///
  /// 서버가 반환하는 상대 경로 URL(/uploads/...)을
  /// v7ApiEndpoint 기반 full URL(https://philgo.com/uploads/...)로 변환한다.
  factory V7UploadModel.fromJson(Map<String, dynamic> json) {
    final baseUrl =
        PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '');

    return V7UploadModel(
      idx: _toInt(json['idx']),
      idxMember: _toInt(json['idx_member']),
      createdAt: _toInt(json['created_at']),
      updatedAt: _toInt(json['updated_at']),
      name: json['name']?.toString() ?? '',
      size: _toInt(json['size']),
      type: json['type']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      url: _toFullUrl(baseUrl, json['url']?.toString() ?? ''),
      thumbnail400x400Url: _toFullUrl(
        baseUrl,
        json['thumbnail_400x400_url']?.toString() ?? '',
      ),
      thumbnail800x800Url: _toFullUrl(
        baseUrl,
        json['thumbnail_800x800_url']?.toString() ?? '',
      ),
      thumbnail1000Url: _toFullUrl(
        baseUrl,
        json['thumbnail_1000_url']?.toString() ?? '',
      ),
      attachedTo: _toInt(json['attached_to']),
    );
  }

  /// 상대 경로를 full URL로 변환
  ///
  /// 이미 http로 시작하면 그대로 반환, 빈 문자열이면 빈 문자열 반환
  static String _toFullUrl(String baseUrl, String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl$path';
  }

  /// 서버 응답 값을 안전하게 int로 변환
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() => 'V7UploadModel(idx: $idx, name: $name, url: $url)';
}
