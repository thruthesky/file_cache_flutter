import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'package:philgo/api/api.service.dart';
import 'package:philgo/file_upload/file_upload.model.dart';

/// 파일 업로드 위젯
///
/// GestureDetector로 child를 감싸 탭 시 업로드 소스 선택 바텀시트를 표시한다.
/// 카메라 사진, 카메라 동영상, 갤러리, 파일 네 가지 소스를 지원하며 선택 후 자동으로 업로드한다.
///
/// 사용 예시:
/// ```dart
/// FileUpload(
///   module: 'company',
///   code: 'main_photo',
///   camera: true,
///   gallery: true,
///   onUploaded: (model) {
///     setState(() => photoUrl = model.url);
///   },
///   child: Icon(Icons.camera_alt),
/// )
/// ```
class FileUpload extends StatefulWidget {
  /// 탭 가능한 자식 위젯
  final Widget child;

  /// 모듈명 (예: 'company', 'post', 'user')
  final String? module;

  /// 세부 분류 (예: 'main_photo', 'gallery', 'profile_photo')
  final String? code;

  /// 카메라 사진 소스 활성화 여부 (기본: true)
  final bool camera;

  /// 카메라 동영상 소스 활성화 여부 (기본: false)
  final bool cameraVideo;

  /// 갤러리 소스 활성화 여부 (기본: true)
  final bool gallery;

  /// 파일 피커 소스 활성화 여부 (기본: false)
  final bool file;

  /// 이미지 최대 너비 (픽셀)
  final double? maxWidth;

  /// 이미지 최대 높이 (픽셀)
  final double? maxHeight;

  /// 이미지 압축 품질 (0~100)
  final int imageQuality;

  /// FormData에 추가할 임의 필드
  final Map<String, dynamic>? extraData;

  /// 업로드 시작 전 콜백 (false 반환 시 업로드 취소)
  final Future<bool> Function()? onBeforeUpload;

  /// 업로드 진행률 콜백 (0.0 ~ 1.0)
  final void Function(double progress)? onProgress;

  /// 업로드 완료 콜백
  final void Function(FileUploadModel model)? onUploaded;

  /// 업로드 에러 콜백
  final void Function(dynamic error)? onError;

  /// 사용자가 소스 선택을 취소했을 때 콜백
  final void Function()? onCancelled;

  const FileUpload({
    super.key,
    required this.child,
    this.module,
    this.code,
    this.camera = true,
    this.cameraVideo = false,
    this.gallery = true,
    this.file = false,
    this.maxWidth,
    this.maxHeight,
    this.imageQuality = 85,
    this.extraData,
    this.onBeforeUpload,
    this.onProgress,
    this.onUploaded,
    this.onError,
    this.onCancelled,
  });

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  bool _uploading = false;

  Future<void> _onTap() async {
    if (_uploading) return;

    // 업로드 전 콜백
    if (widget.onBeforeUpload != null) {
      final proceed = await widget.onBeforeUpload!();
      if (!proceed) return;
    }

    final source = await _showSourceSheet();
    if (source == null) {
      widget.onCancelled?.call();
      return;
    }

    String? filePath;

    try {
      filePath = await _pickFile(source);
    } catch (e) {
      widget.onError?.call(e);
      return;
    }

    if (filePath == null) {
      widget.onCancelled?.call();
      return;
    }

    setState(() => _uploading = true);

    try {
      final json = await ApiService.fileUpload(
        filePath: filePath,
        module: widget.module,
        code: widget.code,
        extraData: widget.extraData,
        onProgress: widget.onProgress,
      );
      final model = FileUploadModel.fromJson(json);
      widget.onUploaded?.call(model);
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// 업로드 소스 선택 바텀시트 표시
  Future<_UploadSource?> _showSourceSheet() async {
    final hasOptions =
        widget.camera || widget.cameraVideo || widget.gallery || widget.file;

    if (!hasOptions) return null;

    // 단일 옵션이면 바텀시트 없이 바로 반환
    final sources = <_UploadSource>[
      if (widget.camera) _UploadSource.cameraPhoto,
      if (widget.cameraVideo) _UploadSource.cameraVideo,
      if (widget.gallery) _UploadSource.gallery,
      if (widget.file) _UploadSource.file,
    ];
    if (sources.length == 1) return sources.first;

    return showModalBottomSheet<_UploadSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            // 드래그 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            // 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '업로드 옵션 선택',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            if (widget.camera)
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.lightCamera,
                  size: 20,
                  color: Colors.grey[700],
                ),
                title: const Text('카메라로 사진 찍기'),
                onTap: () => Navigator.pop(ctx, _UploadSource.cameraPhoto),
              ),
            if (widget.cameraVideo)
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.lightVideo,
                  size: 20,
                  color: Colors.grey[700],
                ),
                title: const Text('카메라로 동영상 촬영'),
                onTap: () => Navigator.pop(ctx, _UploadSource.cameraVideo),
              ),
            if (widget.gallery)
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.lightImages,
                  size: 20,
                  color: Colors.grey[700],
                ),
                title: const Text('갤러리에서 선택'),
                onTap: () => Navigator.pop(ctx, _UploadSource.gallery),
              ),
            if (widget.file)
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.lightPaperclip,
                  size: 20,
                  color: Colors.grey[700],
                ),
                title: const Text('파일 업로드'),
                onTap: () => Navigator.pop(ctx, _UploadSource.file),
              ),
            ListTile(
              leading: FaIcon(
                FontAwesomeIcons.lightXmark,
                size: 20,
                color: Colors.grey[500],
              ),
              title: Text('취소', style: TextStyle(color: Colors.grey[600])),
              onTap: () => Navigator.pop(ctx, null),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  /// 선택한 소스에서 파일 경로 획득
  Future<String?> _pickFile(_UploadSource source) async {
    switch (source) {
      case _UploadSource.cameraPhoto:
        final picked = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
          imageQuality: widget.imageQuality,
        );
        return picked?.path;

      case _UploadSource.cameraVideo:
        final picked = await ImagePicker().pickVideo(
          source: ImageSource.camera,
        );
        return picked?.path;

      case _UploadSource.gallery:
        final picked = await ImagePicker().pickMedia(
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
          imageQuality: widget.imageQuality,
        );
        return picked?.path;

      case _UploadSource.file:
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
        return result?.files.single.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_uploading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _UploadSource { cameraPhoto, cameraVideo, gallery, file }
