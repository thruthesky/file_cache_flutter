import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 화면 빠른 글쓰기 박스 위젯 (Home Quick Post Box Widget)
///
/// 클릭하면 새 글쓰기 페이지로 이동하는 가짜 입력 박스입니다.
/// A fake input box that navigates to the new post creation page when clicked.
///
/// 포인트 이벤트 기간에만 표시됩니다.
/// Only displayed during point event periods.
///
/// UI 구성 (UI Structure):
/// [카메라 아이콘] + [입력 박스 텍스트] + [전송 아이콘]
/// [Camera Icon] + [Input Box Text] + [Send Icon]
///
/// 사용 예시 (Usage Example):
/// ```dart
/// HomeQuickPostBox()
/// ```
class HomeQuickPostBox extends StatelessWidget {
  const HomeQuickPostBox({super.key});

  @override
  Widget build(BuildContext context) {
    /// FutureBuilder를 사용하여 포인트 이벤트 정보를 가져옵니다.
    /// Use FutureBuilder to fetch point event info.
    ///
    /// - 로딩 중: 위젯을 숨깁니다 (깜빡임 방지)
    /// - 이벤트 기간: 이벤트 메시지 표시
    /// - 이벤트 기간 아님: 기본 메시지 표시
    return FutureBuilder<PointEventInfo>(
      future: getPointEventInfo(),
      builder: (context, snapshot) {
        /// 로딩 중에는 숨김 (깜빡임 방지)
        /// Hide during loading to prevent flickering
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        /// 이벤트 여부 확인 (데이터가 있고 이벤트 기간인 경우 true)
        /// Check if in event period (true if data exists and in event)
        final bool inEvent = snapshot.hasData && snapshot.data!.inEvent;

        /// 가짜 입력 박스 표시 (이벤트 여부에 따라 메시지 다르게 표시)
        /// Show fake input box (different message based on event status)
        return _buildQuickPostBox(context, inEvent: inEvent);
      },
    );
  }

  /// 가짜 입력 박스 UI 빌드
  /// Build fake input box UI
  ///
  /// [inEvent] - 현재 포인트 이벤트 기간인지 여부
  /// [inEvent] - Whether currently in point event period
  Widget _buildQuickPostBox(BuildContext context, {required bool inEvent}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      /// 좌우 패딩 적용
      /// Apply horizontal padding
      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),

      child: InkWell(
        /// 클릭 시 카테고리 선택 다이얼로그 표시
        /// Show category selection dialog on tap
        onTap: () => showPostCategoryDialog(context),

        /// 둥근 모서리 터치 피드백
        /// Rounded corner touch feedback
        borderRadius: BorderRadius.circular(24),

        child: Container(
          /// 가짜 입력 박스 스타일 (둥근 모서리, 테두리)
          /// Input box style (rounded corners, border)
          decoration: BoxDecoration(
            /// 테두리 색상
            /// Border color
            border: Border.all(color: scheme.outlineVariant, width: 1.5),

            /// 둥근 모서리 (24px)
            /// Rounded corners (24px)
            borderRadius: BorderRadius.circular(24),

            /// 배경색
            /// Background color
            color: scheme.surface,
          ),

          /// 내부 패딩
          /// Internal padding
          padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),

          child: Row(
            children: [
              /// 카메라 아이콘 (왼쪽)
              /// Camera icon (left)
              FaIcon(
                FontAwesomeIcons.camera,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),

              SizedBox(width: sp.s8),

              /// 입력 박스 텍스트 (중앙, 확장)
              /// Input box text (center, expanded)
              /// 이벤트 기간에는 이벤트 메시지, 아니면 기본 메시지 표시
              /// Show event message during event period, otherwise show default message
              Expanded(
                child: Text(
                  inEvent ? T.quickPostEventMessage : T.quickPostDefaultMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(width: sp.s8),

              /// 전송 아이콘 (오른쪽)
              /// Send icon (right)
              FaIcon(
                FontAwesomeIcons.paperPlane,
                size: 18,
                color: scheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
