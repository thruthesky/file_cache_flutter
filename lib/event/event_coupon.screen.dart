import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/event/event.service.dart';
import 'package:philgo/event/event_coupon.model.dart';
import 'package:philgo/globals.dart';
import 'package:share_plus/share_plus.dart';

/// 이벤트 쿠폰 화면
///
/// 포인트 응모 스피닝 휠에서 당첨된 쿠폰 목록을 표시한다.
class EventCouponScreen extends StatefulWidget {
  static const String routeName = '/event-coupon';
  static Future<dynamic> push(BuildContext context) => context.push(routeName);

  const EventCouponScreen({super.key});

  @override
  State<EventCouponScreen> createState() => _EventCouponScreenState();
}

class _EventCouponScreenState extends State<EventCouponScreen> {
  List<EventCoupon> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    final result = await EventService.myCoupons();
    if (!mounted) return;
    setState(() {
      _coupons = result.items;
      _isLoading = false;
    });
  }

  /// 쿠폰 이미지의 전체 URL 생성
  String _getCouponImageUrl(EventCoupon coupon) {
    final imageUrl = coupon.displayImageUrl;
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return '${Config.v7BaseUrl}$imageUrl';
  }

  /// 쿠폰 당첨 날짜 포맷
  String _formatDate(int timestamp) {
    if (timestamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // "Event Coupons"
      appBar: AppBar(title: Text('이벤트 쿠폰'.tr()), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _coupons.isEmpty
          ? _buildEmptyState()
          : _buildCouponList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.ticket,
              size: 48,
              color: color.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              // "[NO TRANSLATION: 당첨된 쿠폰이 없습니다]"
              '당첨된 쿠폰이 없습니다'.tr(),
              textAlign: TextAlign.center,
              style: text.bodyLarge?.copyWith(color: color.onSurfaceVariant),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }

  /// 쿠폰 클릭 → 확인 다이얼로그 → QR 코드 표시
  Future<void> _onCouponTap(EventCoupon coupon, String imageUrl) async {
    // 이미 확인한 쿠폰은 바로 QR 표시
    if (coupon.isViewed) {
      _showCouponImage(imageUrl, coupon: coupon);
      return;
    }

    // 미확인 쿠폰: 확인 다이얼로그 표시
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        // "[NO TRANSLATION: 쿠폰 사용]"
        title: Text('쿠폰 사용'.tr()),
        // "[NO TRANSLATION: 쿠폰을 사용하시겠습니까?]"
        content: Text('쿠폰을 사용하시겠습니까?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            // "[NO TRANSLATION: 예, 사용하겠습니다]"
            child: Text('예, 사용하겠습니다'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await EventService.viewCoupon(idx: coupon.idx);
    if (!mounted) return;
    final index = _coupons.indexOf(coupon);
    if (index >= 0) {
      setState(() {
        _coupons[index] = coupon.copyWith(
          viewedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      });
    }

    if (mounted) _showCouponImage(imageUrl, coupon: coupon);
  }

  /// 쿠폰 공유
  Future<void> _shareCoupon(EventCoupon coupon, String imageUrl) async {
    final couponName = coupon.title.isNotEmpty
        ? coupon.title
        : coupon.couponType;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await SharePlus.instance.share(
      ShareParams(
        text: '필고 이벤트 쿠폰: $couponName\n$imageUrl',
        subject: '필고 이벤트 쿠폰',
        sharePositionOrigin: origin,
      ),
    );
  }

  void _showCouponImage(String imageUrl, {EventCoupon? coupon}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
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
                      color: color.surfaceContainerLow,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.image,
                          size: 48,
                          color: color.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (coupon != null)
                      IconButton.filled(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _shareCoupon(coupon, imageUrl);
                        },
                        icon: const FaIcon(
                          FontAwesomeIcons.lightShareNodes,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(width: 4),
                    IconButton.filled(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCouponNotice() {
    final notices = [
      // "[NO TRANSLATION: 이미 결제 완료된 쿠폰은 재발행이 불가합니다.]"
      '이미 결제 완료된 쿠폰은 재발행이 불가합니다.'.tr(),
      // "[NO TRANSLATION: QR코드 쿠폰은 타인에게 전송 가능합니다.]"
      'QR코드 쿠폰은 타인에게 전송 가능합니다.'.tr(),
      // "[NO TRANSLATION: 쿠폰 사용에 대한 책임은 당첨자에게 있습니다.]"
      '쿠폰 사용에 대한 책임은 당첨자에게 있습니다.'.tr(),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.errorContainer,
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
                    color: color.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notices[i],
                    style: text.bodySmall?.copyWith(
                      color: color.onErrorContainer,
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

  Widget _buildCouponList() {
    return Column(
      children: [
        _buildCouponNotice(),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: _coupons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final coupon = _coupons[index];
              final imageUrl = _getCouponImageUrl(coupon);
              final date = _formatDate(coupon.wonAt);
              final couponId = '${coupon.idx}';
              final viewedDate = coupon.isViewed
                  ? _formatDate(coupon.viewedAt)
                  : '';

              return InkWell(
                onTap: imageUrl.isNotEmpty
                    ? () => _onCouponTap(coupon, imageUrl)
                    : null,
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  elevation: 0,
                  color: color.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _buildCouponLabel(coupon),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coupon.title.isNotEmpty
                                    ? coupon.title
                                    : coupon.couponType,
                                style: text.titleSmall?.copyWith(
                                  color: color.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.calendar,
                                    size: 11,
                                    color: color.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    date.isNotEmpty ? date : '-',
                                    style: text.bodySmall?.copyWith(
                                      color: color.onSurfaceVariant,
                                    ),
                                  ),
                                  if (couponId.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color.secondaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '#$couponId',
                                        style: text.labelSmall?.copyWith(
                                          color: color.onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildStatusBadge(coupon.isSent),
                              if (coupon.isViewed && viewedDate.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  // "[NO TRANSLATION: 확인 날짜: {}]"
                                  '확인 날짜: {}'.tr(args: [viewedDate]),
                                  style: text.bodySmall?.copyWith(
                                    color: color.tertiary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (imageUrl.isNotEmpty)
                          FaIcon(
                            FontAwesomeIcons.chevronRight,
                            size: 14,
                            color: color.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
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

  Widget _buildCouponLabel(EventCoupon coupon) {
    final displayText = switch (coupon.couponType) {
      'starbucks' => '스타벅스\n300 쿠폰',
      'mcdonalds' => '맥도날드\n쿠폰',
      _ => coupon.title.isNotEmpty ? coupon.title : coupon.couponType,
    };

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.primaryContainer,
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
            style: text.labelSmall?.copyWith(
              color: color.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isSent) {
    final bgColor = isSent ? color.tertiaryContainer : color.secondaryContainer;
    final fgColor = isSent
        ? color.onTertiaryContainer
        : color.onSecondaryContainer;
    final icon = isSent
        ? FontAwesomeIcons.circleCheck
        : FontAwesomeIcons.trophy;
    // "[NO TRANSLATION: 전송완료]", "[NO TRANSLATION: 당첨]"
    final label = isSent ? '전송완료'.tr() : '당첨'.tr();

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
            style: text.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
