import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';

import 'package:philgo/storage/storage.functions.dart';
import 'package:philgo/util/util.functions.dart';

/// Message input widget for typing and sending messages with multiple file support
class ChatRoomMessageInput extends StatefulWidget {
  final String roomId; // Room ID for sending messages
  final Function() onSend;
  final int maxFiles; // Maximum number of files allowed
  // final bool enableBuyAndSell; // Enable buy and sell post feature

  const ChatRoomMessageInput({
    super.key,
    required this.roomId,
    required this.onSend,
    this.maxFiles = 5, // Default maximum of 5 files
    // this.enableBuyAndSell = false, // Enable buy and sell post feature
  });

  @override
  State<ChatRoomMessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<ChatRoomMessageInput> {
  final TextEditingController _messageController = TextEditingController();

  final List<XFile> _selectedFiles = [];
  final List<String> _uploadedUrls = [];
  bool _isUploading = false;

  bool isLoading = false;
  Map<int, double> _uploadProgress = {}; // Track progress for each file
  int _completedUploads = 0;

  void _handleSend() {
    final text = _messageController.text.trim();

    // Handle regular message
    if ((text.isEmpty && _uploadedUrls.isEmpty) || isLoading || _isUploading) {
      return;
    }

    // Send message with text and/or multiple URLs
    _sendMessage(text, _uploadedUrls.isNotEmpty ? _uploadedUrls : null);

    _clearFiles();
    // GestureDetector를 사용하므로 포커스가 유지되어 키보드가 사라지지 않음
  }

  void _clearFiles() {
    // TEST
    setState(() {
      _selectedFiles.clear();
      _uploadedUrls.clear();
      _uploadProgress.clear();
      _completedUploads = 0;
    });
  }

  void _removeFileAt(int index) {
    setState(() {
      if (index < _selectedFiles.length) {
        _selectedFiles.removeAt(index);
      }
      if (index < _uploadedUrls.length) {
        final urlToDelete = _uploadedUrls.removeAt(index);
        deleteImage(
          urlToDelete,
          onError: (error) {
            debugLog('There should not be Error deleting file $index: $error');
          },
        );
      }
      _uploadProgress.remove(index);
      // Update progress indices
      final newProgress = <int, double>{};
      _uploadProgress.forEach((key, value) {
        if (key > index) {
          newProgress[key - 1] = value;
        } else if (key < index) {
          newProgress[key] = value;
        }
      });
      _uploadProgress = newProgress;
    });
  }

  Future<void> _showFilePicker() async {
    if (_selectedFiles.length >= widget.maxFiles) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("You can select up to {widget.maxFiles} files."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          runSpacing: 16,
          children: [
            // Header with title and close button
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Files",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Divider(),
              ],
            ),

            // Camera option
            if (!kIsWeb)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text("Camera"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickAndUploadImages(
                      ImageSource.camera,
                      single: true,
                    );
                  },
                ),
              ),

