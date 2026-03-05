import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.review_point_result.screen.dart';
import 'package:philgo/v7_api/company_api.dart';
import 'package:philgo/v7_api/v7_api.dart';
import 'package:philgo/v7_api/widgets/upload/v7_file_upload.dart';
import 'package:philgo_api/philgo_api.dart';

/// 업소록 방문 후기 작성 화면
///
/// QR 삼단콤보 중 [4단계] 후기 작성.
/// 내용 10자 이상, 사진 1장 이상 필수.
/// 저장 시 company.submitVisitReview API 호출 → 2,000~3,000P 적립.
class CompanyVisitReviewScreen extends StatefulWidget {
  static const String routeName = '/company/visit-review';

  final int usageIdx;
  final int idxCompany;
  final String companyName;

  const CompanyVisitReviewScreen({
    super.key,
    required this.usageIdx,
    required this.idxCompany,
    required this.companyName,
  });

  /// 화면 이동 헬퍼
  static Future<dynamic> push(
    BuildContext context, {
    required int usageIdx,
    required int idxCompany,
    required String companyName,
  }) =>
      context.push(routeName, extra: {
        'usageIdx': usageIdx,
        'idxCompany': idxCompany,
        'companyName': companyName,
      });

  @override
  State<CompanyVisitReviewScreen> createState() =>
      _CompanyVisitReviewScreenState();
}

class _CompanyVisitReviewScreenState extends State<CompanyVisitReviewScreen> {
  final TextEditingController _contentController = TextEditingController();

  /// 업로드된 사진 목록 [{idx: int, url: String}, ...]
  final List<Map<String, dynamic>> _uploadedPhotos = [];

  bool _isSubmitting = false;
  String? _errorMessage;

  /// 업로드 진행률 (null이면 업로드 중 아님, 0.0~1.0이면 업로드 중)
  double? _uploadProgress;

  /// 업로드 진행 중 여부
  bool _isUploading = false;

  /// v7 API로 가져온 현재 로그인 사용자 정보
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 사용자 정보 로드 (V7FileUpload에 idxMember 전달용)
  Future<void> _loadUserInfo() async {
    try {
      final result = await v7api('user.me');
      if (!mounted) return;
      setState(() => _userInfo = result);
    } catch (e) {
      debugLog('user.me 에러: $e');
    }
  }

