import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostViewScreen extends StatefulWidget {
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
  bool isLiked = false; // Track if user has liked the post
  final ScrollController _scrollController = ScrollController();
  Comment? replyingToComment; // Track which comment is being replied to
  Comment? editingComment; // Track which comment is being edited
  // bool showCommentInput = false; // Track if bottom comment input should be visible

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
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 150;

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

  /// Format date as yyyy-mm-dd
  String formatPostDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Show comment input for creating new comment on post

  /// Enter reply mode - convert bottom field to reply to specific comment
  void setReplyMode(Comment comment) {
    setState(() {
      replyingToComment = comment;
      editingComment = null;
    });
  }

  /// Exit reply mode - return to hidden state
  void cancelReplyMode() {
    setState(() {
      replyingToComment = null;
    });
  }

  /// Enter edit mode - convert bottom field to edit specific comment
  void setEditMode(Comment comment) {
    setState(() {
      editingComment = comment;
      replyingToComment = null;
    });
  }

  /// Exit edit mode - return to hidden state
  void cancelEditMode() {
    setState(() {
      editingComment = null;
    });
  }

  /// Show Comic-styled bottom sheet with post options
  void _showPostOptions() {
    final scheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            border: Border(
              top: BorderSide(color: scheme.outline, width: 2.0),
              left: BorderSide(color: scheme.outline, width: 2.0),
              right: BorderSide(color: scheme.outline, width: 2.0),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),

                /// If not my post, show block and report
                if (!isPostMine()) ...[
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.ban, size: 20),
                    title: Text(PhilgoTr.of(context)!.block),
                    onTap: () {
                      Navigator.pop(context);
                      showBlockDialog(
                        context: context,
                        otherUserUid: firebaseUid,
                      );
                    },
                  ),
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.flag, size: 20),
                    title: Text(PhilgoTr.of(context)!.report),
                    onTap: () {
                      Navigator.pop(context);
                      // Report action
                    },
                  ),
                ],

                /// If my post, show edit and delete
                if (isPostMine()) ...[
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.penToSquare, size: 20),
                    title: Text(PhilgoTr.of(context)!.edit),
                    onTap: () async {
                      Navigator.pop(context);

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

                      if (updatedPost != null && mounted) {
                        setState(() {
                          post = updatedPost;
                        });
                      }
                    },
                  ),
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.trash,
                      size: 20,
                      color: scheme.error,
                    ),
                    title: Text(
                      PhilgoTr.of(context)!.delete,
                      style: TextStyle(color: scheme.error),
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      if (post!.no_of_comment >= 1) {
                        showInfoDialog(
                          context,
                          Lo.of(context)!.alert,
                          Lo.of(context)!.postWithCommentsCannotBeDeleted,
                        );
                        return;
                      }

                      final confirm = await showConfirmDialog(
                        message: Lo.of(context)!.confirmDeletePost,
                      );

                      if (confirm) {
                        await deletePost(widget.post.idx);
                        if (context.mounted) {
                          context.pop();
                        }
                      }
                    },
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build Comic-styled action button widget with border
  Widget _buildComicActionButton({
    required IconData icon,
    String? label, // Make label optional
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? scheme.outline,
          width: 2.0, // Comic Design: 2.0 border
        ),
        borderRadius: BorderRadius.circular(8), // Comic Design: rounded corners
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(icon, size: 16, color: color ?? scheme.onSurface),
              if (label != null && label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color ?? scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = files.isNotEmpty;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    /// Comic AppBar with menu icon
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      leading: BackButton(
                        onPressed: () => Navigator.of(context).canPop()
                            ? Navigator.of(context).pop()
                            : context.go(HomeScreen.routeName),
                      ),
                      actions: [
                        /// Comment button - shows/hides bottom input field
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            icon: FaIcon(FontAwesomeIcons.bars, size: 20),
                            onPressed: _showPostOptions,
                          ),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(1),
                        child: Container(height: 2, color: scheme.outline),
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
                                        '${PhilgoTr.of(context)!.post_from_blocked_user} $nickname',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: scheme.onSurface
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
                                /// Post title - larger and more prominent
                                Text(
                                  subject,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                /// Avatar, name, and date
                                GestureDetector(
                                  onTap: () {
                                    ProfileViewScreen.push(
                                      context,
                                      firebaseUid: firebaseUid,
                                      nickname: nickname,
                                      photoUrl: photoUrl,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Avatar(photoUrl: photoUrl, size: 40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nickname,
                                              style: theme.textTheme.bodyLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              formatPostDate(stamp),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: scheme.onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                /// Images first (if available)
                                /// Hero 트랜지션 항상 활성화
                                /// Forum 탭에서만 PostListTile 사용되므로 충돌 없음
                                if (hasImages) ...[
                                  PostViewImages(
                                    files: files,
                                    postIdx: widget.post.idx,
                                    enableHeroTransition: true,
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                /// Post content
                                PostViewContent(
                                  isLoading: false,
                                  content: content,
                                ),
                                const SizedBox(height: 24),

                                /// Action buttons with Comic design and border
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: scheme.outline,
                                        width: 2.0, // Comic Design: 2.0 border
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      /// Like button
                                      _buildComicActionButton(
                                        icon: isLiked
                                            ? FontAwesomeIcons.solidThumbsUp
                                            : FontAwesomeIcons.thumbsUp,
                                        label:
                                            post?.good != null && post!.good > 0
                                            ? '${post!.good}'
                                            : null, // Hide label when 0
                                        color: scheme.primary,
                                        onPressed: () async {
                                          try {
                                            final updatedGood = await likePost(
                                              widget.post.idx,
                                            );
                                            (post ?? widget.post).good =
                                                updatedGood;
                                            if (mounted) {
                                              setState(() {
                                                isLiked = true;
                                              });
                                            }
                                            if (context.mounted) {
                                              showSuccessSnackBar(
                                                context,
                                                'Post liked',
                                              );
                                            }
                                          } catch (e) {
                                            d('Error liking post: $e');
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
                                      ),

                                      const SizedBox(width: 8),

                                      const Spacer(),

                                      /// If not my post, show block and report
                                      if (!isPostMine()) ...[
                                        _buildComicActionButton(
                                          icon: FontAwesomeIcons.ban,
                                          label: PhilgoTr.of(context)!.block,
                                          onPressed: () {
                                            showBlockDialog(
                                              context: context,
                                              otherUserUid: firebaseUid,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        PostReportButton(
                                          type: 'post',
                                          idx: widget.post.idx,
                                          post: widget.post,
                                        ),
                                      ],

                                      /// If my post, show only edit and delete
                                      if (isPostMine()) ...[
                                        _buildComicActionButton(
                                          icon: FontAwesomeIcons.penToSquare,
                                          label: PhilgoTr.of(context)!.edit,
                                          onPressed: () async {
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
                                              widget.post.subject =
                                                  updatedPost.subject;
                                              widget.post.content =
                                                  updatedPost.content;
                                            }

                                            if (updatedPost != null &&
                                                mounted) {
                                              setState(() {
                                                post = updatedPost;
                                              });
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        _buildComicActionButton(
                                          icon: FontAwesomeIcons.trash,
                                          label: PhilgoTr.of(context)!.delete,
                                          color: scheme.error,
                                          onPressed: () async {
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

                                            final confirm =
                                                await showConfirmDialog(
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
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          /// Comment section
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
                              post?.comments.removeWhere(
                                (comment) => comment.idx == deletedComment.idx,
                              );

                              post!.no_of_comment -= 1;

                              if (mounted) {
                                setState(() {});
                              }
                            },
                            onReplyClicked: setReplyMode,
                            onEditClicked: setEditMode,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),

                /// Floating post info bar
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
                        child: GestureDetector(
                          onTap: () {
                            _scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            height: 64,
                            decoration: BoxDecoration(
                              color: scheme.surface,
                              border: Border(
                                bottom: BorderSide(
                                  color: scheme.outlineVariant,
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
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Builder(
                                        builder: (context) {
                                          final goodCount =
                                              post?.good ?? widget.post.good;
                                          final commentCount = noOfComment;

                                          if ((goodCount) <= 0 &&
                                              commentCount <= 0) {
                                            return const SizedBox.shrink();
                                          }

                                          final children = <Widget>[];

                                          if ((goodCount) > 0) {
                                            children.addAll([
                                              Icon(
                                                Icons.thumb_up,
                                                size: 14,
                                                color: scheme.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$goodCount',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ]);
                                          }

                                          if ((goodCount) > 0 &&
                                              commentCount > 0) {
                                            children.add(
                                              const SizedBox(width: 12),
                                            );
                                          }

                                          if (commentCount > 0) {
                                            children.addAll([
                                              Icon(
                                                Icons.comment,
                                                size: 14,
                                                color: scheme.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '$commentCount',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ]);
                                          }

                                          return Row(children: children);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_up,
                                  size: 24,
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ],
                            ),
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
              child:
                  Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          border: Border(
                            top: BorderSide(color: scheme.outline, width: 1.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Context header (shown when in reply or edit mode)
                            if (replyingToComment != null ||
                                editingComment != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        editingComment != null
                                            ? Icons.edit
                                            : Icons.reply,
                                        size: 16,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            editingComment != null
                                                ? Lo.of(
                                                    context,
                                                  )!.editing_comment
                                                : '${Lo.of(context)!.replying_to} ${replyingToComment!.nickname}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: scheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Comment content preview
                                          Text(
                                            editingComment != null
                                                ? editingComment!.content
                                                : replyingToComment!.content,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 20),
                                      onPressed: editingComment != null
                                          ? cancelEditMode
                                          : cancelReplyMode,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ),

                            // Input field (switches between CommentToPost, ReplyToComment, and CommentUpdate)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: editingComment != null
                                  ? CommentUpdate(
                                      comment: editingComment!,
                                      onUpdated: (updatedComment) {
                                        // Find and update the comment in the list
                                        final index = post?.comments.indexWhere(
                                          (c) => c.idx == updatedComment.idx,
                                        );
                                        if (index != null && index >= 0) {
                                          post?.comments[index].content =
                                              updatedComment.content;
                                          post?.comments[index].files =
                                              updatedComment.files;
                                        }

                                        // Exit edit mode and show success
                                        cancelEditMode();

                                        if (mounted) {
                                          setState(() {});
                                          showSuccessSnackBar(
                                            context,
                                            'A comment has updated',
                                          );
                                        }
                                      },
                                    )
                                  : replyingToComment != null
                                  ? ReplyToComment(
                                      parent: replyingToComment!,
                                      onReplied: (createdComment) {
                                        int? where = post?.comments.indexWhere(
                                          (comment) =>
                                              comment.idx ==
                                              createdComment.idx_parent,
                                        );

                                        if (where != null) {
                                          post?.comments.insert(
                                            where + 1,
                                            createdComment,
                                          );
                                        }

                                        post!.no_of_comment += 1;

                                        // Exit reply mode and show success
                                        cancelReplyMode();

                                        if (mounted) {
                                          setState(() {});
                                          showSuccessSnackBar(
                                            context,
                                            'A comment has replied',
                                          );
                                        }
                                      },
                                    )
                                  : CommentToPost(
                                      post: post!,
                                      onCreated: (createdComment) {
                                        post?.comments.add(createdComment);
                                        post!.no_of_comment += 1;

                                        if (mounted) {
                                          setState(() {});
                                          showSuccessSnackBar(
                                            context,
                                            'Comment has created',
                                          );
                                        }
                                      },
                                    ),
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .slideY(
                        begin: 1.0, // Start from below (100% down)
                        end: 0.0, // End at normal position
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeIn(duration: 200.ms),
            )
          : null,
    );
  }
}
