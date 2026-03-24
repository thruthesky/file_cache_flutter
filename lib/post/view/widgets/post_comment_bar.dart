import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 게시글 하단 고정 댓글 입력 바
///
/// 파일 업로드, 답글 표시, 댓글 전송 기능을 제공한다.
/// [replyTo]가 null이 아니면 답글 모드로 표시된다.
class PostCommentBar extends StatefulWidget {
  final int idxRoot;
  final Post? replyTo;
  final VoidCallback? onCancelReply;
  final Future<void> Function(
    String content,
    int? idxParent,
    List<FileUploadModel> files,
  )
  onSubmit;

  const PostCommentBar({
    super.key,
    required this.idxRoot,
    this.replyTo,
    this.onCancelReply,
    required this.onSubmit,
  });

  @override
  State<PostCommentBar> createState() => _PostCommentBarState();
}

class _PostCommentBarState extends State<PostCommentBar> {
  final _controller = TextEditingController();
  final List<FileUploadModel> _files = [];
  bool _isSending = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if ((content.isEmpty && _files.isEmpty) || _isSending || _isUploading) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await widget.onSubmit(content, widget.replyTo?.idx, List.from(_files));
      _controller.clear();
      setState(() => _files.clear());
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
    final userState = Provider.of<UserState>(context, listen: false);
    final isLoggedIn = userState.isLoggedIn;
    final isReplying = widget.replyTo != null;
    // "Write a reply", "Write a comment"
    final hintText = isReplying ? '답글을 입력하세요'.tr() : '댓글을 입력하세요'.tr();

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        border: Border(
          top: BorderSide(color: color.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 답글 대상 표시 — 카메라 아이콘과 동일한 좌측 정렬
            if (isReplying)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.reply,
                      size: 12,
                      color: color.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 답글 대상 이름
                          Text(
                            '@${widget.replyTo!.userName}',
                            style: text.labelSmall
                                ?.copyWith(
                                  color: color.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // 답글 대상 내용 미리보기
                          if (widget.replyTo!.content.isNotEmpty)
                            Text(
                              widget.replyTo!.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall
                                  ?.copyWith(color: color.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: widget.onCancelReply,
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: 14,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            // 파일 미리보기 스트립
            if (_files.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: _files.map((file) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: UploadedFilePreview(
                        file: file,
                        size: 72,
                        onDelete: () {
                          setState(() => _files.remove(file));
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 로그인 미입력 시 비활성 힌트
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  // "Please login to write a comment."
                  '댓글을 작성하려면 로그인이 필요합니다.'.tr(),
                  style: text.bodySmall?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),

            // 입력 행 (로그인 시에만 표시)
            if (isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 파일 업로드 버튼
                    FileUpload(
                      module: 'post',
                      code: 'comment',
                      camera: true,
                      gallery: true,
                      cameraVideo: true,
                      file: true,
                      onUploadingChanged: (uploading) {
                        setState(() => _isUploading = uploading);
                      },
                      onUploaded: (model) {
                        setState(() => _files.add(model));
                      },
                      onError: (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          // "File upload failed"
                          SnackBar(content: Text('${'파일 업로드 실패'.tr()}: $e')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4, bottom: 4),
                        child: _isUploading
                            ? const SizedBox(
                                width: 36,
                                height: 36,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: 36,
                                height: 36,
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.lightCamera,
                                    size: 20,
                                    color: color.onSurfaceVariant,
                                  ),
                                ),
                              ),
                      ),
                    ),

                    // 텍스트 입력
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: TextStyle(color: color.onSurfaceVariant),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: color.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: color.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: color.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                        style: text.bodyMedium,
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
                              color: color.primary,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
