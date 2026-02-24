import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';

/// 재사용 가능한 폼 필드 라벨 위젯
/// 필수(*) 및 선택(Optional) 여부를 표시합니다.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
    this.isOptional = false,
  });

  final String label;

  /// 필수 필드 여부 (true이면 라벨 옆에 * 표시)
  final bool isRequired;

  /// 선택 필드 여부 (true이면 라벨 옆에 "선택" 뱃지 표시)
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        /// 라벨 텍스트 (필수 필드는 * 포함)
        Text(
          isRequired ? '$label *' : label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),

        /// 선택 필드 뱃지 표시
        if (isOptional) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              T.optional,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
