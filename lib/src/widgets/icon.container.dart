import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 아이콘 컨테이너 위젯
///
/// 아이콘을 감싸는 재사용 가능한 컨테이너 위젯
/// 다양한 크기와 스타일을 지원하며, Theme 기반 색상을 사용
class IconContainer extends StatelessWidget {
  const IconContainer({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconSize = 24,
    this.borderRadius = 12,
    this.backgroundColor,
    this.iconColor,
  });

  /// 표시할 아이콘
  final IconData icon;

  /// 컨테이너 크기 (width, height 동일)
  final double size;

  /// 아이콘 크기
  final double iconSize;

  /// 모서리 둥글기
  final double borderRadius;

  /// 배경색 (null이면 Theme의 primaryContainer 사용)
  final Color? backgroundColor;

  /// 아이콘 색상 (null이면 Theme의 primary 사용)
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: FaIcon(icon, color: iconColor ?? scheme.primary, size: iconSize),
      ),
    );
  }
}
