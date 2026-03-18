import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Avatar Widget (아바타 위젯)
///
/// 사용자 프로필 사진을 원형으로 표시하는 위젯입니다.
/// photoUrl이 유효한 URL인 경우에만 이미지를 로드하고,
/// 그렇지 않으면 기본 아이콘을 표시합니다.
///
/// Features:
/// - URL 유효성 검사 (http:// 또는 https://로 시작해야 함)
/// - CachedNetworkImage를 사용한 이미지 캐싱
/// - 로딩 중 CircularProgressIndicator 표시
/// - 에러 발생 시 기본 아이콘 표시
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.photoUrl,
    this.size = 40.0,
    this.radius = 25.0,
  });

  final String? photoUrl;
  final double size;
  final double radius;

  /// URL이 유효한지 검사하는 메서드
  /// http:// 또는 https://로 시작하는 URL만 유효한 것으로 판단합니다.
  /// "null" 문자열이나 빈 문자열, 비정상적인 URL은 false를 반환합니다.
  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    // "null" 문자열 체크 (API에서 문자열 "null"이 올 수 있음)
    if (url.toLowerCase() == 'null') return false;
    // 공백만 있는 경우 체크
    if (url.trim().isEmpty) return false;
    // http:// 또는 https://로 시작하는지 확인
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    // URL이 유효하지 않으면 기본 아이콘 표시
    // null, 빈 문자열, "null" 문자열, http(s)로 시작하지 않는 URL 모두 처리
    if (!_isValidUrl(photoUrl)) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: CircleAvatar(child: Icon(Icons.person, size: size / 1.5)),
      );
    }

    // 유효한 URL인 경우 CachedNetworkImage로 이미지 로드
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: CachedNetworkImage(
        imageUrl: photoUrl!,
        // 이미지 빌더: 원형 아바타로 표시
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(backgroundImage: imageProvider),
        // 로딩 중: 기본 아이콘 표시 (로딩 인디케이터 대신)
        // 캐시된 이미지는 즉시 표시되므로 깜빡임 방지
        placeholder: (context, url) =>
            CircleAvatar(child: Icon(Icons.person, size: size / 1.5)),
        // 에러 발생 시: 기본 아이콘 표시
        errorWidget: (context, url, error) =>
            CircleAvatar(child: Icon(Icons.person, size: size / 1.5)),
        // 네트워크 타임아웃 방지를 위한 httpHeaders와 memCacheWidth/Height 설정
        memCacheWidth: (size * 2).toInt(),
        memCacheHeight: (size * 2).toInt(),
        // fadeIn 애니메이션 비활성화로 빠른 표시
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      ),
    );
  }
}
