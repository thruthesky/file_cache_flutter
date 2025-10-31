import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ReplyToComment extends StatefulWidget {
  const ReplyToComment({
    super.key,
    required this.parent,
    required this.onReplied,
  });

  final Comment parent;
  final Function(Comment) onReplied;

  @override
  State<ReplyToComment> createState() => _ReplyToPostFormState();
}

class _ReplyToPostFormState extends State<ReplyToComment> {
  final contentController = TextEditingController();

  bool isCreatingReply = false;
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    contentController.addListener(onTextChanged);
  }

  @override
  void dispose() {
    super.dispose();
    contentController.removeListener(onTextChanged);
    contentController.dispose();
  }

  void onTextChanged() {
    final isEmpty = contentController.text.trim().isEmpty;

    if (isEmpty != isTextEmpty) {
      setState(() {
        isTextEmpty = isEmpty;
      });
    }
  }

  void onTapReplyToComment() async {
    try {
      setState(() {
        isCreatingReply = true;
      });

      final createdComment = await philgoApiCreateComment({
        'idx_root': widget.parent.idx_root,
        'idx_parent': widget.parent.idx,
        'content': contentController.text,
      });

      widget.onReplied(createdComment);
    } finally {
      setState(() {
        contentController.text = '';

        isCreatingReply = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: contentController,
      minLines: 1,
      maxLines: 2,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: FileUpload(
          file: true,
          video: true,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FaIcon(FontAwesomeIcons.lightCamera),
          ),
          onUploaded: (url) {
            debugLog('url: $url');
          },
        ),
        hintText: LibTr.of(context)!.enterComment,
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(16.0),
          icon: isCreatingReply
              ? CircularProgressIndicator.adaptive()
              : isTextEmpty
              ? FaIcon(
                  FontAwesomeIcons.lightPaperPlane,
                  color: Theme.of(
                    context,
                  ).iconTheme.color!.withValues(alpha: 0.35),
                )
              : FaIcon(FontAwesomeIcons.solidPaperPlane),
          onPressed: () async {
            isTextEmpty ? null : onTapReplyToComment();
          },
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}
