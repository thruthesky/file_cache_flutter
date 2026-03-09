import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/emergency_contacts.data.dart';
import 'package:philgo/data/models/contact_item.model.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 한인회 연락처 화면 (Korean Association Contact Screen)
///
/// 필리핀 지역별 한인회 연락처 정보를 제공합니다.
/// Provides Korean Association contact information by region in the Philippines.
class KoreanAssociationScreen extends StatelessWidget {
  static const String routeName = '/KoreanAssociation';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const KoreanAssociationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;
    final l10n = Lo.of(context)!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.peopleGroup,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.quickMenuKoreanAssociation),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [한인총연합회 배너]
            _buildAssociationBanner(context),

            SizedBox(height: sp.s24),

            /// [지역별 한인회 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.peopleGroup,
              title: '지역별 한인회',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(
              context,
              EmergencyContactsData.koreanAssociation,
            ),

            SizedBox(height: sp.s24),

            /// [한인회 안내 섹션]
            _buildAssociationInfoSection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 한인총연합회 배너 빌드 (Build Korean Association Banner)
  /// UKCA (United Korean Community Association) 정보를 표시합니다.
  /// 전국 단위 연합회로 각 지역 한인회·교민 단체를 아우르는 역할을 합니다.
  Widget _buildAssociationBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 배너 헤더 (Banner Header)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.peopleGroup,
                size: 24,
                color: scheme.onPrimary,
              ),
              SizedBox(width: sp.s12),
              Text(
                '필리핀한인총연합회 (UKCA)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),

          /// 배너 설명 텍스트 (Banner Description Text)
          /// 전국 단위 연합회의 역할 설명
          Text(
            '필리핀 내 여러 지역 한인회·교민 단체를 아우르는 전국 단위 연합회',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s4),

          /// 주요 활동 요약 (Key Activities Summary)
          Text(
            '교민 공지 • 커뮤니티 정보 • 공공사업/행사 지원',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s12),

          /// 주소 정보 (Address Information)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  size: 14,
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
                SizedBox(width: sp.s8),
                Flexible(
                  child: Text(
                    'Suite 1104 Antel 2000 Corporate Center,\n121 Valero St., Salcedo Village, Makati City',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s12),

          /// 전화번호 버튼들 (Phone Number Buttons)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickDialButton(context, '+63-2-8886-4848', '대표'),
              _buildQuickDialButton(context, '+63-917-886-4848', '긴급'),
            ],
          ),
          SizedBox(height: sp.s8),

          /// 이메일 버튼 (Email Button)
          InkWell(
            onTap: () => _sendEmail('ukca@korea.com.ph'),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                color: scheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.envelope,
                    size: 14,
                    color: scheme.onPrimary,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    'ukca@korea.com.ph',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 빠른 전화 버튼 빌드 (Build Quick Dial Button)
  Widget _buildQuickDialButton(
    BuildContext context,
    String number,
    String label,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return InkWell(
      onTap: () => _makePhoneCall(number),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
        decoration: BoxDecoration(
          color: scheme.onPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            /// 전화번호 텍스트 (Phone Number Text)
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            Text(
              number,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onPrimary,
              ),
            ),

            /// 라벨 텍스트 (Label Text)
            /// labelSmall → labelMedium으로 변경하여 가독성 향상
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimary.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build Section Header)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
        ),
        SizedBox(width: sp.s12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 연락처 카드 빌드 (Build Contact Cards)
  Widget _buildContactCards(BuildContext context, List<ContactItem> contacts) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: contacts.map((contact) {
        final bgColor = contact.isEmergency
            ? scheme.primaryContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerLow;
        final iconBgColor = contact.isEmergency
            ? scheme.primary
            : scheme.primaryContainer;
        final iconColor = contact.isEmergency
            ? scheme.onPrimary
            : scheme.onPrimaryContainer;

        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 아이콘
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: FaIcon(contact.icon, size: 18, color: iconColor),
                    ),
                  ),
                  SizedBox(width: sp.s12),

                  /// 이름 및 설명
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 연락처 이름 (Contact Name)
                        /// titleSmall → titleMedium으로 변경하여 가독성 향상
                        Text(
                          contact.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (contact.description != null) ...[
                          SizedBox(height: sp.s4),

                          /// 연락처 설명 (Contact Description)
                          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                          Text(
                            contact.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (contact.address != null) ...[
                          SizedBox(height: sp.s4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 14,
                                color: scheme.outline,
                              ),
                              SizedBox(width: sp.s4),
                              Expanded(
                                /// 주소 텍스트 (Address Text)
                                /// labelSmall → bodySmall으로 변경하여 가독성 향상
                                child: Text(
                                  contact.address!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: scheme.outline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              /// 전화번호 버튼들
              SizedBox(height: sp.s8),
              Wrap(
                spacing: sp.s8,
                runSpacing: sp.s8,
                children: contact.phones.map((phone) {
                  return _buildPhoneButton(context, phone, contact.isEmergency);
                }).toList(),
              ),

              /// 이메일, 웹사이트
              if (contact.email != null || contact.website != null) ...[
                SizedBox(height: sp.s8),
                Wrap(
                  spacing: sp.s8,
                  runSpacing: sp.s8,
                  children: [
                    if (contact.email != null)
                      _buildLinkButton(
                        context,
                        icon: FontAwesomeIcons.envelope,
                        label: '이메일',
                        onTap: () => _sendEmail(contact.email!),
                      ),
                    if (contact.website != null)
                      _buildLinkButton(
                        context,
                        icon: FontAwesomeIcons.globe,
                        label: '홈페이지',
                        onTap: () => _openWebsite(contact.website!),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 전화번호 버튼 빌드 (Build Phone Button)
  Widget _buildPhoneButton(
    BuildContext context,
    String phone,
    bool isEmergency,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final bgColor = isEmergency ? scheme.primary : scheme.primaryContainer;
    final textColor = isEmergency
        ? scheme.onPrimary
        : scheme.onPrimaryContainer;

    return InkWell(
      onTap: () => _makePhoneCall(phone),
      onLongPress: () => _copyToClipboard(context, phone),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.phone, size: 12, color: textColor),
            SizedBox(width: sp.s4),
            Text(
              phone,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 링크 버튼 빌드 (Build Link Button)
  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: scheme.onSecondaryContainer),
            SizedBox(width: sp.s4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 한인회 안내 섹션 빌드 (Build Association Info Section)
  Widget _buildAssociationInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.circleInfo,
                size: 18,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),

              /// 안내 섹션 제목 (Info Section Title)
              /// titleSmall → titleMedium으로 변경하여 가독성 향상
              Text(
                '한인회 안내',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          _buildInfoRow(context, '주요 활동', '교민 지원, 문화 행사, 네트워킹'),
          SizedBox(height: sp.s8),
          _buildInfoRow(context, '긴급 지원', '사건사고 발생 시 24시간 긴급 연락'),
          SizedBox(height: sp.s8),
          _buildInfoRow(context, '가입 문의', '각 지역 한인회로 직접 연락'),
          SizedBox(height: sp.s12),

          /// 긴급 안내 텍스트 (Emergency Notice Text)
          /// labelSmall → bodySmall으로 변경하여 가독성 향상
          Text(
            '※ 긴급 상황 시 가까운 지역 한인회로 연락해 주세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.error,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행 빌드 (Build Info Row)
  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,

          /// 라벨 텍스트 (Label Text)
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          /// 값 텍스트 (Value Text)
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }

  /// 전화 걸기 (Make Phone Call)
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// 이메일 보내기 (Send Email)
  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  /// 웹사이트 열기 (Open Website)
  Future<void> _openWebsite(String url) async {
    final Uri websiteUri = Uri.parse(url);
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri, mode: LaunchMode.externalApplication);
    }
  }

  /// 클립보드에 복사 (Copy to Clipboard)
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text 복사됨'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
