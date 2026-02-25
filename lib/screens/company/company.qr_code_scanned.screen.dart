import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// QR 코드 스캔 결과 화면 (Company QR Code Scanned Screen)
///
/// Purpose: QR 코드 스캔 후 업체 정보를 콤팩트하게 요약 표시하고,
/// 영수증 업로드를 통한 포인트 이벤트 참여를 유도하는 화면.
///
/// Flow: QR 스캔 → 업체 확인 → 영수증 업로드 → 텍스트 분석 →
///       날짜/시간/업체 판별 → 포인트 획득 → Spin Wheel 추첨
class CompanyQrCodeScannedScreen extends StatefulWidget {
  static const String routeName = '/company/qr-code-scanned.php';

  final int idx;
  final String verificationId;

  const CompanyQrCodeScannedScreen({
    super.key,
    required this.idx,
    required this.verificationId,
  });

  static Future<void> Function(
    BuildContext ctx,
    int idx,
    String verificationId,
  ) push = (ctx, idx, verificationId) => ctx.push(
        '$routeName?idx=$idx&verification_id=$verificationId',
      );

  @override
  State<CompanyQrCodeScannedScreen> createState() =>
      _CompanyQrCodeScannedScreenState();
}

class _CompanyQrCodeScannedScreenState
    extends State<CompanyQrCodeScannedScreen> {
  Company? company;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    try {
      final details = await getCompany(widget.idx);
      if (!mounted) return;
      setState(() {
        company = details;
        isLoading = false;
      });
    } catch (e) {
      debugLog('Error fetching company from QR scan: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Check if a string value is a URL (not a real address/location)
  bool _isUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  /// Build a single-line contact summary string
  /// Combines phone, mobile, kakao into one compact line
  String _buildContactSummary(Company c) {
    final parts = <String>[];
    if (c.phone_number.isNotEmpty) parts.add(c.phone_number);
    if (c.mobile_number.isNotEmpty) parts.add(c.mobile_number);
    if (c.kakaotalk_id.isNotEmpty) parts.add(c.kakaotalk_id);
    if (c.telegram_id.isNotEmpty) parts.add(c.telegram_id);
    return parts.join(' · ');
  }

  /// Get valid address (non-URL) from location or address field
  String _getValidAddress(Company c) {
    if (c.location.isNotEmpty && !_isUrl(c.location)) return c.location;
    if (c.address.isNotEmpty && !_isUrl(c.address)) return c.address;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      /// AppBar: show logo + company name when loaded
      appBar: AppBar(
        title: _buildAppBarTitle(theme, scheme),
        elevation: 0,
      ),
      body: _buildBody(scheme, theme),
    );
  }

  /// AppBar title: logo + company name (compact)
  Widget _buildAppBarTitle(ThemeData theme, ColorScheme scheme) {
    if (company == null) {
      return Text(T.pointEvent, style: theme.textTheme.titleLarge);
    }

    final c = company!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Company logo in AppBar
        if (c.logo_url.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              c.logo_url,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FaIcon(
                  FontAwesomeIcons.building,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        if (c.logo_url.isNotEmpty) const SizedBox(width: 8),
        Flexible(
          child: Text(
            c.name,
            style: theme.textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ColorScheme scheme, ThemeData theme) {
    /// Loading state
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              T.loading,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    /// Error state
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 48,
                color: scheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                T.failedToLoadCompanies,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _loadCompany();
                },
                icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
                label: Text(T.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (company == null) return const SizedBox.shrink();

    final c = company!;
    final contactSummary = _buildContactSummary(c);
    final validAddress = _getValidAddress(c);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// Compact company info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Company name + title (one line each)
                if (c.title.isNotEmpty)
                  Text(
                    c.title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                /// Category tag (compact)
                if (c.category.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      c.category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],

                /// Contact summary (one line: phone · mobile · kakao)
                if (contactSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.phone,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          contactSummary,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                /// Address (one line)
                if (validAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          validAddress,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                /// Description (one line)
                if (c.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleInfo,
                        size: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          c.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                /// View full details link
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => CompanyViewScreen.push(context, widget.idx),
                  child: Text(
                    T.viewDetails,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0),

          /// Spacer to push button to bottom
          const Spacer(),

          /// Receipt upload button (main CTA)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () {
                // TODO: Implement receipt upload flow
              },
              icon: const FaIcon(FontAwesomeIcons.receipt, size: 18),
              label: Text(
                T.uploadReceiptForPointEvent,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onPrimary,
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
