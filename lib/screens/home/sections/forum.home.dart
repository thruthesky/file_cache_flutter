// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/philgo_app.config.dart';
import 'package:philgo/screens/home/widgets/forum.category_header.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/state/forum.state.dart';
import 'package:provider/provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ForumHome extends StatefulWidget {
  const ForumHome({super.key});

  @override
  State<ForumHome> createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  List<PostCategoryItem> get categories => PhilGoAppConfig.getCategories();

  late final PostListViewController controller = PostListViewController();

  @override
  Widget build(BuildContext context) {
    // Selector 사용 - homePostCategory가 변경될 때만 이 부분이 리빌드됨
    // ForumState의 다른 변수(editPostCategory 등)가 변경되어도 리빌드되지 않음
    return Selector<ForumState, PostCategoryItem>(
      selector: (context, state) => state.homePostCategory,
      builder: (context, homePostCategory, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SafeArea(child: Container()),
            ),
            Container(
              height: 70,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 4),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Row(
                    children: [
                      if (index == 0) SizedBox(width: 16),
                      FilterChip(
                        // 현재 선택된 카테고리인지 확인
                        selected:
                            homePostCategory.postId == category.postId &&
                            homePostCategory.category == category.category,
                        label: Text(category.getLabel(context)),
                        // 선택된 칩의 배경색 - alpha 값을 0.3으로 높여서 더 진하게 표시
                        // 이전 0.15는 너무 연해서 선택 상태가 잘 보이지 않았음
                        selectedColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        // 체크마크 색상 - primary 색상 그대로 사용
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        onSelected: (_) => ForumState.of(
                          context,
                        ).setHomePostCategory(category),
                      ),
                      if (index == categories.length - 1) SizedBox(width: 16),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: PostListView(
                controller: controller,
                postCategory: homePostCategory,
                // 게시물 탭 시 PostViewScreen으로 네비게이션하는 콜백 함수 제공
                onTap: (post) async {
                  // PostViewScreen에서 수정된 post를 반환받음
                  await PostViewScreen.push(context, post);

                  // 수정된 post가 있으면 원본 post 객체의 속성 업데이트
                  // post 객체는 레퍼런스이므로 직접 수정하면 리스트에도 반영됨

                  // 원본 post 객체의 수정 가능한 속성만 업데이트
                  // setState를 호출하여 UI 업데이트
                  // PostListView가 다시 빌드되면서 수정된 내용이 화면에 반영됨
                  if (mounted) {
                    setState(() {});
                  }
                },
                headerBuilder: (context, totalPostCount) {
                  return ForumCategoryHeader(
                    // postCategory: homePostCategory,
                    totalPostCount: totalPostCount,
                    onCreated: (post) async {
                      // PostCreateScreen에서 게시물이 생성되면 이 콜백이 호출됩니다.
                      // 여기서 게시물 목록을 새로고침하거나 새 게시물을 목록 상단에 추가하는 등의 작업을 수행할 수 있습니다.
                      debugLog('New post created: $post');
                      // 예: await ForumState.of(context, listen: false).refreshPosts();
                      // 또는 목록 상단에 새 게시물을 추가하는 로직
                      onNewPostCreated(post);
                    },
                  );
                },
                noItemsFoundIndicatorBuilder: (context) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EmptyPostList(),
                        const SizedBox(height: 16),

                        /// Create Post Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final post = await PostCreateScreen.push(context);
                            debugLog('post: $post');
                            if (post != null) {
                              onNewPostCreated(post);
                            }
                          },
                          icon: const FaIcon(
                            FontAwesomeIcons.penToSquare,
                            size: 18,
                          ),
                          label: Text(
                            LibTr.of(context)!.create_post,
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void onNewPostCreated(Post newPost) {
    controller.state.pagingController.refresh();
  }
}
