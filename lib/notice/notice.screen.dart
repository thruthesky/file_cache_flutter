import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/notice/notice.model.dart';
import 'package:philgo/notice/notice.service.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';

/// 공지사항 화면
///
/// 외교부(MOFA) 해외여행 공지와 필고 공지를 함께 표시한다.
class NoticeScreen extends StatefulWidget {
  static const String routeName = '/notice';
  static void push(BuildContext context) => context.push(routeName);

  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool _isMofaLoading = true;
  MofaNoticeResponse? _mofaResponse;

  bool _isPhilgoLoading = true;
  List<Post> _philgoNotices = [];

  @override
  void initState() {
    super.initState();
    _loadMofaNotices();
    _loadPhilgoNotices();
  }

  Future<void> _loadMofaNotices({bool forceRefresh = false}) async {
    if (mounted) setState(() => _isMofaLoading = true);

    final response = await NoticeService.instance.loadMofaNotices(
      forceRefresh: forceRefresh,
    );

    if (mounted) {
      setState(() {
        _mofaResponse = response;
        _isMofaLoading = false;
      });
    }
  }

  Future<void> _loadPhilgoNotices() async {
    final result = await PostService.list(postId: 'caution', limit: 10);
    if (mounted) {
      setState(() {
        _philgoNotices = result.posts;
        _isPhilgoLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.lightBullhorn,
                size: 20, color: color.primary),
            const SizedBox(width: 8),
            Text('공지사항'.tr()),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: color.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadMofaNotices(forceRefresh: true),
            _loadPhilgoNotices(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: FontAwesomeIcons.lightPlane,
                title: '해외 여행 공지'.tr(),
                onRefreshTap: () => _loadMofaNotices(forceRefresh: true),
              ),
              const SizedBox(height: 12),
              _buildMofaSection(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                icon: FontAwesomeIcons.lightMegaphone,
                title: '필고 공지'.tr(),
              ),
              const SizedBox(height: 12),
              _buildPhilgoSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    VoidCallback? onRefreshTap,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: color.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color.onSurface,
          ),
        ),
        const Spacer(),
        if (onRefreshTap != null)
          IconButton(
            onPressed: _isMofaLoading ? null : onRefreshTap,
            icon: FaIcon(
              FontAwesomeIcons.lightArrowsRotate,
              size: 16,
              color: _isMofaLoading ? color.outline : color.primary,
            ),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            tooltip: '새로고침'.tr(),
          ),
      ],
    );
  }

  // ── MOFA 섹션 ──

  Widget _buildMofaSection() {
    if (_isMofaLoading) return _buildLoadingCard(color.primaryContainer);

    if (_mofaResponse == null || !_mofaResponse!.isSuccess) {
      return _buildErrorCard(
        '공지사항을 불러올 수 없습니다'.tr(),
        '새로고침 버튼을 눌러 다시 시도해주세요'.tr(),
      );
    }

    if (_mofaResponse!.notices.isEmpty) {
      return _buildEmptyCard(
        FontAwesomeIcons.lightPlaneUp,
        '해외 여행 관련 공지가 없습니다'.tr(),
        '외교부 공지사항이 여기에 표시됩니다'.tr(),
        color.primaryContainer,
        color.onPrimaryContainer,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_mofaResponse!.notices.length, (index) {
          final notice = _mofaResponse!.notices[index];
          final isLast = index == _mofaResponse!.notices.length - 1;
          return Column(
            children: [
              _buildMofaItem(notice),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: color.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMofaItem(MofaNotice notice) {
    return InkWell(
      onTap: () => _showMofaDetail(notice),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(FontAwesomeIcons.lightFileLines,
                  size: 16, color: color.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.decodedTitle,
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notice.writtenDate,
                    style: text.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(FontAwesomeIcons.lightChevronRight,
                size: 14, color: color.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  void _showMofaDetail(MofaNotice notice) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.lightPlane,
                        size: 20, color: color.onPrimaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '해외 여행 공지'.tr(),
                        style: text.titleMedium?.copyWith(
                          color: color.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.lightXmark,
                          color: color.onPrimaryContainer),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.decodedTitle,
                        style: text.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FaIcon(FontAwesomeIcons.lightCalendar,
                              size: 14, color: color.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            notice.writtenDate,
                            style: text.bodyMedium?.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: color.outlineVariant),
                      const SizedBox(height: 16),
                      Text(
                        notice.decodedContent,
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurface,
                          height: 1.6,
                        ),
                      ),
                      if (notice.fileUrl.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Divider(color: color.outlineVariant),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            FaIcon(FontAwesomeIcons.lightPaperclip,
                                size: 14, color: color.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '첨부파일이 있습니다'.tr(),
                                style: text.bodyMedium?.copyWith(
                                  color: color.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('닫기'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 필고 공지 섹션 ──

  Widget _buildPhilgoSection() {
    if (_isPhilgoLoading) return _buildLoadingCard(color.tertiaryContainer);

    if (_philgoNotices.isEmpty) {
      return _buildEmptyCard(
        FontAwesomeIcons.lightCircleInfo,
        '필고 공지가 없습니다'.tr(),
        '필고 서비스 관련 공지사항이 여기에 표시됩니다'.tr(),
        color.tertiaryContainer,
        color.onTertiaryContainer,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: color.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_philgoNotices.length, (index) {
          final notice = _philgoNotices[index];
          final isLast = index == _philgoNotices.length - 1;
          return Column(
            children: [
              _buildPhilgoItem(notice),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: color.outlineVariant.withValues(alpha: 0.5),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPhilgoItem(Post notice) {
    return InkWell(
      onTap: () => PostViewScreen.push(context, notice),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(FontAwesomeIcons.lightFileLines,
                  size: 16, color: color.onTertiaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.subject,
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatStamp(notice.stamp),
                    style: text.bodySmall?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            FaIcon(FontAwesomeIcons.lightChevronRight,
                size: 14, color: color.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ── 공통 위젯 ──

  String _formatStamp(int stamp) {
    if (stamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _buildLoadingCard(Color containerColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: containerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: color.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '공지사항을 불러오는 중...'.tr(),
            style: text.bodyMedium?.copyWith(
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(FontAwesomeIcons.lightTriangleExclamation,
              size: 32, color: color.onErrorContainer),
          const SizedBox(height: 12),
          Text(
            message,
            style: text.bodyMedium?.copyWith(
              color: color.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: text.bodyMedium?.copyWith(
              color: color.onErrorContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    IconData icon,
    String message,
    String description,
    Color bgColor,
    Color fgColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: FaIcon(icon, size: 32, color: fgColor),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: text.titleSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: text.bodyMedium?.copyWith(
              color: fgColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
