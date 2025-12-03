import 'package:flutter/material.dart';

/// ComicButton - Comic 스타일 버튼 위젯
///
/// Comic 디자인 원칙을 따르는 재사용 가능한 버튼 위젯입니다.
/// - 테두리 (2.0px - Comic 스타일 표준)
/// - 그림자 없음 (elevation: 0)
/// - 둥근 모서리 (borderRadius: 12 - 큰 요소, 8 - 그 외)
/// - Theme 기반 색상 사용
///
/// 사용 예시:
/// ```dart
/// ComicButton(
///   onPressed: () => print('Clicked'),
///   child: Text(Lo.of(context)!.login),
/// )
/// ```
class ComicButton extends StatelessWidget {
  /// 버튼 클릭 시 실행되는 콜백 함수
  final VoidCallback? onPressed;

  /// 버튼 내부에 표시될 위젯 (주로 Text)
  final Widget child;

  /// 버튼의 최소 너비 (기본값: null - 컨텐츠에 맞춤)
  final double? minWidth;

  /// 버튼의 최소 높이 (기본값: null - 컨텐츠에 맞춤)
  final double? minHeight;

  /// 버튼 배경색 (기본값: Theme의 surface 색상)
  final Color? backgroundColor;

  /// 버튼 전경색 - 텍스트/아이콘 색상 (기본값: Theme의 onSurface 색상)
  final Color? foregroundColor;

  /// 테두리 색상 (기본값: Theme의 outline 색상)
  final Color? borderColor;

  /// 테두리 두께 (기본값: 2.0 - Comic 스타일 표준)
  final double borderWidth;

  /// 모서리 둥글기 (기본값: 12 - 큰 요소 기준)
  final double borderRadius;

  /// 버튼 내부 패딩 (기본값: horizontal 24, vertical 16)
  final EdgeInsetsGeometry? padding;

  /// 중요 버튼 여부 (기본값: false)
  /// - true: labelLarge 텍스트 스타일 사용 (강조)
  /// - false: bodyLarge 텍스트 스타일 사용 (일반)
  final bool important;

  const ComicButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12,
    this.padding,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    // Theme에서 색상 스키마 가져오기
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // Comic 스타일: 그림자 없음 (elevation: 0)
        elevation: WidgetStateProperty.all(0),

        // Comic 스타일: 둥근 모서리와 테두리 (2.0px)
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            // Comic 스타일 둥근 모서리
            borderRadius: BorderRadius.circular(borderRadius),
            // Comic 스타일 테두리 (outline 색상 사용, 2.0px)
            side: BorderSide(
              color: borderColor ?? colorScheme.outline,
              width: borderWidth,
            ),
          ),
        ),

        // 버튼 텍스트 스타일
        // important: true → labelLarge (강조), false → bodyLarge (일반)
        textStyle: WidgetStateProperty.all(
          important ? textTheme.labelLarge : textTheme.bodyLarge,
        ),

        // 배경색 - Theme의 surface 색상 (또는 사용자 지정)
        backgroundColor: WidgetStateProperty.all(
          backgroundColor ?? colorScheme.surface,
        ),

        // 전경색(텍스트/아이콘) - Theme의 onSurface 색상 (또는 사용자 지정)
        foregroundColor: WidgetStateProperty.all(
          foregroundColor ?? colorScheme.onSurface,
        ),

        // 버튼 패딩 설정 (8의 배수 사용)
        padding: WidgetStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),

        // 최소 크기 설정
        minimumSize: WidgetStateProperty.all(
          Size(minWidth ?? 0, minHeight ?? 0),
        ),
      ),
      child: child,
    );
  }
}

/// ComicPrimaryButton - Comic 스타일 Primary 버튼
///
/// Primary 색상을 사용하는 Comic 스타일 버튼입니다.
/// - 배경: primary 색상
/// - 텍스트: onPrimary 색상
/// - 테두리: primary 색상
class ComicPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final bool important;

  const ComicPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.padding,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ComicButton(
      onPressed: onPressed,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      borderColor: colorScheme.primary,
      minWidth: minWidth,
      minHeight: minHeight,
      padding: padding,
      important: important,
      child: child,
    );
  }
}

/// ComicSecondaryButton - Comic 스타일 Secondary 버튼
///
/// Secondary 색상을 사용하는 Comic 스타일 버튼입니다.
/// - 배경: secondary 색상
/// - 텍스트: onSecondary 색상
/// - 테두리: secondary 색상
class ComicSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? minWidth;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final bool important;

  const ComicSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.padding,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ComicButton(
      onPressed: onPressed,
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      borderColor: colorScheme.secondary,
      minWidth: minWidth,
      minHeight: minHeight,
      padding: padding,
      important: important,
      child: child,
    );
  }
}
