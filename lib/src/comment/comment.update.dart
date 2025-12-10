import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

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
  bool isTextEmpty = false;

  List<String> imageUrls = [];
  int uploadingCount = 0;

  @override
  void initState() {
    super.initState();
    contentController.text = widget.comment.content;
    imageUrls = List<String>.from(widget.comment.files);
    isTextEmpty = contentController.text.trim().isEmpty;
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

  Future<void> onUpdateComment() async {
    if (uploadingCount > 0) {
      showSafeErrorDialog(
        'Image upload is in progress, please try again in a moment.',
      );
      return;
    }
    setState(() {
      submitting = true;
    });
    try {
      final updatedComment = await updateComment({
        'idx': widget.comment.idx,
        'content': contentController.text,
        'files': imageUrls.join(','),
      });
      debugLog('updatedComment: $updatedComment');
      widget.onUpdated(updatedComment);
    } catch (e) {
      debugLog('댓글 업데이트 실패: $e');
      showSafeErrorDialog('댓글 업데이트에 실패했습니다: $e');
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 미리보기 섹션
        if (imageUrls.isNotEmpty || uploadingCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  ...imageUrls.map(
                    (url) => UploadPreview(
                      url: url,
                      width: 80,
                      height: 80,
                      borderRadius: 8,
                      onDelete: () async {
                        try {
                          await philgoApiFileDelete(url);
                          imageUrls.remove(url);
                          setState(() {});
                        } catch (e) {
                          showSafeErrorDialog("Failed to delete file: $e");
                        }
                      },
                    ),
                  ),
                  // 업로드 중인 이미지 로딩 박스
                  ...List.generate(
                    uploadingCount,
                    (index) =>
                        LoadingBox(width: 80, height: 80, borderRadius: 8),
                  ),
                ],
              ),
            ),
          ),
        // 텍스트 입력 필드 with Comic Design
        TextField(
          controller: contentController,
          minLines: 1,
          maxLines: 2,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            // Comic Design: 2.0px border with rounded corners
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
            ),
            prefixIcon: FileUpload(
              file: true,
              video: true,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FaIcon(FontAwesomeIcons.lightCamera),
              ),
              onBeforeUpload: () {
                setState(() {
                  uploadingCount++;
                });
              },
              onUploaded: (url) {
                debugLog('새 이미지 업로드 완료: $url');
                imageUrls.add(url);
                uploadingCount--;
                setState(() {});
              },
            ),
            suffixIcon: IconButton(
              padding: const EdgeInsets.all(16.0),
              icon: submitting
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : isTextEmpty
                  ? FaIcon(
                      FontAwesomeIcons.lightPaperPlane,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withValues(alpha: 0.35),
                    )
                  : FaIcon(FontAwesomeIcons.solidPaperPlane),
              onPressed: () async {
                if (isTextEmpty) return;
                await onUpdateComment();
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
