import 'package:flutter/material.dart';

/// ComicTextFormField - Comic 스타일 TextFormField 위젯
///
/// Comic 디자인 원칙을 따르는 재사용 가능한 텍스트 입력 위젯입니다.
/// - 테두리 (2.0px - Comic 스타일 표준)
/// - 그림자 없음 (elevation: 0)
/// - 둥근 모서리 (borderRadius: 12)
/// - Theme 기반 색상 사용
///
/// 사용 예시:
/// ```dart
/// ComicTextFormField(
///   labelText: Lo.of(context)!.phoneNumber,
///   hintText: Lo.of(context)!.enterPhoneNumber,
/// )
/// ```
class ComicTextFormField extends StatelessWidget {
  /// TextFormField의 컨트롤러
  final TextEditingController? controller;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 에러 텍스트
  final String? errorText;

  /// 접두사 아이콘
  final Widget? prefixIcon;

  /// 접미사 아이콘
  final Widget? suffixIcon;

  /// 텍스트 입력 타입
  final TextInputType? keyboardType;

  /// 비밀번호 필드 여부
  final bool obscureText;

  /// 입력값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백
  final ValueChanged<String>? onFieldSubmitted;

  /// 유효성 검사 함수
  final String? Function(String?)? validator;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 활성화 여부
  final bool enabled;

  /// 최대 줄 수
  final int? maxLines;

  /// 최소 줄 수
  final int? minLines;

  /// 최대 글자 수
  final int? maxLength;

  /// 자동 포커스 여부
  final bool autofocus;

  /// 테두리 색상 (기본값: Theme의 outline 색상)
  final Color? borderColor;

  /// 포커스 시 테두리 색상 (기본값: Theme의 primary 색상)
  final Color? focusedBorderColor;

  /// 에러 시 테두리 색상 (기본값: Theme의 error 색상)
  final Color? errorBorderColor;

  /// 테두리 두께 (기본값: 2.0 - Comic 스타일 표준)
  final double borderWidth;

  /// 모서리 둥글기 (기본값: 12 - Comic 스타일 표준)
  final double borderRadius;

  /// 내부 패딩
  final EdgeInsetsGeometry? contentPadding;

  const ComicTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    // Theme에서 색상 스키마 가져오기
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Comic 스타일 테두리 생성 함수
    OutlineInputBorder buildBorder(Color color) {
      return OutlineInputBorder(
        // Comic 스타일 둥근 모서리
        borderRadius: BorderRadius.circular(borderRadius),
        // Comic 스타일 테두리 (2.0px)
        borderSide: BorderSide(
          color: color,
          width: borderWidth,
        ),
      );
    }

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofocus: autofocus,
      // Theme 기반 텍스트 스타일 사용
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        // Theme 기반 라벨 스타일 사용
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        hintText: hintText,
        // Theme 기반 힌트 스타일 사용
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        // 내부 패딩 (8의 배수 사용)
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        // 배경색 - Theme의 surface 색상
        filled: true,
        fillColor: colorScheme.surface,
        // Comic 스타일: 그림자 없음 (elevation: 0)
        // Comic 스타일: 테두리 (2.0px, outline 색상)
        enabledBorder: buildBorder(
          borderColor ?? colorScheme.outline,
        ),
        // 포커스 시 테두리 (primary 색상)
        focusedBorder: buildBorder(
          focusedBorderColor ?? colorScheme.primary,
        ),
        // 에러 시 테두리 (error 색상)
        errorBorder: buildBorder(
          errorBorderColor ?? colorScheme.error,
        ),
        // 포커스된 에러 테두리 (error 색상)
        focusedErrorBorder: buildBorder(
          errorBorderColor ?? colorScheme.error,
        ),
        // 비활성화 시 테두리
        disabledBorder: buildBorder(
          colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
