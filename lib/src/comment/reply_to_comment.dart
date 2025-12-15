import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

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
  final focusNode = FocusNode();

  bool isCreatingReply = false;
  bool isTextEmpty = true;

  List<String> imageUrls = [];
  int uploadingCount = 0; // Track number of ongoing uploads

  @override
  void initState() {
    super.initState();
    contentController.addListener(onTextChanged);
  }

  @override
  void dispose() {
    contentController.removeListener(onTextChanged);
    contentController.dispose();
    focusNode.dispose();
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

  void onTapReplyToComment() async {
    // Dismiss keyboard immediately after successful reply creation
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
        'idx_root': widget.parent.idx_root,
        'idx_parent': widget.parent.idx,
        'content': contentController.text,
        'files': imageUrls.join(','),
      });

      widget.onReplied(createdComment);

      contentController.text = '';
      imageUrls.clear();
      uploadingCount = 0;
    } catch (e) {
      debugLog('Failed to post reply: $e');
      showSafeErrorDialog('Failed to post reply: $e');
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
                          debugLog("Failed to delete file: $e");
                          showSafeErrorDialog("Failed to delete file: $e");
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
        TextField(
          controller: contentController,
          focusNode: focusNode,
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
                debugLog('url: $url');
                imageUrls.add(url);
                uploadingCount--;
                setState(() {});
              },
              onCancelled: () {
                // Decrement upload count when upload fails or is cancelled
                uploadingCount--;
                setState(() {});
                debugLog('File upload cancelled or failed, uploadingCount: $uploadingCount');
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
                  : FaIcon(FontAwesomeIcons.solidPaperPlane),
              onPressed: () {
                isTextEmpty ? null : onTapReplyToComment();
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
