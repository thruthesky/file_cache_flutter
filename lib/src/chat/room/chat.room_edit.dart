import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ChatRoomEdit extends StatefulWidget {
  final ChatRoom room;
  final VoidCallback? onRoomUpdated;

  const ChatRoomEdit({super.key, required this.room, this.onRoomUpdated});

  @override
  State<ChatRoomEdit> createState() => _ChatRoomEditState();
}

class _ChatRoomEditState extends State<ChatRoomEdit> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late bool _isOpen;
  late bool _blockAdvertisement;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  String? _currentImageUrl;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _descriptionController = TextEditingController(
      text: widget.room.description,
    );
    _isOpen = widget.room.open;
    _blockAdvertisement = widget.room.blockAdvertisement ?? false;
    _currentImageUrl = widget.room.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      // Comic design: no shadow
      elevation: 0,
      // Comic design: rounded corners (borderRadius: 12)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Remove default background to use Container decoration
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          // Comic design: surface background color
          color: colorScheme.surface,
          // Comic design: 2.0px outline border with rounded corners
          border: Border.all(
            color: colorScheme.outline,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section - Comic design spacing (multiples of 8)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                LibTr.of(context)!.edit_chat_room,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Content section - Comic design spacing
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar Section
                      _buildAvatarSection(),
                      const SizedBox(height: 20),

                      // Room Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: '${LibTr.of(context)!.room_name} *',
                          hintText: LibTr.of(context)!.enter_room_name,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.group),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return LibTr.of(context)!.room_name_required;
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Room Description Field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: LibTr.of(context)!.room_description,
                          hintText: LibTr.of(context)!.enter_room_description,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Open Room Toggle
                      SwitchListTile(
                        title: Text(LibTr.of(context)!.open_room),
                        subtitle: Text(LibTr.of(context)!.open_room_description),
                        value: _isOpen,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _isOpen = value;
                                });
                              },
                        secondary: Icon(_isOpen ? Icons.public : Icons.lock),
                      ),

                      const SizedBox(height: 8),

                      // Block Advertisement Toggle
                      SwitchListTile(
                        title: Text(LibTr.of(context)!.block_advertisement),
                        subtitle: Text(
                          LibTr.of(context)!.block_advertisement_description,
                        ),
                        value: _blockAdvertisement,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  _blockAdvertisement = value;
                                });
                              },
                        secondary: Icon(
                          _blockAdvertisement ? Icons.block : Icons.ads_click,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Actions section - Comic design buttons with spacing
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button - Comic design neutral button
                  ElevatedButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: surface background
                      backgroundColor:
                          WidgetStateProperty.all(colorScheme.surface),
                      // Comic design: onSurface text color
                      foregroundColor:
                          WidgetStateProperty.all(colorScheme.onSurface),
                      // Comic design: padding in multiples of 8
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                    child: Text(LibTr.of(context)!.cancel),
                  ),
                  const SizedBox(width: 8),
                  // Save button - Comic design primary button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSaveRoom,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _isLoading
                                ? colorScheme.outline
                                : colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: primary background
                      backgroundColor: WidgetStateProperty.all(
                        _isLoading
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.primary,
                      ),
                      // Comic design: onPrimary text color
                      foregroundColor: WidgetStateProperty.all(
                        _isLoading
                            ? colorScheme.onSurface
                            : colorScheme.onPrimary,
                      ),
                      // Comic design: padding in multiples of 8
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onSurface,
                            ),
                          )
                        : Text(LibTr.of(context)!.save),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveRoom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    setState(() {});

    editChatRoom(
      roomId: widget.room.id,
      name: _nameController.text,
      description: _descriptionController.text,
      open: _isOpen,
      blockAdvertisement: _blockAdvertisement,
      success: (room) {
        if (mounted) {
          // Show success message
          showSuccessSnackBar(
            context,
            LibTr.of(context)!.edit_chat_room_success,
          );

          // Call callback and close dialog
          widget.onRoomUpdated?.call();
          Navigator.of(context).pop();
          setState(() {
            _isLoading = false;
          });
        }
      },
      error: (e) {
        if (mounted) {
          showErrorSnackBar(
            context,
            LibTr.of(context)!.failed_to_update_room(e),
          );
        }
      },
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar Display
        GestureDetector(
          onTap: _isLoading || _isUploadingImage ? null : onUploadHandle,
          child: Stack(
            children: [
              // Avatar Circle
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: _isUploadingImage
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: _uploadProgress,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${(_uploadProgress * 100).toInt()}%',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : _currentImageUrl == null || _currentImageUrl!.isEmpty
                      ? const Icon(Icons.group, size: 50, color: Colors.grey)
                      : ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _currentImageUrl!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.group,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),

              // Edit Button
              if (!_isUploadingImage)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : onUploadHandle,
                          icon: Icon(
                            Icons.camera_alt,
                            color: Theme.of(context).colorScheme.surface,
                            size: 16,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!_isUploadingImage &&
                  _currentImageUrl != null &&
                  _currentImageUrl!.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          onPressed: _isLoading ? null : deleteChatRoomProfile,
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.surface,
                            size: 16,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onUploadHandle() async {
    return uploadImagePicker(
      context,
      onUpload: (url) async {
        await editChatRoomPhotoUrl(widget.room.id, url);
        setState(() {
          _currentImageUrl = url;
          _isUploadingImage = false;
        });
        if (mounted) {
          showSuccessSnackBar(
            context,
            LibTr.of(context)!.profile_photo_updated,
          );
          // Call callback to refresh the UI
          widget.onRoomUpdated?.call();
        }
      },
      onError: (error) {
        setState(() {
          _isUploadingImage = false;
        });

        if (mounted) {
          showErrorSnackBar(
            context,
            '${LibTr.of(context)!.upload_photo_failed}: $error',
          );
        }
      },
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
          _isUploadingImage = true;
        });
      },
      currentImageUrl: _currentImageUrl,
    );
  }

  Future<void> deleteChatRoomProfile() async {
    if (_currentImageUrl == null || _currentImageUrl!.isEmpty) {
      return;
    }

    try {
      setState(() {
        _isUploadingImage = true; // Use this to show loading state
      });

      // Delete chat room avatar immediately via API
      await deleteChatRoomPhotoUrl(widget.room.id);

      setState(() {
        _currentImageUrl = null;
        _isUploadingImage = false;
      });

      if (mounted) {
        showSuccessSnackBar(context, LibTr.of(context)!.profile_photo_removed);
        // Call callback to refresh the UI
        widget.onRoomUpdated?.call();
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        showErrorSnackBar(
          context,
          LibTr.of(context)!.failed_to_remove_profile_photo(e.toString()),
        );
      }
    }
  }
}
