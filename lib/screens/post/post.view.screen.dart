import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostViewScreen extends StatefulWidget {
  // You may add routeName with dynamic parameters if needed like this:
  // static const String routeName = '/screen-name/:id';
  // And update the push and go methods accordingly like below.
  // static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName.replaceFirst(':id'));
  static const String routeName = '/post-view';

  static Future<Post?> Function(BuildContext ctx, Post post) push =
      (ctx, post) => ctx.push(routeName, extra: post);

  static void Function(BuildContext ctx, Post post) pushReplacement =
      (ctx, post) => ctx.pushReplacement(routeName, extra: post);

  final Post post;

  const PostViewScreen({super.key, required this.post});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  Post? post;
  bool isLoading = true;
  bool showPostInfoBar = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPost();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show post info bar when scrolled past a certain point
    // This will be triggered when reaching the comment section
    final shouldShow =
        _scrollController.hasClients &&
        _scrollController.offset > 150; // Adjust threshold as needed

    if (shouldShow != showPostInfoBar) {
      setState(() {
        showPostInfoBar = shouldShow;
      });
    }
  }

  Future<void> loadPost() async {
    try {
      final details = await getPost(widget.post.idx);

      debugLog('------> LOADED POST: $details');

      if (mounted) {
        setState(() {
          post = details;
          isLoading = false;
        });
      }
    } catch (e) {
      d('Error fetching post details: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool isPostMine() {
    final myIdx = AppState.of(context).user?.idx;
    if (myIdx == null) return false;
    return myIdx == widget.post.idx_member;
  }

  bool isCommentMine(int idxMember) {
    final myIdx = AppState.of(context).user?.idx;
    if (myIdx == null) return false;
    return myIdx == idxMember;
  }

  List<String> get files => post != null ? post!.files : widget.post.files;
  String get content => post != null ? post!.content : widget.post.content;
  String get subject => post != null ? post!.subject : widget.post.subject;
  String get nickname {
    final name = post != null ? post!.nickname : widget.post.nickname;
    return name.isEmpty ? 'No Name' : name;
  }

  int get stamp => post?.stamp ?? widget.post.stamp;
  String get noOfView => post != null
      ? post!.no_of_view.toString()
      : widget.post.no_of_view.toString();
  int get noOfComment =>
      post != null ? post!.no_of_comment : widget.post.no_of_comment;
  String? get photoUrl => post?.photo_url ?? widget.post.photo_url;
  String get firebaseUid => post?.firebase_uid ?? widget.post.firebase_uid;

  @override
  Widget build(BuildContext context) {
    final hasImages = files.isNotEmpty;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    /// Primary colored AppBar
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      leading: BackButton(
                        onPressed: () => Navigator.of(context).canPop()
                            ? Navigator.of(context).pop()
                            : context.go(HomeScreen.routeName),
                      ),
                    ),

                    /// Main content
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Blocked(
                            otherUserUid: firebaseUid,
                            yes: () => GestureDetector(
                              onTap: () {
                                showUnblockDialog(
                                  context: context,
                                  otherUserUid: firebaseUid,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Avatar(photoUrl: photoUrl),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '${LibTr.of(context)!.post_from_blocked_user} $nickname',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            no: () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PostViewHeader(
                                  subject: subject,
                                  nickname: nickname,
                                  stamp: stamp,
                                  noOfView: noOfView,
                                  photoUrl: photoUrl,
                                  onTapNickname: () {
                                    /// 닉네임 클릭 시 사용자 프로필 화면으로 이동
                                    ProfileViewScreen.push(
                                      context,
                                      firebaseUid: firebaseUid,
                                      nickname: nickname,
                                      photoUrl: photoUrl,
                                    );
                                  },
                                ),
                                SizedBox(height: 16),
                                if (hasImages)
                                  Selector<NavigationState, bool>(
                                    selector: (context, state) =>
                                        state.homeNav ==
                                        HomeNavigationItem.forum,
                                    builder: (context, isInForum, _) {
                                      return PostViewImages(
                                        files: files,
                                        postIdx: widget.post.idx,
                                        enableHeroTransition: isInForum,
                                      );
                                    },
                                  ),
                                SizedBox(height: 16),
                                PostViewContent(
                                  isLoading: false,
                                  content: content,
                                ),
                                SizedBox(height: 16),
                                PostViewButtons(
                                  post: post,
                                  myPost: isPostMine(),
                                  onLike: () async {
                                    /// Call like API and update the like count
                                    try {
                                      final updatedGood = await likePost(
                                        widget.post.idx,
                                      );
                                      debugLog(
                                        'Widget Post idx: ${widget.post.idx}',
                                      );
                                      debugLog(
                                        'Post liked, new good count: $updatedGood',
                                      );

                                      // Update the good count in the current post object
                                      (post ?? widget.post).good = updatedGood;
                                      if (mounted) {
                                        setState(() {});
                                      }

                                      if (context.mounted) {
                                        showSuccessSnackBar(
                                          context,
                                          'Post liked',
                                        );
                                      }
                                    } catch (e) {
                                      d('Error liking post: $e');

                                      // Handle already-liked error
                                      if (e.toString().contains(
                                        'already-liked',
                                      )) {
                                        if (context.mounted) {
                                          showErrorSnackBar(
                                            context,
                                            'Already liked this post',
                                          );
                                        }
                                      }
                                    }
                                  },
                                  onTapUpdate: () async {
                                    /// 댓글이 있는 경우 수정 불가
                                    if (post!.no_of_comment >= 1) {
                                      showInfoDialog(
                                        context,
                                        Lo.of(context)!.alert,
                                        Lo.of(
                                          context,
                                        )!.postWithCommentsCannotBeEdited,
                                      );
                                      return;
                                    }

                                    final updatedPost =
                                        await PostUpdateScreen.push(
                                          context,
                                          post: post!,
                                        );
                                    if (updatedPost != null) {
                                      widget.post.subject = updatedPost.subject;
                                      widget.post.content = updatedPost.content;
                                    }

                                    if (updatedPost != null && mounted) {
                                      setState(() {
                                        post = updatedPost;
                                      });
                                    }
                                  },
                                  onTapDelete: () async {
                                    /// 댓글이 있는 경우 삭제 불가
                                    if (post!.no_of_comment >= 1) {
                                      showInfoDialog(
                                        context,
                                        Lo.of(context)!.alert,
                                        Lo.of(
                                          context,
                                        )!.postWithCommentsCannotBeDeleted,
                                      );
                                      return;
                                    }

                                    debugLog("deleted post");

                                    final confirm = await showConfirmDialog(
                                      message: Lo.of(
                                        context,
                                      )!.confirmDeletePost,
                                    );

                                    if (confirm) {
                                      await deletePost(widget.post.idx);

                                      if (context.mounted) {
                                        context.pop();
                                      }
                                    }
                                  },
                                  onTapBlock: () {
                                    showBlockDialog(
                                      context: context,
                                      otherUserUid: firebaseUid,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),
                          CommentDetailListView(
                            myComment: isCommentMine,
                            noOfComment: noOfComment,
                            isLoading: false,
                            post: post,
                            onReplied: (createdComment) {
                              int? where = post?.comments.indexWhere(
                                (comment) =>
                                    comment.idx == createdComment.idx_parent,
                              );

                              if (where != null) {
                                post?.comments.insert(
                                  where + 1,
                                  createdComment,
                                );
                              }

                              post!.no_of_comment += 1;

                              if (mounted) {
                                setState(() {});
                                showSuccessSnackBar(
                                  context,
                                  'A comment has replied',
                                );
                              }
                            },
                            onUpdated: (oldComment, updatedComment) {
                              oldComment.content = updatedComment.content;
                              oldComment.files = updatedComment.files;

                              if (mounted) {
                                setState(() {});
                                showSuccessSnackBar(
                                  context,
                                  'A comment has updated',
                                );
                              }
                            },
                            onDeleted: (deletedComment) {
                              // Remove the deleted comment from the list
                              post?.comments.removeWhere(
                                (comment) => comment.idx == deletedComment.idx,
                              );

                              // Decrease comment count
                              post!.no_of_comment -= 1;

                              // Update UI
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),

                /// Floating post info bar that appears on scroll
                Positioned(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: !showPostInfoBar,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      offset: showPostInfoBar
                          ? Offset.zero
                          : const Offset(0, -1),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: showPostInfoBar ? 1.0 : 0.0,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              /// Thumbnail image (if available)
                              if (hasImages)
                                Container(
                                  width: 44,
                                  height: 44,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    image: DecorationImage(
                                      image: NetworkImage(files.first),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                              /// Title, likes, and comments info
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Post title
                                    Text(
                                      subject.isNotEmpty
                                          ? subject
                                          : content.substring(
                                              0,
                                              content.length > 20
                                                  ? 20
                                                  : content.length,
                                            ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 4),

                                    /// Likes and comments count
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${post?.good ?? widget.post.good}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.comment,
                                          size: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$noOfComment',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: post != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CommentToPost(
                  post: post!,
                  onCreated: (createdComment) {
                    post?.comments.add(createdComment);
                    post!.no_of_comment += 1;
                    if (mounted) {
                      setState(() {});
                      showSuccessSnackBar(context, 'Comment has created');
                    }
                  },
                ),
              ),
            )
          : null,
    );
  }
}
