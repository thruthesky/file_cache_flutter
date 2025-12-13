import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 연락처 아이템 데이터 클래스 (Contact Item Data Class)
///
/// 각 연락처의 아이콘, 이름, 전화번호, 설명을 담습니다.
/// Contains icon, name, phone number, and description for each contact.
class _ContactItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 이름 (Name)
  final String name;

  /// 전화번호 목록 (Phone numbers)
  final List<String> phones;

  /// 부가 설명 (Description - optional)
  final String? description;

  /// 주소 (Address - optional)
  final String? address;

  /// 이메일 (Email - optional)
  final String? email;

  /// 홈페이지 (Website - optional)
  final String? website;

  /// 긴급 여부 (Is emergency)
  final bool isEmergency;

  const _ContactItem({
    required this.icon,
    required this.name,
    required this.phones,
    this.description,
    this.address,
    this.email,
    this.website,
    this.isEmergency = false,
  });
}

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
  /// 필리핀 긴급 번호 (Philippine Emergency Numbers)
  static const List<_ContactItem> _emergencyNumbers = [
    _ContactItem(
      icon: FontAwesomeIcons.lightPhoneVolume,
      name: '긴급 핫라인 (National Emergency)',
      phones: ['911'],
      description: '경찰, 소방, 앰뷸런스 통합',
      isEmergency: true,
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShieldHalved,
      name: '필리핀 국립경찰 (PNP)',
      phones: ['117', '(02) 8722-0650', '0917-847-5757'],
      description: 'Text hotline: 0917-847-5757',
      isEmergency: true,
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightFireExtinguisher,
      name: '필리핀 소방청 (BFP)',
      phones: ['116', '(02) 8426-0219', '(02) 8426-0246'],
      isEmergency: true,
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightTruckMedical,
      name: '앰뷸런스',
      phones: ['911', '112'],
      isEmergency: true,
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightKitMedical,
      name: '필리핀 적십자 (Red Cross)',
      phones: ['143'],
      isEmergency: true,
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightTrafficLight,
      name: '메트로마닐라개발청 (MMDA)',
      phones: ['136'],
      description: '교통사고, 도로 긴급상황',
    ),
  ];

  /// 대한민국 공관 (Korean Embassy/Consulate)
  static const List<_ContactItem> _koreanEmbassy = [
    _ContactItem(
      icon: FontAwesomeIcons.lightHeadset,
      name: '외교부 영사 콜센터 (24시간)',
      phones: ['00800-2100-0404', '+82-2-3210-0404'],
      description: '해외에서: 00800-2100-0404 (무료)\n유료: +82-2-3210-0404',
      isEmergency: true,
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightLandmarkFlag,
      name: '주필리핀 대한민국 대사관',
      phones: ['+63-2-8856-9210', '+63-917-817-5703'],
      description: '대표전화 (근무시간)\n긴급당직 (근무시간 외)',
      address: '122 Upper McKinley Road, McKinley Town Center,\nFort Bonifacio, Taguig City 1634',
      email: 'philippines@mofa.go.kr',
      website: 'http://overseas.mofa.go.kr/ph-ko/index.do',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightBuilding,
      name: '주세부 대한민국 분관',
      phones: ['+63-32-231-1516', '+63-917-808-3907'],
      description: '대표전화 (근무시간)\n긴급당직 (근무시간 외)',
      address: '12th Floor Chinabank Corporate Center,\nCebu Business Park, Mabolo, Cebu City',
      email: 'phi_cebu2015@mofa.go.kr',
      website: 'http://overseas.mofa.go.kr/ph-cebu-ko/index.do',
    ),
  ];

  /// 한인회 연락처 (Korean Association)
  static const List<_ContactItem> _koreanAssociation = [
    _ContactItem(
      icon: FontAwesomeIcons.lightPeopleGroup,
      name: '필리핀 한인총연합회 (마닐라)',
      phones: ['+63-2-8886-4848', '+63-917-886-4848'],
      description: '사건사고 긴급: +63-917-886-4848',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '세부 한인회',
      phones: ['+63-32-505-5761'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '중부루손한인회 (클락/앙헬레스)',
      phones: ['+63-45-598-0571', '0917-893-1355'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '남부(알라방) 한인회',
      phones: ['+63-2-7945-0221'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '바기오 한인회',
      phones: ['+63-74-423-2099'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '다바오 한인회',
      phones: ['0906-310-0409'],
      description: '카카오톡: pf.kakao.com/_xexczrM',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      name: '한인파출소',
      phones: ['0915-242-3926'],
    ),
  ];

  /// 경찰서 (Police Stations)
  static const List<_ContactItem> _policeStations = [
    _ContactItem(
      icon: FontAwesomeIcons.lightBuildingShield,
      name: '메트로마닐라 수도경찰청',
      phones: ['+63-2-8838-0251'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Manila City 경찰청',
      phones: ['+63-2-8523-5611'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Makati City 경찰서',
      phones: ['+63-2-8843-7971', '+63-2-8887-6642'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Quezon City 경찰청',
      phones: ['+63-2-8925-8417'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Pasay City 경찰서',
      phones: ['+63-2-8831-1359'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Cebu City 경찰서',
      phones: ['+63-32-256-0116'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Davao City 경찰서',
      phones: ['+63-82-224-1313'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Angeles City 경찰서',
      phones: ['+63-908-377-0144'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Baguio City 경찰서',
      phones: ['+63-74-442-7944'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHandcuffs,
      name: '납치전담 (Anti-Kidnapping)',
      phones: ['+63-2-8724-7378'],
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightCarBurst,
      name: '차량강도 (Highway Patrol)',
      phones: ['+63-2-8723-0401'],
      description: '내선 5379',
    ),
  ];

  /// 병원 (Hospitals)
  static const List<_ContactItem> _hospitals = [
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Makati Medical Center',
      phones: ['+63-2-8888-8999'],
      address: 'Makati City',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: "St. Luke's Global Hospital",
      phones: ['+63-2-8789-7700'],
      address: 'Fort Bonifacio, Taguig',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Manila Doctors Hospital',
      phones: ['+63-2-8558-0888'],
      address: 'Manila',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Asian Hospital',
      phones: ['+63-2-8771-9000'],
      address: 'Alabang',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Phil. Korean Friendship Hospital',
      phones: ['+63-46-419-1465', '+63-46-419-1714'],
      address: 'Cavite',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Chong Hwa Hospital',
      phones: ['+63-32-253-9409'],
      address: 'Cebu',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: "Davao Doctor's Hospital",
      phones: ['+63-82-222-8000'],
      address: 'Davao',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Baguio General Hospital',
      phones: ['+63-74-442-6230'],
      address: 'Baguio',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Angeles Medical Center',
      phones: ['+63-45-887-3139'],
      address: 'Angeles City',
    ),
  ];

  /// 기타 기관 (Other Agencies)
  static const List<_ContactItem> _otherAgencies = [
    _ContactItem(
      icon: FontAwesomeIcons.lightPassport,
      name: '필리핀 이민국 (BI)',
      phones: ['(02) 8524-3769', '(02) 8465-2400'],
      description: '비자 연장, 출입국 관련',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightCloudSunRain,
      name: '필리핀 기상청 (PAGASA)',
      phones: ['(02) 8284-0800'],
      description: '태풍, 날씨 정보',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightVolcano,
      name: '화산지진연구소 (PHILVOCS)',
      phones: ['(02) 8426-1468'],
      description: '지진, 화산 정보',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightHouseFloodWater,
      name: '재해위기관리위원회 (NDRRMC)',
      phones: ['(02) 8421-1918', '(02) 8913-2786'],
      description: '자연재해, 재난 대응',
    ),
    _ContactItem(
      icon: FontAwesomeIcons.lightCarSide,
      name: '필리핀 교통부 (DOTr)',
      phones: ['7890', '(02) 8790-8300'],
      description: '교통 관련 문의',
    ),
  ];

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
            FaIcon(FontAwesomeIcons.lightPhoneVolume, size: 20, color: scheme.error),
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
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightSiren, title: '필리핀 긴급 번호', isEmergency: true),
            SizedBox(height: sp.s12),
            _buildContactCards(context, _emergencyNumbers),

            SizedBox(height: sp.s24),

            /// [대한민국 공관 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightLandmarkFlag, title: '대한민국 공관'),
            SizedBox(height: sp.s12),
            _buildContactCards(context, _koreanEmbassy),

            SizedBox(height: sp.s24),

            /// [한인회 연락처 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightPeopleGroup, title: '한인회 연락처'),
            SizedBox(height: sp.s12),
            _buildContactCards(context, _koreanAssociation),

            SizedBox(height: sp.s24),

            /// [경찰서 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightBuildingShield, title: '경찰서'),
            SizedBox(height: sp.s12),
            _buildContactCards(context, _policeStations),

            SizedBox(height: sp.s24),

            /// [병원 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightHospital, title: '병원'),
            SizedBox(height: sp.s12),
            _buildContactCards(context, _hospitals),

            SizedBox(height: sp.s24),

            /// [기타 기관 섹션]
            _buildSectionHeader(context, icon: FontAwesomeIcons.lightBuildings, title: '기타 기관'),
            SizedBox(height: sp.s12),
            _buildContactCards(context, _otherAgencies),

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
          colors: [
            scheme.error,
            scheme.error.withValues(alpha: 0.8),
          ],
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
              FaIcon(FontAwesomeIcons.lightTriangleExclamation, size: 24, color: scheme.onError),
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
  Widget _buildQuickDialButton(BuildContext context, String number, String label) {
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

    final bgColor = isEmergency ? scheme.errorContainer : scheme.primaryContainer;
    final iconColor = isEmergency ? scheme.onErrorContainer : scheme.onPrimaryContainer;

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
  Widget _buildContactCards(BuildContext context, List<_ContactItem> contacts) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: contacts.map((contact) {
        final bgColor = contact.isEmergency
            ? scheme.errorContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerLow;
        final iconBgColor = contact.isEmergency ? scheme.error : scheme.primaryContainer;
        final iconColor = contact.isEmergency ? scheme.onError : scheme.onPrimaryContainer;

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
                    child: Center(child: FaIcon(contact.icon, size: 18, color: iconColor)),
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
                              FaIcon(FontAwesomeIcons.lightLocationDot, size: 12, color: scheme.outline),
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
  Widget _buildPhoneButton(BuildContext context, String phone, bool isEmergency) {
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
              FaIcon(FontAwesomeIcons.lightClock, size: 18, color: scheme.onTertiaryContainer),
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
          _buildHoursRow(context, '일반 업무', '08:30 ~ 17:00 (월-금)'),
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
                FaIcon(FontAwesomeIcons.lightCircleExclamation, size: 14, color: scheme.error),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '근무시간 외 긴급상황: 긴급당직번호 이용',
                    style: theme.textTheme.bodySmall?.copyWith(
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onTertiaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          hours,
          style: theme.textTheme.bodySmall?.copyWith(
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
