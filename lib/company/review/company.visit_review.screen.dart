import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/review/company.review_point_result.screen.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/globals.dart';

/// 업소록 방문 후기 작성 화면
///
/// QR 삼단콤보 중 [3단계] 후기 작성.
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
  final List<FileUploadModel> _uploadedPhotos = [];
  bool _isSubmitting = false;
  String? _errorMessage;
  double? _uploadProgress;
  bool _isUploading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final content = _contentController.text.trim();

    if (content.length < 10) {
      // "Please write at least 10 characters for the review."
      _showSnackBar('후기 내용을 10자 이상 입력해 주세요.'.tr());
      return;
    }

    if (_uploadedPhotos.isEmpty) {
      // "Please attach at least 1 photo."
      _showSnackBar('사진을 1장 이상 첨부해 주세요.'.tr());
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final photoIdxs = _uploadedPhotos.map((p) => p.idx).toList();

    final result = await CompanyService.submitVisitReview(
      usageIdx: widget.usageIdx,
      content: content,
      photoIdxs: photoIdxs,
    );

    if (!mounted) return;

    CompanyReviewPointResultScreen.push(
      context,
      rewardPoints: (result['reward_points'] as num?)?.toInt() ?? 0,
      pointBefore: (result['point_before'] as num?)?.toInt() ?? 0,
      pointAfter: (result['point_after'] as num?)?.toInt() ?? 0,
      idxCompany: widget.idxCompany,
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // "Visit Review"
          '${widget.companyName} ${'방문 후기'.tr()}',
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
                  _buildRewardBanner(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      FaIcon(FontAwesomeIcons.lightPenLine, size: 14,
                          color: color.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        // "Visit Review"
                        '방문 후기'.tr(),
                        style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      // "Write your visit review. (min. 10 characters)"
                      hintText: '방문 후기를 작성해 주세요. (10자 이상)'.tr(),
                      hintStyle: text.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: color.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: color.surfaceContainerLowest,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: 24),
                  _buildPhotoSection(),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.lightTriangleExclamation,
                              size: 14, color: color.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: text.bodySmall?.copyWith(
                                color: color.error,
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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(color: color.surface),
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
                              color.onPrimary,
                            ),
                          ),
                        )
                      : const FaIcon(FontAwesomeIcons.lightPenToSquare,
                          size: 18),
                  label: Text(
                    // "Saving...", "Save Review"
                    _isSubmitting ? '저장 중...'.tr() : '후기 저장'.tr(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(FontAwesomeIcons.lightGift, size: 22,
                  color: color.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // "Earn points by writing a review!"
                  '후기 작성 시 포인트를 드립니다!'.tr(),
                  style: text.bodySmall?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '2,000 ~ 3,000P',
                  style: text.titleMedium?.copyWith(
                    color: color.primary,
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

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FaIcon(FontAwesomeIcons.lightCamera, size: 14,
                color: color.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              // "Add Photo"
              '사진 추가'.tr(),
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (_uploadedPhotos.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_uploadedPhotos.length}',
                  style: text.labelSmall?.copyWith(
                    color: color.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isUploading) ...[
          _buildUploadProgressBar(),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ..._uploadedPhotos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: UploadedFilePreview(
                    file: photo,
                    size: 110,
                    onDelete: () {
                      setState(() => _uploadedPhotos.removeAt(index));
                    },
                  ),
                );
              }),
              FileUpload(
                module: 'visit_review',
                onUploaded: (result) {
                  setState(() {
                    _uploadedPhotos.add(result);
                    _isUploading = false;
                    _uploadProgress = null;
                  });
                },
                onProgress: (progress) {
                  if (!mounted) return;
                  setState(() => _uploadProgress = progress);
                },
                onBeforeUpload: () async {
                  setState(() {
                    _isUploading = true;
                    _uploadProgress = 0;
                  });
                  return true;
                },
                onError: (error) {
                  setState(() {
                    _isUploading = false;
                    _uploadProgress = null;
                  });
                  _showSnackBar(error.toString());
                },
                child: _isUploading
                    ? _buildUploadingSlot()
                    : _buildAddPhotoButton(),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildUploadProgressBar() {
    final percent = ((_uploadProgress ?? 0) * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    // "Uploading..."
                    '업로드 중...'.tr(),
                    style: text.labelMedium?.copyWith(
                      color: color.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                '$percent%',
                style: text.labelMedium?.copyWith(
                  color: color.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _uploadProgress ?? 0,
              minHeight: 6,
              backgroundColor: color.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color.primary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildUploadingSlot() {
    final percent = ((_uploadProgress ?? 0) * 100).toInt();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: color.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress,
                    strokeWidth: 3,
                    backgroundColor: color.primary.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                  ),
                  Text(
                    '$percent%',
                    style: text.labelSmall?.copyWith(
                      color: color.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              // "Uploading..."
              '업로드 중...'.tr(),
              style: text.labelSmall?.copyWith(
                color: color.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildAddPhotoButton() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: FaIcon(FontAwesomeIcons.lightPlus, size: 18,
                  color: color.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // "Add Photo"
            '사진 추가'.tr(),
            style: text.labelSmall?.copyWith(
              color: color.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
