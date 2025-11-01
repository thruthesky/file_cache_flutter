import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
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
              ),
              SizedBox(height: 16),
              if (hasImages) PostViewImages(files: files),
              SizedBox(height: 16),
              PostViewContent(isLoading: isLoading, content: content),
              SizedBox(height: 16),
              PostViewButtons(
                post: post,
                onTapUpdate: () async {
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
              ),
              SizedBox(height: 16),
              ReplyToPost(
                post: widget.post,
                onCreated: (createdComment) {
                  post?.comments.add(createdComment);
                  post!.no_of_comment += 1;
                  setState(() {});
                  showSuccessSnackBar(context, 'Comment has created');
                },
              ),
              SizedBox(height: 32),
              CommentDetailListView(
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
                  // int? where = post?.comments.indexWhere(
                  //   (comment) => comment.idx == updatedComment.idx,
                  // );

                  // if (where != null && where >= 0) {
                  //   post?.comments[where] = updatedComment;
                  // }

                  oldComment.content = updatedComment.content;

                  setState(() {});
                  showSuccessSnackBar(context, 'A comment has updated');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
