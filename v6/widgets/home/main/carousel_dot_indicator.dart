import 'package:flutter/material.dart';

/// 카로셀 Dot Indicator 위젯 (Carousel Dot Indicator Widget)
///
/// 카로셀의 현재 페이지를 시각적으로 표시하고,
/// 탭하여 특정 페이지로 이동할 수 있는 네비게이션 dot 목록입니다.
///
/// Displays the current carousel page visually and provides
/// navigation dots that can be tapped to navigate to specific pages.
///
/// ### Parameters:
/// - [itemCount] → 전체 아이템 수 (Total number of items)
/// - [currentIndex] → 현재 선택된 인덱스 (Currently selected index)
/// - [onDotTap] → dot 탭 시 콜백 (Callback when dot is tapped)
///
/// ### Example:
/// ```dart
/// CarouselDotIndicator(
///   itemCount: 4,
///   currentIndex: 0,
///   onDotTap: (index) => print('Tapped: $index'),
/// )
/// ```
class CarouselDotIndicator extends StatelessWidget {
  /// 전체 아이템 수 (Total number of items)
  final int itemCount;

  /// 현재 선택된 인덱스 (Currently selected index)
  final int currentIndex;

  /// dot 탭 시 콜백 (Callback when dot is tapped)
  final void Function(int index)? onDotTap;

  const CarouselDotIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        /// 현재 선택된 dot 여부 (Whether this dot is selected)
        final isSelected = index == currentIndex;

        return GestureDetector(
          /// dot 탭 시 해당 인덱스로 이동
          /// Navigate to index when dot is tapped
          onTap: () => onDotTap?.call(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,

            /// dot 간 간격 (Spacing between dots)
            margin: const EdgeInsets.symmetric(horizontal: 4),

            /// 선택된 dot은 넓게, 비선택 dot은 작게
            /// Selected dot is wider, unselected dot is smaller
            width: isSelected ? 16 : 8,
            height: 8,

            decoration: BoxDecoration(
              /// 선택된 dot은 primary 색상, 비선택은 outline 색상
              /// Selected dot uses primary color, unselected uses outline color
              color: isSelected
                  ? scheme.primary
                  : scheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
