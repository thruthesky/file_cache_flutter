/// 앱 실행 시, 약 20초 후, 빌드 번호를 점검하는 초기화 함수입니다.
/// API에서 최소 요구 빌드 번호를 가져와서 현재 앱의 빌드 번호와 비교합니다.
/// 빌드 번호가 최소 요구 빌드 번호보다 낮으면 업그레이드 안내 다이얼로그를 표시합니다.
/// 참고: .claude/skills/philgo-app/SKILL.md 와 .claude/skills/philgo-app/references/upgrade.md 를 참고합니다.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:philgo/config/app.config.dart';
import 'package:philgo/router.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo_api/philgo_api.dart';

/// 앱 실행 후 약 20초 후에 빌드 번호를 점검합니다.
/// API func('version')을 호출하여 서버에서 최소 요구 빌드 번호를 가져옵니다.
/// 현재 앱의 빌드 번호가 서버의 최소 요구 빌드 번호보다 낮으면
/// 사용자에게 업그레이드를 안내하는 다이얼로그를 표시합니다.
void initMinimalBuildNumberCheck() {
  // 5초 후에 빌드 번호 체크 실행
  Timer(const Duration(seconds: 5), () async {
    try {
      // 1. 현재 앱의 빌드 번호 조회
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      // 2. API에서 버전 정보 가져오기
      // API 응답 형식:
      // {"version":"2025-12-11-14-41-07","app":{"android":{"version":"2.0.3","build_number":36},"ios":{"version":"2.0.3","build_number":36}}}
      final versionInfo = await func('version');

      // 3. 플랫폼별 최소 요구 빌드 번호 추출
      int minBuildNumber = 0;
      if (Platform.isAndroid) {
        // Android 플랫폼: app.android.build_number 값 사용
        minBuildNumber = versionInfo['app']?['android']?['build_number'] ?? 0;
      } else if (Platform.isIOS) {
        // iOS 플랫폼: app.ios.build_number 값 사용
        minBuildNumber = versionInfo['app']?['ios']?['build_number'] ?? 0;
      }

      debugPrint(
        '[BuildNumberCheck] 현재 빌드 번호: $currentBuildNumber, '
        'API 최소 요구 빌드 번호: $minBuildNumber',
      );

      // 4. 현재 빌드 번호가 최소 요구 빌드 번호보다 낮으면 업그레이드 안내 다이얼로그 표시
      if (currentBuildNumber < minBuildNumber) {
        _showUpgradeDialog();
      }
    } catch (e) {
      // API 호출 실패 또는 파싱 오류 시 로그만 출력하고 종료
      // 네트워크 오류 등으로 인해 사용자 경험을 방해하지 않음
      debugPrint('[BuildNumberCheck] 빌드 번호 체크 중 오류 발생: $e');
    }
  });
}

/// 업그레이드 안내 다이얼로그를 표시합니다.
/// Comic 스타일 다이얼로그를 사용하며, 플랫폼에 따라 적절한 스토어로 이동합니다.
void _showUpgradeDialog() {
  // globalContext가 마운트되어 있는지 확인
  if (!globalNavigatorKey.currentContext!.mounted) {
    debugPrint('[BuildNumberCheck] Context가 마운트되어 있지 않습니다.');
    return;
  }

  final context = globalContext;
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  showDialog(
    context: context,
    barrierDismissible: false, // 바깥 영역 탭으로 닫기 불가
    builder: (dialogContext) {
      return Dialog(
        elevation: 0, // Comic Design: 그림자 없음
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Comic Design: 12px 라운드
          side: BorderSide(
            color: scheme.outline, // Comic Design: outline 색상 테두리
            width: 2.0, // Comic Design: 2.0px 테두리
          ),
        ),
        backgroundColor: scheme.surface,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.all(24), // 8의 배수
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // PhilGo 로고 (애니메이션 효과 적용)
              const PhilGoLogoTriangles(
                size: 100,
                animated: true,
                rotating: true,
                pulsing: true,
              ),
              const SizedBox(height: 16),

              // 제목
              Text(
                '업데이트 필요',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // 안내 메시지
              Text(
                '새로운 버전이 출시되었습니다.\n더 나은 서비스를 위해 앱을 업데이트해 주세요.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Android 전용 강조 메시지
              if (Platform.isAndroid) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // 경고 색상 배경 (연한 주황색)
                    color: scheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scheme.error.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Font Awesome Pro Light 삼각형 경고 아이콘 사용
                      // (프로젝트 가이드라인: Material Icons 대신 Font Awesome Pro 사용)
                      FaIcon(
                        FontAwesomeIcons.lightTriangleExclamation,
                        color: scheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '만약, 업데이트가 잘 안되면, 기존에 설치된 앱을 삭제하고 새로 설치를 해야합니다.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.error,
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
                  // 닫기 버튼 (연하게 표시)
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        // 연하게 표시하기 위해 opacity 적용
                        foregroundColor: scheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        '닫기',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 업데이트 버튼 (강조, 다운로드 아이콘 포함)
                  Expanded(
                    flex: 2,
                    child: ComicPrimaryButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _openStore();
                      },
                      padding: ComicButtonPadding.medium,
                      textSize: ComicButtonTextSize.medium,
                      // Font Awesome Pro Light 다운로드 아이콘과 텍스트를 포함한 버튼 내용
                      // (프로젝트 가이드라인: Material Icons 대신 Font Awesome Pro 사용)
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightDownload,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text('업데이트'),
                        ],
                      ),
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

/// 플랫폼에 따라 적절한 앱 스토어를 엽니다.
/// Android: PlayStore, iOS: AppStore
void _openStore() {
  final String storeUrl;

  if (Platform.isAndroid) {
    storeUrl = AppConfig.playstoreUrl;
  } else if (Platform.isIOS) {
    storeUrl = AppConfig.appstoreUrl;
  } else {
    debugPrint('[BuildNumberCheck] 지원하지 않는 플랫폼입니다.');
    return;
  }

  debugPrint('[BuildNumberCheck] 스토어 열기: $storeUrl');
  launchApp(storeUrl, true);
}
