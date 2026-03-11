import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:philgo/file_upload/file_upload.model.dart';
import 'package:philgo/file_upload/file_upload.service.dart';

/// 파일 업로드 위젯
///
/// GestureDetector로 child를 감싸 탭 시 업로드 소스 선택 바텀시트를 표시한다.
/// 카메라, 갤러리, 파일 세 가지 소스를 지원하며 선택 후 자동으로 업로드한다.
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

  /// 카메라 소스 활성화 여부 (기본: true)
  final bool camera;

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
      final model = await FileUploadService.upload(
        filePath: filePath,
        module: widget.module,
        code: widget.code,
        extraData: widget.extraData,
        onProgress: widget.onProgress,
      );
      widget.onUploaded?.call(model);
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  /// 업로드 소스 선택 바텀시트 표시
  Future<_UploadSource?> _showSourceSheet() async {
    final sources = <_UploadSource>[
      if (widget.camera) _UploadSource.camera,
      if (widget.gallery) _UploadSource.gallery,
      if (widget.file) _UploadSource.file,
    ];

    if (sources.isEmpty) return null;
    if (sources.length == 1) return sources.first;

    return showModalBottomSheet<_UploadSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (widget.camera)
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('카메라'),
                onTap: () => Navigator.pop(context, _UploadSource.camera),
              ),
            if (widget.gallery)
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('갤러리'),
                onTap: () => Navigator.pop(context, _UploadSource.gallery),
              ),
            if (widget.file)
              ListTile(
                leading: const Icon(Icons.attach_file_outlined),
                title: const Text('파일'),
                onTap: () => Navigator.pop(context, _UploadSource.file),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 선택한 소스에서 파일 경로 획득
  Future<String?> _pickFile(_UploadSource source) async {
    switch (source) {
      case _UploadSource.camera:
        final picked = await ImagePicker().pickImage(
          source: ImageSource.camera,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
          imageQuality: widget.imageQuality,
        );
        return picked?.path;

      case _UploadSource.gallery:
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
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

enum _UploadSource { camera, gallery, file }