            // Gallery  and Multiple files option
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
              child: ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickAndUploadImages(
                    ImageSource.gallery,
                    single: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImages(
    ImageSource source, {
    bool single = false,
  }) async {
    try {
      List<XFile> images = [];
      final ImagePicker imagePicker = ImagePicker();
      if (single) {
        final XFile? image = await imagePicker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (image != null) {
          images = [image];
        }
      } else {
        final remainingSlots = widget.maxFiles - _selectedFiles.length;
        final selectedImages = await imagePicker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        images = selectedImages;

        // Limit to remaining slots
        if (images.length > remainingSlots) {
          images = images.take(remainingSlots).toList();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text("You can select up to ${widget.maxFiles} files."),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      if (images.isNotEmpty) {
        // final files = images.map((image) => File(image.path)).toList();
        _selectedFiles.addAll(images);
        _isUploading = true;
        _completedUploads = 0;
        // Initialize progress for new files
        _uploadProgress.clear();
        log('_uploadProgress: $_uploadProgress');
        for (int i = _uploadedUrls.length; i < _selectedFiles.length; i++) {
          _uploadProgress[i] = 0.0;
          log('Initialized upload progress for file $i: ${_uploadProgress[i]}');
        }
        setState(() {});

        try {
          // Upload the new files
          final startIndex = _uploadedUrls.length;
          final urls = await uploadMultipleImages(
            images,
            onProgress: (index, progress) {
              debugLog("index: $index, progress: $progress");
              setState(() {
                _uploadProgress[startIndex + index] = progress;
                if (_completedUploads <= images.length &&
                    _uploadProgress[startIndex + index] == 100) {
                  _completedUploads++;
                }
              });
            },
            onFileCompleted: (completed, total) {
              setState(() {
                _completedUploads = completed;
              });
            },
          );

          setState(() {
            _uploadedUrls.addAll(urls);
            _isUploading = false;
          });
        } catch (e) {
          setState(() {
            _isUploading = false;
            // Remove the files that failed to upload
            for (int i = 0; i < images.length; i++) {
              if (_selectedFiles.isNotEmpty) {
                _selectedFiles.removeLast();
              }
            }
            _uploadProgress.clear();
          });

          if (mounted) {
            showErrorSnackBar(context, "Upload image failed: ${e.toString()}");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, "Upload failed: ${e.toString()}");
      }
    }
  }

  Future<String> _sendMessage(String text, List<String>? urls) async {
    // if ((text.isEmpty && (urls == null || urls.isEmpty)) || isLoading) {
    //   return '';
    // }
    isLoading = true;
    setState(() {});
    String messageId = '';
    try {
      debugPrint('Sending message: text="$text", urls=$urls');

      if (urls != null && urls.isNotEmpty) {
        // Send message with multiple files
        messageId = await ChatService.instance.sendMessage(
          roomId: widget.roomId,
          text: text.isEmpty ? '' : text,
          urls: urls,
        );
      } else {
        // Send text message
        messageId = await ChatService.instance.sendMessage(roomId: widget.roomId, text: text);
      }

      // moderate the message if it has an ID
      // if (messageId.isNotEmpty) {
      //   // Add 1 second delay before moderating the message
      //   Future.delayed(const Duration(seconds: 1), () {
      //     moderateChat(widget.roomId, messageId)
      //         .then((_) {
      //           debugPrint('Message moderated successfully');
      //         })
      //         .catchError((e) {
      //           debugPrint('Error moderating message: $e');
      //         });
      //   });
      // }

      _messageController.clear();
      debugPrint('Message sent successfully');
      widget.onSend.call();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        showErrorSnackBar(context, "Failed to send message: $e{e.toString()}");
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
    if (_selectedFiles.isEmpty && _uploadedUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: filePreviewMarginTop),
      height: filePreviewHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          // debugLog("ListView.builder index: $index, uploadedUrls: $_uploadProgress");

          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            margin: EdgeInsets.only(right: filePreviewSpacing, left: index == 0 ? filePreviewSpacing : 0),
            width: filePreviewWidth,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(filePreviewBorderRadius),

              /// Flat design - subtle border
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(filePreviewBorderRadius),
                  child: index < _uploadedUrls.length
                      ? Image.network(
                          _uploadedUrls[index],
                          height: filePreviewHeight,
                          width: filePreviewWidth + 20,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: filePreviewHeight,
                              width: filePreviewWidth + 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(filePreviewBorderRadius),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: filePreviewHeight,
                              width: filePreviewWidth + 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(filePreviewBorderRadius),
                              ),
                              child: const Icon(Icons.error, color: Colors.red),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                        ),
                ),

                // Upload progress overlay
                if (_isUploading && _uploadProgress.containsKey(index))
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(filePreviewBorderRadius),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _uploadProgress[index],
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(_uploadProgress[index]! * 100).round()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: uploadProgressFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Delete button
                if (!_isUploading || index >= _uploadedUrls.length)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeFileAt(index),
                      child: Container(
                        padding: EdgeInsets.all(deleteButtonPadding),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: deleteIconSize,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadingStatus() {
    if (!_isUploading || _selectedFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: loadingIndicatorSize,
            height: loadingIndicatorSize,
            child: CircularProgressIndicator(strokeWidth: loadingStrokeWidth),
          ),
          SizedBox(width: loadingSpacing),
          Text(
            'Uploading images ($_completedUploads/${_selectedFiles.length})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            // Upload status
            _buildUploadingStatus(),

            // Files preview
            _buildFilesPreview(),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final iconButtonWidth = 48.0; // Attachment button width
                final sendButtonWidth = 56.0; // Send button width + spacing
                final minTextFieldWidth =
                    availableWidth * 0.8 - iconButtonWidth - sendButtonWidth;

                return Padding(
                  padding: inputAreaPadding,
                  child: Row(
                    children: [
                      // Attachment Button
                      IconButton(
                        onPressed: (isLoading || _isUploading)
                            ? null
                            : _showFilePicker,
                        icon: Stack(
                          children: [
                            const Icon(Icons.add),
                            if (_selectedFiles.isNotEmpty)
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
                                    '${_selectedFiles.length}',
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
                        tooltip: "Attach files",
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
                              hintText: "Type a message...",
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputBorderRadius),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputBorderRadius),
                                borderSide: BorderSide(
                                  color: colorScheme.outlineVariant.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(inputBorderRadius),
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
                            // enabled: !isLoading && !_isUploading,
                            onSubmitted: (_) => _handleSend(),
                          ),
                        ),
                      ),

                      SizedBox(width: sendButtonSpacing),

                      // Send Button with enhanced flat design
                      GestureDetector(
                        // Use onTapDown to trigger send before focus changes
                        onTapDown: (isLoading || _isUploading)
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
                              /// Gradient background for visual interest
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: (isLoading || _isUploading)
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

                              /// Flat design - subtle border
                              border: Border.all(
                                color: (isLoading || _isUploading)
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
                              child: (isLoading || _isUploading)
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
