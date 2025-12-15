import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentCreateForm extends StatefulWidget {
  const CommentCreateForm({
    super.key,
    required this.post,
    required this.onCreated,
    this.focusNode,
  });

  final Post post;
  final Function(Comment) onCreated;
  final FocusNode? focusNode;

  @override
  State<CommentCreateForm> createState() => _CommentCreateFormState();
}

class _CommentCreateFormState extends State<CommentCreateForm> {
  final contentController = TextEditingController();
  late final FocusNode focusNode;

  bool isCreatingReply = false;
  bool isTextEmpty = true;

  List<String> imageUrls = [];
  int uploadingCount = 0; // Track number of ongoing uploads

  @override
  void initState() {
    super.initState();
    // Use provided focusNode or create a new one
    focusNode = widget.focusNode ?? FocusNode();
    contentController.addListener(onTextChanged);
  }

  @override
  void dispose() {
    contentController.removeListener(onTextChanged);
    contentController.dispose();
    // Only dispose focusNode if we created it (not provided externally)
    if (widget.focusNode == null) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void onTextChanged() {
    final isEmpty = contentController.text.trim().isEmpty;

    if (isEmpty != isTextEmpty) {
      setState(() {
        isTextEmpty = isEmpty;
      });
    }
  }

  void onTapCommentToPost() async {
    focusNode.unfocus();

    try {
      if (uploadingCount > 0) {
        showSafeErrorDialog(
          'Image upload is in progress, please try again in a moment.',
        );
        return;
      }

      isCreatingReply = true;

      setState(() {});

      final createdComment = await createComment({
        'idx_root': widget.post.idx,
        'content': contentController.text,
        'files': imageUrls.join(','),
      });

      widget.onCreated(createdComment);

      contentController.text = '';
      imageUrls.clear();
      uploadingCount = 0;
    } catch (e) {
      debugLog('Failed to post comment: $e');
      showSafeErrorDialog('Failed to post comment: $e');
    } finally {
      isCreatingReply = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image preview section
        if (imageUrls.isNotEmpty || uploadingCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  // Display uploaded images with delete button
                  ...imageUrls.map(
                    (url) => UploadPreview(
                      url: url,
                      width: 80,
                      height: 80,
                      borderRadius: 8,
                      onDelete: () async {
                        try {
                          await philgoApiFileDelete(url);
                          debugLog("File deleted: $url");
                          imageUrls.remove(url);
                          setState(() {});
                        } catch (e) {
                          debugLog("파일 삭제 실패: $e");
                          showSafeErrorDialog("파일 삭제에 실패했습니다: $e");
                        }
                      },
                    ),
                  ),
                  // Display loading boxes for uploading images
                  ...List.generate(
                    uploadingCount,
                    (url) => LoadingBox(width: 80, height: 80, borderRadius: 8),
                  ),
                ],
              ),
            ),
          ),
        // Comment input field with Comic Design
        // 포커스 시 minLines를 4로 확장하여 더 넓은 입력 영역 제공
        // multiline 키보드 타입으로 엔터키가 줄바꿈으로 동작
        TextField(
          controller: contentController,
          focusNode: focusNode,
          minLines: 1, //
          maxLines: 6,
          keyboardType: TextInputType.multiline, // 엔터키로 줄바꿈 가능
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
                debugLog('url: $url');
                imageUrls.add(url);
                uploadingCount--;
                setState(() {});
              },
              onCancelled: () {
                // Decrement upload count when upload fails or is cancelled
                uploadingCount--;
                setState(() {});
                debugLog(
                  'File upload cancelled or failed, uploadingCount: $uploadingCount',
                );
              },
            ),
            suffixIcon: IconButton(
              padding: const EdgeInsets.all(16.0),
              icon: isCreatingReply
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
                  : FaIcon(
                      FontAwesomeIcons.solidPaperPlane,
                      // Use primary color for active send button
                      color: Theme.of(context).colorScheme.primary,
                    ),
              onPressed: () {
                isTextEmpty ? null : onTapCommentToPost();
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
