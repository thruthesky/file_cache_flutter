/// UI/UX 관련 함수
/// UI/UX related functions
library;

import 'package:flutter/material.dart';
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
              Text(
                    lo.shorebirdUpdateMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
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

              /// [버튼 섹션] - Comic 스타일 확인 버튼 (펄스 애니메이션)
              /// Button Section - Comic style confirm button (pulse animation)
              SizedBox(
                    /// 버튼 너비를 100%로 설정
                    /// Set button width to 100%
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),

                      /// Comic 스타일 버튼 스타일
                      /// Comic style button styling
                      style: OutlinedButton.styleFrom(
                        /// 배경색
                        /// Background color
                        backgroundColor: scheme.primary,

                        /// 테두리
                        /// Border
                        side: BorderSide(color: scheme.outline, width: 2.0),

                        /// 둥근 모서리
                        /// Rounded corners
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        /// 패딩
                        /// Padding
                        padding: EdgeInsets.symmetric(
                          vertical: sp.s12,
                          horizontal: sp.s24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// 다운로드 아이콘 추가 (Font Awesome Light 스타일)
                          /// Download icon added (Font Awesome Light style)
                          FaIcon(
                            FontAwesomeIcons.lightDownload,
                            size: 16,
                            color: scheme.onPrimary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lo.confirm,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  /// 페이드인 + 스케일 효과 (딜레이 적용)
                  /// Fade in + scale effect (with delay)
                  .fadeIn(delay: 600.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    delay: 600.ms,
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  )
                  /// 부드러운 펄스 효과 (무한 반복) - 버튼 주목 유도
                  /// Smooth pulse effect (infinite loop) - draw attention to button
                  .then()
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.03, 1.03),
                    duration: 1200.ms,
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
        ),
      );
    },
  );
}
