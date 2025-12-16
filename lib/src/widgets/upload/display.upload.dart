import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

import 'file.placeholder.dart';
import 'image.error.placeholder.dart';

/// 업로드된 파일의 미리보기 박스를 표시하는 위젯입니다.
///
/// `DisplayUpload`는 파일 타입(이미지, 비디오, 일반 파일)에 따라
/// 적절한 미리보기 콘텐츠를 테두리가 있는 컨테이너 안에 표시합니다.
///
/// ### 지원하는 파일 타입:
/// - **이미지**: CachedNetworkImage로 썸네일 최적화 및 캐싱
/// - **비디오**: 작은 크기(120 이하)에서는 썸네일 + 플레이 버튼, 큰 크기에서는 UploadedVideoPlayer
/// - **파일**: FilePlaceholder로 파일 아이콘과 확장자 배지
///
/// ### 매개변수:
/// - [width] → 박스의 너비. 기본값은 `120`.
/// - [height] → 박스의 높이. 기본값은 `120`.
/// - [borderRadius] → 모서리 둥글기. 기본값은 `8`.
/// - [url] → 업로드된 파일의 URL.
/// - [onTap] → 탭 시 실행할 콜백 (비디오 썸네일 모드에서 사용)
///
/// ### 예시:
/// ```dart
/// DisplayUpload(
///   url: 'https://example.com/uploads/video.mp4',
///   width: 80,
///   height: 80,
///   onTap: () => Navigator.push(...), // 글 읽기 페이지로 이동
/// )
/// ```
class DisplayUpload extends StatelessWidget {
  /// 박스의 너비
  final double width;

  /// 박스의 높이
  final double height;

  /// 모서리 둥글기
  final double borderRadius;

  /// 업로드된 파일의 URL
  final String url;

  /// 탭 시 실행할 콜백 (비디오 썸네일 모드에서 글 읽기 페이지로 이동 등)
  final VoidCallback? onTap;

  /// 파일명 표시 여부 (파일 미리보기에서만 적용)
  final bool showFileName;

  const DisplayUpload({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 8.0,
    required this.url,
    this.onTap,
    this.showFileName = false,
  });

  /// URL에서 파일 확장자를 추출하여 대문자로 반환합니다.
  /// 예: "pdf" → "PDF", "doc" → "DOC"
  String _getFileExtension() {
    final extension = getFileExtension(url);
    return extension.isNotEmpty ? extension.toUpperCase() : 'FILE';
  }

  /// 파일 타입에 따라 적절한 미리보기 콘텐츠를 빌드합니다.
  /// - 이미지: CachedNetworkImage로 썸네일 표시
  /// - 비디오: UploadedVideoPlayer로 비디오 재생
  /// - 파일: FilePlaceholder로 파일 아이콘 표시
  Widget _buildPreviewContent(BuildContext context) {
    final fileType = detectFileType(url);

    switch (fileType) {
      case UploadFileType.image:
        // 이미지 미리보기 - CachedNetworkImage로 캐싱 및 성능 향상
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 2),
          child: CachedNetworkImage(
            imageUrl: thumbnail_image_url(url),
            width: width,
            height: height,
            fit: BoxFit.cover,
            // 이미지 로드 실패 시 에러 플레이스홀더 표시
            errorWidget: (context, url, error) {
              return ImageErrorPlaceholder(width: width, height: height);
            },
          ),
        );

      case UploadFileType.video:
        // 비디오 미리보기
        // 작은 크기(120 이하)에서는 Chewie 컨트롤이 overflow 발생하므로
        // video_player로 첫 프레임만 표시 + 플레이 버튼 오버레이
        // 탭하면 상위 InkWell의 onTap이 실행되어 글 읽기 페이지로 이동
        if (width <= 120 || height <= 120) {
          return VideoThumbnail(
            url: url,
            width: width,
            height: height,
            borderRadius: borderRadius - 2,
            onTap: onTap,
          );
        }
        // 큰 크기에서는 전체 비디오 플레이어 표시
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 2),
          child: UploadedVideoPlayer(url: url),
        );

      case UploadFileType.file:
        // 일반 파일 미리보기 - FilePlaceholder 위젯 사용
        // Extract filename from URL
        final fileName = url.split('/').last;
        return FilePlaceholder(
          width: width,
          height: height,
          borderRadius: borderRadius - 2,
          extension: _getFileExtension(),
          fileName: fileName,
          showFileName: showFileName,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: _buildPreviewContent(context),
    );
  }
}
