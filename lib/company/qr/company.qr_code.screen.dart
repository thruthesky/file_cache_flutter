import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/globals.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

/// 업소 QR 코드 화면
///
/// 업소의 QR 코드를 표시하고, 공유/다운로드 기능을 제공한다.
/// QR 코드는 업소의 웹 URL을 인코딩한다.
class CompanyQrCodeScreen extends StatefulWidget {
  static const String routeName = '/company-qr-code';

  static Future<dynamic> push(BuildContext context, int companyIdx) =>
      context.push('$routeName?idx=$companyIdx');

  final int companyIdx;

  const CompanyQrCodeScreen({super.key, required this.companyIdx});

  @override
  State<CompanyQrCodeScreen> createState() => _CompanyQrCodeScreenState();
}

class _CompanyQrCodeScreenState extends State<CompanyQrCodeScreen> {
  CompanyModel? _company;
  bool _isLoading = true;
  String? _errorMessage;

  final GlobalKey _qrKey = GlobalKey();

  String get _companyUrl =>
      'https://philgo.com/company/view.php?idx=${_company?.idx ?? widget.companyIdx}';

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final company = await CompanyService.get(widget.companyIdx);
    if (!mounted) return;
    if (company != null) {
      setState(() {
        _company = company;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = '업소 정보를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _shareCompany() async {
    if (_company == null) return;
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    await SharePlus.instance.share(
      ShareParams(
        text: '${_company!.name}\n$_companyUrl',
        subject: _company!.name,
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<void> _downloadQrCode() async {
    final boundary =
        _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    await Gal.putImageBytes(pngBytes, name: 'philgo_qr_${_company!.idx}');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        // "QR code saved to gallery."
        SnackBar(content: Text('QR 코드가 갤러리에 저장되었습니다.'.tr())),
      );
    }
  }

  String _getCategoryDisplayName(String categoryId) {
    final categoryMap = {
      // "Government"
      'public-office': '관공서'.tr(),
      // "Education"
      'education': '교육'.tr(),
      // "Food & Drink"
      'food': '음식/음료'.tr(),
      // "Transportation"
      'transport': '교통'.tr(),
      // "Health/Hospital"
      'hospital': '건강/병원'.tr(),
      // "Shopping/Mart"
      'mart': '쇼핑/마트'.tr(),
      // "Bank/Finance"
      'bank': '은행/금융'.tr(),
      // "Electronics"
      'gadget': '전자제품'.tr(),
      // "Travel/Tourism"
      'travel-agency': '여행/관광'.tr(),
      // "Hotel"
      'hotel': '호텔'.tr(),
      // "Rent a Car"
      'rentcar': '렌터카'.tr(),
      // "Beauty/Wellness"
      'beauty': '미용/웰빙'.tr(),
      // "Real Estate"
      'real-estate': '부동산'.tr(),
      // "Entertainment"
      'ktv': '엔터테인먼트'.tr(),
      // "Spa/Relaxation"
      'spa': '스파/휴식'.tr(),
      // "Other Services"
      'etc': '기타 서비스'.tr(),
    };
    return categoryMap[categoryId.toLowerCase()] ?? categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "View QR Code"
        title: Text('QR 코드 보기'.tr(), style: text.titleLarge),
        backgroundColor: color.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: color.outlineVariant),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _company != null && !_isLoading && _company!.qrCodeEnabled
              ? _buildBottomBar()
              : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(color.primary),
            ),
            const SizedBox(height: 16),
            Text(
              // "Loading..."
              '로딩 중...'.tr(),
              style: text.bodyMedium?.copyWith(color: color.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 48,
                color: color.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: text.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadCompany();
                },
                icon: const FaIcon(FontAwesomeIcons.arrowRotateRight, size: 16),
                // "Try Again"
                label: Text('다시 시도'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (_company == null) return const SizedBox.shrink();

    if (!_company!.qrCodeEnabled) {
      return _buildNotApprovedMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildCompanyInfoSection()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 28),
          _buildEventBanner()
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 28),
          _buildQrCodeSection()
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 14,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  // "Scan this QR code to participate in PhilGo business events."
                  '이 QR 코드를 스캔하여 필고 업소 이벤트에 참가하세요.'.tr(),
                  style: text.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
          const SizedBox(height: 32),
          _buildFraudWarningBanner()
              .animate()
              .fadeIn(duration: 500.ms, delay: 400.ms)
              .slideY(begin: 0.15, end: 0),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompanyInfoSection() {
    final c = _company!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.logoUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    c.logoUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 56,
                      height: 56,
                      color: color.surfaceContainerHighest,
                      child: FaIcon(
                        FontAwesomeIcons.building,
                        size: 24,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: text.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (c.category.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getCategoryDisplayName(c.category),
                          style: text.labelMedium?.copyWith(
                            color: color.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (c.location.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: color.outlineVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 14,
                  color: color.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.location,
                    style: text.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (c.phoneNumber.isNotEmpty || c.mobileNumber.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                FaIcon(
                  c.phoneNumber.isNotEmpty
                      ? FontAwesomeIcons.phone
                      : FontAwesomeIcons.mobileScreen,
                  size: 14,
                  color: color.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  c.phoneNumber.isNotEmpty ? c.phoneNumber : c.mobileNumber,
                  style: text.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEventBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.primary, color.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'EVENT',
            style: text.labelLarge?.copyWith(
              color: color.onPrimary.withValues(alpha: 0.8),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PhilGo + ${_company!.name}',
            style: text.headlineSmall?.copyWith(
              color: color.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            // "Join Event"
            '이벤트 참여'.tr(),
            style: text.bodyLarge?.copyWith(
              color: color.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.surfaceContainerLowest,
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: QrImageView(
            data: _companyUrl,
            version: QrVersions.auto,
            size: 240,
            backgroundColor: Colors.white,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: color.onSurface,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: color.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotApprovedMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightClockRotateLeft,
              size: 56,
              color: color.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              // "QR code for this business is not yet available.\nPlease wait for admin approval."
              '이 업소의 QR 코드는 아직 사용할 수 없습니다.\n관리자 승인을 기다려 주세요.'.tr(),
              style: text.bodyLarge?.copyWith(color: color.onSurfaceVariant),
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

  Widget _buildFraudWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.error.withValues(alpha: 0.08),
            color.error.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.error.withValues(alpha: 0.25),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightTriangleExclamation,
            size: 18,
            color: color.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              // "Warning: Businesses that misuse this QR code will be removed from the directory."
              '주의: 본 QR 코드를 부정 사용하는 업소는 업소 목록에서 삭제가 됩니다.'.tr(),
              style: text.bodyMedium?.copyWith(
                color: color.error,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.surface,
          border: Border(
            top: BorderSide(color: color.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareCompany,
                icon: FaIcon(
                  FontAwesomeIcons.lightShareNodes,
                  size: 14,
                  color: color.onSurface,
                ),
                // "Share"
                label: Text('공유'.tr()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: _downloadQrCode,
                icon: FaIcon(
                  FontAwesomeIcons.lightDownload,
                  size: 14,
                  color: color.onPrimary,
                ),
                // "Download"
                label: Text('다운로드'.tr()),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => CompanyViewScreen.push(
                  context,
                  company: CompanyModel.minimal(idx: widget.companyIdx),
                ),
                icon: FaIcon(
                  FontAwesomeIcons.lightBuilding,
                  size: 14,
                  color: color.onSurface,
                ),
                // "View Business"
                label: Text('업소 보기'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
