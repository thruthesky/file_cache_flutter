import 'package:flutter/material.dart';

/// ComicButtonRounded - 버튼 모서리 둥글기 옵션
///
/// - full: 완전히 둥근 모서리 (StadiumBorder 스타일)
/// - normal: 일반 둥근 모서리 (borderRadius: 12)
enum ComicButtonRounded {
  /// 완전히 둥근 모서리 (pill 형태)
  full,

  /// 일반 둥근 모서리 (borderRadius: 12)
  normal,
}

/// ComicButtonPadding - 버튼 패딩 크기 옵션
///
/// - large: 큰 패딩 (horizontal: 32, vertical: 20)
/// - medium: 중간 패딩 (horizontal: 24, vertical: 16)
/// - small: 작은 패딩 (horizontal: 16, vertical: 12)
enum ComicButtonPadding {
  /// 큰 패딩 - 중요한 액션 버튼에 사용
  large,

  /// 중간 패딩 - 기본 버튼에 사용
  medium,

  /// 작은 패딩 - 컴팩트한 버튼에 사용
  small,
}

/// ComicButtonTextSize - 버튼 텍스트 크기 옵션
///
/// - large: 큰 텍스트 (titleMedium) - 중요한 액션 버튼에 사용
/// - medium: 중간 텍스트 (bodyLarge) - 기본 버튼에 사용
/// - small: 작은 텍스트 (bodyMedium) - 컴팩트한 버튼에 사용
enum ComicButtonTextSize {
  /// 큰 텍스트 (titleMedium) - 중요한 액션 버튼에 사용
  large,

  /// 중간 텍스트 (bodyLarge) - 기본 버튼에 사용
  medium,

  /// 작은 텍스트 (bodyMedium) - 컴팩트한 버튼에 사용
  small,
}

