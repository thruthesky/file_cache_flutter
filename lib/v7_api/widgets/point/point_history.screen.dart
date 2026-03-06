import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/v7_api/models/v7_point_log_model.dart';
import 'package:philgo/v7_api/point_log_api.dart';
import 'package:philgo/v7_api/widgets/api_list_view/api_list_view.dart';

/// 포인트 내역 화면 (Point History Screen)
///
/// pointLog.memberPoint API로 현재 보유 포인트를 표시하고,
/// ApiListView를 사용하여 포인트 변동 기록을 무한 스크롤로 조회한다.
class PointHistoryScreen extends StatefulWidget {
  static const String routeName = '/point-history';

  /// 화면 이동 헬퍼
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  /// 현재 보유 포인트
  int _currentPoint = 0;

  /// 포인트 로딩 상태
  bool _isPointLoading = true;

  /// 포인트 로딩 에러
  String? _pointError;

  /// 페이지당 항목 수
  static const int _pageLimit = 20;

  /// ApiListView의 GlobalKey (새로고침용)
  final _listKey = GlobalKey<ApiListViewState<PointLog>>();

  @override
  void initState() {
    super.initState();
    _loadCurrentPoint();
  }

  /// 현재 보유 포인트 로딩
  Future<void> _loadCurrentPoint() async {
    try {
      final point = await PointLogApi.memberPoint();
      if (!mounted) return;
      setState(() {
        _currentPoint = point;
        _isPointLoading = false;
      });
    } catch (e) {
      debugPrint('포인트 로딩 에러: $e');
      if (!mounted) return;
      setState(() {
        _pointError = e.toString();
        _isPointLoading = false;
      });
    }
  }

  /// Unix timestamp → 날짜 문자열 변환
  String _formatDate(dynamic stamp) {
    if (stamp == null) return '';
    final ts = stamp is int ? stamp : int.tryParse('$stamp') ?? 0;
    if (ts == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }

  /// module/action 조합에 따른 아이콘 반환
  IconData _getLogIcon(String module, String action) {
    return switch (module) {
      'post' => FontAwesomeIcons.penToSquare,
      'comment' => FontAwesomeIcons.comment,
      'vote' => FontAwesomeIcons.thumbsUp,
      'event' || 'point_event' => FontAwesomeIcons.dharmachakra,
      'admin' => FontAwesomeIcons.userShield,
      'adv' => FontAwesomeIcons.bullhorn,
      'company' => FontAwesomeIcons.store,
      _ => FontAwesomeIcons.coins,
    };
  }

  /// module/action 조합에 따른 설명 텍스트 반환
  String _getLogDescription(String module, String action, String etc) {
    if (etc.isNotEmpty) return etc;
    final desc = switch ((module, action)) {
      ('post', 'create') => 'Post created',
      ('post', 'delete') => 'Post deleted',
      ('comment', 'create') => 'Comment created',
      ('comment', 'delete') => 'Comment deleted',
      ('vote', 'like') => 'Like',
      ('event', 'spin') || ('point_event', 'spin') => 'Spin wheel',
      ('admin', _) => 'Admin',
      ('adv', _) => 'Point advertisement',
      ('company', 'revisit') => 'Revisit point',
      ('company', 'review') => 'Review point',
      _ => '$module/$action',
    };
    return desc;
  }

  /// 포인트 숫자 포맷 (천 단위 콤마)
  String _formatPoint(int point) {
    return NumberFormat('#,###').format(point);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pointHistory),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 현재 보유 포인트 카드
          _buildPointCard(scheme, l10n),

          // 포인트 기록 리스트 (ApiListView)
          Expanded(
            child: ApiListView<PointLog>(
              key: _listKey,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              fetchPage: (page) => PointLogApi.history(
                page: page,
                limit: _pageLimit,
              ),
              noItemsBuilder: (context) =>
                  _buildEmptyState(scheme, l10n),
              errorBuilder: (context, error, retry) =>
                  _buildErrorState(scheme, error, retry),
              itemBuilder: (context, log, index) =>
                  _buildLogItem(scheme, log, index),
            ),
          ),
        ],
      ),
    );
  }

  /// 현재 보유 포인트 카드
  Widget _buildPointCard(ColorScheme scheme, Lo l10n) {
    if (_isPointLoading) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pointError != null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 16,
              color: scheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _pointError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPointLoading = true;
                  _pointError = null;
                });
                _loadCurrentPoint();
              },
              child: FaIcon(
                FontAwesomeIcons.arrowRotateRight,
                size: 14,
                color: scheme.onErrorContainer,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            l10n.currentPoints,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.coins,
                size: 24,
                color: scheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Text(
                _formatPoint(_currentPoint),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                'P',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(ColorScheme scheme, Lo l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPointHistory,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  /// 에러 상태 위젯
  Widget _buildErrorState(
    ColorScheme scheme,
    String error,
    VoidCallback retry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: scheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: retry,
              icon: const FaIcon(FontAwesomeIcons.arrowRotateRight, size: 14),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// 포인트 기록 아이템 위젯
  Widget _buildLogItem(
    ColorScheme scheme,
    PointLog log,
    int index,
  ) {

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // module/action 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: log.isPositive
                    ? scheme.primaryContainer
                    : scheme.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(
                  _getLogIcon(log.module, log.action),
                  size: 16,
                  color: log.isPositive
                      ? scheme.onPrimaryContainer
                      : scheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 설명 + 날짜
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLogDescription(log.module, log.action, log.etc),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(log.stamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),

            // 포인트 변동량 + 잔액
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${log.isPositive ? '+' : ''}${_formatPoint(log.point)}P',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: log.isPositive ? scheme.primary : scheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatPoint(log.pointAfter)}P',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index.clamp(0, 10) * 30).ms);
  }
}
