import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo/widgets/theme/comic_snackbar.dart';
import 'package:philgo/v7_api/company_api.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// Company QR Code Screen
///
/// Displays the company's QR code with basic info, event banner, and action buttons.
/// The QR code encodes the company's web URL for easy scanning.
///
/// Features:
/// - Company basic info (logo, name, category, location, contacts)
/// - Event banner with gradient background
/// - QR code generated from company URL (using qr_flutter)
/// - Bottom action bar: Share, Download, View Company
class CompanyQrCodeScreen extends StatefulWidget {
  static const String routeName = '/company-qr-code';

  /// push navigation pattern (consistent with other company screens)
  static Future<void> Function(BuildContext ctx, int companyIdx) push =
      (ctx, companyIdx) => ctx.push(routeName, extra: companyIdx);

  const CompanyQrCodeScreen({super.key, required this.companyIdx});

  final int companyIdx;

  @override
  State<CompanyQrCodeScreen> createState() => _CompanyQrCodeScreenState();
}

class _CompanyQrCodeScreenState extends State<CompanyQrCodeScreen> {
  Company? company;
  bool isLoading = true;
  String? errorMessage;

  /// GlobalKey for capturing QR code image via RepaintBoundary
  final GlobalKey _qrKey = GlobalKey();

  /// Company web URL to encode in the QR code
  String get companyUrl =>
      'https://philgo.com/company/view.php?idx=${company?.idx ?? widget.companyIdx}';

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  /// Load company information by idx (same pattern as CompanyViewScreen)
  Future<void> _loadCompany() async {
    try {
      final details = await CompanyApi.get(widget.companyIdx);
      if (!mounted) return;
      setState(() {
        company = details;
        isLoading = false;
      });
    } catch (e) {
      debugLog('Error fetching company for QR: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// Share company URL via share_plus (same pattern as post_view_buttons.dart)
  Future<void> _shareCompany() async {
    if (company == null) return;
    try {
      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;
      await SharePlus.instance.share(
        ShareParams(
          text: '${company!.name}\n$companyUrl',
          subject: company!.name,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugLog('Error sharing company: $e');
    }
  }

  /// Download QR code to device gallery
  /// Captures the RepaintBoundary widget as a PNG image and saves via gal package
  Future<void> _downloadQrCode() async {
    try {
      final boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes,
          name: 'philgo_qr_${company!.idx}');

      if (mounted) {
        showComicSuccessSnackBar(context, T.qrCodeSavedToGallery);
      }
    } catch (e) {
      debugLog('Error saving QR code: $e');
      if (mounted) {
        showComicErrorSnackBar(context, T.qrCodeSaveFailed);
      }
    }
  }

  /// Maps a category ID to a localized display name using i18n
  /// (Same logic as CompanyViewScreen._getCategoryDisplayName)
  String _getCategoryDisplayName(String categoryId) {
    final categoryMap = {
      'public-office': T.publicOffice,
      'education': T.education,
      'food': T.foodAndDrink,
      'transport': T.transportation,
      'hospital': T.healthAndHospitals,
      'mart': T.shoppingAndMarts,
      'bank': T.bankingAndFinance,
      'gadget': T.gadgets,
      'travel-agency': T.travelAndTourism,
      'hotel': T.hotels,
      'rentcar': T.carRental,
      'beauty': T.beautyAndWellness,
      'real-estate': T.realEstate,
      'ktv': T.entertainment,
      'spa': T.spaAndRelaxation,
      'etc': T.otherServices,
    };

    return categoryMap[categoryId.toLowerCase()] ?? categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      /// AppBar: Comic Design - elevation 0, 1px bottom border
      appBar: AppBar(
        title: Text(T.viewQrCode, style: theme.textTheme.titleLarge),
        backgroundColor: scheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),

      /// Main content area
      body: _buildBody(scheme, theme),

      /// Bottom action bar: [Share] [Download] [View Company]
      /// Only shown when company is loaded and qr_code_enabled is true (admin-approved)
      bottomNavigationBar: company != null &&
              !isLoading &&
              company!.qr_code_enabled
          ? _buildBottomBar(scheme)
          : null,
    );
  }

  /// Build main body content based on loading/error/success state
  Widget _buildBody(ColorScheme scheme, ThemeData theme) {
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
                icon: const FaIcon(
                  FontAwesomeIcons.arrowRotateRight,
                  size: 16,
                ),
                label: Text(T.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (company == null) return const SizedBox.shrink();

    /// Check if QR code is enabled/approved by admin via the qr_code_enabled field
    /// Only companies with qr_code_enabled == true can display QR codes
    final isApproved = company!.qr_code_enabled;

    /// If not approved, show a "not approved" message instead of QR code
    if (!isApproved) {
      return _buildNotApprovedMessage(scheme, theme);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          /// [1] Company basic info section
          _buildCompanyInfoSection(scheme, theme)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 28),

          /// [2] Event banner with gradient background
          _buildEventBanner(scheme, theme)
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 28),

          /// [3] QR code card (wrapped in RepaintBoundary for image capture)
          _buildQrCodeSection(scheme, theme)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 16),

          /// [4] QR code scan guide text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  T.qrCodeScanGuide,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms),

          const SizedBox(height: 32),

          /// [5] QR 코드 부정 사용 경고 배너
          _buildFraudWarningBanner(scheme, theme)
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// [1] Company basic info section
  /// Shows logo, name, category tag, location, and phone number
  Widget _buildCompanyInfoSection(ColorScheme scheme, ThemeData theme) {
    final c = company!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Logo + Name + Category tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.logo_url.isNotEmpty) ...[
                CompanyLogo(company: c),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Company name
                    Text(
                      c.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// Category tag (localized)
                    if (c.category.isNotEmpty)
                      CompanyCategoryTag(
                        category: c.category,
                        displayName: _getCategoryDisplayName(c.category),
                      ),
                  ],
                ),
              ),
            ],
          ),

