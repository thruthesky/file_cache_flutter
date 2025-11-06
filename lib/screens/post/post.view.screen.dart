import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/user/user.profile.screen.dart';
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

  @override
  void initState() {
    super.initState();
    loadPost();
  }

  Future loadPost() async {
    try {
      final details = await getPost(widget.post.idx);

      debugLog('------> LOADED POST: $details');

      setState(() {
        post = details;
        isLoading = false;
      });
    } catch (e) {
      d('Error fetching post details: $e');
      setState(() {
        isLoading = false;
      });
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
  String get nickname => post != null ? post!.nickname : widget.post.nickname;
  String get timeString => widget.post.timeString;
  String get noOfView => post != null
      ? post!.no_of_view.toString()
      : widget.post.no_of_view.toString();
  int get noOfComment =>
      post != null ? post!.no_of_comment : widget.post.no_of_comment;

  @override
  Widget build(BuildContext context) {
    final hasImages = files.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,

        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PostViewHeader(
                subject: subject,
                nickname: nickname,
                timeString: widget.post.timeString,
                noOfView: noOfView,
                photoUrl: widget.post.photo_url,
                onTapNickname: () {
                  /// 닉네임 클릭 시 사용자 프로필 화면으로 이동
                  UserProfileScreen.push(
                    context,
                    firebaseUid: widget.post.firebase_uid,
                    nickname: widget.post.nickname,
                    photoUrl: widget.post.photo_url,
                  );
                },
              ),
              SizedBox(height: 16),
              if (hasImages) PostViewImages(files: files),
              SizedBox(height: 16),
              PostViewContent(isLoading: isLoading, content: content),
              SizedBox(height: 16),
              PostViewButtons(
                post: post,
                myPost: isPostMine(),
                onTapUpdate: () async {
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
                  if (updatedPost != null) {
                    widget.post.subject = updatedPost.subject;
                    widget.post.content = updatedPost.content;
                  }

                  if (updatedPost != null) {
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
                      Lo.of(context)!.postWithCommentsCannotBeDeleted,
                    );
                    return;
                  }

                  debugLog("deleted post");

                  final confirm = await showConfirmDialog(
                    message: Lo.of(context)!.confirmDeletePost,
                  );

                  if (confirm) {
                    await philgoApiDeletePost(widget.post.idx);

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
                isLoading: isLoading,
                post: post,
                onReplied: (createdComment) {
                  int? where = post?.comments.indexWhere(
                    (comment) => comment.idx == createdComment.idx_parent,
                  );

                  if (where != null) {
                    post?.comments.insert(where + 1, createdComment);
                  }

                  post!.no_of_comment += 1;

                  setState(() {});
                  showSuccessSnackBar(context, 'A comment has replied');
                },
                onUpdated: (oldComment, updatedComment) {
                  oldComment.content = updatedComment.content;
                  oldComment.files = updatedComment.files;

                  setState(() {});
                  showSuccessSnackBar(context, 'A comment has updated');
                },
                onDeleted: (deletedComment) {
                  // Remove the deleted comment from the list
                  post?.comments.removeWhere(
                    (comment) => comment.idx == deletedComment.idx,
                  );

                  // Decrease comment count
                  post!.no_of_comment -= 1;

                  // Update UI
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CommentToPost(
            post: widget.post,
            onCreated: (createdComment) {
              post?.comments.add(createdComment);
              post!.no_of_comment += 1;
              setState(() {});
              showSuccessSnackBar(context, 'Comment has created');
            },
          ),
        ),
      ),
    );
  }
}
