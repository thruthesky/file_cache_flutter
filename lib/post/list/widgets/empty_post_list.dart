import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyPostList extends StatelessWidget {
  final ColorScheme scheme;
  const EmptyPostList({super.key, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.lightFolderOpen,
            size: 48,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '게시글이 없습니다'.tr(),
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
