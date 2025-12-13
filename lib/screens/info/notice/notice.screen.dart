import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 공지 화면 (Notice Screen)
///
/// 해외 여행 공지, 대사관/영사관 공지, 필고 공지 등
/// 다양한 공지사항을 표시합니다.
/// Displays various notices including overseas travel notices,
/// embassy/consulate notices, and Philgo notices.
class NoticeScreen extends StatefulWidget {
  static const String routeName = '/Notice';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.lightBullhorn, size: 20, color: scheme.primary),
            SizedBox(width: sp.s8),
            const Text('공지사항'),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [해외 여행 공지 섹션]
            /// Overseas Travel Notice Section
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPlane,
              title: '해외 여행 공지',
              onMoreTap: () {
                // TODO: 해외 여행 공지 더보기 페이지로 이동
                // TODO: Navigate to overseas travel notices page
              },
            ),
            SizedBox(height: sp.s12),
            _buildEmptyNoticeSection(
              context,
              icon: FontAwesomeIcons.lightPlaneUp,
              message: '해외 여행 관련 공지가 없습니다',
              description: '외교부 및 항공사 공지사항이 여기에 표시됩니다',
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [대사관 공지 섹션]
            /// Embassy Notice Section
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLandmarkFlag,
              title: '대사관 공지',
              onMoreTap: () {
                // TODO: 대사관 공지 더보기 페이지로 이동
                // TODO: Navigate to embassy notices page
              },
            ),
            SizedBox(height: sp.s12),
            _buildEmptyNoticeSection(
              context,
              icon: FontAwesomeIcons.lightBuilding,
              message: '대사관 공지가 없습니다',
              description: '주필리핀 대한민국 대사관 공지사항이 여기에 표시됩니다',
              backgroundColor: scheme.secondaryContainer,
              foregroundColor: scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [필고 공지 섹션]
            /// Philgo Notice Section
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMegaphone,
              title: '필고 공지',
              onMoreTap: () {
                // TODO: 필고 공지 더보기 페이지로 이동
                // TODO: Navigate to Philgo notices page
              },
            ),
            SizedBox(height: sp.s12),
            _buildEmptyNoticeSection(
              context,
              icon: FontAwesomeIcons.lightCircleInfo,
              message: '필고 공지가 없습니다',
              description: '필고 서비스 관련 공지사항이 여기에 표시됩니다',
              backgroundColor: scheme.tertiaryContainer,
              foregroundColor: scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header)
  ///
  /// 아이콘과 제목을 포함한 섹션 헤더를 생성합니다.
  /// Creates a section header with icon and title.
  ///
  /// [icon] - 섹션 아이콘 (Section icon)
  /// [title] - 섹션 제목 (Section title)
  /// [onMoreTap] - 더보기 버튼 탭 콜백 (More button tap callback)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onMoreTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        /// 섹션 아이콘 컨테이너 (Section icon container)
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
        ),
        SizedBox(width: sp.s12),

        /// 섹션 제목 (Section title)
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),

        /// 우측 공간 채우기 (Fill right space)
        const Spacer(),

        /// 더보기 버튼 (More button)
        /// onMoreTap 콜백이 제공된 경우에만 표시
        /// Only displayed when onMoreTap callback is provided
        if (onMoreTap != null)
          TextButton(
            onPressed: onMoreTap,
            style: TextButton.styleFrom(
              /// 최소 패딩으로 컴팩트한 버튼 스타일
              /// Compact button style with minimal padding
              padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '더보기',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                SizedBox(width: sp.s4),
                FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 12,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 빈 공지 섹션 빌드 (Build empty notice section)
  ///
  /// 공지가 없을 때 표시되는 빈 상태 UI를 생성합니다.
  /// Creates an empty state UI when there are no notices.
  Widget _buildEmptyNoticeSection(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String description,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s24),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// 아이콘 (Icon)
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              icon,
              size: 32,
              color: foregroundColor,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 메시지 (Message)
          Text(
            message,
            style: theme.textTheme.titleSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s8),

          /// 설명 (Description)
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foregroundColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
