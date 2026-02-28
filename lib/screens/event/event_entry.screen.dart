import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;

/// 이벤트 응모 화면 (Event Entry Screen)
///
/// 상단: 내가 참여했던 이벤트 업소 목록 (더미 데이터, 추후 API 연동)
/// 하단: 이벤트 응모 안내 (추후 구현)
class EventEntryScreen extends StatelessWidget {
  static const String routeName = '/event-entry';

  /// 화면 이동 헬퍼
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const EventEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    /// 더미 데이터: 추후 API 연동 시 교체
    final dummyHistory = [
      _EventHistory(
        companyName: 'Jollibee Makati',
        visitDate: '2026-02-25',
        points: 1500,
      ),
      _EventHistory(
        companyName: 'SM Supermarket Cebu',
        visitDate: '2026-02-20',
        points: 1200,
      ),
      _EventHistory(
        companyName: 'Korean Mart Manila',
        visitDate: '2026-02-15',
        points: 1800,
      ),
      _EventHistory(
        companyName: 'Café Seoul BGC',
        visitDate: '2026-02-10',
        points: 2100,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickMenuEventEntry),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 참여 기록 헤더
            _buildHistoryHeader(theme, scheme, l10n),
            const SizedBox(height: 20),

            /// 참여 업소 목록
            ...dummyHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final history = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildHistoryCard(
                  theme: theme,
                  scheme: scheme,
                  l10n: l10n,
                  history: history,
                  index: index + 1,
                )
                    .animate()
                    .fadeIn(
                      duration: 350.ms,
                      delay: (100 * index).ms,
                    )
                    .slideX(begin: 0.05, end: 0),
              );
            }),
            const SizedBox(height: 16),

            /// 구분선
            Divider(color: scheme.outlineVariant),
            const SizedBox(height: 16),

            /// 이벤트 응모 안내 (추후 구현)
            _buildComingSoonSection(theme, scheme, l10n)
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
          ],
        ),
      ),
    );
  }

  /// 참여 기록 섹션 헤더: 아이콘 + 제목 + 설명
  Widget _buildHistoryHeader(
    ThemeData theme,
    ColorScheme scheme,
    Lo l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.lightClipboardList,
            size: 32,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.eventEntryMyHistory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.eventEntryMyHistoryDesc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 업소 참여 기록 카드: 순번 배지 + 업소명 + 방문일 + 획득 포인트
  Widget _buildHistoryCard({
    required ThemeData theme,
    required ColorScheme scheme,
    required Lo l10n,
    required _EventHistory history,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          /// 순번 배지
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),

          /// 업소명 + 방문일
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.companyName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.eventEntryVisitDate}: ${history.visitDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          /// 획득 포인트
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+${history.points}P',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 이벤트 응모 안내 (추후 구현 영역)
  Widget _buildComingSoonSection(
    ThemeData theme,
    ColorScheme scheme,
    Lo l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.lightGift,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.comingSoon,
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 이벤트 참여 기록 더미 데이터 모델
/// 추후 API 연동 시 실제 모델로 교체
class _EventHistory {
  final String companyName;
  final String visitDate;
  final int points;

  const _EventHistory({
    required this.companyName,
    required this.visitDate,
    required this.points,
  });
}
