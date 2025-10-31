import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
  late final FocusNode _messageFocusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent) {
        final isShiftPressed =
            HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.shiftLeft,
            ) ||
            HardwareKeyboard.instance.isLogicalKeyPressed(
              LogicalKeyboardKey.shiftRight,
            );

        if (event.logicalKey == LogicalKeyboardKey.enter) {
          if (isShiftPressed) {
            // Shift + Enter: Allow default behavior (new line)
            _messageController.text += '\n';
            return KeyEventResult.ignored;
          } else {
            // Enter alone: Send message
            _handleSend();
            return KeyEventResult.handled;
          }
        }
      }
      return KeyEventResult.ignored;
    },
  );
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
  }

  void _clearFiles() {
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
          content: Text(LibTr.of(context)!.max_files_reached(widget.maxFiles)),
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
                        LibTr.of(context)!.select_files,
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
                  title: Text(LibTr.of(context)!.camera),
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
                title: Text(LibTr.of(context)!.gallery),
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
                content: Text(
                  LibTr.of(context)!.max_files_reached(widget.maxFiles),
                ),
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
            showErrorSnackBar(
              context,
              LibTr.of(context)!.upload_photo_failed(e.toString()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          LibTr.of(context)!.upload_photo_failed(e.toString()),
        );
      }
    }
  }

  Future<String> _sendMessage(String text, List<String>? urls) async {
    // if ((text.isEmpty && (urls == null || urls.isEmpty)) || isLoading) {
    //   return '';
    // }

    setState(() => isLoading = true);
    String messageId = '';
    try {
      debugPrint('Sending message: text="$text", urls=$urls');

      if (urls != null && urls.isNotEmpty) {
        // Send message with multiple files
        messageId = await sendMessage(
          roomId: widget.roomId,
          text: text.isEmpty ? '' : text,
          urls: urls,
        );
      } else {
        // Send text message
        messageId = await sendMessage(roomId: widget.roomId, text: text);
      }

      // moderate the message if it has an ID
      if (messageId.isNotEmpty) {
        // Add 1 second delay before moderating the message
        Future.delayed(const Duration(seconds: 1), () {
          moderateChat(widget.roomId, messageId)
              .then((_) {
                debugPrint('Message moderated successfully');
              })
              .catchError((e) {
                debugPrint('Error moderating message: $e');
              });
        });
      }

      _messageController.clear();
      debugPrint('Message sent successfully');
      // Request focus after clearing to ensure text field remains focused
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messageFocusNode.requestFocus();
      });
      widget.onSend.call();
    } catch (e) {
      debugPrint('Error sending message: $e');
      if (mounted) {
        showErrorSnackBar(
          context,
          LibTr.of(context)!.failed_to_send_message(e.toString()),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
    return messageId;
  }

  @override
  void dispose() {
    _messageController.dispose();
    // _titleController.dispose();
    super.dispose();
  }

  Widget _buildFilesPreview() {
    if (_selectedFiles.isEmpty && _uploadedUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length,
        itemBuilder: (context, index) {
          // debugLog("ListView.builder index: $index, uploadedUrls: $_uploadProgress");

          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: index < _uploadedUrls.length
                      ? Image.network(
                          _uploadedUrls[index],
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
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
                        borderRadius: BorderRadius.circular(12),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
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
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            '${LibTr.of(context)!.uploading_images} ($_completedUploads/${_selectedFiles.length})',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload status
            _buildUploadingStatus(),

            // Files preview
            _buildFilesPreview(),
            Row(
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: LibTr.of(context)!.attach_files,
                ),

                // Message Input Field
                Expanded(
                  child: TextField(
                    autofocus: true,
                    controller: _messageController,
                    focusNode: _messageFocusNode,
                    keyboardType: TextInputType.multiline,
                    textInputAction: kIsWeb ? TextInputAction.none : null,
                    decoration: InputDecoration(
                      hintText: LibTr.of(context)!.type_message,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !isLoading && !_isUploading,
                  ),
                ),

                const SizedBox(width: 8),

                // Send Button
                Container(
                  decoration: BoxDecoration(
                    color: (isLoading || _isUploading)
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: (isLoading || _isUploading) ? null : _handleSend,
                    icon: (isLoading || _isUploading)
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
