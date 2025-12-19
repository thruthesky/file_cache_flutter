import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

class CommentUpdate extends StatefulWidget {
  const CommentUpdate({
    super.key,
    required this.comment,
    required this.onUpdated,
    this.onBusyStateChanged,
    this.onFileDeleted,
    this.onFileUpdated,
  });
  final Comment comment;
  final Function(Comment) onUpdated;
  final Function(bool isBusy)? onBusyStateChanged;
  final Function(Comment)? onFileDeleted;
  final Function(Comment)? onFileUpdated;

  @override
  State<CommentUpdate> createState() => _CommentUpdateState();
}

class _CommentUpdateState extends State<CommentUpdate> {
  final contentController = TextEditingController();
  final focusNode = FocusNode();
  bool submitting = false;
  bool isTextEmpty = false;

  List<String> imageUrls = [];
  int uploadingCount = 0;
  String? deletingFileUrl;

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
    final isBusy = uploadingCount > 0 || deletingFileUrl != null || submitting;
    widget.onBusyStateChanged?.call(isBusy);
  }

  Future<void> onUpdateComment() async {
    focusNode.unfocus();

    setState(() {
      submitting = true;
    });
    notifyBusyState();
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
      if (mounted) {
        showSafeErrorDialog(
          PhilgoTr.of(context)!.failedToUpdateComment(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
        notifyBusyState();
      }
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
                            // Ask user for confirmation before deleting
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(PhilgoTr.of(context)!.delete),
                                content: Text(
                                  PhilgoTr.of(context)!.deleteFileConfirmation,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text(PhilgoTr.of(context)!.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    child: Text(PhilgoTr.of(context)!.delete),
                                  ),
                                ],
                              ),
                            );

                            // If user cancelled, return early
                            if (confirmed != true) return;

                            // Mark this file as being deleted
                            setState(() {
                              deletingFileUrl = url;
                            });
                            notifyBusyState();

                            try {
                              // Delete file from storage
                              await philgoApiFileDelete(url);

                              // Remove from local list
                              imageUrls.remove(url);

                              // Update comment on server immediately
                              final updatedComment = await updateComment({
                                'idx': widget.comment.idx,
                                'content': contentController.text,
                                'files': imageUrls.join(','),
                              });

                              debugPrint(
                                'Updated comment -----> $updatedComment',
                              );

                              // Notify parent to update comment data without exiting edit mode
                              widget.onFileDeleted?.call(updatedComment);
                            } catch (e) {
                              if (mounted && context.mounted) {
                                showSafeErrorDialog(
                                  PhilgoTr.of(context)!.failedToDeleteFile(
                                    e.toString(),
                                  ),
                                );
                              }
                            } finally {
                              // Clear deleting state and stay in edit mode
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
                      if (!mounted) return;
                      setState(() {
                        uploadingCount++;
                      });
                      notifyBusyState();
                    },
                    onUploaded: (url) async {
                      if (!mounted) return;
                      debugLog('새 이미지 업로드 완료: $url');
                      imageUrls.add(url);
                      uploadingCount--;
                      setState(() {});
                      notifyBusyState();

                      // Update comment on server immediately after file upload
                      try {
                        final updatedComment = await updateComment({
                          'idx': widget.comment.idx,
                          'content': contentController.text,
                          'files': imageUrls.join(','),
                        });

                        debugPrint(
                          'Updated comment after file upload -----> $updatedComment',
                        );

                        // Notify parent to update comment data without exiting edit mode
                        widget.onFileUpdated?.call(updatedComment);
                      } catch (e) {
                        debugLog(
                          'Failed to update comment after file upload: $e',
                        );
                        if (context.mounted) {
                          showSafeErrorDialog(
                            PhilgoTr.of(context)!.failedToUpdateComment(
                              e.toString(),
                            ),
                          );
                        }
                      }
                    },
                    onCancelled: () {
                      if (!mounted) return;
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
              icon: submitting || deletingFileUrl != null
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
              onPressed: () async {
                // Disable if empty, submitting, or deleting a file
                if (isTextEmpty || submitting || deletingFileUrl != null) {
                  return;
                }
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
