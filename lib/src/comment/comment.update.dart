import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class CommentUpdate extends StatefulWidget {
  const CommentUpdate({
    super.key,
    required this.comment,
    required this.onUpdated,
  });
  final Comment comment;
  final Function(Comment) onUpdated;

  @override
  State<CommentUpdate> createState() => _CommentUpdateState();
}

class _CommentUpdateState extends State<CommentUpdate> {
  final contentController = TextEditingController();
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    contentController.text = widget.comment.content;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: contentController,
          minLines: 5,
          maxLines: 10,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: LibTr.of(context)!.updateComment,

            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        SubmitButton(
          isLoading: submitting,
          onPressed: () async {
            //
            setState(() {
              submitting = true;
            });
            try {
              final updatedComment = await philgoApiUpdateComment({
                'idx': widget.comment.idx,
                'content': contentController.text,
              });
              debugLog('updatedComment: $updatedComment');
              widget.onUpdated(updatedComment);
            } finally {
              setState(() {
                submitting = false;
              });
            }
          },
          child: Text(LibTr.of(context)!.update),
        ),
      ],
    );
  }
}
