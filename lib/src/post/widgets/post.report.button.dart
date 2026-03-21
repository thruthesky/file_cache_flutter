import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시물 및 댓글 신고 버튼 위젯
///
/// 사용자가 부적절한 게시물이나 댓글을 신고할 수 있는 기능을 제공
/// - 버튼 클릭 시 바텀 시트 모달을 통해 신고 사유 선택
/// - 타입(post/comment)에 따라 다른 신고 사유 목록 표시
/// - 신고 완료 시 성공 메시지 표시
class PostReportButton extends StatefulWidget {
  const PostReportButton({
    super.key,
    required this.type,
    required this.idx,
    this.post,
    this.comment,
  });

  /// 신고 대상 타입 ('post' 또는 'comment')
  final String type;

  /// 신고 대상의 고유 ID
  final int idx;
  final Post? post;
  final Comment? comment;

  @override
  State<PostReportButton> createState() => _PostReportButtonState();
}

class _PostReportButtonState extends State<PostReportButton> {
  int currentReportCounter = 0;

  @override
  void initState() {
    super.initState();
    currentReportCounter = getReportCounter();
  }

  /// Increase the report counter and update UI
  void increaseCounter() {
    currentReportCounter++;
    setState(() {});
  }

  /// Get the current report counter based on type
  int getReportCounter() {
    if (widget.type == 'post' && widget.post != null) {
      return widget.post!.reportCounter;
    } else if (widget.type == 'comment' && widget.comment != null) {
      return widget.comment!.reportCounter;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.2),
          width: 1.0, // Comic Design: 2.0 border
        ),
        borderRadius: BorderRadius.circular(8), // Comic Design: rounded corners
      ),
      child: InkWell(
        onTap: () => showReportReasonBottomSheet(
          context: context,
          type: widget.type,
          idx: widget.idx,
          onReportSuccess: increaseCounter,
        ),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.hexagonExclamation, size: 16, color: scheme.onSurface),
              // 신고 횟수가 있는 경우에만 숫자 표시
              if (currentReportCounter > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '$currentReportCounter',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
