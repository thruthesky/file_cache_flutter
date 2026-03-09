import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/services/data/data.service.dart';
import 'package:philgo/services/data/mofa_notice.model.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 공지 화면 (Notice Screen)
///
/// 해외 여행 공지, 대사관/영사관 공지, 필고 공지 등
/// 다양한 공지사항을 표시합니다.
/// Displays various notices including overseas travel notices,
/// embassy/consulate notices, and Philgo notices.
class NoticeScreen extends StatefulWidget {
  static const String routeName = '/Notice';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  /// 외교부 공지사항 로딩 상태 (MOFA notice loading state)
  bool _isMofaLoading = true;

  /// 외교부 공지사항 응답 데이터 (MOFA notice response data)
  MofaNoticeResponse? _mofaResponse;

  /// 필고 공지사항 로딩 상태 (Philgo notice loading state)
  bool _isPhilgoLoading = true;

  /// 필고 공지사항 목록 (Philgo notice list)
  List<Notice> _philgoNotices = [];

  @override
  void initState() {
    super.initState();

    /// 화면 진입 시 공지사항 로드 (Load notices on screen entry)
    _loadMofaNotices();
    _loadPhilgoNotices();
  }

  /// 필고 공지사항 로드 (Load Philgo notices)
  Future<void> _loadPhilgoNotices() async {
    try {
      final notices = await PhilgoService.instance.loadLatestNotices(limit: 10);
      if (mounted) {
        setState(() {
          _philgoNotices = notices;
          _isPhilgoLoading = false;
        });
      }
    } catch (e) {
      debugPrint('필고 공지사항 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isPhilgoLoading = false;
        });
      }
    }
  }

  /// 외교부 공지사항 로드 (Load MOFA notices)
  Future<void> _loadMofaNotices() async {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🖥️ [NoticeScreen] _loadMofaNotices() 호출됨');
    debugPrint('═══════════════════════════════════════════════════════════');

    final response = await DataService.instance.loadMofaNotices();

    debugPrint('🖥️ [NoticeScreen] DataService.loadMofaNotices() 완료');
    debugPrint('🖥️ [NoticeScreen] 응답 결과:');
    debugPrint('   - resultCode: ${response.resultCode}');
    debugPrint('   - resultMsg: ${response.resultMsg}');
    debugPrint('   - isSuccess: ${response.isSuccess}');
    debugPrint('   - totalCount: ${response.totalCount}');
    debugPrint('   - notices 개수: ${response.notices.length}');

    if (response.notices.isNotEmpty) {
      debugPrint('🖥️ [NoticeScreen] 공지사항 목록:');
      for (int i = 0; i < response.notices.length; i++) {
        final notice = response.notices[i];
        debugPrint('   📌 [$i] ID: ${notice.id}');
        debugPrint('       제목: ${notice.title}');
        debugPrint('       날짜: ${notice.writtenDate}');
      }
    } else {
      debugPrint('⚠️ [NoticeScreen] 공지사항이 비어 있습니다!');
    }

    if (mounted) {
      debugPrint('🖥️ [NoticeScreen] setState 호출 (mounted: true)');
      setState(() {
        _mofaResponse = response;
        _isMofaLoading = false;
      });
      debugPrint('🖥️ [NoticeScreen] 상태 업데이트 완료');
      debugPrint('   - _isMofaLoading: $_isMofaLoading');
      debugPrint('   - _mofaResponse: ${_mofaResponse != null ? "설정됨" : "null"}');
    } else {
      debugPrint('⚠️ [NoticeScreen] 위젯이 마운트되지 않음 (mounted: false)');
    }

    debugPrint('═══════════════════════════════════════════════════════════');
  }

  /// 외교부 공지사항 새로고침 (Refresh MOFA notices)
  Future<void> _refreshMofaNotices() async {
    setState(() {
      _isMofaLoading = true;
    });

    /// 캐시 초기화 후 다시 로드 (Clear cache and reload)
    await DataService.instance.clearMofaCache();
    await _loadMofaNotices();
  }

  /// 필고 공지사항 상세 다이얼로그 표시 (Show Philgo notice detail dialog)
  ///
  /// get_post API를 호출하여 전체 내용을 가져온 후 팝업으로 표시합니다.
  /// Calls get_post API to fetch full content and displays in a popup.
  Future<void> _showPhilgoNoticeDetail(BuildContext context, Notice notice) async {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 로딩 다이얼로그 표시 (Show loading dialog)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(sp.s24),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: scheme.primary),
              SizedBox(height: sp.s16),
              Text(
                '공지사항을 불러오는 중...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      /// API에서 전체 내용 가져오기 (Fetch full content from API)
      final fullNotice = await PhilgoService.instance.getPost(idx: notice.idx);

      if (!context.mounted) return;

      /// 로딩 다이얼로그 닫기 (Close loading dialog)
      Navigator.pop(context);

      /// 상세 다이얼로그 표시 (Show detail dialog)
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.all(sp.s16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 헤더 영역 (Header area)
                Container(
                  padding: EdgeInsets.all(sp.s16),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightMegaphone,
                        size: 20,
                        color: scheme.onTertiaryContainer,
                      ),
                      SizedBox(width: sp.s12),
                      Expanded(
                        child: Text(
                          '필고 공지',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onTertiaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.lightXmark,
                          color: scheme.onTertiaryContainer,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                /// 내용 영역 (Content area)
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(sp.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 제목 (Title)
                        Text(
                          fullNotice.subject,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(height: sp.s8),

                        /// 작성일 (Written date)
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.lightCalendar,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            SizedBox(width: sp.s4),
                            Text(
                              fullNotice.timeString ?? _formatDate(fullNotice.createdAt),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: sp.s16),

                        Divider(color: scheme.outlineVariant),
                        SizedBox(height: sp.s16),

                        /// 내용 (Content)
                        Text(
                          fullNotice.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// 하단 버튼 (Bottom button)
                Padding(
                  padding: EdgeInsets.all(sp.s16),
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      /// 로딩 다이얼로그 닫기 (Close loading dialog)
      Navigator.pop(context);

      /// 에러 스낵바 표시 (Show error snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('공지사항을 불러올 수 없습니다: $e'),
          backgroundColor: scheme.error,
        ),
      );
    }
  }

  /// 날짜 포맷팅 헬퍼 (Date formatting helper)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 공지사항 상세 다이얼로그 표시 (Show notice detail dialog)
  ///
  /// [notice] 표시할 공지사항 데이터
  void _showNoticeDetail(BuildContext context, MofaNotice notice) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        /// 전체 화면에 가깝게 표시 (Display close to full screen)
        insetPadding: EdgeInsets.all(sp.s16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 헤더 영역 (Header area)
              Container(
                padding: EdgeInsets.all(sp.s16),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  children: [
                    /// 아이콘 (Icon)
                    FaIcon(
                      FontAwesomeIcons.lightPlane,
                      size: 20,
                      color: scheme.onPrimaryContainer,
                    ),
                    SizedBox(width: sp.s12),

                    /// 제목 (Title)
                    Expanded(
                      child: Text(
                        '해외 여행 공지',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    /// 닫기 버튼 (Close button)
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        color: scheme.onPrimaryContainer,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              /// 내용 영역 (Content area)
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(sp.s16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 공지 제목 (Notice title)
                      /// HTML 엔티티가 디코딩된 제목 사용
                      Text(
                        notice.decodedTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sp.s8),

                      /// 작성일 (Written date)
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightCalendar,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          SizedBox(width: sp.s4),
                          Text(
                            notice.writtenDate,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s16),

                      /// 구분선 (Divider)
                      Divider(color: scheme.outlineVariant),
                      SizedBox(height: sp.s16),

                      /// 공지 내용 (Notice content)
                      Text(
                        notice.decodedContent,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          height: 1.6,
                        ),
                      ),

                      /// 첨부파일 링크 (Attachment link)
                      if (notice.fileUrl.isNotEmpty) ...[
                        SizedBox(height: sp.s16),
                        Divider(color: scheme.outlineVariant),
                        SizedBox(height: sp.s12),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.lightPaperclip,
                              size: 14,
                              color: scheme.primary,
                            ),
                            SizedBox(width: sp.s8),
                            Expanded(
                              child: Text(
                                '첨부파일이 있습니다',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.primary,
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

              /// 하단 버튼 (Bottom button)
              Padding(
                padding: EdgeInsets.all(sp.s16),
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.lightBullhorn, size: 20, color: scheme.primary),
            SizedBox(width: sp.s8),
            const Text('공지사항'),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [해외 여행 공지 섹션]
            /// Overseas Travel Notice Section
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPlane,
              title: '해외 여행 공지',
              onRefreshTap: _refreshMofaNotices,
            ),
            SizedBox(height: sp.s12),

            /// 외교부 공지사항 표시 (Display MOFA notices)
            _buildMofaNoticeSection(context),

            SizedBox(height: sp.s24),

            /// [필고 공지 섹션]
            /// Philgo Notice Section
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMegaphone,
              title: '필고 공지',
            ),
            SizedBox(height: sp.s12),

            /// 필고 공지사항 표시 (Display Philgo notices)
            _buildPhilgoNoticeSection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 외교부 공지사항 섹션 빌드 (Build MOFA notice section)
  ///
  /// 로딩, 에러, 빈 상태, 데이터 상태에 따라 다른 UI를 표시합니다.
  Widget _buildMofaNoticeSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    debugPrint('🎨 [NoticeScreen] _buildMofaNoticeSection() 호출');
    debugPrint('   - _isMofaLoading: $_isMofaLoading');
    debugPrint('   - _mofaResponse: ${_mofaResponse != null ? "존재" : "null"}');
    if (_mofaResponse != null) {
      debugPrint('   - isSuccess: ${_mofaResponse!.isSuccess}');
      debugPrint('   - notices.length: ${_mofaResponse!.notices.length}');
    }

    /// 로딩 중 (Loading state)
    if (_isMofaLoading) {
      debugPrint('🎨 [NoticeScreen] → 로딩 UI 표시');
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sp.s24),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: sp.s12),
            Text(
              '공지사항을 불러오는 중...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    /// API 호출 실패 또는 에러 (API error state)
    if (_mofaResponse == null || !_mofaResponse!.isSuccess) {
      debugPrint('🎨 [NoticeScreen] → 에러 UI 표시');
      debugPrint('   - _mofaResponse == null: ${_mofaResponse == null}');
      if (_mofaResponse != null) {
        debugPrint('   - resultCode: ${_mofaResponse!.resultCode}');
        debugPrint('   - resultMsg: ${_mofaResponse!.resultMsg}');
      }
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sp.s24),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            FaIcon(
              FontAwesomeIcons.lightTriangleExclamation,
              size: 32,
              color: scheme.onErrorContainer,
            ),
            SizedBox(height: sp.s12),
            Text(
              '공지사항을 불러올 수 없습니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: sp.s4),
            Text(
              '새로고침 버튼을 눌러 다시 시도해주세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    /// 공지사항이 없는 경우 (Empty state)
    if (_mofaResponse!.notices.isEmpty) {
      debugPrint('🎨 [NoticeScreen] → 빈 상태 UI 표시 (공지사항 없음)');
      return _buildEmptyNoticeSection(
        context,
        icon: FontAwesomeIcons.lightPlaneUp,
        message: '해외 여행 관련 공지가 없습니다',
        description: '외교부 공지사항이 여기에 표시됩니다',
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      );
    }

    /// 공지사항 목록 표시 (Display notice list)
    debugPrint('🎨 [NoticeScreen] → 공지사항 목록 UI 표시');
    debugPrint('   - 표시할 공지사항: ${_mofaResponse!.notices.length}개');
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 공지사항 목록 (Notice list)
          ...List.generate(_mofaResponse!.notices.length, (index) {
            final notice = _mofaResponse!.notices[index];
            final isLast = index == _mofaResponse!.notices.length - 1;

            return Column(
              children: [
                /// 공지사항 아이템 (Notice item)
                _buildNoticeItem(context, notice),

                /// 구분선 (Divider) - 마지막 아이템 제외
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: sp.s16,
                    endIndent: sp.s16,
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 공지사항 아이템 빌드 (Build notice item)
  ///
  /// [notice] 표시할 공지사항 데이터
  Widget _buildNoticeItem(BuildContext context, MofaNotice notice) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return InkWell(
      onTap: () => _showNoticeDetail(context, notice),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(sp.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 아이콘 (Icon)
            Container(
              padding: EdgeInsets.all(sp.s8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                FontAwesomeIcons.lightFileLines,
                size: 16,
                color: scheme.onPrimaryContainer,
              ),
            ),
            SizedBox(width: sp.s12),

            /// 제목 및 날짜 (Title and date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 제목 (Title) - 최대 2줄
                  /// HTML 엔티티가 디코딩된 제목 사용
                  Text(
                    notice.decodedTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sp.s4),

                  /// 작성일 (Written date)
                  Text(
                    notice.writtenDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            /// 화살표 아이콘 (Arrow icon)
            FaIcon(
              FontAwesomeIcons.lightChevronRight,
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header)
  ///
  /// 아이콘과 제목을 포함한 섹션 헤더를 생성합니다.
  /// Creates a section header with icon and title.
  ///
  /// [icon] - 섹션 아이콘 (Section icon)
  /// [title] - 섹션 제목 (Section title)
  /// [onMoreTap] - 더보기 버튼 탭 콜백 (More button tap callback)
  /// [onRefreshTap] - 새로고침 버튼 탭 콜백 (Refresh button tap callback)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onMoreTap,
    VoidCallback? onRefreshTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        /// 섹션 아이콘 컨테이너 (Section icon container)
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
        ),
        SizedBox(width: sp.s12),

        /// 섹션 제목 (Section title)
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),

        /// 우측 공간 채우기 (Fill right space)
        const Spacer(),

        /// 새로고침 버튼 (Refresh button)
        if (onRefreshTap != null)
          IconButton(
            onPressed: _isMofaLoading ? null : onRefreshTap,
            icon: FaIcon(
              FontAwesomeIcons.lightArrowsRotate,
              size: 16,
              color: _isMofaLoading ? scheme.outline : scheme.primary,
            ),
            padding: EdgeInsets.all(sp.s8),
            constraints: const BoxConstraints(),
            tooltip: '새로고침',
          ),

        /// 더보기 버튼 (More button)
        /// onMoreTap 콜백이 제공된 경우에만 표시
        /// Only displayed when onMoreTap callback is provided
        if (onMoreTap != null)
          TextButton(
            onPressed: onMoreTap,
            style: TextButton.styleFrom(
              /// 최소 패딩으로 컴팩트한 버튼 스타일
              /// Compact button style with minimal padding
              padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '더보기',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                SizedBox(width: sp.s4),
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 12,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 필고 공지사항 섹션 빌드 (Build Philgo notice section)
  ///
  /// 로딩, 빈 상태, 데이터 상태에 따라 다른 UI를 표시합니다.
  /// Displays different UI based on loading, empty, or data state.
  Widget _buildPhilgoNoticeSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 로딩 중 (Loading state)
    if (_isPhilgoLoading) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(sp.s24),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.tertiary,
              ),
            ),
            SizedBox(height: sp.s12),
            Text(
              '공지사항을 불러오는 중...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    /// 공지사항이 없는 경우 (Empty state)
    if (_philgoNotices.isEmpty) {
      return _buildEmptyNoticeSection(
        context,
        icon: FontAwesomeIcons.lightCircleInfo,
        message: '필고 공지가 없습니다',
        description: '필고 서비스 관련 공지사항이 여기에 표시됩니다',
        backgroundColor: scheme.tertiaryContainer,
        foregroundColor: scheme.onTertiaryContainer,
      );
    }

    /// 공지사항 목록 표시 (Display notice list)
    return Container(
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...List.generate(_philgoNotices.length, (index) {
            final notice = _philgoNotices[index];
            final isLast = index == _philgoNotices.length - 1;

            return Column(
              children: [
                /// 필고 공지사항 아이템 (Philgo notice item)
                _buildPhilgoNoticeItem(context, notice),

                /// 구분선 (Divider) - 마지막 아이템 제외
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: sp.s16,
                    endIndent: sp.s16,
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// 필고 공지사항 아이템 빌드 (Build Philgo notice item)
  ///
  /// [notice] 표시할 공지사항 데이터
  Widget _buildPhilgoNoticeItem(BuildContext context, Notice notice) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return InkWell(
      onTap: () => _showPhilgoNoticeDetail(context, notice),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(sp.s16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 아이콘 (Icon)
            Container(
              padding: EdgeInsets.all(sp.s8),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FaIcon(
                FontAwesomeIcons.lightFileLines,
                size: 16,
                color: scheme.onTertiaryContainer,
              ),
            ),
            SizedBox(width: sp.s12),

            /// 제목 및 날짜 (Title and date)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 제목 (Title) - 최대 2줄
                  Text(
                    notice.subject,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: sp.s4),

                  /// 작성일 (Written date)
                  Text(
                    notice.timeString ?? _formatDate(notice.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            /// 화살표 아이콘 (Arrow icon)
            FaIcon(
              FontAwesomeIcons.lightChevronRight,
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 공지 섹션 빌드 (Build empty notice section)
  ///
  /// 공지가 없을 때 표시되는 빈 상태 UI를 생성합니다.
  /// Creates an empty state UI when there are no notices.
  Widget _buildEmptyNoticeSection(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String description,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s24),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// 아이콘 (Icon)
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              icon,
              size: 32,
              color: foregroundColor,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 메시지 (Message)
          Text(
            message,
            style: theme.textTheme.titleSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s8),

          /// 설명 (Description)
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: foregroundColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
