import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/globals.dart';

/// 게시판/카테고리 선택 바텀시트 표시
///
/// 주요 게시판 목록을 바텀시트로 표시하고, 서브 카테고리가 있으면
/// 서브 카테고리 선택까지 진행한 후 콜백을 호출합니다.
///
/// [context] BuildContext (바텀시트를 열기 위한 부모 context)
/// [onSelected] 게시판 선택 완료 시 콜백 (postId, category)
///
/// 사용 예시:
/// ```dart
/// showPostCategoryBottomSheet(
///   context,
///   onSelected: (postId, category) {
///     // PostCreateScreen으로 이동
///   },
/// );
/// ```
void showPostCategoryBottomSheet(
  BuildContext context, {
  required void Function(String postId, String? category) onSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return _PostCategoryBottomSheet(
        parentContext: context,
        onSelected: onSelected,
      );
    },
  );
}

/// majorForumCategories의 각 postId에 대한 라벨 가져오기
String _getCategoryLabel(String postId) {
  final found = forumCategories.where(
    (c) => c.$1 == postId && c.$2 == null,
  );
  if (found.isNotEmpty) return found.first.$3;
  return postId;
}

/// 특정 postId의 서브 카테고리 목록 가져오기
List<(String, String)> _getSubCategories(String postId) {
  return forumCategories
      .where((c) => c.$1 == postId && c.$2 != null)
      .map((c) => (c.$2!, c.$3))
      .toList();
}

/// 카테고리 이모지
const _emojiMap = <String, String>{
  'freetalk': '💬',
  'qna': '❓',
  'buyandsell': '🛒',
  'wanted': '💼',
  'massage': '💆',
  'boarding_house': '🏠',
  'travel': '✈️',
  'business': '🏢',
  'school': '🎓',
  'caution': '⚠️',
  'greeting': '👋',
  'food_delivery': '🍔',
  'rest': '🍽️',
  'blog': '📖',
  'youtube': '🎬',
  'temp': '📋',
  'study': '📚',
};

class _PostCategoryBottomSheet extends StatelessWidget {
  /// 바텀시트를 열기 위한 원래 부모 context
  final BuildContext parentContext;
  final void Function(String postId, String? category) onSelected;

  const _PostCategoryBottomSheet({
    required this.parentContext,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = majorForumCategories(
      includeTemp: isDeveloperModeEnabled,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            /// 드래그 핸들
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: color.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            /// 타이틀
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Text(
                '게시판을 선택해주세요'.tr(),
                style: text.titleMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
              ),
            ),

            /// 게시판 목록
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: categories.length,
                itemBuilder: (_, index) {
                  final postId = categories[index];
                  final label = _getCategoryLabel(postId);
                  final emoji = _emojiMap[postId] ?? '📝';
                  final subCategories = _getSubCategories(postId);
                  final hasSubCategories = subCategories.isNotEmpty;

                  return ListTile(
                    leading: Text(emoji, style: const TextStyle(fontSize: 24)),
                    title: Text(label.tr()),
                    trailing: hasSubCategories
                        ? FaIcon(
                            FontAwesomeIcons.chevronRight,
                            size: 14,
                            color: color.onSurfaceVariant,
                          )
                        : null,
                    onTap: () {
                      if (hasSubCategories) {
                        /// 1차 바텀시트 닫기
                        Navigator.pop(context);

                        /// 서브 카테고리 바텀시트 열기 (parentContext 사용)
                        _showSubCategoryBottomSheet(
                          parentContext,
                          postId: postId,
                          label: label,
                          subCategories: subCategories,
                          onSelected: onSelected,
                        );
                      } else {
                        /// 바텀시트 닫고 콜백 호출
                        Navigator.pop(context);
                        onSelected(postId, null);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 서브 카테고리 선택 바텀시트
void _showSubCategoryBottomSheet(
  BuildContext parentContext, {
  required String postId,
  required String label,
  required List<(String, String)> subCategories,
  required void Function(String postId, String? category) onSelected,
}) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              /// 드래그 핸들
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              /// 뒤로가기 + 타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.arrowLeft,
                        size: 18,
                        color: color.onSurface,
                      ),
                      onPressed: () {
                        /// 2차 바텀시트 닫기
                        Navigator.pop(context);

                        /// 1차 게시판 선택 바텀시트 다시 열기
                        showPostCategoryBottomSheet(
                          parentContext,
                          onSelected: onSelected,
                        );
                      },
                    ),
                    Text(
                      label.tr(),
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              /// 서브 카테고리 목록
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: subCategories.length,
                  itemBuilder: (_, index) {
                    final (categoryId, categoryLabel) = subCategories[index];

                    return ListTile(
                      title: Text(categoryLabel.tr()),
                      onTap: () {
                        /// 바텀시트 닫고 콜백 호출
                        Navigator.pop(context);
                        onSelected(postId, categoryId);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
