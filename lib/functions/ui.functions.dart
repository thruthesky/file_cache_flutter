/// UI/UX 관련 함수
/// UI/UX related functions
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/themes/app.spacing.dart';

import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo_api/philgo_api.dart';

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
