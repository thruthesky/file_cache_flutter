import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo_api/philgo_api.dart';

import '../../v7_api/v7_api.dart';

/// v7 파일 업로드 위젯 (재활용 가능)
///
/// child 위젯을 GestureDetector로 감싸서,
/// 탭 시 Bottom Sheet로 업로드 옵션을 보여주고
/// v7 API(upload.upload)로 파일을 업로드한다.
///
/// 기존 FileUpload 위젯(v6)과 동일한 UX 패턴이지만,
/// v7 시스템(api.php, v7apiFileUpload)을 사용한다.
///
/// **⚠️ 재활용 필수**: v7 시스템에서 파일 업로드가 필요한 모든 곳에서
/// 이 위젯을 재활용해야 합니다. 새로운 업로드 위젯을 만들지 마세요.
///
/// 지원 기능:
/// - 카메라 촬영 (이미지/비디오)
/// - 갤러리 선택 (이미지/비디오)
/// - 일반 파일 선택
/// - 이미지 품질 조정
/// - 이미지 최대 크기 제한
/// - 비디오 최대 길이 제한
/// - 업로드 진행률 콜백
/// - 에러 스낵바 자동 표시 제어
/// - 모듈/코드 분류 태깅
///
/// 사용 예시:
/// ```dart
/// /// 영수증 이미지만 업로드 (카메라 + 갤러리)
/// V7FileUpload(
///   idxMember: '123',
///   module: 'receipt',
///   onUploaded: (result) => print(result['url']),
///   child: FilledButton.icon(
///     onPressed: () {},
///     icon: Icon(Icons.upload),
///     label: Text('영수증 업로드'),
///   ),
/// )
///
/// /// 프로필 사진 업로드 (카메라만)
/// V7FileUpload(
///   idxMember: '123',
///   module: 'profile',
///   gallery: false,
///   maxWidth: 512,
///   maxHeight: 512,
///   imageQuality: 70,
///   onUploaded: (result) => updateProfile(result['url']),
///   child: CircleAvatar(child: Icon(Icons.camera)),
/// )
///
/// /// 동영상 업로드 (갤러리만)
/// V7FileUpload(
///   idxMember: '123',
///   module: 'video',
///   image: false,
///   video: true,
///   camera: false,
///   maxDuration: Duration(minutes: 5),
///   onUploaded: (result) => print(result['url']),
///   child: Text('동영상 선택'),
/// )
///
/// /// 모든 파일 업로드 가능
/// V7FileUpload(
///   idxMember: '123',
///   module: 'document',
///   file: true,
///   onUploaded: (result) => print(result['url']),
///   child: Text('파일 첨부'),
/// )
/// ```
class V7FileUpload extends StatefulWidget {
  const V7FileUpload({
    super.key,
    required this.child,
    required this.idxMember,
    required this.onUploaded,
    this.onBeforeUpload,
    this.onCancelled,
    this.onProgress,
    this.onError,
    this.module,
    this.code,
    this.image = true,
    this.video = false,
    this.file = false,
    this.camera = true,
    this.gallery = true,
    this.imageQuality = 85,
    this.maxWidth,
    this.maxHeight,
    this.maxDuration,
    this.apiMethod = 'upload.upload',
    this.showErrorSnackBar = true,
    this.debug = true,
  });

  /// 탭 가능한 자식 위젯
  final Widget child;

  /// 회원번호 (필수)
  final String idxMember;

  /// 업로드 완료 시 호출되는 콜백 (v7 응답 Map 전달)
  /// 응답 필드: idx, idx_member, name, size, type, module, code, url 등
  final Function(Map<String, dynamic>) onUploaded;

  /// 업로드 시작 전 호출되는 콜백
  final VoidCallback? onBeforeUpload;

  /// 업로드 취소 시 호출되는 콜백
  final VoidCallback? onCancelled;

  /// 업로드 진행률 콜백 (0.0 ~ 1.0)
  final void Function(double)? onProgress;

  /// 업로드 에러 시 호출되는 콜백 (에러 메시지 전달)
  final void Function(String)? onError;

  /// 업로드 모듈명 (예: 'receipt', 'profile', 'post')
  final String? module;

  /// 업로드 코드 (모듈 내 세부 분류)
  final String? code;

  /// 이미지 선택 가능 여부 (기본값: true)
  final bool image;

  /// 비디오 선택 가능 여부 (기본값: false)
  final bool video;

  /// 일반 파일 선택 가능 여부 (기본값: false)
  final bool file;

  /// 카메라 촬영 옵션 표시 여부 (기본값: true)
  final bool camera;

  /// 갤러리 선택 옵션 표시 여부 (기본값: true)
  final bool gallery;

  /// 이미지 압축 품질 (0~100, 기본값: 85)
  final int imageQuality;

  /// 이미지 최대 너비 (픽셀, null이면 제한 없음)
  final double? maxWidth;

  /// 이미지 최대 높이 (픽셀, null이면 제한 없음)
  final double? maxHeight;

  /// 비디오 최대 촬영 시간 (null이면 제한 없음)
  final Duration? maxDuration;

  /// 에러 발생 시 스낵바 자동 표시 여부 (기본값: true)
  final bool showErrorSnackBar;

  /// v7apiFileUpload()에 전달할 API method (기본값: 'upload.upload')
  /// 영수증 AI 분석 시 'ai.analyzeReceipt'를 지정
  final String apiMethod;

  /// 디버그 로깅 (기본값: true)
  final bool debug;

  @override
  State<V7FileUpload> createState() => _V7FileUploadState();
}

class _V7FileUploadState extends State<V7FileUpload> {
  final ImagePicker _picker = ImagePicker();

