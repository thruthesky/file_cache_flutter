import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:philgo/screens/company/company.qr_code_scanned.screen.dart';

/// QR 코드 스캐너 화면 (QR Scanner Screen)
///
/// 업소 이벤트 참여를 위해 QR 코드를 스캔하는 화면.
/// mobile_scanner 패키지를 사용하여 카메라 프리뷰를 표시하고,
/// QR 코드 인식 시 URL에서 idx, verification_id를 파싱하여
/// CompanyQrCodeScannedScreen으로 이동한다.
class QrScannerScreen extends StatefulWidget {
  static const String routeName = '/qr-scanner';

  /// 화면 이동 헬퍼
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController _controller;

  /// 중복 스캔 방지 플래그
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

  /// QR 코드 감지 콜백
  /// URL에서 idx, verification_id를 파싱하여 결과 화면으로 이동
  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing || !mounted) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final rawValue = barcode.rawValue!;
    debugPrint('[QR] rawValue: $rawValue');

    /// URL 파싱하여 idx, verification_id 추출
    final uri = Uri.tryParse(rawValue);
    debugPrint('[QR] uri: $uri');
    debugPrint('[QR] uri.scheme: ${uri?.scheme}');
    debugPrint('[QR] uri.host: ${uri?.host}');
    debugPrint('[QR] uri.path: ${uri?.path}');
    debugPrint('[QR] uri.queryParameters: ${uri?.queryParameters}');

    if (uri == null) {
      debugPrint('[QR] ERROR: Uri.tryParse 실패 - rawValue를 파싱할 수 없음');
      _showInvalidQrSnackBar();
      return;
    }

    /// 쿼리 파라미터에서 idx, verification_id 추출
    /// URL 형식: https://philgo.com/company/qr-code-scanned.php?idx={idx}&verification_id={vid}
    /// 또는 code 파라미터 사용: ?code={verification_id}
    final idxStr = uri.queryParameters['idx'];
    final verificationId = uri.queryParameters['verification_id'] ??
        uri.queryParameters['code'] ??
        '';

    final idx = int.tryParse(idxStr ?? '') ?? 0;

    debugPrint('[QR] idxStr: $idxStr, idx: $idx');
    debugPrint('[QR] verificationId: $verificationId');

    if (idx == 0 || verificationId.isEmpty) {
      debugPrint('[QR] ERROR: idx=$idx, verificationId=$verificationId - 유효하지 않음');
      _showInvalidQrSnackBar();
      return;
    }

    /// 중복 스캔 방지
    _isProcessing = true;

    /// CompanyQrCodeScannedScreen으로 이동
    CompanyQrCodeScannedScreen.push(context, idx, verificationId);
  }

  /// 유효하지 않은 QR 코드 스낵바 표시
  void _showInvalidQrSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('유효하지 않은 QR 코드입니다.'),
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
        title: const Text('QR 코드 스캔'),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          /// 카메라 프리뷰
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
                      '카메라를 사용할 수 없습니다.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          /// 스캔 가이드 오버레이
          _buildScanOverlay(scheme, theme),
        ],
      ),
    );
  }

  /// 스캔 가이드 오버레이: 중앙 사각형 프레임 + 안내 텍스트
  Widget _buildScanOverlay(ColorScheme scheme, ThemeData theme) {
    return Column(
      children: [
        const Spacer(flex: 2),

        /// 스캔 프레임
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

        /// 안내 텍스트
        Text(
          '업소의 QR 코드를 프레임 안에 맞춰주세요',
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
