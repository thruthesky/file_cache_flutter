import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:philgo/globals.dart';

/// 버전 및 디바이스 정보 화면
class VersionScreen extends StatefulWidget {
  static const String routeName = '/version';

  const VersionScreen({super.key});

  static void push(BuildContext context) {
    context.push(routeName);
  }

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  PackageInfo? _packageInfo;
  AndroidDeviceInfo? _androidInfo;
  IosDeviceInfo? _iosInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (Platform.isAndroid) {
        _androidInfo = await _deviceInfoPlugin.androidInfo;
      } else if (Platform.isIOS) {
        _iosInfo = await _deviceInfoPlugin.iosInfo;
      }
    } catch (e) {
      debugPrint('[VersionScreen] 디바이스 정보 로드 오류: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('버전 정보'.tr()), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      _buildInfoRow(
                        '앱 이름'.tr(),
                        _packageInfo?.appName ?? '-',
                      ),
                      _buildInfoRow(
                        '패키지 이름'.tr(),
                        _packageInfo?.packageName ?? '-',
                      ),
                      _buildInfoRow(
                        '버전'.tr(),
                        _packageInfo?.version ?? '-',
                      ),
                      _buildInfoRow(
                        '빌드 번호'.tr(),
                        _packageInfo?.buildNumber ?? '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// 디바이스 정보
                  if (Platform.isAndroid && _androidInfo != null)
                    _buildAndroidInfo()
                  else if (Platform.isIOS && _iosInfo != null)
                    _buildIosInfo(),

                  /// 개발자 모드 (Easter egg)
                  if (isDeveloperModeEnabled) ...[
                    _buildSectionHeader(
                      icon: FontAwesomeIcons.bug,
                      title: 'Test',
                    ),
                    _buildInfoCard(
                      children: [
                        _buildWidgetInfoRow(
                          'Crash Test',
                          ElevatedButton(
                            onPressed: () => throw Exception(),
                            child: const Text('Throw Test Exception'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildAndroidInfo() {
    final info = _androidInfo!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 기본 정보
        _buildSectionHeader(
          icon: FontAwesomeIcons.android,
          title: '기본 정보'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('디바이스 이름'.tr(), info.name),
            _buildInfoRow('모델'.tr(), info.model),
            _buildInfoRow('브랜드'.tr(), info.brand),
            _buildInfoRow('제조사'.tr(), info.manufacturer),
            _buildInfoRow('제품'.tr(), info.product),
            _buildInfoRow('디바이스'.tr(), info.device),
            _buildInfoRow('하드웨어'.tr(), info.hardware),
            _buildInfoRow('보드'.tr(), info.board),
            _buildInfoRow(
              '물리 디바이스'.tr(),
              info.isPhysicalDevice ? '예'.tr() : '아니오'.tr(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// 시스템 정보
        _buildSectionHeader(
          icon: FontAwesomeIcons.gear,
          title: '시스템 정보'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('Android 버전'.tr(), info.version.release),
            _buildInfoRow('SDK Int', info.version.sdkInt.toString()),
            _buildInfoRow(
              '보안 패치'.tr(),
              info.version.securityPatch ?? '-',
            ),
            _buildInfoRow('디스플레이'.tr(), info.display),
            _buildInfoRow('ID', info.id),
            _buildInfoRow('핑거프린트'.tr(), info.fingerprint),
            _buildInfoRow('호스트'.tr(), info.host),
            _buildInfoRow('부트로더'.tr(), info.bootloader),
            _buildInfoRow('타입'.tr(), info.type),
            _buildInfoRow('태그'.tr(), info.tags),
          ],
        ),
        const SizedBox(height: 24),

        /// 메모리 및 저장소
        _buildSectionHeader(
          icon: FontAwesomeIcons.memory,
          title: '메모리 및 저장소'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('물리 RAM'.tr(), '${info.physicalRamSize} MB'),
            _buildInfoRow('가용 RAM'.tr(), '${info.availableRamSize} MB'),
            _buildInfoRow(
              '저메모리 디바이스'.tr(),
              info.isLowRamDevice ? '예'.tr() : '아니오'.tr(),
            ),
            _buildInfoRow('전체 디스크'.tr(), _formatBytes(info.totalDiskSize)),
            _buildInfoRow('여유 디스크'.tr(), _formatBytes(info.freeDiskSize)),
          ],
        ),
        const SizedBox(height: 24),

        /// 지원 ABI
        _buildSectionHeader(
          icon: FontAwesomeIcons.microchip,
          title: '지원 ABI'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('지원 ABI'.tr(), info.supportedAbis.join(', ')),
            _buildInfoRow(
              '32비트 ABI'.tr(),
              info.supported32BitAbis.join(', '),
            ),
            _buildInfoRow(
              '64비트 ABI'.tr(),
              info.supported64BitAbis.join(', '),
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// 시스템 기능
        _buildSectionHeader(
          icon: FontAwesomeIcons.listCheck,
          title: '시스템 기능'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildExpandableInfoRow(
              '시스템 기능'.tr(),
              info.systemFeatures.join('\n'),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildIosInfo() {
    final info = _iosInfo!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 기본 정보
        _buildSectionHeader(
          icon: FontAwesomeIcons.apple,
          title: '기본 정보'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('디바이스 이름'.tr(), info.name),
            _buildInfoRow('모델'.tr(), info.model),
            _buildInfoRow('모델 이름'.tr(), info.modelName),
            _buildInfoRow('로컬 모델'.tr(), info.localizedModel),
            _buildInfoRow(
              '물리 디바이스'.tr(),
              info.isPhysicalDevice ? '예'.tr() : '아니오'.tr(),
            ),
            _buildInfoRow(
              'Mac에서 iOS 앱'.tr(),
              info.isiOSAppOnMac ? '예'.tr() : '아니오'.tr(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// 시스템 정보
        _buildSectionHeader(
          icon: FontAwesomeIcons.gear,
          title: '시스템 정보'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('시스템 이름'.tr(), info.systemName),
            _buildInfoRow('시스템 버전'.tr(), info.systemVersion),
            _buildInfoRow(
              'Vendor ID'.tr(),
              info.identifierForVendor ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 24),

        /// 메모리 및 저장소
        _buildSectionHeader(
          icon: FontAwesomeIcons.memory,
          title: '메모리 및 저장소'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('물리 RAM'.tr(), '${info.physicalRamSize} MB'),
            _buildInfoRow('가용 RAM'.tr(), '${info.availableRamSize} MB'),
            _buildInfoRow('전체 디스크'.tr(), _formatBytes(info.totalDiskSize)),
            _buildInfoRow('여유 디스크'.tr(), _formatBytes(info.freeDiskSize)),
          ],
        ),
        const SizedBox(height: 24),

        /// UTSNAME 정보
        _buildSectionHeader(
          icon: FontAwesomeIcons.terminal,
          title: 'UTSNAME 정보'.tr(),
        ),
        _buildInfoCard(
          children: [
            _buildInfoRow('Sysname', info.utsname.sysname),
            _buildInfoRow('Nodename', info.utsname.nodename),
            _buildInfoRow('Release', info.utsname.release),
            _buildInfoRow('Version', info.utsname.version),
            _buildInfoRow('Machine', info.utsname.machine),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  int _tapCount = 0;

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    return InkWell(
      onTap: () {
        if (++_tapCount > 5 && !isDeveloperModeEnabled) {
          isDeveloperModeEnabled = true;
          setState(() {});
        }
      },
      child: Padding(
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
        border: Border.all(color: color.outline, width: 1.0),
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
            width: 140,
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

  Widget _buildExpandableInfoRow(String label, String value) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Text(
        label,
        style: text.bodyMedium?.copyWith(
          color: color.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        SizedBox(
          width: double.infinity,
          child: SelectableText(
            value,
            style: text.bodySmall?.copyWith(
              color: color.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetInfoRow(String label, Widget widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: text.bodyMedium?.copyWith(
                color: color.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          widget,
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
