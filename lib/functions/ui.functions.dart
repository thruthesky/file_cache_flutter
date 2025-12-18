/// UI/UX 관련 함수
/// UI/UX related functions
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/advertisement/advertisement.view.screen.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/themes/app.spacing.dart';

import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo_api/philgo_api.dart';

/// 슬라이드 방향 열거형 (Slide Direction Enum)
///
/// 전체 화면 다이얼로그의 슬라이드 애니메이션 방향을 지정합니다.
/// Specifies the slide animation direction for full screen dialogs.
enum SlideDirection {
  /// 아래에서 위로 슬라이드 (Slide from bottom to top)
  bottomToTop,

  /// 위에서 아래로 슬라이드 (Slide from top to bottom)
  topToBottom,

  /// 왼쪽에서 오른쪽으로 슬라이드 (Slide from left to right)
  leftToRight,

  /// 오른쪽에서 왼쪽으로 슬라이드 (Slide from right to left)
  rightToLeft,
}

/// 전체 화면 다이얼로그 표시 (Show Full Screen Dialog)
///
/// showGeneralDialog를 사용하여 전체 화면 다이얼로그를 표시합니다.
/// 슬라이드 + 페이드 애니메이션이 적용됩니다.
///
/// Uses showGeneralDialog to display a full screen dialog.
/// Slide + fade animation is applied.
///
/// ### Parameters:
/// - [context] BuildContext for dialog
/// - [child] 표시할 위젯 (Widget to display)
/// - [barrierDismissible] 배경 탭 시 닫기 여부 (기본값: true)
/// - [barrierLabel] 접근성 레이블 (optional)
/// - [barrierColor] 배경색 (기본값: Colors.black54)
/// - [transitionDuration] 애니메이션 시간 (기본값: 300ms)
/// - [slideDirection] 슬라이드 방향 (기본값: bottomToTop)
/// - [curve] 애니메이션 커브 (기본값: Curves.easeOutCubic)
///
/// ### Example:
/// ```dart
/// showFullScreen(
///   context,
///   child: const MyScreen(),
///   barrierDismissible: true,
///   slideDirection: SlideDirection.bottomToTop,
/// );
/// ```
Future<T?> showFullScreen<T>(
  BuildContext context, {
  required Widget child,
  bool barrierDismissible = true,
  String? barrierLabel,
  Color barrierColor = Colors.black54,
  Duration transitionDuration = const Duration(milliseconds: 300),
  SlideDirection slideDirection = SlideDirection.bottomToTop,
  Curve curve = Curves.easeOutCubic,
}) {
  return showGeneralDialog<T>(
    context: context,

    /// 배경 탭 시 다이얼로그 닫기 여부
    /// Whether to close dialog when tapping background
    barrierDismissible: barrierDismissible,

    /// 배경 레이블 (접근성)
    /// Background label (accessibility)
    barrierLabel:
        barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,

    /// 배경색
    /// Background color
    barrierColor: barrierColor,

    /// 다이얼로그 전환 애니메이션 시간
    /// Dialog transition animation duration
    transitionDuration: transitionDuration,

    /// 다이얼로그 빌더
    /// Dialog builder
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
    },

    /// 슬라이드 + 페이드 인 애니메이션
    /// Slide + fade in animation
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

      /// 슬라이드 방향에 따른 시작 오프셋 계산
      /// Calculate start offset based on slide direction
      final beginOffset = switch (slideDirection) {
        SlideDirection.bottomToTop => const Offset(0, 1),
        SlideDirection.topToBottom => const Offset(0, -1),
        SlideDirection.leftToRight => const Offset(-1, 0),
        SlideDirection.rightToLeft => const Offset(1, 0),
      };

      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(opacity: curvedAnimation, child: child),
      );
    },
  );
}

