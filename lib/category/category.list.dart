import 'package:flutter/material.dart';
import 'package:philgo/app.config.dart';

/// 카테고리 목록 위젯 (Category List Widget)
///
/// PhilgoConfig.categories에 저장된 카테고리들을 리스트로 표시합니다.
/// 카테고리 선택 시 postId와 category를 콜백으로 전달합니다.
class CategoryList extends StatelessWidget {
  const CategoryList({super.key, required this.onTap});

  /// 카테고리 선택 콜백 (Category selection callback)
  /// [postId] 메인 카테고리 ID
  /// [category] 서브 카테고리 (null 가능)
  final Function(String postId, String? category) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: forumCategories.map((postId) {
        /// philgoTr을 사용하여 다국어 번역된 카테고리 이름 표시
        /// Display localized category name using philgoTr
        final (categoryId, subCategory, name) = postId;
        // final localizedName = philgoTr(context, postId);

        return Card(
          child: ListTile(
            title: Text(name),

            /// 메인 카테고리만 전달 (서브 카테고리는 null)
            /// Pass only main category (sub-category is null)
            onTap: () => onTap(categoryId, null),
          ),
        );
      }).toList(),
    );
  }
}
