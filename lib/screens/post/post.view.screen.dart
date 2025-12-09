import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Post View Screen
///
/// Displays a post with its content, images, comments, and action buttons.
/// The layout is designed to work like a chat application where the comment
/// input field stays at the bottom and becomes visible when keyboard appears.
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
  bool isLiked = false;
  Comment? replyingToComment;
  Comment? editingComment;

  @override
  void initState() {
    super.initState();
    loadPost();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Load post details from server
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

  /// Check if the current post belongs to the logged-in user
  bool isPostMine() {
    final myIdx = AppState.of(context).user?.idx;
    if (myIdx == null) return false;
    return myIdx == widget.post.idx_member;
  }

  /// Check if a comment belongs to the logged-in user
  bool isCommentMine(int idxMember) {
    final myIdx = AppState.of(context).user?.idx;
    if (myIdx == null) return false;
    return myIdx == idxMember;
  }

  // Getters for post data with fallback to widget.post
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

  /// Enter reply mode - convert bottom field to reply to specific comment
  void setReplyMode(Comment comment) {
    setState(() {
      replyingToComment = comment;
      editingComment = null;
    });
  }

  /// Exit reply mode - return to normal state
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

  /// Exit edit mode - return to normal state
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

                      await showPostUpdateDialog(
                        context,
                        post: post!,
                        onUpdated: (updated) {
                          widget.post.subject = updated.subject;
                          widget.post.content = updated.content;

                          if (mounted) {
                            setState(() {
                              post = updated;
                            });
                          }
                        },
                      );
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
    String? label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color ?? scheme.outline, width: 2.0),
        borderRadius: BorderRadius.circular(8),
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
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
        actions: [
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
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
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
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Avatar(photoUrl: photoUrl),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${PhilgoTr.of(context)!.post_from_blocked_user} $nickname',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
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
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                            if (hasImages) ...[
                              PostViewImages(
                                files: files,
                                postIdx: widget.post.idx,
                                enableHeroTransition: true,
                              ),
                              const SizedBox(height: 16),
                            ],

                            /// Post content
                            PostViewContent(isLoading: false, content: content),
                            const SizedBox(height: 24),

                            /// Action buttons with Comic design and border
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: scheme.outline,
                                    width: 2.0,
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
                                    label: post?.good != null && post!.good > 0
                                        ? '${post!.good}'
                                        : null,
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
                                            Lo.of(context)!.postLiked,
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
                                              Lo.of(context)!.alreadyLikedPost,
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

                                        await showPostUpdateDialog(
                                          context,
                                          post: post!,
                                          onUpdated: (updated) {
                                            widget.post.subject =
                                                updated.subject;
                                            widget.post.content =
                                                updated.content;

                                            if (mounted) {
                                              setState(() {
                                                post = updated;
                                              });
                                            }
                                          },
                                        );
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
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

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
                            post?.comments.insert(where + 1, createdComment);
                          }

                          post!.no_of_comment += 1;

                          if (mounted) {
                            setState(() {});
                            showSuccessSnackBar(
                              context,
                              Lo.of(context)!.commentReplied,
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
                              Lo.of(context)!.commentUpdated,
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

                /// Bottom spacing to prevent content from being hidden behind the sticky comment input
                /// On iOS, we need more space to account for the bottomSheet height
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 0
                        : 200,
                  ),
                ),
              ],
            ),

      /// Sticky comment input at the bottom (like chat apps)
      bottomSheet: post != null
          ? Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  top: BorderSide(color: scheme.outlineVariant, width: 1.0),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Context header (shown when in reply or edit mode)
                    if (replyingToComment != null || editingComment != null)
                      Container(
                        decoration: BoxDecoration(color: scheme.surface),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    editingComment != null
                                        ? Lo.of(context)!.editing_comment
                                        : '${Lo.of(context)!.replying_to} ${replyingToComment!.nickname}',
                                    style: theme.textTheme.bodySmall?.copyWith(
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
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
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
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 32,
                        left: 16,
                        right: 16,
                      ),
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
                                    Lo.of(context)!.commentUpdated,
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
                                      comment.idx == createdComment.idx_parent,
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
                                    Lo.of(context)!.commentReplied,
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
                                    Lo.of(context)!.commentCreated,
                                  );
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
