import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

class ReplyToComment extends StatefulWidget {
  const ReplyToComment({
    super.key,
    required this.parent,
    required this.onReplied,
    this.onBusyStateChanged,
  });

  final Comment parent;
  final Function(Comment) onReplied;
  final Function(bool isBusy)? onBusyStateChanged;

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
  String? deletingFileUrl; // Track which file is being deleted

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

  /// Notify parent if widget is busy (uploading, deleting, or submitting)
  void notifyBusyState() {
    final isBusy =
        uploadingCount > 0 || deletingFileUrl != null || isCreatingReply;
    widget.onBusyStateChanged?.call(isBusy);
  }

  void onTapReplyToComment() async {
    // Dismiss keyboard immediately after successful reply creation
    focusNode.unfocus();
    try {
      isCreatingReply = true;
      setState(() {});
      notifyBusyState();

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
      if (mounted) {
        showSafeErrorDialog(
          PhilgoTr.of(context)!.failedToPostReply(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        isCreatingReply = false;
        setState(() {});
        notifyBusyState();
      }
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
                    (url) => IgnorePointer(
                      // Disable interaction when any file is being deleted
                      ignoring:
                          deletingFileUrl != null && deletingFileUrl != url,
                      child: Opacity(
                        // Dim other files when one is being deleted
                        opacity:
                            deletingFileUrl != null && deletingFileUrl != url
                            ? 0.5
                            : 1.0,
                        child: UploadPreview(
                          url: url,
                          width: 80,
                          height: 80,
                          borderRadius: 8,
                          isDeleting: deletingFileUrl == url,
                          onDelete: () async {
                            // Mark this file as being deleted
                            setState(() {
                              deletingFileUrl = url;
                            });
                            notifyBusyState();

                            try {
                              await philgoApiFileDelete(url);
                              debugLog("File deleted: $url");
                              imageUrls.remove(url);
                            } catch (e) {
                              debugLog("Failed to delete file: $e");
                              if (mounted && context.mounted) {
                                showSafeErrorDialog(
                                  PhilgoTr.of(
                                    context,
                                  )!.failedToDeleteFile(e.toString()),
                                );
                              }
                            } finally {
                              // Clear deleting state
                              if (mounted) {
                                setState(() {
                                  deletingFileUrl = null;
                                });
                                notifyBusyState();
                              }
                            }
                          },
                        ),
                      ),
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
            prefixIcon: deletingFileUrl != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FaIcon(
                      FontAwesomeIcons.lightCamera,
                      color: Theme.of(
                        context,
                      ).iconTheme.color!.withValues(alpha: 0.3),
                    ),
                  )
                : FileUpload(
                    file: true,
                    video: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FaIcon(FontAwesomeIcons.lightCamera),
                    ),
                    onBeforeUpload: () {
                      if (!mounted) false;
                      setState(() {
                        uploadingCount++;
                      });
                      notifyBusyState();
                    },
                    onUploaded: (url) {
                      if (!mounted) false;
                      debugLog('url: $url');
                      imageUrls.add(url);
                      uploadingCount--;
                      setState(() {});
                      notifyBusyState();
                    },
                    onCancelled: () {
                      if (!mounted) false;
                      // Decrement upload count when upload fails or is cancelled
                      uploadingCount--;
                      setState(() {});
                      notifyBusyState();
                      debugLog(
                        'File upload cancelled or failed, uploadingCount: $uploadingCount',
                      );
                    },
                  ),
            suffixIcon: IconButton(
              padding: const EdgeInsets.all(16.0),
              icon: isCreatingReply || deletingFileUrl != null
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
                // Disable if empty, submitting, or deleting a file
                if (isTextEmpty || isCreatingReply || deletingFileUrl != null) {
                  return;
                }
                onTapReplyToComment();
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
