import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/emergency_contacts.data.dart';
import 'package:philgo/data/models/contact_item.model.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 경찰서 연락처 화면 (Police Station Contact Screen)
///
/// 필리핀 주요 경찰서 연락처 정보를 제공합니다.
/// Provides Philippine police station contact information.
class PoliceStationScreen extends StatelessWidget {
  static const String routeName = '/PoliceStation';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const PoliceStationScreen({super.key});

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
              FontAwesomeIcons.buildingShield,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.quickMenuPoliceStation),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [긴급 신고 배너]
            _buildEmergencyBanner(context),

            SizedBox(height: sp.s24),

            /// [필리핀 긴급 번호 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.siren,
              title: '필리핀 긴급 번호',
              isEmergency: true,
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(
              context,
              EmergencyContactsData.emergencyNumbers
                  .where(
                    (c) =>
                        c.name.contains('경찰') ||
                        c.name.contains('PNP') ||
                        c.name.contains('핫라인'),
                  )
                  .toList(),
            ),

            SizedBox(height: sp.s24),

            /// [경찰서 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.buildingShield,
              title: '주요 경찰서',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(context, EmergencyContactsData.policeStations),

            SizedBox(height: sp.s24),

            /// [한인파출소 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.shieldCheck,
              title: '한인파출소',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(
              context,
              EmergencyContactsData.koreanAssociation
                  .where((c) => c.name.contains('파출소'))
                  .toList(),
            ),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 긴급 배너 빌드
  Widget _buildEmergencyBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.error, scheme.error.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                FontAwesomeIcons.triangleExclamation,
                size: 24,
                color: scheme.onError,
              ),
              SizedBox(width: sp.s12),
              Text(
                '긴급 신고',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onError,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickDialButton(context, '911', '통합 긴급'),
              _buildQuickDialButton(context, '117', '경찰'),
            ],
          ),
        ],
      ),
    );
  }

  /// 빠른 전화 버튼 빌드
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
        padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
        decoration: BoxDecoration(
          color: scheme.onError.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onError,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onError.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isEmergency = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final bgColor = isEmergency
        ? scheme.errorContainer
        : scheme.primaryContainer;
    final iconColor = isEmergency
        ? scheme.onErrorContainer
        : scheme.onPrimaryContainer;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: iconColor),
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

  /// 연락처 카드 빌드
  Widget _buildContactCards(BuildContext context, List<ContactItem> contacts) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: contacts.map((contact) {
        final bgColor = contact.isEmergency
            ? scheme.errorContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerLow;
        final iconBgColor = contact.isEmergency
            ? scheme.error
            : scheme.primaryContainer;
        final iconColor = contact.isEmergency
            ? scheme.onError
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
                        Text(
                          contact.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (contact.description != null) ...[
                          SizedBox(height: sp.s4),
                          Text(
                            contact.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
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
                                size: 12,
                                color: scheme.outline,
                              ),
                              SizedBox(width: sp.s4),
                              Expanded(
                                child: Text(
                                  contact.address!,
                                  style: theme.textTheme.labelSmall?.copyWith(
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
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 전화번호 버튼 빌드
  Widget _buildPhoneButton(
    BuildContext context,
    String phone,
    bool isEmergency,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final bgColor = isEmergency ? scheme.error : scheme.primaryContainer;
    final textColor = isEmergency ? scheme.onError : scheme.onPrimaryContainer;

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

  /// 전화 걸기
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// 클립보드에 복사
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
