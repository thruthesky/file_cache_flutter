import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/router.dart';
import 'package:philgo/setting/setting.model.dart';
import 'package:url_launcher/url_launcher.dart';

/// 빌드 번호를 비교하여 강제 업데이트가 필요하면 다이얼로그를 표시한다.
///
/// SettingService._loadSettings()에서 설정을 로드한 직후 호출된다.
/// 현재 앱의 빌드 번호가 서버의 최소 요구 빌드 번호보다 낮으면
/// 사용자에게 업그레이드를 안내하는 다이얼로그를 표시한다.
Future<void> checkBuildNumber(Settings settings) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

  int minBuildNumber = 0;
  if (Platform.isAndroid) {
    minBuildNumber =
        int.tryParse(settings.appVersionAndroidBuild) ?? 0;
  } else if (Platform.isIOS) {
    minBuildNumber =
        int.tryParse(settings.appVersionIosBuild) ?? 0;
  }

  if (currentBuildNumber < minBuildNumber) {
    _showUpgradeDialog();
  }
}

/// 업그레이드 안내 다이얼로그를 표시한다.
void _showUpgradeDialog() {
  if (!globalNavigatorKey.currentContext!.mounted) return;

  final context = globalContext;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: color.outline,
            width: 2.0,
          ),
        ),
        backgroundColor: color.surface,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 앱 아이콘
              FaIcon(
                FontAwesomeIcons.lightCircleUp,
                size: 64,
                color: color.primary,
              ),
              const SizedBox(height: 16),

              // 제목
              Text(
                '업데이트 필요'.tr(),
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 안내 메시지 1
              Text(
                '새로운 버전이 출시되었습니다.'.tr(),
                style: text.bodyLarge?.copyWith(
                  color: color.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 안내 메시지 2
              Text(
                '더 나은 서비스를 위해 앱을 업데이트해 주세요.'.tr(),
                style: text.bodyMedium?.copyWith(
                  color: color.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Android 전용 경고
              if (Platform.isAndroid) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.error.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightTriangleExclamation,
                        color: color.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '업데이트가 안되면 앱을 삭제 후 다시 설치해 주세요.'.tr(),
                          style: text.bodySmall?.copyWith(
                            color: color.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              // 버튼 영역
              Row(
                children: [
                  // 닫기 버튼
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor:
                            color.onSurface.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '닫기'.tr(),
                        style: text.bodyMedium?.copyWith(
                          color: color.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 업데이트 버튼
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _openStore();
                      },
                      icon: const FaIcon(
                        FontAwesomeIcons.lightDownload,
                        size: 18,
                      ),
                      label: Text('업데이트'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// 플랫폼에 따라 적절한 앱 스토어를 연다.
void _openStore() {
  final String storeUrl;

  if (Platform.isAndroid) {
    storeUrl = Config.playstoreUrl;
  } else if (Platform.isIOS) {
    storeUrl = Config.appstoreUrl;
  } else {
    return;
  }

  launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
}
