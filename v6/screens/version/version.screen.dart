/// 버전 및 디바이스 정보 화면 (Version and Device Info Screen)
///
/// device_info_plus 패키지를 사용하여 디바이스의 모든 정보를 표시합니다.
/// Displays all device information using the device_info_plus package.
library;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 버전 및 디바이스 정보 화면 (Version and Device Info Screen)
///
/// 앱 버전 정보와 디바이스 하드웨어/소프트웨어 정보를 표시합니다.
/// Displays app version info and device hardware/software information.
class VersionScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/version';

  const VersionScreen({super.key});

  /// 화면 이동 헬퍼 메서드 (Navigation helper method)
  static void push(BuildContext context) {
    context.push(routeName);
  }

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  /// 디바이스 정보 플러그인 (Device info plugin)
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// 앱 패키지 정보 (App package info)
  PackageInfo? _packageInfo;

  /// Android 디바이스 정보 (Android device info)
  AndroidDeviceInfo? _androidInfo;

  /// iOS 디바이스 정보 (iOS device info)
  IosDeviceInfo? _iosInfo;

  /// 로딩 상태 (Loading state)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  /// 디바이스 정보 로드 (Load device information)
  Future<void> _loadDeviceInfo() async {
    try {
      /// 앱 패키지 정보 로드 (Load app package info)
      _packageInfo = await PackageInfo.fromPlatform();

      /// 플랫폼별 디바이스 정보 로드 (Load platform-specific device info)
      if (Platform.isAndroid) {
        _androidInfo = await _deviceInfoPlugin.androidInfo;
      } else if (Platform.isIOS) {
        _iosInfo = await _deviceInfoPlugin.iosInfo;
      }
    } catch (e) {
      debugPrint('[VersionScreen] 디바이스 정보 로드 오류: $e');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final lo = Lo.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(lo.versionTitle), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      _buildInfoRow(
                        lo.packageName,
                        _packageInfo?.packageName ?? '-',
                      ),
                      _buildInfoRow(lo.version, _packageInfo?.version ?? '-'),
                      _buildInfoRow(
                        lo.buildNumber,
                        _packageInfo?.buildNumber ?? '-',
                      ),
                    ],
                  ),
                  SizedBox(height: sp.s24),

                  /// [디바이스 정보 섹션] - Device Information Section
                  if (Platform.isAndroid && _androidInfo != null) ...[
                    _buildAndroidInfo(context, lo, sp),
                  ] else if (Platform.isIOS && _iosInfo != null) ...[
                    _buildIosInfo(context, lo, sp),
                  ],

                  if (isDeveloperModeEnabled) ...[
                    _buildSectionHeader(
                      context,
                      icon: FontAwesomeIcons.bug,
                      title: 'Test',
                    ),
                    _buildInfoCard(
                      context,
                      children: [
                        _buildWidgetInfoRow(
                          'Crash Test',
                          ElevatedButton(
                            onPressed: () => throw Exception(),
                            child: const Text("Throw Test Exception"),
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

  /// Android 디바이스 정보 빌드 (Build Android device info)
  Widget _buildAndroidInfo(BuildContext context, Lo lo, AppSpacing sp) {
    final info = _androidInfo!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// [기본 정보] - Basic Information
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.android,
          title: lo.deviceBasicInfo,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.deviceName, info.name),
            _buildInfoRow(lo.deviceModel, info.model),
            _buildInfoRow(lo.deviceBrand, info.brand),
            _buildInfoRow(lo.deviceManufacturer, info.manufacturer),
            _buildInfoRow(lo.deviceProduct, info.product),
            _buildInfoRow(lo.deviceDevice, info.device),
            _buildInfoRow(lo.deviceHardware, info.hardware),
            _buildInfoRow(lo.deviceBoard, info.board),
            _buildInfoRow(
              lo.isPhysicalDevice,
              info.isPhysicalDevice ? lo.yes : lo.no,
            ),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [시스템 정보] - System Information
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.gear,
          title: lo.systemInfo,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.androidVersion, info.version.release),
            _buildInfoRow(lo.sdkInt, info.version.sdkInt.toString()),
            _buildInfoRow(lo.securityPatch, info.version.securityPatch ?? '-'),
            _buildInfoRow(lo.deviceDisplay, info.display),
            _buildInfoRow(lo.deviceId, info.id),
            _buildInfoRow(lo.deviceFingerprint, info.fingerprint),
            _buildInfoRow(lo.deviceHost, info.host),
            _buildInfoRow(lo.deviceBootloader, info.bootloader),
            _buildInfoRow(lo.deviceType, info.type),
            _buildInfoRow(lo.deviceTags, info.tags),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [메모리 및 저장소] - Memory and Storage
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.memory,
          title: lo.memoryAndStorage,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.physicalRam, '${info.physicalRamSize} MB'),
            _buildInfoRow(lo.availableRam, '${info.availableRamSize} MB'),
            _buildInfoRow(
              lo.isLowRamDevice,
              info.isLowRamDevice ? lo.yes : lo.no,
            ),
            _buildInfoRow(lo.totalDisk, _formatBytes(info.totalDiskSize)),
            _buildInfoRow(lo.freeDisk, _formatBytes(info.freeDiskSize)),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [지원 ABI] - Supported ABIs
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.microchip,
          title: lo.supportedAbis,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.supportedAbis, info.supportedAbis.join(', ')),
            _buildInfoRow(
              lo.supported32BitAbis,
              info.supported32BitAbis.join(', '),
            ),
            _buildInfoRow(
              lo.supported64BitAbis,
              info.supported64BitAbis.join(', '),
            ),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [시스템 기능] - System Features
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.listCheck,
          title: lo.systemFeatures,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildExpandableInfoRow(
              lo.systemFeatures,
              info.systemFeatures.join('\n'),
            ),
          ],
        ),
        SizedBox(height: sp.s24),
      ],
    );
  }

  /// iOS 디바이스 정보 빌드 (Build iOS device info)
  Widget _buildIosInfo(BuildContext context, Lo lo, AppSpacing sp) {
    final info = _iosInfo!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// [기본 정보] - Basic Information
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.apple,
          title: lo.deviceBasicInfo,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.deviceName, info.name),
            _buildInfoRow(lo.deviceModel, info.model),
            _buildInfoRow(lo.modelName, info.modelName),
            _buildInfoRow(lo.localizedModel, info.localizedModel),
            _buildInfoRow(
              lo.isPhysicalDevice,
              info.isPhysicalDevice ? lo.yes : lo.no,
            ),
            _buildInfoRow(
              lo.isiOSAppOnMac,
              info.isiOSAppOnMac ? lo.yes : lo.no,
            ),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [시스템 정보] - System Information
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.gear,
          title: lo.systemInfo,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.systemName, info.systemName),
            _buildInfoRow(lo.systemVersion, info.systemVersion),
            _buildInfoRow(
              lo.identifierForVendor,
              info.identifierForVendor ?? '-',
            ),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [메모리 및 저장소] - Memory and Storage
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.memory,
          title: lo.memoryAndStorage,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.physicalRam, '${info.physicalRamSize} MB'),
            _buildInfoRow(lo.availableRam, '${info.availableRamSize} MB'),
            _buildInfoRow(lo.totalDisk, _formatBytes(info.totalDiskSize)),
            _buildInfoRow(lo.freeDisk, _formatBytes(info.freeDiskSize)),
          ],
        ),
        SizedBox(height: sp.s24),

        /// [UTSNAME 정보] - UTSNAME Information
        _buildSectionHeader(
          context,
          icon: FontAwesomeIcons.terminal,
          title: lo.utsnameInfo,
        ),
        _buildInfoCard(
          context,
          children: [
            _buildInfoRow(lo.sysname, info.utsname.sysname),
            _buildInfoRow(lo.nodename, info.utsname.nodename),
            _buildInfoRow(lo.release, info.utsname.release),
            _buildInfoRow(lo.utsnameVersion, info.utsname.version),
            _buildInfoRow(lo.machine, info.utsname.machine),
          ],
        ),
        SizedBox(height: sp.s24),
      ],
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

    int count = 0;

    return InkWell(
      onTap: () {
        if (++count > 5 && !isDeveloperModeEnabled) {
          isDeveloperModeEnabled = true;
          setState(() {});
        }
      },
      child: Padding(
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
        border: Border.all(color: scheme.outline, width: 1.0),
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
            width: 140,
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

  /// 확장 가능한 정보 행 빌드 (Build expandable info row)
  Widget _buildExpandableInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.only(bottom: sp.s8),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        SizedBox(
          width: double.infinity,
          child: SelectableText(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetInfoRow(String label, Widget widget) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          widget,
        ],
      ),
    );
  }

  /// 바이트 포맷팅 (Format bytes)
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
