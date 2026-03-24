import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:philgo/company/qr/company.qr_code_scanned.screen.dart';

/// QR 코드 스캐너 화면
///
/// 업소 이벤트 참여를 위해 QR 코드를 스캔하는 화면.
/// mobile_scanner 패키지를 사용하여 카메라 프리뷰를 표시하고,
/// QR 코드 인식 시 URL에서 code를 파싱하여
/// CompanyQrCodeScannedScreen으로 이동한다.
class QrScannerScreen extends StatefulWidget {
  static const String routeName = '/qr-scanner';

  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.qrCode],
    );
    unawaited(_controller.start());
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _controller.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    final uri = Uri.tryParse(rawValue);

    if (uri == null) {
      _showInvalidQrSnackBar();
      return;
    }

    final code = uri.queryParameters['code'] ?? '';
    final idxStr = uri.queryParameters['idx'];
    final idx = int.tryParse(idxStr ?? '') ?? 0;

    if (code.isEmpty) {
      _showInvalidQrSnackBar();
      return;
    }

    _isProcessing = true;

    if (mounted) {
      context.pushReplacement(
        '${CompanyQrCodeScannedScreen.routeName}?idx=$idx&code=$code',
      );
    }
  }

  void _showInvalidQrSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // "Invalid QR code."
        content: Text('유효하지 않은 QR 코드입니다.'.tr()),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // "Scan QR Code"
        title: Text('QR 코드 스캔'.tr()),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.cameraRotate,
                      size: 48,
                      color: scheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      // "Camera is unavailable."
                      '카메라를 사용할 수 없습니다.'.tr(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          _buildScanOverlay(scheme, theme),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(ColorScheme scheme, ThemeData theme) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.8),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.03, duration: 1200.ms),
        ),
        const SizedBox(height: 24),
        Text(
          // "Align the business QR code within the frame"
          '업소의 QR 코드를 프레임 안에 맞춰주세요'.tr(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        const Spacer(flex: 3),
      ],
    );
  }
}
