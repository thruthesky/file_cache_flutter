import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:philgo/post/post.model.dart';

/// 댓글 수정 다이얼로그
///
/// 기존 댓글 내용을 편집하고 수정된 내용을 반환한다.
/// 반환: 수정된 content 문자열 (취소 시 null)
class CommentEditDialog extends StatefulWidget {
  final Post comment;

  const CommentEditDialog({super.key, required this.comment});

  /// 다이얼로그를 표시하고 수정된 내용을 반환한다.
  static Future<String?> show(BuildContext context, Post comment) {
    return showDialog<String>(
      context: context,
      builder: (_) => CommentEditDialog(comment: comment),
    );
  }

  @override
  State<CommentEditDialog> createState() => _CommentEditDialogState();
}

class _CommentEditDialogState extends State<CommentEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comment.content);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('댓글 수정'.tr()),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 2,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: '댓글 내용을 입력하세요'.tr(),
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'.tr()),
        ),
        FilledButton(
          onPressed: () {
            final content = _controller.text.trim();
            if (content.isEmpty) return;
            Navigator.pop(context, content);
          },
          child: Text('수정'.tr()),
        ),
      ],
    );
  }
}
