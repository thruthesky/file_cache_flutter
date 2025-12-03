import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 아이콘 컨테이너 위젯
///
/// 아이콘을 감싸는 재사용 가능한 컨테이너 위젯
/// 다양한 크기와 스타일을 지원하며, Theme 기반 색상을 사용
/// Comic design principles:
/// - 2.0px border thickness
/// - No shadow (elevation: 0)
/// - Rounded corners (8 for small, 12 for large)
/// - Theme-based colors
class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconSize = 24,
    this.borderRadius = 12,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  /// 표시할 아이콘
  final IconData icon;

  /// 컨테이너 크기 (width, height 동일)
  final double size;

  /// 아이콘 크기
  final double iconSize;

  /// 모서리 둥글기 (Comic design: 8 for small, 12 for large)
  final double borderRadius;

  /// 배경색 (null이면 Theme의 primaryContainer 사용)
  final Color? backgroundColor;

  /// 아이콘 색상 (null이면 Theme의 primary 사용)
  final Color? iconColor;

  /// 테두리 색상 (null이면 iconColor 또는 Theme의 primary 사용)
  final Color? borderColor;

  /// 테두리 두께 (Comic design: 기본값 2.0)
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? scheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.primaryContainer,
        // Comic design: Rounded corners (8 for small, 12 for large)
        borderRadius: BorderRadius.circular(borderRadius),
        // Comic design: 2.0px border
        border: Border.all(
          color: borderColor ?? effectiveIconColor,
          width: borderWidth,
        ),
      ),
      child: Center(
        child: FaIcon(icon, color: effectiveIconColor, size: iconSize),
      ),
    );
  }
}
