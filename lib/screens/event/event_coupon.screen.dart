import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo_api/philgo_api.dart' show PhilgoConfig;
import 'package:philgo/v7_api/v7_api.dart';

/// 이벤트 쿠폰 화면 (Event Coupon Screen)
///
/// 포인트 응모 스피닝 휠에서 당첨된 쿠폰 목록을 표시한다.
/// event.myCoupons API를 호출하여 event_coupons 테이블에서 당첨(won/sent) 쿠폰을 조회한다.
/// 쿠폰 이미지는 uploads 테이블 기반 URL(display_image_url)로 표시한다.
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
  /// 당첨 쿠폰 목록 (event_coupons 테이블 기반)
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

  /// event.myCoupons API를 호출하여 당첨 쿠폰 목록 조회
  Future<void> _loadCoupons() async {
    try {
      final result = await v7api('event.myCoupons', data: {
        'page': 1,
        'limit': 100,
      });
      if (!mounted) return;

      final items = (result['items'] as List<dynamic>?) ?? [];

      setState(() {
        _coupons = items.whereType<Map<String, dynamic>>().toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('event.myCoupons API 에러: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 쿠폰 이미지의 전체 URL 생성
  ///
  /// event_coupons + uploads JOIN 결과의 display_image_url을 사용한다.
  /// 절대 URL이면 그대로 사용, 상대 경로면 v7ApiEndpoint 기준으로 결합.
  String _getCouponImageUrl(Map<String, dynamic> coupon) {
    final imageUrl = coupon['display_image_url'] as String? ?? '';
    if (imageUrl.isEmpty) return '';
    // 절대 URL인 경우 그대로 반환
    if (imageUrl.startsWith('http')) return imageUrl;
    // 상대 경로인 경우 baseUrl 결합
    final baseUrl = PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '');
    return '$baseUrl$imageUrl';
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

  /// 쿠폰 클릭 시 확인 다이얼로그 → API 호출 → QR 코드 표시
  ///
  /// 1. 확인 다이얼로그로 사용자 의사 확인
  /// 2. event.viewCoupon API 호출하여 viewed_at 기록
  /// 3. QR 코드 이미지를 전체 화면으로 표시
  Future<void> _onCouponTap(Map<String, dynamic> coupon, String imageUrl) async {
    final l10n = Lo.of(context)!;
    final couponIdx = coupon['idx'];
    final viewedAt = coupon['viewed_at'];

    // 이미 확인한 쿠폰은 바로 QR 표시
    if (viewedAt != null && viewedAt != 0 && '$viewedAt' != '0') {
      _showCouponImage(imageUrl);
      return;
    }

    // 미확인 쿠폰: 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.couponUseConfirmTitle),
        content: Text(l10n.couponUseConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.couponUseConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // event.viewCoupon API 호출하여 viewed_at 기록
    try {
      await v7api('event.viewCoupon', data: {'idx': couponIdx});

      // 로컬 쿠폰 데이터에 viewed_at 업데이트
      if (mounted) {
        setState(() {
          coupon['viewed_at'] = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        });
      }
    } catch (e) {
      debugPrint('event.viewCoupon API 에러: $e');
    }

    // QR 코드 이미지 표시
    if (mounted) {
      _showCouponImage(imageUrl);
    }
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


  /// 쿠폰 경고 메시지 위젯 (목록 상단 고정)
  Widget _buildCouponNotice(ColorScheme scheme, Lo l10n) {
    final notices = [
      l10n.couponNoticeAlreadyPaid,
      l10n.couponNoticeQrTransfer,
      l10n.couponNoticeDisclaimer,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // 경고 메시지 배경은 errorContainer 색상 사용
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < notices.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    size: 12,
                    // 경고 아이콘은 onErrorContainer 색상 사용
                    color: scheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notices[i],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          // 경고 텍스트는 onErrorContainer 색상 사용
                          color: scheme.onErrorContainer,
                          height: 1.4,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 쿠폰 목록 위젯
  Widget _buildCouponList(ColorScheme scheme) {
    final l10n = Lo.of(context)!;

    return Column(
      children: [
        /// 경고 메시지 (스크롤되지 않는 고정 헤더)
        _buildCouponNotice(scheme, l10n),
        const SizedBox(height: 8),

        /// 쿠폰 카드 목록
        Expanded(
          child: ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _coupons.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final coupon = _coupons[index];
        final imageUrl = _getCouponImageUrl(coupon);
        final date = _formatDate(coupon['won_at']);
        // event_coupons 테이블의 idx를 식별 코드로 사용
        final couponId = '${coupon['idx'] ?? ''}';
        final title = coupon['title'] as String? ?? '';
        final couponType = coupon['coupon_type'] as String? ?? '';
        final status = coupon['status'] as String? ?? '';
        final isSent = status == 'sent';
        final viewedAt = coupon['viewed_at'];
        final isViewed = viewedAt != null && viewedAt != 0 && '$viewedAt' != '0';
        final viewedDate = isViewed ? _formatDate(viewedAt) : '';

        return InkWell(
          onTap: imageUrl.isNotEmpty ? () => _onCouponTap(coupon, imageUrl) : null,
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: 0,
            color: scheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  /// 쿠폰 유형 라벨 (이미지 대신 텍스트 표시)
                  _buildCouponLabel(
                    scheme,
                    couponType: couponType,
                    title: title,
                  ),
                  const SizedBox(width: 16),

                  /// 쿠폰 정보 (제목 + 날짜/코드 + 상태)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 쿠폰 제목
                        Text(
                          title.isNotEmpty ? title : couponType,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: scheme.onSurface,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        /// 당첨 날짜 + 식별 코드
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.calendar,
                              size: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              date.isNotEmpty ? date : '-',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                            if (couponId.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              // 식별 코드를 작은 칩으로 표시
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  // 칩 배경은 secondaryContainer 색상 사용
                                  color: scheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#$couponId',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: scheme.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// 상태 배지
                        _buildStatusBadge(scheme, isSent: isSent, l10n: l10n),

                        /// QR 확인 날짜 (viewed_at이 있는 경우만 표시)
                        if (isViewed && viewedDate.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.couponViewedDate(viewedDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: scheme.tertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  /// 쿠폰 보기 화살표
                  if (imageUrl.isNotEmpty)
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 14,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms);
      },
          ),
        ),
      ],
    );
  }

  /// 쿠폰 유형 라벨 위젯 (이미지 대신 유형 + 제목 텍스트 표시)
  Widget _buildCouponLabel(
    ColorScheme scheme, {
    required String couponType,
    required String title,
  }) {
    // 쿠폰 유형별 고정 라벨 텍스트
    final displayText = switch (couponType) {
      'starbucks' => '스타벅스\n300 쿠폰',
      'mcdonalds' => '맥도날드\n쿠폰',
      _ => title.isNotEmpty ? title : couponType,
    };

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        // 라벨 배경은 primaryContainer 색상 사용
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            displayText,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  // 라벨 텍스트는 onPrimaryContainer 색상 사용
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
          ),
        ),
      ),
    );
  }

  /// 전송 상태 배지 위젯
  Widget _buildStatusBadge(
    ColorScheme scheme, {
    required bool isSent,
    required Lo l10n,
  }) {
    // 전송 완료: tertiary, 당첨(미전송): secondary
    final bgColor =
        isSent ? scheme.tertiaryContainer : scheme.secondaryContainer;
    final fgColor =
        isSent ? scheme.onTertiaryContainer : scheme.onSecondaryContainer;
    final icon =
        isSent ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.trophy;
    final label = isSent ? l10n.couponSent : l10n.couponWon;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 10, color: fgColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

}
