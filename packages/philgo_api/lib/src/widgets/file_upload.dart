import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:philgo_api/philgo_api.dart';

/// 파일 업로드 위젯
///
/// 사용자가 카메라로 사진/동영상을 촬영하거나,
/// 갤러리에서 미디어를 선택하거나, 파일을 업로드할 수 있는 기능을 제공합니다.
class FileUpload extends StatefulWidget {
  const FileUpload({
    super.key,
    required this.child,
    required this.onUploaded,
    this.onQrCodeDetected,
    this.deleteFile,
    this.onBeforeUpload,
    this.onCancelled,
    this.onProgress,
    this.image = true,
    this.video = false,
    this.audio = false,
    this.file = false,
    this.isDecodeQr = false,
  });

  /// 탭 가능한 자식 위젯
  final Widget child;

  /// 파일 업로드 완료 시 호출되는 콜백
  /// 파일 경로를 매개변수로 받음
  final Function(String)? onUploaded;

  final Function(String?)? onQrCodeDetected;

  final String? deleteFile;

  /// 업로드 시작 전 호출되는 콜백
  final Function()? onBeforeUpload;

  /// 업로드 취소 시 호출되는 콜백
  final Function()? onCancelled;

  /// 업로드 진행률 콜백
  final void Function(double progress)? onProgress;

  /// 이미지 선택 가능 여부
  final bool image;

  /// 비디오 선택 가능 여부
  final bool video;

  /// 오디오 선택 가능 여부
  final bool audio;

  /// 일반 파일 선택 가능 여부
  final bool file;

  final bool isDecodeQr;

  @override
  State<FileUpload> createState() => _FileUploadState();
}

class _FileUploadState extends State<FileUpload> {
  // ImagePicker 인스턴스
  final ImagePicker _picker = ImagePicker();

