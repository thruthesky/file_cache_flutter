import 'package:philgo/api/api.service.dart';

/// 방문 후기 사진 모델
class CompanyReviewPhotoModel {
  final String url;
  final String thumbnailUrl;

  const CompanyReviewPhotoModel({
    required this.url,
    required this.thumbnailUrl,
  });

  factory CompanyReviewPhotoModel.fromJson(Map<String, dynamic> json) {
    return CompanyReviewPhotoModel(
      url: (json['url'] as String?) ?? '',
      thumbnailUrl: (json['thumbnail_400x400_url'] as String?) ?? '',
    );
  }

  /// 표시할 이미지 URL (썸네일 우선, 없으면 원본)
  String get displayUrl => thumbnailUrl.isNotEmpty ? thumbnailUrl : url;
}

/// 방문 후기 모델
class CompanyReviewModel {
  final String content;
  final String authorName;
  final dynamic createdAtRaw;
  final List<CompanyReviewPhotoModel> photos;

  const CompanyReviewModel({
    required this.content,
    required this.authorName,
    required this.createdAtRaw,
    required this.photos,
  });

  factory CompanyReviewModel.fromJson(Map<String, dynamic> json) {
    final rawPhotos = (json['photos'] as List<dynamic>?) ?? [];
    final photos = rawPhotos
        .whereType<Map<String, dynamic>>()
        .map(CompanyReviewPhotoModel.fromJson)
        .toList();

    return CompanyReviewModel(
      content: (json['content'] as String?) ?? '',
      authorName: (json['author_name'] as String?) ?? '',
      createdAtRaw: json['created_at'],
      photos: photos,
    );
  }

  /// 포맷된 날짜 문자열 (yyyy.MM.dd)
  String get formattedDate {
    if (createdAtRaw is int && (createdAtRaw as int) > 0) {
      final date =
          DateTime.fromMillisecondsSinceEpoch((createdAtRaw as int) * 1000);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } else if (createdAtRaw is String && (createdAtRaw as String).isNotEmpty) {
      final parsed = DateTime.tryParse(createdAtRaw as String);
      if (parsed != null) {
        return '${parsed.year}.${parsed.month.toString().padLeft(2, '0')}.${parsed.day.toString().padLeft(2, '0')}';
      }
    }
    return '';
  }
}

/// 방문 후기 목록 조회 결과 모델
class CompanyReviewListResult {
  final List<CompanyReviewModel> reviews;
  final int total;
  final int page;
  final int limit;

  CompanyReviewListResult({
    required this.reviews,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory CompanyReviewListResult.fromJson(Map<String, dynamic> json) {
    final raw = (json['reviews'] as List<dynamic>?) ?? [];
    final reviews = raw
        .whereType<Map<String, dynamic>>()
        .map(CompanyReviewModel.fromJson)
        .toList();

    return CompanyReviewListResult(
      reviews: reviews,
      total: ApiService.toInt(json['total']),
      page: ApiService.toInt(json['page']),
      limit: ApiService.toInt(json['limit']),
    );
  }
}