  /// 후기 제출
  Future<void> _submitReview() async {
    final content = _contentController.text.trim();

    /// 유효성 검사: 내용 10자 이상
    if (content.length < 10) {
      _showSnackBar(T.visitReviewContentTooShort);
      return;
    }

    /// 유효성 검사: 사진 1장 이상
    if (_uploadedPhotos.isEmpty) {
      _showSnackBar(T.visitReviewPhotoRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final photoIdxs = _uploadedPhotos
          .map((p) => (p['idx'] as num).toInt())
          .toList();

      final result = await CompanyApi.submitVisitReview(
        usageIdx: widget.usageIdx,
        content: content,
        photoIdxs: photoIdxs,
      );

      if (!mounted) return;

      /// 성공 → 후기 포인트 결과 화면으로 이동
      CompanyReviewPointResultScreen.push(
        context,
        rewardPoints: (result['reward_points'] as num?)?.toInt() ?? 0,
        pointBefore: (result['point_before'] as num?)?.toInt() ?? 0,
        pointAfter: (result['point_after'] as num?)?.toInt() ?? 0,
        idxCompany: widget.idxCompany,
      );
    } catch (e) {
      debugLog('company.submitVisitReview 에러: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.companyName} ${T.visitReviewTitle}',
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 보상 포인트 안내 배너
                  _buildRewardBanner(scheme, theme),

                  const SizedBox(height: 24),

                  /// 후기 내용 입력 라벨
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightPenLine,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        T.visitReviewTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 8),

                  /// 후기 내용 입력
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: T.visitReviewHint,
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: scheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: scheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: scheme.surfaceContainerLowest,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

                  const SizedBox(height: 24),

                  /// 사진 업로드 섹션
                  _buildPhotoSection(scheme, theme),

                  /// 에러 메시지
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightTriangleExclamation,
                            size: 14,
                            color: scheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          /// 하단 저장 버튼
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: scheme.surface,
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitReview,
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scheme.onPrimary,
                            ),
                          ),
                        )
                      : const FaIcon(
                          FontAwesomeIcons.lightPenToSquare,
                          size: 18,
                        ),
                  label: Text(
                    _isSubmitting
                        ? T.visitReviewSubmitting
                        : T.visitReviewSubmit,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 보상 포인트 안내 배너
  Widget _buildRewardBanner(ColorScheme scheme, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// 포인트 아이콘 배지
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightGift,
                size: 22,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),

          /// 안내 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  T.visitReviewGuide,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2,000 ~ 3,000P',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  /// 사진 업로드 섹션 (진행률 포함)
  Widget _buildPhotoSection(ColorScheme scheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 사진 라벨 + 카운터
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.lightCamera,
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              T.addPhoto,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            if (_uploadedPhotos.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_uploadedPhotos.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        /// 업로드 진행률 표시 바 (업로드 중일 때만)
        if (_isUploading) ...[
          _buildUploadProgressBar(scheme, theme),
          const SizedBox(height: 12),
        ],

        /// 업로드된 사진 목록 + 추가 버튼
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              /// 기존 업로드 사진들
              ..._uploadedPhotos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return _buildPhotoThumbnail(
                  scheme,
                  theme,
                  photo,
                  index,
                );
              }),

              /// 업로드 중 슬롯 표시
              if (_isUploading) _buildUploadingSlot(scheme, theme),

              /// 사진 추가 버튼 (V7FileUpload)
              if (_userInfo != null && !_isUploading)
                V7FileUpload(
                  idxMember: _userInfo!['idx']?.toString() ?? '',
                  module: 'visit_review',
                  onBeforeUpload: () {
                    setState(() {
                      _isUploading = true;
                      _uploadProgress = 0;
                    });
                  },
                  onProgress: (progress) {
                    if (!mounted) return;
                    setState(() => _uploadProgress = progress);
                  },
                  onUploaded: (result) {
                    // ignore: avoid_print
                    print('[UPLOAD] 업로드 응답 전체: $result');
                    // ignore: avoid_print
                    print('[UPLOAD] url: ${result['url']}');
                    // ignore: avoid_print
                    print('[UPLOAD] 모든 키: ${result.keys.toList()}');
                    setState(() {
                      _uploadedPhotos.add(result);
                      _isUploading = false;
                      _uploadProgress = null;
                    });
                  },
                  onError: (error) {
                    setState(() {
                      _isUploading = false;
                      _uploadProgress = null;
                    });
                    _showSnackBar(error);
                  },
                  child: _buildAddPhotoButton(scheme, theme),
                ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  /// 업로드 진행률 프로그레스 바
  Widget _buildUploadProgressBar(ColorScheme scheme, ThemeData theme) {
    final percent = ((_uploadProgress ?? 0) * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 진행률 텍스트
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    T.uploading,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// 프로그레스 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _uploadProgress ?? 0,
              minHeight: 6,
              backgroundColor: scheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  /// 업로드된 사진 썸네일
  Widget _buildPhotoThumbnail(
    ColorScheme scheme,
    ThemeData theme,
    Map<String, dynamic> photo,
    int index,
  ) {
    final url = photo['url']?.toString() ?? '';
    final baseUrl =
        PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '');
    final fullUrl = url.startsWith('http') ? url : '$baseUrl$url';
    // ignore: avoid_print
    print('[UPLOAD-PREVIEW] url=$url, baseUrl=$baseUrl, fullUrl=$fullUrl');

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          /// 사진 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              fullUrl,
              width: 110,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightImage,
                    color: scheme.onSurfaceVariant,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          /// 삭제 버튼
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _uploadedPhotos.removeAt(index);
                });
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 업로드 중 슬롯 (진행률 원형 표시)
  Widget _buildUploadingSlot(ColorScheme scheme, ThemeData theme) {
    final percent = ((_uploadProgress ?? 0) * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 원형 프로그레스
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                    strokeWidth: 3,
                    backgroundColor: scheme.primary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                  ),
                  Text(
                    '$percent%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              T.uploading,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  /// 사진 추가 버튼
  Widget _buildAddPhotoButton(ColorScheme scheme, ThemeData theme) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightPlus,
                size: 18,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            T.addPhoto,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
