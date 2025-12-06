import 'package:flutter/material.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

/// AppHeader Widget (앱 헤더 위젯)
///
/// A reusable header widget that displays app title, user avatar, and action buttons.
/// Can be used across different screens for consistent app bar design.
///
/// 재사용 가능한 헤더 위젯으로 앱 타이틀, 사용자 아바타, 액션 버튼을 표시합니다.
/// 여러 화면에서 일관된 앱바 디자인을 위해 사용됩니다.
///
/// Layout: [Leading] [Title] ───────── [Avatar] [Actions]
/// 레이아웃: [로고/리딩] [타이틀] ───────── [아바타] [액션들]
///
/// Features:
/// - Leading widget on the left (e.g., logo image)
/// - App title after leading (default: "필고")
/// - User avatar with customizable size
/// - Action buttons on the right (e.g., settings button)
/// - Comic Design: 2.0px bottom border
///
/// Usage:
/// ```dart
/// AppHeader(
///   leading: Image.asset('assets/logo.png', width: 32, height: 32),
///   actions: [
///     IconButton(
///       icon: FaIcon(FontAwesomeIcons.lightGear),
///       onPressed: () {},
///     ),
///   ],
/// )
/// ```
class AppHeader extends StatelessWidget {
  /// Leading widget to display before the title (e.g., logo)
  /// 타이틀 앞에 표시할 리딩 위젯 (예: 로고 이미지)
  final Widget? leading;

  /// Title text to display on the left side (default: "필고")
  /// 왼쪽에 표시할 타이틀 텍스트 (기본값: "필고")
  final String title;

  /// Action widgets to display on the right side after avatar
  /// 아바타 오른쪽에 표시할 액션 위젯 목록 (예: 설정 버튼)
  final List<Widget>? actions;

  /// Size of the user avatar (default: 40)
  /// 사용자 아바타 크기 (기본값: 40)
  final double avatarSize;

  /// Border radius of the avatar (default: 20, circular)
  /// 아바타 테두리 반경 (기본값: 20, 원형)
  final double avatarRadius;

  /// Custom padding for the header container
  /// 헤더 컨테이너의 커스텀 패딩
  final EdgeInsetsGeometry? padding;

  /// Whether to show bottom border (default: true)
  /// 하단 테두리 표시 여부 (기본값: true)
  final bool showBottomBorder;

  const AppHeader({
    super.key,
    this.leading,
    this.title = '필고',
    this.actions,
    this.avatarSize = 40,
    this.avatarRadius = 20,
    this.padding,
    this.showBottomBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// Default padding if not provided
    /// 패딩이 제공되지 않은 경우 기본 패딩 사용
    final effectivePadding = padding ??
        EdgeInsets.only(
          top: sp.s12,
          bottom: sp.s12,
          left: sp.s16,
          right: sp.s8,
        );

    return SafeArea(
      bottom: false,
      child: Container(
        padding: effectivePadding,
        decoration: BoxDecoration(
          // Comic Design: 2.0px bottom border with outline color
          // 코믹 디자인: outline 색상으로 2.0px 하단 테두리
          border: showBottomBorder
              ? Border(
                  bottom: BorderSide(color: scheme.outlineVariant, width: 1.0),
                )
              : null,
        ),
        child: Row(
          children: [
            /// Leading Widget (리딩 위젯)
            /// Displays logo or custom widget before title
            if (leading != null) ...[
              leading!,
              SizedBox(width: sp.s8),
            ],

            /// App Title (앱 타이틀)
            /// Displays app name on the left side
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            /// User Avatar Section (사용자 아바타 영역)
            /// Displays user avatar
            Selector<AppState, User?>(
              selector: (_, appState) => appState.user,
              builder: (_, user, _) {
                return Avatar(
                  photoUrl: user?.photoUrl,
                  size: avatarSize,
                  radius: avatarRadius,
                );
              },
            ),

            /// Action Widgets (액션 위젯들)
            /// Display action buttons after avatar
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
