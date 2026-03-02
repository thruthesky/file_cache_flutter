import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/screens/event/event_entry.screen.dart';
import 'package:philgo_api/philgo_api.dart' show PhilgoConfig;
import 'package:philgo/v7_api/v7_api.dart';

/// 이벤트 쿠폰 화면 (Event Coupon Screen)
///
/// 포인트 응모 스피닝 휠에서 당첨된 스타벅스 쿠폰 목록을 표시한다.
/// event.history API를 호출하여 prize_type == 'starbucks'인 항목만 필터링하여 보여준다.
/// 당첨된 쿠폰이 없으면 빈 상태 메시지를 표시한다.
class EventCouponScreen extends StatefulWidget {
  static const String routeName = '/event-coupon';

  /// 화면 이동 헬퍼
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const EventCouponScreen({super.key});

  @override
  State<EventCouponScreen> createState() => _EventCouponScreenState();
}

class _EventCouponScreenState extends State<EventCouponScreen> {
  /// 스타벅스 쿠폰 당첨 기록 목록
  List<Map<String, dynamic>> _coupons = [];

  /// 로딩 상태
  bool _isLoading = true;

  /// 에러 메시지
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  /// event.history API를 호출하여 스타벅스 쿠폰 당첨 기록만 필터링
  Future<void> _loadCoupons() async {
    try {
      // 최대 100건의 기록을 가져와서 스타벅스 쿠폰만 필터링
      final result = await v7api('event.history', data: {
        'page': 1,
        'limit': 100,
      });
      if (!mounted) return;

      final items = (result['items'] as List<dynamic>?) ?? [];
      final starbucksCoupons = items
          .whereType<Map<String, dynamic>>()
          .where((item) => item['prize_type'] == 'starbucks')
          .toList();

      setState(() {
        _coupons = starbucksCoupons;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('event.history API 에러: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 쿠폰 이미지의 전체 URL 생성
  /// v7ApiEndpoint에서 api.php를 제거하고 쿠폰 상대 경로를 결합
  String _getCouponImageUrl(Map<String, dynamic> coupon) {
    final relativePath = coupon['starbucks_coupon_url'] as String? ?? '';
    if (relativePath.isEmpty) return '';
    final baseUrl = PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '');
    return '$baseUrl$relativePath';
  }

  /// 쿠폰 당첨 날짜 포맷 (Unix timestamp → 날짜 문자열)
  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    final ts = timestamp is int ? timestamp : int.tryParse('$timestamp') ?? 0;
    if (ts == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventCoupon),
        elevation: 0,
        actions: [
          /// 이벤트 응모 페이지로 이동하는 액션 버튼
          IconButton(
            onPressed: () => EventEntryScreen.push(context),
            icon: const FaIcon(FontAwesomeIcons.gift, size: 20),
            tooltip: l10n.quickMenuEventEntry,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState(scheme)
              : _coupons.isEmpty
                  ? _buildEmptyState(scheme, l10n)
                  : _buildCouponList(scheme),
    );
  }

  /// 에러 상태 위젯
  Widget _buildErrorState(ColorScheme scheme) {
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
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 쿠폰이 없을 때 빈 상태 위젯
  Widget _buildEmptyState(ColorScheme scheme, Lo l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.ticket,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noCouponsMessage,
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

  /// 쿠폰 이미지를 전체 화면 다이얼로그로 표시
  void _showCouponImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              /// 쿠폰 이미지 (핀치 줌 지원)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => Container(
                      height: 300,
                      color: scheme.surfaceContainerLow,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.image,
                          size: 48,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 닫기 버튼
              Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 쿠폰 목록 위젯
  Widget _buildCouponList(ColorScheme scheme) {
    final l10n = Lo.of(context)!;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _coupons.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        final imageUrl = _getCouponImageUrl(coupon);
        final date = _formatDate(coupon['created_at']);

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
                /// 당첨 날짜 + 파일명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 당첨 날짜
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.calendar,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            date.isNotEmpty ? date : '-',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurface,
                                ),
                          ),
                        ],
                      ),

                      /// 쿠폰 파일명
                      if ((coupon['starbucks_coupon_file'] as String?)?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          coupon['starbucks_coupon_file'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                /// 쿠폰 확인 버튼
                if (imageUrl.isNotEmpty)
                  FilledButton.tonalIcon(
                    onPressed: () => _showCouponImage(imageUrl),
                    icon: const FaIcon(FontAwesomeIcons.lightImage, size: 14),
                    label: Text(l10n.viewCoupon),
                  ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms);
      },
    );
  }
}
