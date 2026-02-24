import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// QR 코드 스캔 결과 화면 (Company QR Code Scanned Screen)
///
/// QR 코드 스캔으로 전달받은 업체 idx와 verification_id를 이용하여
/// 해당 업체의 정보를 조회하고 표시하는 화면입니다.
///
/// ### 라우트 파라미터:
/// - `idx`: 업체 고유 번호 (company idx)
/// - `verification_id`: QR 코드 인증 ID
class CompanyQrCodeScannedScreen extends StatefulWidget {
  static const String routeName = '/company/qr-code-scanned.php';

  /// 라우터에서 전달받은 업체 고유 번호
  final int idx;

  /// 라우터에서 전달받은 QR 코드 인증 ID
  final String verificationId;

  const CompanyQrCodeScannedScreen({
    super.key,
    required this.idx,
    required this.verificationId,
  });

  /// push 네비게이션 (쿼리 파라미터로 idx와 verification_id 전달)
  static Future<void> Function(BuildContext ctx, int idx, String verificationId)
      push = (ctx, idx, verificationId) => ctx.push(
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

  /// 업체 정보 로드 (Load company information by idx)
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          T.company,
          style: theme.textTheme.titleLarge,
        ),
        elevation: 0,
      ),
      body: _buildBody(scheme, theme),
    );
  }

  /// 화면 본문 빌드 (Build body based on loading/error/success state)
  Widget _buildBody(ColorScheme scheme, ThemeData theme) {
    /// 로딩 상태 (Loading state)
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

    /// 에러 상태 (Error state)
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
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
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

    /// 업체 정보 표시 (Display company information)
    if (company == null) {
      return const SizedBox.shrink();
    }

    final c = company!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 업체 타이틀 이미지 (Company title image)
          if (c.title_image_url.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                c.title_image_url,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          if (c.title_image_url.isNotEmpty) const SizedBox(height: 16),

          /// 업체 로고 + 이름 (Company logo and name)
          Row(
            children: [
              if (c.logo_url.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    c.logo_url,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 56,
                      height: 56,
                      color: scheme.surfaceContainerHighest,
                      child: FaIcon(
                        FontAwesomeIcons.building,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              if (c.logo_url.isNotEmpty) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: theme.textTheme.titleLarge,
                    ),
                    if (c.title.isNotEmpty)
                      Text(
                        c.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          /// 카테고리 & 위치 태그 (Category & location tags)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (c.category.isNotEmpty)
                Chip(
                  avatar: FaIcon(
                    FontAwesomeIcons.tag,
                    size: 14,
                    color: scheme.primary,
                  ),
                  label: Text(c.category),
                  backgroundColor: scheme.surfaceContainerLow,
                  side: BorderSide.none,
                ),
              if (c.location.isNotEmpty)
                Chip(
                  avatar: FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 14,
                    color: scheme.primary,
                  ),
                  label: Text(c.location),
                  backgroundColor: scheme.surfaceContainerLow,
                  side: BorderSide.none,
                ),
            ],
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 24),

          /// 연락처 정보 섹션 (Contact information section)
          if (_hasContactInfo(c)) ...[
            _buildSectionHeader(
              theme,
              scheme,
              FontAwesomeIcons.addressBook,
              T.contactInformation,
            ),
            const SizedBox(height: 12),
            _buildContactCard(c, scheme, theme),
            const SizedBox(height: 24),
          ],

          /// 주소 섹션 (Address section)
          if (c.address.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              scheme,
              FontAwesomeIcons.mapLocationDot,
              T.address,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                c.address,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
          ],

          /// 설명 섹션 (Description section)
          if (c.description.isNotEmpty) ...[
            _buildSectionHeader(
              theme,
              scheme,
              FontAwesomeIcons.circleInfo,
              T.description,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                c.description,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
          ],

          /// QR 인증 정보 (QR verification info)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.qrcode,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification ID',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        widget.verificationId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 24),

          /// 업체 상세보기 버튼 (Navigate to full company view)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  CompanyViewScreen.push(context, widget.idx),
              icon: const FaIcon(FontAwesomeIcons.arrowRight, size: 16),
              label: Text(T.viewDetails),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 연락처 정보가 있는지 확인 (Check if any contact info exists)
  bool _hasContactInfo(Company c) {
    return c.phone_number.isNotEmpty ||
        c.mobile_number.isNotEmpty ||
        c.kakaotalk_id.isNotEmpty ||
        c.telegram_id.isNotEmpty;
  }

  /// 섹션 헤더 빌드 (Build section header with icon and title)
  Widget _buildSectionHeader(
    ThemeData theme,
    ColorScheme scheme,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        FaIcon(icon, size: 16, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 연락처 카드 빌드 (Build contact information card)
  Widget _buildContactCard(Company c, ColorScheme scheme, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (c.phone_number.isNotEmpty)
            _buildContactRow(
              scheme,
              theme,
              FontAwesomeIcons.phone,
              T.phoneNumber,
              c.phone_number,
            ),
          if (c.mobile_number.isNotEmpty)
            _buildContactRow(
              scheme,
              theme,
              FontAwesomeIcons.mobile,
              T.mobileNumber,
              c.mobile_number,
            ),
          if (c.kakaotalk_id.isNotEmpty)
            _buildContactRow(
              scheme,
              theme,
              FontAwesomeIcons.comment,
              T.kakaoId,
              c.kakaotalk_id,
            ),
          if (c.telegram_id.isNotEmpty)
            _buildContactRow(
              scheme,
              theme,
              FontAwesomeIcons.paperPlane,
              T.telegramId,
              c.telegram_id,
            ),
        ],
      ),
    );
  }

  /// 연락처 행 빌드 (Build single contact row)
  Widget _buildContactRow(
    ColorScheme scheme,
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          FaIcon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