  /// Bottom Sheet를 표시하여 업로드 옵션을 선택하게 함
  void _showUploadOptions() {
    // 번역 텍스트를 위한 localizations 인스턴스
    final lo = PhilgoTr.of(context)!;

    showModalBottomSheet(
      context: context,
      // 둥근 모서리를 위한 shape 설정
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom Sheet 제목
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  lo.select_upload_option,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Divider(),
              // 카메라로 사진 촬영 옵션
              if (widget.image)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(lo.take_photo_with_camera),
                  onTap: () {
                    Navigator.pop(context);
                    _takePicture();
                  },
                ),
              // 카메라로 동영상 촬영 옵션
              if (widget.video)
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: Text(lo.record_video_with_camera),
                  onTap: () {
                    Navigator.pop(context);
                    _recordVideo();
                  },
                ),
              // 갤러리에서 선택 옵션
              if (widget.image || widget.video)
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(lo.select_from_gallery),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFromGallery();
                  },
                ),
              // 파일 업로드 옵션
              if (widget.file)
                ListTile(
                  leading: const Icon(Icons.attach_file),
                  title: Text(lo.upload_file),
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                ),
              // 취소 버튼
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(lo.cancel),
                onTap: () {
                  Navigator.pop(context);
                  widget.onCancelled?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 카메라로 사진 촬영
  Future<void> _takePicture() async {
    try {
      // 카메라로 사진 촬영
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // 이미지 품질 설정
      );

      if (photo != null) {
        // 파일 경로 출력 (테스트용)
        debugLog('📷 사진 촬영 완료: ${photo.path}');
        // 파일 업로드
        final uploadedFile = await _uploadFile(photo.path);
        if (uploadedFile != null) {
          // 업로드된 파일 URL을 onUploaded 콜백으로 전달
          widget.onUploaded?.call(uploadedFile.url);
        }
      }
    } catch (e) {
      debugLog('❌ 사진 촬영 오류: $e');
    }
  }

  /// 카메라로 동영상 촬영
  Future<void> _recordVideo() async {
    try {
      // 카메라로 동영상 촬영
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10), // 최대 10분
      );

      if (video != null) {
        // 파일 경로 출력 (테스트용)
        debugLog('📹 동영상 촬영 완료: ${video.path}');
        // 파일 업로드
        final uploadedFile = await _uploadFile(video.path);
        if (uploadedFile != null) {
          // 업로드된 파일 URL을 onUploaded 콜백으로 전달
          widget.onUploaded?.call(uploadedFile.url);
        }
      }
    } catch (e) {
      debugLog('❌ 동영상 촬영 오류: $e');
    }
  }

  /// 갤러리에서 미디어 선택
  Future<void> _pickFromGallery() async {
    try {
      // 이미지와 비디오 모두 가능한 경우 미디어 타입 선택
      if (widget.image && widget.video) {
        // 갤러리에서 이미지 또는 비디오 선택
        final XFile? media = await _picker.pickMedia(
          imageQuality: 85, // 이미지 품질 설정
        );

        if (media != null) {
          // 파일 경로 출력 (테스트용)
          debugLog('🖼️ 미디어 선택 완료: ${media.path}');
          // 파일 업로드
          final uploadedFile = await _uploadFile(media.path);
          if (uploadedFile != null) {
            // 업로드된 파일 URL을 onUploaded 콜백으로 전달
            widget.onUploaded?.call(uploadedFile.url);
          }
        }
      } else if (widget.image) {
        // 이미지만 선택
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85, // 이미지 품질 설정
        );

        if (image != null) {
          // 파일 경로 출력 (테스트용)
          debugLog('🖼️ 이미지 선택 완료: ${image.path}');
          // 파일 업로드
          final uploadedFile = await _uploadFile(image.path);
          if (uploadedFile != null) {
            widget.onUploaded?.call(uploadedFile.url);
            if (widget.isDecodeQr) {
              widget.onQrCodeDetected?.call(uploadedFile.qr_code);
            }
          }
        }
      } else if (widget.video) {
        // 비디오만 선택
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
        );

        if (video != null) {
          // 파일 경로 출력 (테스트용)
          debugLog('🎥 비디오 선택 완료: ${video.path}');
          // 파일 업로드
          final uploadedFile = await _uploadFile(video.path);
          if (uploadedFile != null) {
            // 업로드된 파일 URL을 onUploaded 콜백으로 전달
            widget.onUploaded?.call(uploadedFile.url);
          }
        }
      }
    } catch (e) {
      debugLog('❌ 갤러리 선택 오류: $e');
    }
  }

  /// 파일 선택
  Future<void> _pickFile() async {
    try {
      // 파일 선택 다이얼로그 표시
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // 모든 파일 타입 허용
        allowMultiple: false, // 단일 파일 선택
      );

      if (result != null && result.files.single.path != null) {
        // 선택된 파일 정보
        PlatformFile file = result.files.single;
        // 파일 경로 출력 (테스트용)
        debugLog('📁 파일 선택 완료:');
        debugLog('  - 이름: ${file.name}');
        debugLog('  - 크기: ${file.size} bytes');
        debugLog('  - 경로: ${file.path}');
        // 파일 업로드
        final uploadedFile = await _uploadFile(file.path!);
        if (uploadedFile != null) {
          // 업로드된 파일 URL을 onUploaded 콜백으로 전달
          widget.onUploaded?.call(uploadedFile.url);
        }
      }
    } catch (e) {
      debugLog('❌ 파일 선택 오류: $e');
    }
  }

  /// 파일을 서버에 업로드하고 FileUploadResponse 객체를 반환합니다.
  Future<FileUploadResponse?> _uploadFile(String path) async {
    try {
      // 파일 업로드 시작 전 콜백 호출
      widget.onBeforeUpload?.call();

      // PhilGo API를 통해 파일 업로드
      final uploadedFile = await philgoApiFileUpload(
        path,
        deleteFile: widget.deleteFile,
        qrCode: widget.isDecodeQr,
        onProgress: (progress) {
          // 업로드 진행률 콜백 호출
          widget.onProgress?.call(progress);
        },
      );

      if (uploadedFile != null) {
        debugLog('✅ 파일 업로드 성공: ${uploadedFile.url}');
        debugLog(
          '✅ QR CODEEEEEE -------------------------->>: ${uploadedFile.qr_code}',
        );
        return uploadedFile;
      } else {
        debugLog('❌ 파일 업로드 실패');
        // Show error snackbar when upload fails
        showSafeErrorSnackBar('파일 업로드에 실패했습니다. 다시 시도해 주세요.');
        // 업로드 취소 콜백 호출
        widget.onCancelled?.call();
        return null;
      }
    } catch (e) {
      debugLog('❌ 파일 업로드 오류: $e');

      // Show error snackbar with the actual error message
      showSafeErrorSnackBar('파일 업로드 실패: $e');

      // 업로드 취소 콜백 호출
      widget.onCancelled?.call();
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector로 child를 감싸서 탭 이벤트 처리
    return GestureDetector(onTap: _showUploadOptions, child: widget.child);
  }
}
