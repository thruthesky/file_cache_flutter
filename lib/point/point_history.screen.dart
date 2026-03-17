import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/point/point.service.dart';
import 'package:philgo/point/point_log.model.dart';

/// 포인트 내역 화면
class PointHistoryScreen extends StatefulWidget {
  static const String routeName = '/point-history';

  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const PointHistoryScreen({super.key});

  @override
  State<PointHistoryScreen> createState() => _PointHistoryScreenState();
}

class _PointHistoryScreenState extends State<PointHistoryScreen> {
  int _currentPoint = 0;
  bool _isPointLoading = true;
  String? _pointError;

  static const int _pageLimit = 20;

  late final PagingController<int, PointLog> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, PointLog>(
      getNextPageKey: (state) {
        final keys = state.keys;
        if (keys == null || keys.isEmpty) return 1;
        return keys.last + 1;
      },
      fetchPage: _fetchPage,
    );
    _loadCurrentPoint();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<PointLog>> _fetchPage(int page) async {
    return PointService.history(page: page, limit: _pageLimit);
  }

  Future<void> _loadCurrentPoint() async {
    try {
      final point = await PointService.memberPoint();
      if (!mounted) return;
      setState(() {
        _currentPoint = point;
        _isPointLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pointError = e.toString();
        _isPointLoading = false;
      });
    }
  }

  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }

  IconData _getLogIcon(String module) {
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

  String _getLogDescription(String module, String action, String etc) {
    if (etc.isNotEmpty) return etc;
    return switch ((module, action)) {
      ('post', 'create') => '글 작성'.tr(),
      ('post', 'delete') => '글 삭제'.tr(),
      ('comment', 'create') => '댓글 작성'.tr(),
      ('comment', 'delete') => '댓글 삭제'.tr(),
      ('vote', 'like') => '좋아요'.tr(),
      ('event', 'spin') || ('point_event', 'spin') => '스피닝 휠'.tr(),
      ('admin', _) => '관리자'.tr(),
      ('adv', _) => '포인트 광고'.tr(),
      ('company', 'revisit') => '재방문 포인트'.tr(),
      ('company', 'review') => '후기 포인트'.tr(),
      _ => '$module/$action',
    };
  }

  String _formatPoint(int point) {
    return NumberFormat('#,###').format(point);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('포인트 내역'.tr()),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPointCard(theme, scheme),
          Expanded(
            child: PagingListener(
              controller: _pagingController,
              builder: (context, state, fetchNextPage) {
                return PagedListView<int, PointLog>.separated(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  builderDelegate: PagedChildBuilderDelegate<PointLog>(
                    itemBuilder: (context, log, index) =>
                        _buildLogItem(scheme, log, index),
                    noItemsFoundIndicatorBuilder: (_) =>
                        _buildEmptyState(scheme),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(ThemeData theme, ColorScheme scheme) {
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
            '보유 포인트'.tr(),
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

  Widget _buildEmptyState(ColorScheme scheme) {
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
              '포인트 내역이 없습니다'.tr(),
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

  Widget _buildLogItem(ColorScheme scheme, PointLog log, int index) {
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
                  _getLogIcon(log.module),
                  size: 16,
                  color: log.isPositive
                      ? scheme.onPrimaryContainer
                      : scheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