          /// Location info
          if (c.location.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],

          /// Contact info (show first available phone number)
          if (c.phone_number.isNotEmpty || c.mobile_number.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                FaIcon(
                  c.phone_number.isNotEmpty
                      ? FontAwesomeIcons.phone
                      : FontAwesomeIcons.mobileScreen,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  c.phone_number.isNotEmpty
                      ? c.phone_number
                      : c.mobile_number,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// [2] Event banner with gradient background
  /// Shows "EVENT" header, "PhilGo + company name", and "Join Event" text
  Widget _buildEventBanner(ColorScheme scheme, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        /// Gradient from primary to tertiary (design requirement from screenshot)
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// "EVENT" header with star icons
          Text(
            'EVENT',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.8),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),

          /// "PhilGo + Company Name" title
          Text(
            '${T.appName} + ${company!.name}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          /// "Join Event" subtitle
          Text(
            T.eventParticipation,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// [3] QR code section
  /// Wrapped in RepaintBoundary for image capture (download feature)
  Widget _buildQrCodeSection(ColorScheme scheme, ThemeData theme) {
    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: QrImageView(
            data: companyUrl,
            version: QrVersions.auto,
            size: 240,

            /// QR code must have white background for reliable scanning
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: scheme.onSurface,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  /// Build "not approved" message when company QR code is not yet approved by admin
  /// Shows a centered icon and message informing the user that the QR code is pending approval
  Widget _buildNotApprovedMessage(ColorScheme scheme, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightClockRotateLeft,
              size: 56,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              T.qrCodeNotApproved,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  /// [5] QR 코드 부정 사용 경고 배너
  /// 빨간 계열 그라데이션 배경에 경고 아이콘과 텍스트를 표시
  Widget _buildFraudWarningBanner(ColorScheme scheme, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.error.withValues(alpha: 0.08),
            scheme.error.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightTriangleExclamation,
            size: 18,
            color: scheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              T.qrCodeFraudWarning,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.error,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom action bar with 3 buttons: Share, Download, View Company
  /// Follows CompanyFormScreen bottom bar pattern
  Widget _buildBottomBar(ColorScheme scheme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(
            top: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            /// [Share] button
            Expanded(
              child: ComicButton(
                onPressed: _shareCompany,
                rounded: ComicButtonRounded.normal,
                padding: ComicButtonPadding.small,
                textSize: ComicButtonTextSize.small,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightShareNodes,
                      size: 14,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(T.share),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            /// [Download] button (primary action)
            Expanded(
              child: ComicPrimaryButton(
                onPressed: _downloadQrCode,
                rounded: ComicButtonRounded.normal,
                padding: ComicButtonPadding.small,
                textSize: ComicButtonTextSize.small,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightDownload,
                      size: 14,
                      color: scheme.onPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(T.downloadQrCode),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            /// [View Company] button
            Expanded(
              child: ComicButton(
                onPressed: () =>
                    CompanyViewScreen.push(context, widget.companyIdx),
                rounded: ComicButtonRounded.normal,
                padding: ComicButtonPadding.small,
                textSize: ComicButtonTextSize.small,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightBuilding,
                      size: 14,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(T.viewCompany),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
