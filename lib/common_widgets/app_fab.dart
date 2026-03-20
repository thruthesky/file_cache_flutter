import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';

/// FAB 팝업 메뉴 아이템 데이터 모델
class AppFabMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppFabMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}

/// 공통 FAB(Floating Action Button) 위젯
///
/// 메인 "+" 버튼과 클릭 시 위쪽으로 펼쳐지는 팝업 메뉴를 제공한다.
/// 홈, 게시판, 업소록, 메뉴 화면에서 공유하여 사용한다.
///
/// 상태(펼침/접힘)는 부모 위젯에서 관리한다.
/// 오버레이(반투명 배경)도 부모에서 처리한다.
class AppFab extends StatelessWidget {
  /// 팝업 메뉴에 표시할 아이템 목록
  final List<AppFabMenuItem> menuItems;

  /// 메뉴 펼침 상태
  final bool isExpanded;

  /// 메인 FAB 토글 콜백
  final VoidCallback onToggle;

  /// 메뉴 닫기 콜백
  final VoidCallback onClose;

  /// 이벤트 FAB 표시 여부
  final bool showEventButton;

  /// 이벤트 FAB 클릭 콜백
  final VoidCallback? onEventTap;

  const AppFab({
    super.key,
    required this.menuItems,
    required this.isExpanded,
    required this.onToggle,
    required this.onClose,
    this.showEventButton = false,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 펼쳐지는 메뉴 아이템들
        if (isExpanded)
          ...menuItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FabMenuItem(item: item, onClose: onClose),
            )
                .animate()
                .fadeIn(
                  duration: 200.ms,
                  delay: (index * 40).ms,
                )
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 200.ms,
                  delay: (index * 40).ms,
                  curve: Curves.easeOutCubic,
                );
          }),

        // 하단 FAB 버튼들 (이벤트 + 메인)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이벤트 FAB (조건부)
            if (showEventButton) ...[
              _EventFabButton(onTap: onEventTap),
              const SizedBox(width: 10),
            ],

            // 메인 FAB (+/×)
            _MainFabButton(isExpanded: isExpanded, onTap: onToggle),
          ],
        ),
      ],
    );
  }
}

/// 메인 FAB 버튼 (+/× 토글)
class _MainFabButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _MainFabButton({required this.isExpanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.outline, width: 1.5),
        ),
        color: color.surface,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: AnimatedRotation(
              turns: isExpanded ? 0.125 : 0, // 45도 회전 (+ → ×)
              duration: const Duration(milliseconds: 250),
              child: IconTheme(
                data: IconThemeData(color: color.onSurface, size: 20),
                child: const FaIcon(FontAwesomeIcons.plus),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 이벤트 FAB 버튼 (선물 아이콘, 펄스 애니메이션)
class _EventFabButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _EventFabButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: color.error.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        color: color.errorContainer,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Tooltip(
            message: '이벤트응모'.tr(),
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: color.onErrorContainer, size: 20),
                child: const FaIcon(FontAwesomeIcons.gift),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.08, duration: 800.ms)
        .shimmer(duration: 1500.ms);
  }
}

/// 팝업 메뉴 아이템 위젯 (라벨 + 아이콘)
class _FabMenuItem extends StatelessWidget {
  final AppFabMenuItem item;
  final VoidCallback onClose;

  const _FabMenuItem({required this.item, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onClose();
        item.onTap();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              item.label,
              style: text.bodySmall?.copyWith(
                color: color.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 아이콘
          SizedBox(
            width: 36,
            height: 36,
            child: Material(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: item.backgroundColor ?? color.outline,
                  width: 1.5,
                ),
              ),
              color: item.backgroundColor ?? color.surface,
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: FaIcon(
                  item.icon,
                  size: 16,
                  color: item.iconColor ?? color.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
