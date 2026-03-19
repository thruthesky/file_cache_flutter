import 'package:philgo/app.config.dart';

/// v7 파일 업로드 모델
///
/// upload.upload API 응답 및 서버의 uploads 테이블 데이터를
/// 타입 안전하게 다루기 위한 모델 클래스.
///
/// 서버가 반환하는 상대 경로 URL을 full URL로 자동 변환한다.
///
/// 사용 예시:
/// ```dart
/// // 업로드 직후
/// final json = await ApiService.instance.fileUpload(filePath: '/path/to/photo.jpg');
/// final model = FileUploadModel.fromJson(json);
/// print(model.url); // https://philgo.com/uploads/123/abc.webp
///
/// // 서버 API 응답의 업로드 정보 파싱
/// final photos = (json['photos'] as List)
///     .map((e) => FileUploadModel.fromJson(e))
///     .toList();
/// ```
class FileUploadModel {
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

  /// MIME 타입 (예: image/webp, image/jpeg, video/mp4)
  final String type;

  /// 사용 모듈 (예: company, post, user)
  final String module;

  /// 모듈 내 세부 분류 (예: main_photo, gallery, profile_photo)
  final String code;

  /// 파일 다운로드 full URL
  final String url;

  /// 400×400 정사각형 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail400x400Url;

  /// 800×800 정사각형 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail800x800Url;

  /// 1000px 너비 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail1000Url;

  /// 600px 비율 유지 썸네일 full URL (이미지가 아니면 빈 문자열)
  final String thumbnail600Url;

  /// 미리보기에 사용할 최적 썸네일 URL
  ///
  /// thumbnail_600_url → thumbnail_400x400_url → url 순으로 첫 번째 비어있지 않은 값을 반환한다.
  String get previewUrl {
    if (thumbnail600Url.isNotEmpty) return thumbnail600Url;
    if (thumbnail400x400Url.isNotEmpty) return thumbnail400x400Url;
    return url;
  }

  /// 첨부 여부 (0=미첨부, 1=첨부됨)
  final int attached;

  /// 상대경로 URL (예: /uploads/123/abc.webp)
  ///
  /// 서버 API에 files 파라미터로 전달할 때 사용한다.
  String get path => Uri.parse(url).path;

  /// MIME 타입 기반 이미지 여부
  bool get isImage => type.startsWith('image/');

  /// MIME 타입 기반 영상 여부
  bool get isVideo => type.startsWith('video/');

  /// MIME 타입 기반 오디오 여부
  bool get isAudio => type.startsWith('audio/');

  const FileUploadModel({
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
    required this.thumbnail600Url,
    required this.attached,
  });

  /// JSON Map에서 FileUploadModel 생성
  ///
  /// 서버가 반환하는 상대 경로 URL(/uploads/...)을
  /// v7BaseUrl 기반 full URL(https://philgo.com/uploads/...)로 변환한다.
  factory FileUploadModel.fromJson(Map<String, dynamic> json) {
    return FileUploadModel(
      idx: _toInt(json['idx']),
      idxMember: _toInt(json['idx_member']),
      createdAt: _toInt(json['created_at']),
      updatedAt: _toInt(json['updated_at']),
      name: json['name']?.toString() ?? '',
      size: _toInt(json['size']),
      type: json['type']?.toString() ?? '',
      module: json['module']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      url: _toFullUrl(json['url']?.toString() ?? ''),
      thumbnail400x400Url: _toFullUrl(
        json['thumbnail_400x400_url']?.toString() ?? '',
      ),
      thumbnail800x800Url: _toFullUrl(
        json['thumbnail_800x800_url']?.toString() ?? '',
      ),
      thumbnail1000Url: _toFullUrl(
        json['thumbnail_1000_url']?.toString() ?? '',
      ),
      thumbnail600Url: _toFullUrl(
        json['thumbnail_600_url']?.toString() ?? '',
      ),
      attached: _toInt(json['attached']),
    );
  }

  /// 상대 경로를 full URL로 변환
  ///
  /// 이미 http로 시작하면 그대로 반환, 빈 문자열이면 빈 문자열 반환
  static String _toFullUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$v7BaseUrl$path';
  }

  /// 서버 응답 값을 안전하게 int로 변환
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() => 'FileUploadModel(idx: $idx, name: $name, url: $url)';
}
