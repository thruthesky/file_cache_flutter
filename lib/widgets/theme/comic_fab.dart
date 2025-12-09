import 'package:flutter/material.dart';

/// ComicFabSize - FAB 크기 옵션
///
/// - large: 큰 FAB (56x56) - 기본 FAB 크기
/// - small: 작은 FAB (40x40) - 컴팩트한 FAB
/// - mini: 미니 FAB (36x36) - 보조 액션용
enum ComicFabSize {
  /// 큰 FAB (56x56) - 기본 FAB 크기
  large,

  /// 작은 FAB (40x40) - 컴팩트한 FAB
  small,

  /// 미니 FAB (36x36) - 보조 액션용
  mini,
}

/// ComicFab - Comic 스타일 Floating Action Button 위젯
///
/// Comic 디자인 원칙을 따르는 재사용 가능한 FAB 위젯입니다.
/// - 테두리 (2.0px - Comic 스타일 표준)
/// - 그림자 없음 (elevation: 0)
/// - 원형 모양 (CircleBorder)
/// - Theme 기반 색상 사용
///
/// 디자인 옵션:
/// - `size`: large, small, mini FAB 크기
/// - `backgroundColor`: 배경색 (기본: surface)
/// - `foregroundColor`: 아이콘 색상 (기본: onSurface)
/// - `borderColor`: 테두리 색상 (기본: outline)
///
/// 사용 예시:
/// ```dart
/// ComicFab(
///   onPressed: () => print('FAB Clicked'),
///   child: FaIcon(FontAwesomeIcons.plus),
/// )
/// ```
class ComicFab extends StatelessWidget {
  /// FAB 클릭 시 실행되는 콜백 함수
  final VoidCallback? onPressed;

  /// FAB 내부에 표시될 위젯 (주로 Icon)
  final Widget child;

  /// FAB 배경색 (기본값: Theme의 surface 색상)
  final Color? backgroundColor;

  /// FAB 전경색 - 아이콘 색상 (기본값: Theme의 onSurface 색상)
  final Color? foregroundColor;

  /// 테두리 색상 (기본값: Theme의 outline 색상)
  final Color? borderColor;

  /// 테두리 두께 (기본값: 2.0 - Comic 스타일 표준)
  final double borderWidth;

  /// FAB 크기 옵션 (기본값: large)
  /// - large: 큰 FAB (56x56)
  /// - small: 작은 FAB (40x40)
  /// - mini: 미니 FAB (36x36)
  final ComicFabSize size;

  /// FAB 툴팁 메시지 (기본값: null)
  final String? tooltip;

  /// FAB의 heroTag (기본값: null - 자동 생성)
  /// 같은 화면에 여러 FAB가 있을 경우 고유한 태그 필요
  final Object? heroTag;

  const ComicFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.size = ComicFabSize.large,
    this.tooltip,
    this.heroTag,
  });

  /// FAB 크기 옵션에 따른 크기 반환
  double _getSize() {
    switch (size) {
      case ComicFabSize.large:
        // 큰 FAB: 56x56 (표준 FAB 크기)
        return 56;
      case ComicFabSize.small:
        // 작은 FAB: 40x40
        return 40;
      case ComicFabSize.mini:
        // 미니 FAB: 36x36
        return 36;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme에서 색상 스키마 가져오기
    final colorScheme = Theme.of(context).colorScheme;

    // Comic Design: 흰색 배경, 검정색 아이콘, outline 테두리
    // Comic Design: white background, black icon, outline border
    final bgColor = backgroundColor ?? colorScheme.surface;
    final fgColor = foregroundColor ?? colorScheme.onSurface;
    final bdColor = borderColor ?? colorScheme.outline;

    // FAB 크기 가져오기
    final fabSize = _getSize();

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: Material(
        // Comic 스타일: 그림자 없음 (elevation: 0)
        elevation: 0,
        // Comic Design: borderRadius 24로 둥근 사각형
        // Comic Design: rounded rectangle with borderRadius 24
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: bdColor,
            width: borderWidth,
          ),
        ),
        // 배경색 (흰색 - Theme surface)
        // Background color (white - Theme surface)
        color: bgColor,
        // 클리핑 적용
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          // InkWell ripple 효과를 위한 borderRadius 설정 (Material과 동일하게 24)
          // InkWell ripple borderRadius (same as Material: 24)
          borderRadius: BorderRadius.circular(24),
          // 툴팁이 있으면 Tooltip 위젯으로 감싸기
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: fgColor, size: 24),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ComicPrimaryFab - Comic 스타일 Primary FAB
///
/// Primary 색상을 사용하는 Comic 스타일 FAB입니다.
/// ComicFab을 확장하여 primary 색상 스키마를 적용합니다.
/// - 배경: primary 색상
/// - 아이콘: onPrimary 색상
/// - 테두리: primary 색상
///
/// 사용 예시:
/// ```dart
/// ComicPrimaryFab(
///   onPressed: () => createPost(),
///   child: FaIcon(FontAwesomeIcons.plus),
/// )
/// ```
class ComicPrimaryFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ComicFabSize size;
  final String? tooltip;
  final Object? heroTag;

  const ComicPrimaryFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ComicFabSize.large,
    this.tooltip,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ComicFab(
      onPressed: onPressed,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      borderColor: colorScheme.primary,
      size: size,
      tooltip: tooltip,
      heroTag: heroTag,
      child: child,
    );
  }
}

/// ComicSecondaryFab - Comic 스타일 Secondary FAB
///
/// Secondary 색상을 사용하는 Comic 스타일 FAB입니다.
/// ComicFab을 확장하여 secondary 색상 스키마를 적용합니다.
/// - 배경: secondary 색상
/// - 아이콘: onSecondary 색상
/// - 테두리: secondary 색상
///
/// 사용 예시:
/// ```dart
/// ComicSecondaryFab(
///   onPressed: () => showMenu(),
///   child: FaIcon(FontAwesomeIcons.bars),
/// )
/// ```
class ComicSecondaryFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ComicFabSize size;
  final String? tooltip;
  final Object? heroTag;

  const ComicSecondaryFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = ComicFabSize.large,
    this.tooltip,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ComicFab(
      onPressed: onPressed,
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      borderColor: colorScheme.secondary,
      size: size,
      tooltip: tooltip,
      heroTag: heroTag,
      child: child,
    );
  }
}
