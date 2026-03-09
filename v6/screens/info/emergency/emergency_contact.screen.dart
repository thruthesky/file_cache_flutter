import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/emergency_contacts.data.dart';
import 'package:philgo/data/models/contact_item.model.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 필리핀 긴급 연락처 화면 (Philippines Emergency Contact Screen)
///
/// 필리핀에서 필요한 긴급 연락처 정보를 제공합니다.
/// Provides emergency contact information needed in the Philippines.
class EmergencyContactScreen extends StatefulWidget {
  static const String routeName = '/EmergencyContact';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightPhoneVolume,
              size: 20,
              color: scheme.error,
            ),
            SizedBox(width: sp.s8),
            const Text('🇵🇭 긴급 연락처'),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [긴급 연락처 배너]
            _buildEmergencyBanner(context),

            SizedBox(height: sp.s24),

            /// [필리핀 긴급 번호 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightSiren,
              title: '필리핀 긴급 번호',
              isEmergency: true,
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(context, EmergencyContactsData.emergencyNumbers),

            SizedBox(height: sp.s24),

            /// [대한민국 공관 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLandmarkFlag,
              title: '대한민국 공관',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(context, EmergencyContactsData.koreanEmbassy),

            SizedBox(height: sp.s24),

            /// [한인회 연락처 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPeopleGroup,
              title: '한인회 연락처',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(
              context,
              EmergencyContactsData.koreanAssociation,
            ),

            SizedBox(height: sp.s24),

            /// [경찰서 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuildingShield,
              title: '경찰서',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(context, EmergencyContactsData.policeStations),

            SizedBox(height: sp.s24),

            /// [병원 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHospital,
              title: '병원',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(context, EmergencyContactsData.hospitals),

            SizedBox(height: sp.s24),

            /// [기타 기관 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuildings,
              title: '기타 기관',
            ),
            SizedBox(height: sp.s12),
            _buildContactCards(context, EmergencyContactsData.otherAgencies),

            SizedBox(height: sp.s24),

            /// [대사관 업무시간 안내]
            _buildEmbassyHoursSection(context),

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
                FontAwesomeIcons.lightTriangleExclamation,
                size: 24,
                color: scheme.onError,
              ),
              SizedBox(width: sp.s12),
              Text(
                '긴급 상황 시',
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
              _buildQuickDialButton(context, '116', '소방'),
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
            /// labelSmall → labelMedium으로 변경하여 가독성 향상
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
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
                                FontAwesomeIcons.lightLocationDot,
                                size: 12,
                                color: scheme.outline,
                              ),
                              SizedBox(width: sp.s4),
                              /// labelSmall → labelMedium으로 변경하여 가독성 향상
                              Expanded(
                                child: Text(
                                  contact.address!,
                                  style: theme.textTheme.labelMedium?.copyWith(
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
                        icon: FontAwesomeIcons.lightEnvelope,
                        label: '이메일',
                        onTap: () => _sendEmail(contact.email!),
                      ),
                    if (contact.website != null)
                      _buildLinkButton(
                        context,
                        icon: FontAwesomeIcons.lightGlobe,
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.lightPhone, size: 12, color: textColor),
            SizedBox(width: sp.s8),
            Text(
              phone,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 링크 버튼 빌드
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: scheme.onSecondaryContainer),
            SizedBox(width: sp.s8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 대사관 업무시간 섹션 빌드
  Widget _buildEmbassyHoursSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightClock,
                size: 18,
                color: scheme.onTertiaryContainer,
              ),
              SizedBox(width: sp.s8),
              Text(
                '대사관 업무시간',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 업무시간: 08:00~17:00 (월-금)
          _buildHoursRow(context, '일반 업무', '08:00 ~ 17:00 (월-금)'),
          SizedBox(height: sp.s8),
          _buildHoursRow(context, '여권/공증', '09:00-12:00, 13:30-16:00'),
          SizedBox(height: sp.s8),
          _buildHoursRow(context, '비자 접수', '08:30 ~ 11:00'),
          SizedBox(height: sp.s8),
          _buildHoursRow(context, '비자 교부', '13:30 ~ 16:00'),
          SizedBox(height: sp.s12),
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleExclamation,
                  size: 14,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '근무시간 외 긴급상황: 긴급당직번호 이용',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 업무시간 행 빌드
  Widget _buildHoursRow(BuildContext context, String label, String hours) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onTertiaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          hours,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onTertiaryContainer,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 전화 걸기
  Future<void> _makePhoneCall(String phoneNumber) async {
    /// 전화번호에서 공백, 괄호 제거
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\(\)\-]'), '');
    final uri = Uri.parse('tel:$cleanNumber');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 이메일 보내기
  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 웹사이트 열기
  Future<void> _openWebsite(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 클립보드에 복사
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text 복사됨'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
