import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 댓글/대댓글 입력 폼
///
/// [idxRoot] 원글 idx (필수)
/// [idxParent] 부모 댓글 idx (대댓글 시, null이면 최상위 댓글)
/// [onSubmit] 댓글 전송 콜백 (content 전달)
/// [hintText] 힌트 텍스트
/// [autofocus] 자동 포커스 여부
class CommentInput extends StatefulWidget {
  final int idxRoot;
  final int? idxParent;
  final Future<void> Function(String content) onSubmit;
  final String hintText;
  final bool autofocus;

  const CommentInput({
    super.key,
    required this.idxRoot,
    this.idxParent,
    required this.onSubmit,
    this.hintText = '댓글을 입력하세요',
    this.autofocus = false,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await widget.onSubmit(content);
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      // "Failed to create comment"
      ).showSnackBar(SnackBar(content: Text('${'댓글 작성 실패'.tr()}: $e')));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 텍스트 입력
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              minLines: 1,
              maxLines: 6,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: scheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: scheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          // 전송 버튼
          _isSending
              ? const SizedBox(
                  width: 36,
                  height: 36,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  onPressed: _submit,
                  icon: FaIcon(
                    FontAwesomeIcons.solidPaperPlane,
                    size: 18,
                    color: scheme.primary,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                ),
        ],
      ),
    );
  }
}
