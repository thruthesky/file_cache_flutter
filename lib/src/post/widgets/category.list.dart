import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key, required this.onTap});

  final Function(PostCategoryItem) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: PhilgoConfig.categories.map((category) {
        return Card(
          child: ListTile(
            title: Text(category.getLabel(context)),
            onTap: () => onTap(category),
          ),
        );
      }).toList(),
    );
  }
}
