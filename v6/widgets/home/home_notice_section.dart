import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 화면 공지사항 섹션 위젯 (Home Notice Section Widget)
///
/// 필고 공지사항을 홈 화면에 표시하는 섹션입니다.
/// 최근 공지사항을 불러와 제목만 간결하게 표시합니다.
///
/// Section displaying Philgo notices on the home screen.
/// Fetches recent notices and displays only titles.
///
/// [limit]: 표시할 공지사항 수 (기본값: 3)
/// [onMoreTap]: "더보기" 버튼 클릭 시 콜백
/// [onNoticeTap]: 공지사항 클릭 시 콜백
class HomeNoticeSection extends StatefulWidget {
  /// 표시할 공지사항 수 (기본값: 3)
  /// Number of notices to display (default: 3)
  final int limit;

  /// "더보기" 버튼 클릭 콜백
  /// "More" button tap callback
  final VoidCallback? onMoreTap;

  /// 공지사항 클릭 콜백
  /// Notice tap callback
  final void Function(Notice notice)? onNoticeTap;

  const HomeNoticeSection({
    super.key,
    this.limit = 3,
    this.onMoreTap,
    this.onNoticeTap,
  });

  @override
  State<HomeNoticeSection> createState() => _HomeNoticeSectionState();
}

class _HomeNoticeSectionState extends State<HomeNoticeSection> {
  /// 공지사항 목록
  /// Notice list
  List<Notice>? _notices;

  /// 로딩 상태
  /// Loading state
  bool _isLoading = true;

  /// 에러 메시지
  /// Error message
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  /// 공지사항 로드 (최근 공지사항)
  /// Load notices (recent notices)
  Future<void> _loadNotices() async {
    try {
      /// loadLatestNotices API 호출 (최근 공지사항 조회)
      /// Call loadLatestNotices API (fetch recent notices)
      final result = await PhilgoService.instance.loadLatestNotices(
        limit: widget.limit,
      );

      if (mounted) {
        setState(() {
          _notices = result;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('공지사항 로드 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 섹션 타이틀: "공지사항" (다국어 지원)
    /// Section title: "Notice" (i18n supported)
    final sectionTitle = Lo.of(context)!.subCategoryNotice;

    return Padding(
      padding: EdgeInsets.only(left: sp.s16, right: sp.s16, top: sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (이모지 + 타이틀 + 더보기)
          /// Section header (emoji + title + more button)
          _buildSectionHeader(theme, scheme, sp, sectionTitle),

          SizedBox(height: sp.s12),

          /// 로딩 상태: Shimmer 효과
          /// Loading state: Shimmer effect
          if (_isLoading) _buildLoadingState(sp, scheme),

          /// 에러 상태: 에러 메시지 + 재시도 버튼
          /// Error state: Error message + retry button
          if (_error != null && !_isLoading) _buildErrorState(theme, scheme, sp),

          /// 성공 상태: 공지사항 목록
          /// Success state: Notice list
          if (_notices != null && !_isLoading && _error == null)
            _buildNoticeList(sp),
        ],
      ),
    );
  }

  /// 섹션 헤더 위젯
  /// Section header widget
  Widget _buildSectionHeader(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String title,
  ) {
    return GestureDetector(
      onTap: widget.onMoreTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          /// 섹션 타이틀
          /// Section title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),

          /// 중간 여백
          /// Spacer
          const Spacer(),

          /// "더보기" 텍스트 + 아이콘
          /// "More" text + icon
          if (widget.onMoreTap != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Lo.of(context)!.homeMore,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 12,
                  color: scheme.primary,
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 로딩 상태 UI
  /// Loading state UI
  Widget _buildLoadingState(AppSpacing sp, ColorScheme scheme) {
    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.4),
            scheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(
          widget.limit,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < widget.limit - 1 ? sp.s12 : 0),
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 에러 상태 UI
  /// Error state UI
  Widget _buildErrorState(ThemeData theme, ColorScheme scheme, AppSpacing sp) {
    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '공지사항을 불러올 수 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
          ),
          SizedBox(height: sp.s8),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadNotices();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 공지사항 목록 UI (제목만 표시, 예쁜 디자인)
  /// Notice list UI (title only, beautiful design)
  Widget _buildNoticeList(AppSpacing sp) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 공지사항이 없는 경우
    /// If no notices
    if (_notices == null || _notices!.isEmpty) {
      return Container(
        padding: EdgeInsets.all(sp.s16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.4),
              scheme.secondaryContainer.withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            '공지사항이 없습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }

    /// 공지사항 목록 표시 (제목만, 예쁜 카드 스타일)
    /// Display notice list (title only, beautiful card style)
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s12),
      decoration: BoxDecoration(
        /// Theme 기반 그라데이션 배경
        /// Theme-based gradient background
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.4),
            scheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: _notices!.asMap().entries.map((entry) {
          final index = entry.key;
          final notice = entry.value;
          final isLast = index == _notices!.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => widget.onNoticeTap?.call(notice),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sp.s12, horizontal: sp.s4),
                    child: Row(
                      children: [
                        /// 두꺼운 파이프 아이콘 (공지 표시)
                        /// Thick pipe icon (notice indicator)
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: sp.s12),

                        /// 공지사항 제목
                        /// Notice title
                        Expanded(
                          child: Text(
                            notice.subject,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        SizedBox(width: sp.s8),

                        /// 오른쪽 화살표 아이콘
                        /// Right arrow icon
                        Container(
                          padding: EdgeInsets.all(sp.s4),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.lightChevronRight,
                            size: 10,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /// 구분선 (마지막 아이템 제외)
              /// Divider (except last item)
              if (!isLast)
                Divider(
                  height: 1,
                  color: scheme.outline.withValues(alpha: 0.15),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
