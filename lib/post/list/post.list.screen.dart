import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  /// 현재 선택된 카테고리 인덱스
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            /// 앱바 영역
            _buildAppBar(theme, scheme),
            Container(height: 1, color: scheme.outlineVariant),

            /// 카테고리 목록 (가로 스크롤)
            _buildCategoryList(theme, scheme),
            Container(height: 1, color: scheme.outlineVariant),

            /// 게시글 목록 영역 (추후 구현)
            Expanded(
              child: Center(
                child: Text(
                  _selectedCategoryLabel(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 앱바 영역
  Widget _buildAppBar(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.lightNewspaper,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Text('게시판', style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  /// 카테고리 가로 스크롤 목록
  Widget _buildCategoryList(ThemeData theme, ColorScheme scheme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: forumCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final (_, _, label) = forumCategories[index];
          final isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary
                    : scheme.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 현재 선택된 카테고리 라벨
  String _selectedCategoryLabel() {
    final (postId, category, _) = forumCategories[_selectedIndex];
    if (category != null) {
      return '$postId / $category';
    }
    return postId;
  }
}
