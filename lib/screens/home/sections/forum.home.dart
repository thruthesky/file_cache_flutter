// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
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
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top SafeArea
                SafeArea(child: Container()),

                // Forum Title
                Container(
                  // 포럼 타이틀 배경색 - primaryContainer 사용
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    Lo.of(context)!.forum,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),

                // Filter Chips (Category Tabs)
                SizedBox(
                  height: 60,
                  // 필터 칩 영역도 primaryContainer 배경색 사용
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Row(
                        children: [
                          if (index == 0) const SizedBox(width: 16),
                          FilterChip(
                            // 현재 선택된 카테고리인지 확인
                            selected:
                                homePostCategory.postId == category.postId &&
                                homePostCategory.category == category.category,
                            label: Text(category.getLabel(context)),
                            // 선택된 칩의 배경색
                            selectedColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            // 체크마크 색상
                            checkmarkColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            onSelected: (_) => ForumState.of(
                              context,
                            ).setHomePostCategory(category),
                          ),
                          if (index == categories.length - 1)
                            const SizedBox(width: 16),
                        ],
                      );
                    },
                  ),
                ),

                // Post List
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
                      return Row(
                        children: [
                          ForumCategoryHeader(totalPostCount: totalPostCount),
                          Spacer(),
                          FilledButton.icon(
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
                            label: Text(LibTr.of(context)!.create_post),
                          ),
                        ],
                      );
                    },
                    noItemsFoundIndicatorBuilder: (context) {
                      return const Center(child: EmptyPostList());
                    },
                  ),
                ),
              ],
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
