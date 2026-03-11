import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 이미지 로드 실패 시 표시되는 에러 플레이스홀더 위젯
/// Error placeholder widget displayed when image loading fails
///
/// 이미지 네트워크 로드 실패, 잘못된 URL, 또는 파일 손상 등의 경우에
/// 기본 이미지 대신 표시되는 플레이스홀더입니다.
/// This placeholder is displayed instead of the default image when
/// network image loading fails, URL is invalid, or file is corrupted.
///
/// ### Parameters:
/// - [width] → 플레이스홀더 너비. 기본값: `120`
///            Placeholder width. Default: `120`
/// - [height] → 플레이스홀더 높이. 기본값: `120`
///             Placeholder height. Default: `120`
/// - [iconSize] → 에러 아이콘 크기. 기본값: `32`
///               Error icon size. Default: `32`
/// - [borderRadius] → 모서리 둥글기. 기본값: `0` (둥글지 않음)
///                   Corner radius. Default: `0` (no rounding)
///
/// ### Example:
/// ```dart
/// // 기본 사용
/// ImageErrorPlaceholder()
///
/// // 크기 및 아이콘 크기 지정
/// ImageErrorPlaceholder(
///   width: 100,
///   height: 100,
///   iconSize: 24,
/// )
///
/// // Image.network의 errorBuilder에서 사용
/// Image.network(
///   imageUrl,
///   errorBuilder: (context, error, stackTrace) {
///     return ImageErrorPlaceholder(
///       width: 120,
///       height: 120,
///     );
///   },
/// )
/// ```
class ImageErrorPlaceholder extends StatelessWidget {
  /// 플레이스홀더 너비
  /// Placeholder width
  final double width;

  /// 플레이스홀더 높이
  /// Placeholder height
  final double height;

  /// 에러 아이콘 크기
  /// Error icon size
  final double iconSize;

  /// 모서리 둥글기 (0이면 둥글지 않음)
  /// Corner radius (0 means no rounding)
  final double borderRadius;

  const ImageErrorPlaceholder({
    super.key,
    this.width = 120.0,
    this.height = 120.0,
    this.iconSize = 32.0,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // 둥근 모서리가 있으면 ClipRRect로 감싸기
    // Wrap with ClipRRect if border radius is specified
    Widget content = Container(
      width: width,
      height: height,
      // 배경색: surfaceContainerHighest (Theme 기반)
      // Background color: surfaceContainerHighest (Theme-based)
      color: scheme.surfaceContainerHighest,
      child: Center(
        // Font Awesome Pro 아이콘 사용 (이미지 깨짐 아이콘)
        // Using Font Awesome Pro icon (image slash icon)
        child: FaIcon(
          FontAwesomeIcons.imageSlash,
          size: iconSize,
          // 아이콘 색상: onSurfaceVariant (Theme 기반)
          // Icon color: onSurfaceVariant (Theme-based)
          color: scheme.onSurfaceVariant,
        ),
      ),
    );

    // 둥근 모서리 적용
    // Apply border radius
    if (borderRadius > 0) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }
}
