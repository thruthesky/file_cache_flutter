import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Comic 스타일 액션 버튼 위젯
///
/// 게시글 상세 화면의 액션 버튼들(좋아요, 공유, 댓글 등)에 사용됩니다.
/// Comic 스타일 디자인(둥근 모서리 + 테두리)이 적용되어 있습니다.
///
/// ### 특징:
/// - 아이콘만 표시하거나 아이콘 + 라벨 조합 가능
/// - 커스텀 색상 지원 (기본값: Theme 색상)
/// - InkWell을 사용한 탭 효과
/// - 비활성화 상태 지원 (onPressed가 null이면 Opacity 0.5 적용)
///
/// ### 매개변수:
/// - [icon] → Font Awesome 아이콘
/// - [label] → 버튼 라벨 (선택사항, null이면 아이콘만 표시)
/// - [onPressed] → 버튼 클릭 시 콜백 (null이면 비활성화)
/// - [color] → 아이콘 및 텍스트 색상 (선택사항, 기본값: onSurface)
/// - [disabledOpacity] → 비활성화 시 투명도 (기본값: 0.5)
///
/// ### 예시:
/// ```dart
/// // 활성화 상태
/// ComicActionButton(
///   icon: FontAwesomeIcons.heart,
///   label: '좋아요',
///   onPressed: () => handleLike(),
///   color: Colors.red,
/// )
///
/// // 비활성화 상태 (삭제 진행 중)
/// ComicActionButton(
///   icon: FontAwesomeIcons.spinner,
///   onPressed: null,  // 비활성화
/// )
/// ```
class ComicActionButton extends StatelessWidget {
  /// Font Awesome 아이콘
  final IconData icon;

  /// 버튼 라벨 (선택사항, null이면 아이콘만 표시)
  final String? label;

  /// 버튼 클릭 시 콜백 (null이면 비활성화)
  final VoidCallback? onPressed;

  /// 아이콘 및 텍스트 색상 (선택사항, 기본값: onSurface)
  final Color? color;

  /// 비활성화 시 투명도 (기본값: 0.5)
  final double disabledOpacity;

  const ComicActionButton({
    super.key,
    required this.icon,
    this.label,
    this.onPressed,
    this.color,
    this.disabledOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // 사용할 색상 결정 (커스텀 색상 또는 기본 테마 색상)
    final effectiveColor = color ?? scheme.onSurface;

    // 비활성화 여부 판단 (onPressed가 null이면 비활성화)
    final isDisabled = onPressed == null;

    return Opacity(
      // 비활성화 시 지정된 투명도 적용, 활성화 시 완전 불투명
      opacity: isDisabled ? disabledOpacity : 1.0,
      child: Container(
        // Comic 스타일: 둥근 모서리 + 테두리
        decoration: BoxDecoration(
          border: Border.all(
            color: (color ?? scheme.outline).withValues(alpha: 0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                FaIcon(icon, size: 16, color: effectiveColor),

                // 라벨이 있으면 아이콘 옆에 표시
                if (label != null && label!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    label!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
