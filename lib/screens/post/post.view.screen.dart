import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostViewScreen extends StatefulWidget {
  // You may add routeName with dynamic parameters if needed like this:
  // static const String routeName = '/screen-name/:id';
  // And update the push and go methods accordingly like below.
  // static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName.replaceFirst(':id'));
  static const String routeName = '/post-view';

  static Future<Post?> Function(BuildContext ctx, Post post) push =
      (ctx, post) => ctx.push(routeName, extra: post.idx);

  static void Function(BuildContext ctx, Post post) pushReplacement =
      (ctx, post) => ctx.pushReplacement(routeName, extra: post.idx);

  final int postIdx;

  const PostViewScreen({super.key, required this.postIdx});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  Post? post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPost();
  }

  Future<void> loadPost() async {
    try {
      final details = await getPost(widget.postIdx);

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
    if (myIdx == null || post == null) return false;
    return myIdx == post!.idx_member;
  }

  bool isCommentMine(int idxMember) {
    final myIdx = AppState.of(context).user?.idx;
    if (myIdx == null) return false;
    return myIdx == idxMember;
  }

  List<String> get files => post?.files ?? [];
  String get content => post?.content ?? '';
  String get subject => post?.subject ?? '';
  String get nickname {
    final name = post?.nickname ?? '';
    return name.isEmpty ? 'No Name' : name;
  }

  int get stamp => post?.stamp ?? 0;
  String get noOfView => post?.no_of_view.toString() ?? '0';
  int get noOfComment => post?.no_of_comment ?? 0;

  @override
  Widget build(BuildContext context) {
    final hasImages = files.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostViewHeader(
                      subject: subject,
                      nickname: nickname,
                      stamp: stamp,
                      noOfView: noOfView,
                      photoUrl: post?.photo_url,
                      onTapNickname: post != null
                          ? () {
                              /// 닉네임 클릭 시 사용자 프로필 화면으로 이동
                              ProfileViewScreen.push(
                                context,
                                firebaseUid: post!.firebase_uid,
                                nickname: post!.nickname,
                                photoUrl: post!.photo_url,
                              );
                            }
                          : null,
                    ),
                    SizedBox(height: 16),
                    if (hasImages) PostViewImages(files: files),
                    SizedBox(height: 16),
                    PostViewContent(isLoading: false, content: content),
                    SizedBox(height: 16),
                    PostViewButtons(
                      post: post,
                      myPost: isPostMine(),
                      onLike: () async {
                        if (post == null) return;

                        /// Call like API and update the like count
                        try {
                          final updatedGood = await likePost(widget.postIdx);
                          debugLog('Widget Post idx: ${widget.postIdx}');
                          debugLog('Post liked, new good count: $updatedGood');

                          // Update the good count in the current post object
                          post!.good = updatedGood;
                          if (mounted) {
                            setState(() {});
                          }

                          if (context.mounted) {
                            showSuccessSnackBar(context, 'Post liked');
                          }
                        } catch (e) {
                          d('Error liking post: $e');

                          // Handle already-liked error
                          if (e.toString().contains('already-liked')) {
                            if (context.mounted) {
                              showErrorSnackBar(context, 'Already liked this post');
                            }
                          }
                        }
                      },
                      onTapUpdate: () async {
                        if (post == null) return;

                        /// 댓글이 있는 경우 수정 불가
                        if (post!.no_of_comment >= 1) {
                          showInfoDialog(
                            context,
                            Lo.of(context)!.alert,
                            Lo.of(context)!.postWithCommentsCannotBeEdited,
                          );
                          return;
                        }

                        final updatedPost = await PostUpdateScreen.push(
                          context,
                          post: post!,
                        );

                        if (updatedPost != null && mounted) {
                          setState(() {
                            post = updatedPost;
                          });
                        }
                      },
                      onTapDelete: () async {
                        if (post == null) return;

                        /// 댓글이 있는 경우 삭제 불가
                        if (post!.no_of_comment >= 1) {
                          showInfoDialog(
                            context,
                            Lo.of(context)!.alert,
                            Lo.of(context)!.postWithCommentsCannotBeDeleted,
                          );
                          return;
                        }

                        debugLog("deleted post");

                        final confirm = await showConfirmDialog(
                          message: Lo.of(context)!.confirmDeletePost,
                        );

                        if (confirm) {
                          await deletePost(widget.postIdx);

                          if (context.mounted) {
                            context.pop();
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    CommentDetailListView(
                      myComment: isCommentMine,
                      noOfComment: noOfComment,
                      isLoading: false,
                      post: post,
                      onReplied: (createdComment) {
                        int? where = post?.comments.indexWhere(
                          (comment) => comment.idx == createdComment.idx_parent,
                        );

                        if (where != null) {
                          post?.comments.insert(where + 1, createdComment);
                        }

                        post!.no_of_comment += 1;

                        if (mounted) {
                          setState(() {});
                          showSuccessSnackBar(context, 'A comment has replied');
                        }
                      },
                      onUpdated: (oldComment, updatedComment) {
                        oldComment.content = updatedComment.content;
                        oldComment.files = updatedComment.files;

                        if (mounted) {
                          setState(() {});
                          showSuccessSnackBar(context, 'A comment has updated');
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
                  ],
                ),
              ),
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
