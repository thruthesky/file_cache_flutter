import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/util/util.functions.dart';

/// Message input widget for typing and sending messages with multiple file support
class ChatRoomMessageInput extends StatefulWidget {
  final String roomId; // Room ID for sending messages
  final Function() onSend;
  final int maxFiles; // Maximum number of files allowed

  const ChatRoomMessageInput({
    super.key,
    required this.roomId,
    required this.onSend,
    this.maxFiles = 5, // Default maximum of 5 files
  });

  @override
  State<ChatRoomMessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<ChatRoomMessageInput> {
  final TextEditingController _messageController = TextEditingController();

  final List<FileUploadModel> _uploadedFiles = [];
  bool _isUploading = false;
  bool isLoading = false;

  void _handleSend() {
    final text = _messageController.text.trim();

    if ((text.isEmpty && _uploadedFiles.isEmpty) || isLoading || _isUploading) {
      return;
    }

    final urls = _uploadedFiles.isNotEmpty
        ? _uploadedFiles.map((f) => f.url).toList()
        : null;
    _sendMessage(text, urls);

    setState(() => _uploadedFiles.clear());
  }

  void _removeFileAt(int index) {
    final file = _uploadedFiles[index];
    setState(() => _uploadedFiles.removeAt(index));
    ApiService.instance.fileDeleteByUrl(file.url).catchError((error) {
      debugLog('Error deleting file: $error');
    });
  }

  Future<String> _sendMessage(String text, List<String>? urls) async {
    isLoading = true;
    setState(() {});
    String messageId = '';
    try {
      debugPrint('Sending message: text="$text", urls=$urls');
      messageId = await ChatService.instance.sendMessage(
        roomId: widget.roomId,
        text: text.isEmpty ? '' : text,
        urls: urls,
      );
      _messageController.clear();
      debugPrint('Message sent successfully');
      widget.onSend.call();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        showErrorSnackBar(context, '메시지 전송 실패: {}'.tr(args: [e.toString()]));
      }
    } finally {
      isLoading = false;
      setState(() {});
    }
    return messageId;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Widget _buildFilesPreview() {
    if (_uploadedFiles.isEmpty && !_isUploading) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          ..._uploadedFiles.map(
            (file) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: UploadedFilePreview(
                file: file,
                size: 72,
                onDelete: () => _removeFileAt(_uploadedFiles.indexOf(file)),
              ),
            ),
          ),
          if (_isUploading)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final busy = isLoading || _isUploading;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: inputTopBorderWidth,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Files preview
            _buildFilesPreview(),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final iconButtonWidth = 48.0;
                final sendButtonWidth = 56.0;
                final minTextFieldWidth =
                    availableWidth * 0.8 - iconButtonWidth - sendButtonWidth;

                return Padding(
                  padding: inputAreaPadding,
                  child: Row(
                    children: [
                      // Attachment Button — reuses FileUpload widget
                      FileUpload(
                        module: 'chat',
                        code: 'message',
                        cameraVideo: true,
                        file: true,
                        imageQuality: 80,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        onBeforeUpload: () async {
                          if (_uploadedFiles.length >= widget.maxFiles) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                  '최대 {}개 파일을 선택할 수 있습니다.'.tr(
                                    args: ['${widget.maxFiles}'],
                                  ),
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return false;
                          }
                          return true;
                        },
                        onUploadingChanged: (uploading) =>
                            setState(() => _isUploading = uploading),
                        onUploaded: (FileUploadModel model) =>
                            setState(() => _uploadedFiles.add(model)),
                        onError: (e) => showErrorSnackBar(
                          context,
                          '업로드 실패: {}'.tr(args: [e.toString()]),
                        ),
                        child: busy
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
                            : IconButton(
                                onPressed: null,
                                icon: Stack(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightPaperclip,
                                      size: 20,
                                      color: busy
                                          ? colorScheme.onSurface.withValues(
                                              alpha: 0.3,
                                            )
                                          : colorScheme.onSurface,
                                    ),
                                    if (_uploadedFiles.isNotEmpty)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${_uploadedFiles.length}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fileBadgeFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                tooltip: '파일 첨부'.tr(),
                              ),
                      ),

                      // Message Input Field - 80% minimum width
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: minTextFieldWidth,
                          ),
                          child: TextField(
                            autofocus: false,
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: '메시지를 입력하세요...'.tr(),
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  inputBorderRadius,
                                ),
                                borderSide: BorderSide(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: inputFocusBorderWidth,
                                ),
                              ),
                              contentPadding: inputContentPadding,
                            ),
                            minLines: 1,
                            maxLines: 4,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                      ),

                      SizedBox(width: sendButtonSpacing),

                      // Send Button
                      GestureDetector(
                        onTapDown: busy
                            ? null
                            : (_) {
                                _handleSend();
                              },
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: sendButtonSize,
                            height: sendButtonSize,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: busy
                                    ? [
                                        colorScheme.secondary.withValues(
                                          alpha: 0.7,
                                        ),
                                        colorScheme.secondary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ]
                                    : [
                                        colorScheme.primary,
                                        colorScheme.primary.withValues(
                                          alpha: 0.8,
                                        ),
                                      ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: busy
                                    ? colorScheme.secondary.withValues(
                                        alpha: 0.3,
                                      )
                                    : colorScheme.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: busy
                                  ? SizedBox(
                                      width: sendIconSize,
                                      height: sendIconSize,
                                      child: CircularProgressIndicator(
                                        strokeWidth: loadingStrokeWidth,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : Icon(
                                      Icons.send,
                                      color: colorScheme.onPrimary,
                                      size: sendIconSize,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
