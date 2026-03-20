import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:philgo/user/user.service.dart';

/// 앱 정보 화면
class AppInfoScreen extends StatefulWidget {
  static const String routeName = '/app-info';

  const AppInfoScreen({super.key});

  static void push(BuildContext context) {
    context.push(routeName);
  }

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('[AppInfoScreen] 앱 정보 로드 오류: $e');
    }
    if (mounted) setState(() {});
  }

  bool get _isAdmin {
    final uid = UserService.currentUser?.uid ?? '';
    if (uid.isEmpty) return false;
    final settings = SettingsState.of(context).settings;
    return settings?.adminUids.contains(uid) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('앱 정보'.tr()), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 앱 정보 섹션
            _buildSectionHeader(
              icon: FontAwesomeIcons.mobileScreen,
              title: '앱 정보'.tr(),
            ),
            _buildInfoCard(
              children: [
                _buildInfoRow('앱 이름'.tr(), _packageInfo?.appName ?? '-'),
                _buildInfoRow('버전'.tr(), _packageInfo?.version ?? '-'),
                _buildInfoRow('빌드 번호'.tr(), _packageInfo?.buildNumber ?? '-'),
              ],
            ),
            const SizedBox(height: 24),

            /// API 서버 정보 (관리자만)
            if (_isAdmin) ...[
              _buildSectionHeader(
                icon: FontAwesomeIcons.server,
                title: 'API 서버 정보'.tr(),
              ),
              _buildInfoCard(
                children: [
                  _buildInfoRow('API 서버 주소'.tr(), Config.v7ApiEndpoint),
                  _buildInfoRow('서버 베이스 URL'.tr(), Config.v7BaseUrl),
                ],
              ),
              const SizedBox(height: 24),

              /// 환경 정보 (관리자만)
              _buildSectionHeader(
                icon: FontAwesomeIcons.gear,
                title: '환경 정보'.tr(),
              ),
              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    '환경 모드'.tr(),
                    Config.v7ApiEndpoint.contains('local')
                        ? 'Development'
                        : 'Production',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          FaIcon(icon, size: 18, color: color.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: text.bodyMedium?.copyWith(color: color.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