  /// Bottom Sheet를 표시하여 업로드 옵션을 선택하게 함
  void _showUploadOptions() {
    final lo = PhilgoTr.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final scheme = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        /// 표시할 옵션 목록 구성
        final options = <_UploadOption>[
          if (widget.image && widget.camera)
            _UploadOption(
              icon: FontAwesomeIcons.lightCamera,
              label: lo.take_photo_with_camera,
              subtitle: '카메라로 직접 촬영합니다',
              color: scheme.primary,
              bgColor: scheme.primaryContainer,
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
          if (widget.video && widget.camera)
            _UploadOption(
              icon: FontAwesomeIcons.lightVideo,
              label: lo.record_video_with_camera,
              subtitle: '카메라로 동영상을 촬영합니다',
              color: scheme.tertiary,
              bgColor: scheme.tertiaryContainer,
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
          if ((widget.image || widget.video) && widget.gallery)
            _UploadOption(
              icon: FontAwesomeIcons.lightImages,
              label: lo.select_from_gallery,
              subtitle: '앨범에서 사진을 선택합니다',
              color: scheme.secondary,
              bgColor: scheme.secondaryContainer,
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          if (widget.file)
            _UploadOption(
              icon: FontAwesomeIcons.lightPaperclip,
              label: lo.upload_file,
              subtitle: '문서 또는 파일을 첨부합니다',
              color: scheme.tertiary,
              bgColor: scheme.tertiaryContainer,
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 드래그 핸들
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// 제목
                  Text(
                    lo.select_upload_option,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// 옵션 목록
                  ...options.map(
                    (opt) => _buildOptionTile(
                      theme: theme,
                      scheme: scheme,
                      option: opt,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// 취소 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onCancelled?.call();
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        lo.cancel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 개별 업로드 옵션 타일 위젯
  Widget _buildOptionTile({
    required ThemeData theme,
    required ColorScheme scheme,
    required _UploadOption option,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: option.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                /// 아이콘 배경
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: option.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: FaIcon(
                      option.icon,
                      size: 20,
                      color: option.color,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                /// 텍스트 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 화살표
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 14,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 카메라로 사진 촬영
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: widget.imageQuality,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
      );

      if (photo != null) {
        if (widget.debug) debugLog('카메라 촬영 완료: ${photo.path}');
        await _uploadFile(photo.path);
      }
    } catch (e) {
      if (widget.debug) debugLog('카메라 촬영 오류: $e');
      _handleError(e.toString());
    }
  }

  /// 카메라로 비디오 촬영
  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: widget.maxDuration,
      );

      if (video != null) {
        if (widget.debug) debugLog('비디오 촬영 완료: ${video.path}');
        await _uploadFile(video.path);
      }
    } catch (e) {
      if (widget.debug) debugLog('비디오 촬영 오류: $e');
      _handleError(e.toString());
    }
  }

  /// 갤러리에서 미디어 선택
  Future<void> _pickFromGallery() async {
    try {
      /// 이미지 + 비디오 모두 가능 시 미디어 피커 사용
      if (widget.image && widget.video) {
        final XFile? media = await _picker.pickMedia(
          imageQuality: widget.imageQuality,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
        );
        if (media != null) {
          if (widget.debug) debugLog('미디어 선택 완료: ${media.path}');
          await _uploadFile(media.path);
        }
      } else if (widget.image) {
        /// 이미지만 선택
        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: widget.imageQuality,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
        );
        if (image != null) {
          if (widget.debug) debugLog('이미지 선택 완료: ${image.path}');
          await _uploadFile(image.path);
        }
      } else if (widget.video) {
        /// 비디오만 선택
        final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: widget.maxDuration,
        );
        if (video != null) {
          if (widget.debug) debugLog('비디오 선택 완료: ${video.path}');
          await _uploadFile(video.path);
        }
      }
    } catch (e) {
      if (widget.debug) debugLog('갤러리 선택 오류: $e');
      _handleError(e.toString());
    }
  }

  /// 일반 파일 선택
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        if (widget.debug) {
          debugLog('파일 선택 완료: ${file.name} (${file.size} bytes)');
        }
        await _uploadFile(file.path!);
      }
    } catch (e) {
      if (widget.debug) debugLog('파일 선택 오류: $e');
      _handleError(e.toString());
    }
  }

  /// v7 API로 파일 업로드
  Future<void> _uploadFile(String path) async {
    try {
      widget.onBeforeUpload?.call();

      final result = await v7apiFileUpload(
        filePath: path,
        idxMember: widget.idxMember,
        method: widget.apiMethod,
        module: widget.module,
        code: widget.code,
        debug: widget.debug,
        onProgress: (progress) {
          widget.onProgress?.call(progress);
        },
      );

      if (widget.debug) debugLog('v7 파일 업로드 성공: ${result['url']}');
      widget.onUploaded(result);
    } catch (e) {
      if (widget.debug) debugLog('v7 파일 업로드 오류: $e');
      _handleError(e.toString());
    }
  }

  /// 에러 처리 (콜백 + 선택적 스낵바)
  void _handleError(String error) {
    widget.onError?.call(error);
    if (widget.showErrorSnackBar) {
      showSafeErrorSnackBar('파일 업로드 실패: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// GestureDetector로 child를 감싸서 탭 이벤트 처리
    /// IgnorePointer로 child의 자체 탭 이벤트를 무시시킴
    /// behavior: opaque — IgnorePointer가 child를 hit test에서 제외하므로,
    /// GestureDetector가 직접 hit test를 통과하도록 설정
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showUploadOptions,
      child: IgnorePointer(child: widget.child),
    );
  }
}

/// Bottom Sheet 옵션 데이터 모델
class _UploadOption {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _UploadOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });
}
