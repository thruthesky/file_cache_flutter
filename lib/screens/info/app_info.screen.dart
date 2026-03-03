/// 앱 정보 화면 (App Info Screen)
///
/// 앱의 버전, 빌드 번호, API 서버 주소 등 기본 정보를 표시합니다.
/// Displays basic app information such as version, build number, and API server URL.
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 앱 정보 화면 (App Info Screen)
///
/// 앱 버전, 빌드 번호, API 서버 주소를 간단히 표시합니다.
class AppInfoScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/app-info';

  const AppInfoScreen({super.key});

  /// 화면 이동 헬퍼 메서드 (Navigation helper method)
  static void push(BuildContext context) {
    context.push(routeName);
  }

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  /// 앱 패키지 정보 (App package info)
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  /// 앱 정보 로드 (Load app information)
  Future<void> _loadAppInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      debugPrint('[AppInfoScreen] 앱 정보 로드 오류: $e');
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final lo = Lo.of(context)!;
    final isAdmin = context.select<PhilgoState, bool>((s) => s.isAdmin);

    return Scaffold(
      appBar: AppBar(title: Text(lo.appInfoTitle), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [앱 정보 섹션] - App Information Section
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.mobileScreen,
              title: lo.appInfoTitle,
            ),
            _buildInfoCard(
              context,
              children: [
                _buildInfoRow(lo.appName, _packageInfo?.appName ?? '-'),
                _buildInfoRow(lo.version, _packageInfo?.version ?? '-'),
                _buildInfoRow(lo.buildNumber, _packageInfo?.buildNumber ?? '-'),
              ],
            ),
            SizedBox(height: sp.s24),

            /// [API 서버 정보 섹션] - API Server Information Section
            /// 관리자에게만 표시 (Only visible to admins)
            if (isAdmin) ...[
              _buildSectionHeader(
                context,
                icon: FontAwesomeIcons.server,
                title: lo.apiServerTitle,
              ),
              _buildInfoCard(
                context,
                children: [
                  _buildInfoRow(
                    lo.apiServerAddress,
                    PhilgoConfig.v7ApiEndpoint,
                  ),
                  _buildInfoRow(lo.phpApiAddress, PhilgoConfig.phpApiUrl),
                  _buildInfoRow(
                    lo.fileServerAddress,
                    PhilgoConfig.fileServerUrl,
                  ),
                ],
              ),
              SizedBox(height: sp.s24),

              /// [환경 정보 섹션] - Environment Information Section
              /// 관리자에게만 표시 (Only visible to admins)
              _buildSectionHeader(
                context,
                icon: FontAwesomeIcons.gear,
                title: lo.environmentTitle,
              ),
              _buildInfoCard(
                context,
                children: [
                  _buildInfoRow(
                    lo.environmentMode,
                    PhilgoConfig.isProduction ? 'Production' : 'Development',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        children: [
          FaIcon(icon, size: 18, color: scheme.primary),
          SizedBox(width: sp.s8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 카드 빌드 (Build info card)
  Widget _buildInfoCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// 정보 행 빌드 (Build info row)
  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
