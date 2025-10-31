// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/state/forum.state.dart';
import 'package:v6_apps/v6_apps.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForumCategoryHeader extends StatelessWidget {
  const ForumCategoryHeader({
    super.key,
    // required this.postCategory,
    this.totalPostCount,
    required this.onCreated,
  });

  // final PostCategoryItem postCategory;
  final int? totalPostCount;
  final Future<void> Function(Post) onCreated;

  String get label => HomePostCategory.label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Row(
        children: [
          // RichText를 사용하여 카테고리 레이블과 게시글 수를 하나의 텍스트로 표시
          RichText(
            text: TextSpan(
              children: [
                // 카테고리 레이블 - bodySmall 스타일 적용
                TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                // 띄어쓰기 추가
                TextSpan(
                  text: ' ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                // 게시글 수 - 기본 텍스트 스타일 사용
                TextSpan(
                  text: T.noOfPosts(totalPostCount ?? 0),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    // 게시글 수를 약간 다른 색상으로 표시하여 구분
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            onPressed: () async {
              final created = await PostCreateScreen.push(context);
              // debugLog('post created: $created');
              // debugLog("Refresh the post list or add it on top of the list");
              if (created != null) {
                await onCreated(created);
              }
            },
            icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
            label: Text(T.writePost),
          ),
        ],
      ),
    );
  }
}
