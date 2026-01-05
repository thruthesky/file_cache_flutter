import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/post/widgets/post_blocked_user_info.dart';
import 'package:philgo/screens/post/widgets/post_view_buttons.dart';
import 'package:philgo/screens/post/widgets/post_view_comment_box.dart';
import 'package:philgo/screens/post/widgets/post_view_app_bar.dart';
import 'package:philgo/screens/post/widgets/post_view_meta.dart';
import 'package:philgo/screens/post/widgets/post_view_subject.dart';
import 'package:philgo/screens/post/widgets/sliver_comment_list.dart';
import 'package:philgo/widgets/unfocus_on_tap.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  /// ScrollController for programmatic scrolling to newly created comments
  late ScrollController _scrollController;

  /// FocusNode for comment input field
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    post = widget.post;
    _scrollController = ScrollController();

    // Listen to focus changes to auto-scroll when textfield is focused
    _commentFocusNode.addListener(_onFocusChange);

    loadPost();
  }

  /// Called when comment input focus changes
  /// Automatically scrolls content up when keyboard appears
  void _onFocusChange() {
    if (_commentFocusNode.hasFocus) {
      // Keyboard is appearing, scroll to bottom after a delay
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _commentFocusNode.removeListener(_onFocusChange);
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  /// Load post details from server
  Future<void> loadPost() async {
    try {
      final details = await getPost(widget.post.idx);

      // debugLog('------> LOADED POST: $details');

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
  ///
  @Deprecated('use post?.isMine instead')
  bool isPostMine() {
    final myIdx = PhilgoState.of(context).user?.idx;
    return myIdx == widget.post.idx_member;
  }

  /// Check if a comment belongs to the logged-in user
  ///
  @Deprecated('use comment.isMine instead')
  bool isCommentMine(int idxMember) {
    final myIdx = PhilgoState.of(context).user?.idx;
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

  int get idxMember => post != null ? post!.idx_member : widget.post.idx_member;

  int get stamp => post?.stamp ?? widget.post.stamp;
  String get noOfView => post != null
      ? post!.no_of_view.toString()
      : widget.post.no_of_view.toString();
  int get noOfComment =>
      post != null ? post!.no_of_comment : widget.post.no_of_comment;
  String? get photoUrl => post?.photo_url ?? widget.post.photo_url;
  String get firebaseUid => post?.firebase_uid ?? widget.post.firebase_uid;

  int? get adExpiryTimestamp {
    final timestamp = post?.int5 ?? widget.post.int5;
    if (timestamp == null || timestamp <= 0) {
      return null;
    }
    return timestamp;
  }

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

  /// Scroll to bottom of the list to show newly created comment
  /// Adds a small delay to ensure the new comment is rendered before scrolling
  void scrollToBottom() {
    // Dismiss keyboard immediately
    FocusScope.of(context).unfocus();

    // Wait for the widget tree to rebuild with the new comment
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Focus on the reply input field
  /// The _onFocusChange listener will handle scrolling automatically
  void onTapReply() {
    if (mounted) {
      _commentFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFiles = files.isNotEmpty;
    final adExpiry = adExpiryTimestamp;

    return UnfocusOnTap(
      child: Scaffold(
        // 키보드가 올라올 때 bottomNavigationBar가 키보드 위로 이동하도록 설정
        resizeToAvoidBottomInset: true,
        appBar: PostViewAppBar(
          post: post!,
          onTapReply: onTapReply,
          onEditCompleted: (updated) {
            // 원본 위젯의 게시글 데이터도 업데이트
            if (mounted) {
              setState(() {
                post = updated;
              });
            }
          },
          onDeleteCompleted: (context) {
            context.pop();
          },
        ),
        // 댓글 입력 박스를 하단에 고정
        // bottomNavigationBar는 키보드가 올라올 때 자동으로 위로 이동하고
        // Safe Area도 자동으로 처리됨
        bottomNavigationBar: PostViewCommentBox(
          post: post,
          replyingToComment: replyingToComment,
          editingComment: editingComment,
          commentFocusNode: _commentFocusNode,
          onCancelReplyMode: cancelReplyMode,
          onCancelEditMode: cancelEditMode,
          onScrollToBottom: scrollToBottom,
          onStateChanged: () => setState(() {}),
        ),
        // CustomScrollView를 사용하여 댓글 목록을 lazy loading
        // SingleChildScrollView + Column 대신 Sliver 기반으로 성능 최적화
        body: post == null && isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  /// [Top Banners]
                  /// 상단 배너 - 전체 페이지 배너 표시
                  /// Top banners - display all page banners
                  SliverToBoxAdapter(
                    child: TopBanners(
                      onTap: (url) => openBannerUrl(context, url),
                    ),
                  ),

                  // 게시글 내용 (Blocked 위젯으로 차단 여부에 따라 다른 UI 표시)
                  SliverToBoxAdapter(
                    child: Blocked(
                      otherUserUid: firebaseUid,
                      // 차단된 사용자의 게시글 정보 표시 (탭하면 차단 해제 다이얼로그)
                      yes: () => PostBlockedUserInfo(
                        photoUrl: photoUrl,
                        nickname: nickname,
                        firebaseUid: firebaseUid,
                      ),
                      no: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (adExpiry != null) ...[
                            // const SizedBox(height: 12),
                            PostAdInfoBanner(expiryTimestamp: adExpiry),
                          ],

                          /// Post title - larger and more prominent
                          PostViewSubject(subject: subject),

                          /// Avatar, name, and date
                          PostViewMeta(
                            idxMember: idxMember,
                            nickname: nickname,
                            photoUrl: photoUrl,
                            formattedDate: formatPostDate(stamp),
                          ),

                          SizedBox(height: 16),

                          /// Files (images, videos, and other files) first (if available)
                          if (hasFiles) ...[
                            PostViewFiles(
                              files: files,
                              postIdx: widget.post.idx,
                              enableHeroTransition: true,
                            ),
                          ],

                          PostViewYoutubes(post: post!),

                          /// Post content
                          PostViewContent(isLoading: false, post: post!),

                          /// 액션 버튼 (좋아요, 답글, 차단, 신고, 수정, 삭제)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: PostViewButtons(
                              post: post!,
                              isLiked: isLiked,
                              onLikeToggled: (liked) {
                                setState(() {
                                  isLiked = liked;
                                });
                              },
                              onTapReply: onTapReply,
                              onEditCompleted: (updatedPost) {
                                // 원본 위젯의 게시글 데이터도 업데이트
                                widget.post.subject = updatedPost.subject;
                                widget.post.content = updatedPost.content;

                                if (mounted) {
                                  setState(() {
                                    post = updatedPost;
                                  });
                                }
                              },
                              onDeleteCompleted: (context) {
                                context.pop();
                              },
                              onUpdated: (updated) =>
                                  setState(() => post = updated),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 게시글과 댓글 사이 간격
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 댓글 목록 (SliverList로 lazy loading하여 성능 최적화)
                  SliverCommentList(
                    post: post,
                    myComment: isCommentMine,
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
                        showSuccessSnackBar(
                          context,
                          Lo.of(context)!.commentReplied,
                        );
                        // Scroll to bottom to show the new reply
                        scrollToBottom();
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
                        // Scroll to bottom to show the updated comment
                        scrollToBottom();
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
                ],
              ),
      ),
    );
  }
}
