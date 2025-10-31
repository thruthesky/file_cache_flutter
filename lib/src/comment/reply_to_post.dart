import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReplyToPost extends StatefulWidget {
  const ReplyToPost({super.key, required this.post, required this.onCreated});

  final Post post;
  final Function(Comment) onCreated;

  @override
  State<ReplyToPost> createState() => _ReplyToCommentFormState();
}

class _ReplyToCommentFormState extends State<ReplyToPost> {
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

  void onTapReplyToPost() async {
    try {
      setState(() {
        isCreatingReply = true;
      });

      final createdComment = await philgoApiCreateComment({
        'idx_root': widget.post.idx,
        'content': contentController.text,
      });

      widget.onCreated(createdComment);
    } finally {
      contentController.text = '';

      setState(() {
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
          onPressed: () {
            isTextEmpty ? null : onTapReplyToPost();
          },
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}