/// 글쓰기 다이얼로그 표시
/// Shows PostCreateForm dialog using showGeneralDialog
///
/// [context] BuildContext for dialog
/// [postId] Main category ID (e.g., 'freetalk', 'buyandsell')
/// [category] Sub-category (optional, null if no sub-category)
/// [onSubmitted] Callback when post is successfully created (optional)
///
/// 사용 예시 / Usage example:
/// ```dart
/// showPostCreateDialog(
///   context,
///   postId: 'freetalk',
///   category: null,
///   onSubmitted: (post) {
///     // 글 생성 후 목록
///     pagingController.refresh();
///   },
/// );
/// ```
void showPostCreateDialog(
  BuildContext context, {
  required String postId,
  String? category,
  void Function(Post post)? onSubmitted,
}) {
  /// Navigator.push를 사용하여 전체 화면으로 표시
  /// Use Navigator.push for full-screen display
  Navigator.of(context).push(
    PageRouteBuilder(
      /// 전체 화면 라우트 설정
      /// Full-screen route configuration
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return PostCreateScreen(
          postId: postId,
          category: category,
          onSubmitted: onSubmitted,
        );
      },

      /// 슬라이드 애니메이션 (하단에서 위로)
      /// Slide animation (from bottom to top)
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}

/// 글 수정 다이얼로그 표시
/// Shows PostUpdateScreen using Navigator.push
///
/// [context] BuildContext for navigation
/// [post] The post to update
/// [onUpdated] Callback when post is successfully updated (optional)
///
/// 사용 예시 / Usage example:
/// ```dart
/// showPostUpdateDialog(
///   context,
///   post: myPost,
///   onUpdated: (updatedPost) {
///     // 글 수정 후 처리
///   },
/// );
/// ```
Future<Post?> showPostUpdateDialog(
  BuildContext context, {
  required Post post,
  void Function(Post post)? onUpdated,
}) async {
  /// Navigator.push를 사용하여 전체 화면으로 표시
  /// Use Navigator.push for full-screen display
  final result = await Navigator.of(context).push<Post>(
    PageRouteBuilder(
      /// 전체 화면 라우트 설정
      /// Full-screen route configuration
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return PostUpdateScreen(post: post, onUpdated: onUpdated);
      },

      /// 슬라이드 애니메이션 (하단에서 위로)
      /// Slide animation (from bottom to top)
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );

  return result;
}

/// Shorebird 업데이트 완료 다이얼로그 표시
/// Show Shorebird update complete dialog
///
/// 업데이트 다운로드 완료 후 사용자에게 앱 재시작을 안내하는 다이얼로그를 표시합니다.
/// Shows a dialog to inform the user to restart the app after update download is complete.
///
/// ## 디자인 구성 (Design Composition)
/// - Logo: 상단 중앙에 PhilGo Triangle 로고 표시 (다이나믹 애니메이션 적용)
/// - Title: "업데이트 완료" 텍스트 (titleLarge - 한단계 작게)
/// - Content: 앱 재시작 안내 메시지 (bodyLarge - 한단계 크게)
/// - Button: Comic 스타일 확인 버튼 (펄스 애니메이션)
///
/// ## 다국어 지원 (i18n Support)
/// - Lo 클래스를 통한 다국어 문자열 적용
/// - 한국어, 영어, 일본어, 중국어 지원
void showShorebirdUpdateDialog() {
  final theme = Theme.of(globalContext);
  final scheme = theme.colorScheme;
  final sp = theme.extension<AppSpacing>()!;

  /// 다국어 문자열 가져오기
  /// Get localized strings
  final lo = Lo.of(globalContext)!;

  showDialog(
    context: globalContext,

    /// 다이얼로그 외부 클릭으로 닫기 비활성화 (중요한 알림)
    /// Disable closing by tapping outside (important notification)
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        /// Comic 스타일: elevation 0
        /// Comic style: elevation 0
        elevation: 0,

        /// Comic 스타일: 테두리 적용
        /// Comic style: apply border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline, width: 2.0),
        ),

        /// 다이얼로그 배경색
        /// Dialog background color
        backgroundColor: scheme.surface,

        child: Container(
          /// 다이얼로그 최대 너비 제한
          /// Limit dialog max width
          constraints: const BoxConstraints(maxWidth: 320),

          /// 다이얼로그 내부 패딩
          /// Dialog inner padding
          padding: EdgeInsets.all(sp.s24),

          child: Column(
            /// 내용에 맞게 크기 조절
            /// Size to fit content
            mainAxisSize: MainAxisSize.min,

            /// 중앙 정렬
            /// Center alignment
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              /// [로고 섹션] - PhilGo 로고 (한 단계 작게: 180 → 140)
              /// Logo Section - PhilGo logo (one step smaller: 180 → 140)
              const PhilGoLogoTriangles(
                size: 140,
                animated: true,
                rotating: true,
                pulsing: true,
              ),

              SizedBox(height: sp.s16),

              /// [제목 섹션] - "업데이트 완료" (titleLarge - 한단계 작게)
              /// Title Section - "Update Complete" (titleLarge - one step smaller)
              Text(
                    lo.shorebirdUpdateTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  /// 페이드인 + 슬라이드 효과
                  /// Fade in + slide effect
                  .fadeIn(delay: 200.ms, duration: 300.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: 200.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  )
                  /// 셰이크 효과 (주의 끌기)
                  /// Shake effect (attention grabbing)
                  .shake(
                    delay: 600.ms,
                    duration: 500.ms,
                    hz: 3,
                    offset: const Offset(2, 0),
                  ),

              SizedBox(height: sp.s12),

              /// [내용 섹션] - 안내 메시지 (bodyLarge - 한단계 크게)
              /// Content Section - Information message (bodyLarge - one step larger)
              Column(
                    children: [
                      /// 첫 번째 줄: 앱이 업데이트 되었습니다
                      /// First line: App has been updated
                      Text(
                        lo.shorebirdUpdateMessage,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: sp.s8),

                      /// 두 번째 줄: 앱을 재시작해주세요 (경고 스타일)
                      /// Second line: Please restart the app (warning style)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s12,
                          vertical: sp.s8,
                        ),
                        decoration: BoxDecoration(
                          // 경고 배경색 (error 색상의 연한 버전, border 없음)
                          // Warning background color (lighter version of error, no border)
                          color: scheme.errorContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 강조 아이콘 (Emoji 스타일)
                            // Emphasis icon (Emoji style)
                            Text('🔄', style: TextStyle(fontSize: 16)),
                            SizedBox(width: sp.s8),
                            Text(
                              lo.shorebirdRestartMessage,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                // 경고를 위해 error 색상과 bold 적용
                                // Apply error color and bold for warning
                                color: scheme.error,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  .animate()
                  /// 페이드인 + 슬라이드 효과 (딜레이 적용)
                  /// Fade in + slide effect (with delay)
                  .fadeIn(delay: 400.ms, duration: 300.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 400.ms,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),

              SizedBox(height: sp.s24),

              /// [버튼 섹션] - 확인 버튼과 종료하기 버튼
              /// Button Section - Confirm button and Exit button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 확인 버튼 (회색, 아이콘 없음)
                  /// Confirm button (gray, no icon)
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurface.withValues(alpha: 0.6),
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s16,
                        vertical: sp.s12,
                      ),
                    ),
                    child: Text(
                      lo.confirm,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),

                  SizedBox(width: sp.s12),

                  /// 종료하기 버튼 (빨간색, 아이콘 포함)
                  /// Exit button (red, with icon)
                  OutlinedButton(
                    onPressed: () {
                      // 앱 강제 종료
                      // Force exit the app
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error, width: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s16,
                        vertical: sp.s12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// 종료 아이콘 (Emoji 스타일)
                        /// Exit icon (Emoji style)
                        Text(
                          '⏻',
                          style: TextStyle(fontSize: 16, color: scheme.error),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lo.exitApp,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.error,
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

/// 광고 배너 URL 열기 (Open banner URL)
///
/// 배너 클릭 시 URL을 처리하는 함수입니다.
/// Handles banner click URL processing.
///
/// ### URL 처리 로직 (URL Processing Logic):
/// 1. `http`로 시작하면 → WebView로 열기
/// 2. 숫자만 있으면 → 해당 idx의 글 보기 화면 열기
/// 3. `idx=xxx` 패턴이면 → xxx 숫자 추출하여 글 보기 화면 열기
///
/// ### Parameters:
/// - [context] BuildContext for navigation
/// - [url] 배너 링크 URL (Banner link URL)
///
/// ### Usage:
/// ```dart
/// openBannerUrl(context, 'https://example.com'); // WebView로 열기
/// openBannerUrl(context, '12345'); // idx=12345 글 보기
/// openBannerUrl(context, 'idx=12345'); // idx=12345 글 보기
/// ```
void openBannerUrl(BuildContext context, String url) async {
  debugPrint('[openBannerUrl] banner url: $url');

  /// 1. HTTP URL인 경우 → WebView로 열기
  /// If HTTP URL → Open in WebView
  if (url.startsWith('http')) {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      showFullScreen(
        context,
        child: WebViewScreen(url: url, title: ''),
      );
    }
    return;
  }

  /// 2-3. 내부 글 보기 처리 (Internal post view handling)
  int? idx;

  /// 2. URL이 숫자만으로 구성된 경우 → idx로 변환
  /// If URL consists only of numbers → Convert to idx
  if (RegExp(r'^\d+$').hasMatch(url)) {
    idx = int.tryParse(url);
    debugPrint('[openBannerUrl] 숫자 URL 감지, idx: $idx');
  }

  /// 3. idx=xxx 패턴인 경우 → 숫자 추출
  /// If idx=xxx pattern → Extract number
  if (idx == null) {
    final match = RegExp(r'idx=(\d+)').firstMatch(url);
    if (match != null) {
      idx = int.tryParse(match.group(1) ?? '');
      debugPrint('[openBannerUrl] idx=xxx 패턴 감지, idx: $idx');
    }
  }

  /// 4. idx가 유효하면 AdvertisementViewScreen 열기
  /// If idx is valid, open AdvertisementViewScreen
  if (idx != null && idx > 0) {
    debugPrint('[openBannerUrl] AdvertisementViewScreen 열기, idx: $idx');
    showFullScreen(context, child: AdvertisementViewScreen(idx: idx));
  } else {
    debugPrint('[openBannerUrl] 처리할 수 없는 URL: $url');
  }
}