/// ComicButton - Comic 스타일 버튼 위젯
///
/// Comic 디자인 원칙을 따르는 재사용 가능한 버튼 위젯입니다.
/// - 테두리 (2.0px - Comic 스타일 표준)
/// - 그림자 없음 (elevation: 0)
/// - 둥근 모서리 (borderRadius: 12 - 큰 요소, 8 - 그 외)
/// - Theme 기반 색상 사용
///
/// 디자인 옵션:
/// - `rounded`: full (완전 둥근) 또는 normal (일반 둥근)
/// - `padding`: large, medium, small 패딩 크기
/// - `textSize`: large, medium, small 텍스트 크기
///
/// 사용 예시:
/// ```dart
/// ComicButton(
///   onPressed: () => print('Clicked'),
///   rounded: ComicButtonRounded.full,
///   padding: ComicButtonPadding.large,
///   textSize: ComicButtonTextSize.large,
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

  /// 모서리 둥글기 옵션 (기본값: normal)
  /// - full: 완전히 둥근 모서리 (pill 형태)
  /// - normal: 일반 둥근 모서리 (borderRadius: 12)
  final ComicButtonRounded rounded;

  /// 패딩 크기 옵션 (기본값: medium)
  /// - large: 큰 패딩 (32x20)
  /// - medium: 중간 패딩 (24x16)
  /// - small: 작은 패딩 (16x12)
  final ComicButtonPadding padding;

  /// 텍스트 크기 옵션 (기본값: medium)
  /// - large: 큰 텍스트 (titleMedium)
  /// - medium: 중간 텍스트 (bodyLarge)
  /// - small: 작은 텍스트 (bodyMedium)
  final ComicButtonTextSize textSize;

  /// 커스텀 패딩 (기본값: null)
  /// 이 값이 설정되면 padding enum 대신 이 값을 사용합니다.
  /// 좌우/상하 패딩을 개별적으로 조정하고 싶을 때 사용합니다.
  final EdgeInsetsGeometry? customPadding;

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
    this.rounded = ComicButtonRounded.normal,
    this.padding = ComicButtonPadding.medium,
    this.textSize = ComicButtonTextSize.small,
    this.customPadding,
  });

  /// 패딩 크기 옵션에 따른 EdgeInsets 반환
  /// customPadding이 설정되어 있으면 customPadding을 우선 사용
  EdgeInsetsGeometry _getPadding() {
    // customPadding이 있으면 enum 대신 customPadding 사용
    if (customPadding != null) {
      return customPadding!;
    }
    switch (padding) {
      case ComicButtonPadding.large:
        // 큰 패딩: 중요한 액션 버튼 (8의 배수: 32x20)
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      case ComicButtonPadding.medium:
        // 중간 패딩: 기본 버튼 (8의 배수: 24x16)
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case ComicButtonPadding.small:
        // 작은 패딩: 컴팩트한 버튼 (8의 배수: 16x12)
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  /// 텍스트 크기 옵션에 따른 TextStyle 반환
  TextStyle? _getTextStyle(TextTheme textTheme) {
    switch (textSize) {
      case ComicButtonTextSize.large:
        // 큰 텍스트: titleMedium (중요한 액션 버튼)
        return textTheme.titleMedium;
      case ComicButtonTextSize.medium:
        // 중간 텍스트: bodyLarge (기본 버튼)
        return textTheme.bodyLarge;
      case ComicButtonTextSize.small:
        // 작은 텍스트: bodyMedium (컴팩트 버튼)
        return textTheme.bodyMedium;
    }
  }

  /// 둥글기 옵션에 따른 ShapeBorder 반환
  OutlinedBorder _getShape(ColorScheme colorScheme) {
    final borderSide = BorderSide(
      color: borderColor ?? colorScheme.outline,
      width: borderWidth,
    );

    switch (rounded) {
      case ComicButtonRounded.full:
        // 완전히 둥근 모서리 (pill/stadium 형태)
        return StadiumBorder(side: borderSide);
      case ComicButtonRounded.normal:
        // 일반 둥근 모서리 (borderRadius: 12)
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: borderSide,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme에서 색상 스키마 가져오기
    final colorScheme = Theme.of(context).colorScheme;
    final themeTextTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        // Comic 스타일: 그림자 없음 (elevation: 0)
        elevation: WidgetStateProperty.all(0),

        // Comic 스타일: 둥근 모서리와 테두리 (2.0px)
        shape: WidgetStateProperty.all(_getShape(colorScheme)),

        // 버튼 텍스트 스타일 (textSize 옵션에 따라 결정)
        textStyle: WidgetStateProperty.all(_getTextStyle(themeTextTheme)),

        // 배경색 - Theme의 surface 색상 (또는 사용자 지정)
        backgroundColor: WidgetStateProperty.all(
          backgroundColor ?? colorScheme.surface,
        ),

        // 전경색(텍스트/아이콘) - Theme의 onSurface 색상 (또는 사용자 지정)
        foregroundColor: WidgetStateProperty.all(
          foregroundColor ?? colorScheme.onSurface,
        ),

        // 버튼 패딩 설정 (8의 배수 사용)
        padding: WidgetStateProperty.all(_getPadding()),

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
/// ComicButton을 확장하여 primary 색상 스키마를 적용합니다.
/// - 배경: primary 색상
/// - 텍스트: onPrimary 색상
/// - 테두리: primary 색상
///
/// 사용 예시:
/// ```dart
/// ComicPrimaryButton(
///   onPressed: () => submitForm(),
///   rounded: ComicButtonRounded.full,
///   padding: ComicButtonPadding.large,
///   textSize: ComicButtonTextSize.large,
///   child: Text(Lo.of(context)!.submit),
/// )
/// ```
class ComicPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? minWidth;
  final double? minHeight;

  /// 모서리 둥글기 옵션 (기본값: normal)
  final ComicButtonRounded rounded;

  /// 패딩 크기 옵션 (기본값: medium)
  final ComicButtonPadding padding;

  /// 텍스트 크기 옵션 (기본값: medium)
  final ComicButtonTextSize textSize;

  const ComicPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.rounded = ComicButtonRounded.normal,
    this.padding = ComicButtonPadding.medium,
    this.textSize = ComicButtonTextSize.medium,
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
      rounded: rounded,
      padding: padding,
      textSize: textSize,
      child: child,
    );
  }
}

/// ComicSecondaryButton - Comic 스타일 Secondary 버튼
///
/// Secondary 색상을 사용하는 Comic 스타일 버튼입니다.
/// ComicButton을 확장하여 secondary 색상 스키마를 적용합니다.
/// - 배경: secondary 색상
/// - 텍스트: onSecondary 색상
/// - 테두리: secondary 색상
///
/// 사용 예시:
/// ```dart
/// ComicSecondaryButton(
///   onPressed: () => cancel(),
///   rounded: ComicButtonRounded.full,
///   padding: ComicButtonPadding.small,
///   textSize: ComicButtonTextSize.small,
///   child: Text(Lo.of(context)!.cancel),
/// )
/// ```
class ComicSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? minWidth;
  final double? minHeight;

  /// 모서리 둥글기 옵션 (기본값: normal)
  final ComicButtonRounded rounded;

  /// 패딩 크기 옵션 (기본값: medium)
  final ComicButtonPadding padding;

  /// 텍스트 크기 옵션 (기본값: medium)
  final ComicButtonTextSize textSize;

  const ComicSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.minWidth,
    this.minHeight,
    this.rounded = ComicButtonRounded.normal,
    this.padding = ComicButtonPadding.medium,
    this.textSize = ComicButtonTextSize.medium,
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
      rounded: rounded,
      padding: padding,
      textSize: textSize,
      child: child,
    );
  }
}
