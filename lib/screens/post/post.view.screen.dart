import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/post/widgets/post_blocked_user_info.dart';
import 'package:philgo/screens/post/widgets/post_view_app_bar.dart';
import 'package:philgo/screens/post/widgets/post_view_buttons.dart';
import 'package:philgo/screens/post/widgets/post_view_comment_box.dart';
import 'package:philgo/screens/post/widgets/post_view_meta.dart';
import 'package:philgo/screens/post/widgets/post_view_subject.dart';
import 'package:philgo/screens/post/widgets/sliver_comment_list.dart';
import 'package:philgo/widgets/unfocus_on_tap.dart';
import 'package:philgo_api/philgo_api.dart';

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
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
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
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  /// Load post details from server
  ///
  /// 게시글 상세 정보를 서버에서 가져오고 조회수를 1 증가시킵니다.
  Future<void> loadPost() async {
    try {
      // 조회수 증가 (fire-and-forget 방식)
      // 실패해도 게시글 로드에 영향 없음
      increasePostView(widget.post.idx);

      final details = await getPost(widget.post.idx);

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
                      no: () => _buildPostContent(
                        context: context,
                        adExpiry: adExpiry,
                        hasFiles: hasFiles,
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

  /// 제목 skeleton 위젯 빌드
  /// 로딩 중이고 파라미터로 제목이 넘어오지 않았을 때 표시
  ///
  /// Build subject skeleton widget
  /// Displayed when loading and subject was not passed as parameter
  Widget _buildSubjectSkeleton(ColorScheme scheme) {
    return Container(
      height: 28,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// 내용 skeleton 위젯 빌드
  /// 로딩 중이고 파라미터로 내용이 넘어오지 않았을 때 표시
  /// 여러 줄의 skeleton으로 자연스러운 로딩 효과 제공
  ///
  /// Build content skeleton widget
  /// Displayed when loading and content was not passed as parameter
  /// Multiple lines for natural loading effect
  Widget _buildContentSkeleton(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 첫 번째 줄 (전체 너비)
          /// First line (full width)
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),

          /// 두 번째 줄 (80% 너비)
          /// Second line (80% width)
          FractionallySizedBox(
            widthFactor: 0.8,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// 세 번째 줄 (60% 너비)
          /// Third line (60% width)
          FractionallySizedBox(
            widthFactor: 0.6,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// 네 번째 줄 (90% 너비)
          /// Fourth line (90% width)
          FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// 다섯 번째 줄 (40% 너비)
          /// Fifth line (40% width)
          FractionallySizedBox(
            widthFactor: 0.4,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 게시글 본문 영역 빌드
  ///
  /// 블라인드 처리된 글인 경우:
  /// - 본인 글: 경고 박스 + 사유 + 전체 내용 표시
  /// - 타인 글: 경고 박스만 표시 (제목, 이미지 등 숨김)
  ///
  /// Build post content area
  /// For blinded posts:
  /// - Owner's post: warning box + reason + full content
  /// - Other's post: warning box only (hide title, images, etc.)
  Widget _buildPostContent({
    required BuildContext context,
    required int? adExpiry,
    required bool hasFiles,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// skeleton 표시 조건
    /// 로딩 중이고 파라미터로 해당 값이 넘어오지 않았을 때만 skeleton 표시
    ///
    /// Skeleton display conditions
    /// Show skeleton only when loading and the value was not passed as parameter
    final showSubjectSkeleton = isLoading && widget.post.subject.isEmpty;
    final showContentSkeleton = isLoading && widget.post.content.isEmpty;

    /// 블라인드 처리된 글인지 확인
    /// Check if the post is blinded
    final isBlinded = post?.isBlinded ?? false;
    final isMine = post?.isMine(context) ?? false;

    // ========== 디버그 로그 시작 ==========
    // DEBUG: 블라인드 처리 관련 값 확인
    print('========== [PostViewScreen] 블라인드 체크 디버그 ==========');
    print('[DEBUG] post?.idx: ${post?.idx}');
    print('[DEBUG] post?.post_id: ${post?.post_id}');
    print('[DEBUG] post?.category: ${post?.category}');
    print('[DEBUG] post?.blind 원본값: "${post?.blind}"');
    print('[DEBUG] post?.blind 타입: ${post?.blind.runtimeType}');
    print('[DEBUG] isBlinded (계산값): $isBlinded');
    print('[DEBUG] isMine: $isMine');
    print('[DEBUG] post?.moderationReason: ${post?.moderationReason}');
    print('=========================================================');
    // ========== 디버그 로그 끝 ==========

    /// 만료된 구인/구직 글인지 확인 (90일 규칙)
    /// Check if this is an expired job post (90-day rule)
    final isExpiredJob = post?.isExpiredJobPost ?? false;

    /// 만료된 구인글 경고 박스 위젯
    /// Expired job post warning box widget
    Widget buildExpiredJobWarningBox() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: scheme.tertiary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 만료 경고 아이콘 및 제목
            /// Expired warning icon and title
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightClock,
                  color: scheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    PhilgoTr.of(context)?.expiredJobPost ?? '오래된 구인/구직 글입니다',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// 만료 설명 표시
            /// Display expiration description
            Text(
              PhilgoTr.of(context)?.expiredJobPostDescription ??
                  '잘못된 정보를 방지하기 위해, 90일 이상된 구인/구직 글은 내용을 표시하지 않습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      );
    }

    /// 만료된 구인글인 경우: 경고 박스만 표시
    /// For expired job post: show only warning box
    if (isExpiredJob) {
      return buildExpiredJobWarningBox();
    }

    /// 블라인드 경고 박스 위젯
    /// Blinded warning box widget
    Widget buildWarningBox() {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: scheme.error.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 블라인드 경고 아이콘 및 제목
            /// Blind warning icon and title
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  color: scheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    PhilgoTr.of(context)?.blindedPost ?? '블라인드 처리된 글입니다',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            /// 본인 글인 경우에만 사유 표시
            /// Show reason only for owner's post
            if (isMine) ...[
              const SizedBox(height: 12),

              /// 블라인드 사유 표시
              /// Display blinding reason
              Text(
                '${PhilgoTr.of(context)?.blindReason ?? '사유'}: ${post?.moderationReason ?? (PhilgoTr.of(context)?.blindedPostDescription ?? '커뮤니티 가이드라인 위반')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ],
        ),
      );
    }

    /// 블라인드된 글이고 본인 글이 아닌 경우: 경고 박스만 표시
    /// For blinded post that is not mine: show only warning box
    if (isBlinded && !isMine) {
      return buildWarningBox();
    }

    /// 일반 게시글 또는 본인의 블라인드 글: 전체 내용 표시
    /// Normal post or owner's blinded post: show full content
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// 블라인드된 본인 글인 경우 경고 박스 먼저 표시
        /// Show warning box first for owner's blinded post
        if (isBlinded && isMine) ...[
          buildWarningBox(),
          const SizedBox(height: 16),
        ],

        if (adExpiry != null) ...[
          PostAdInfoBanner(expiryTimestamp: adExpiry),
        ],

        /// Post title - larger and more prominent
        /// 제목 skeleton 또는 실제 제목 표시
        /// Show subject skeleton or actual subject
        if (showSubjectSkeleton)
          _buildSubjectSkeleton(scheme)
        else
          PostViewSubject(subject: subject),

        /// Avatar, name, and date
        PostViewMeta(
          idxMember: idxMember,
          nickname: nickname,
          photoUrl: photoUrl,
          formattedDate: formatPostDate(stamp),
        ),

        const SizedBox(height: 16),

        PostViewDisplayYouTubes(post: post!),

        /// Files (images, videos, and other files) first (if available)
        /// Do not display files for HTML content (already embedded in HTML)
        if (hasFiles && !(post?.isHtml ?? false)) ...[
          PostViewFiles(
            files: files,
            postIdx: widget.post.idx,
            enableHeroTransition: true,
          ),
        ],

        /// Post content (블라인드 글의 경우 contentPrivate 사용)
        /// Post content (use contentPrivate for blinded posts)
        /// 내용 skeleton 또는 실제 내용 표시
        /// Show content skeleton or actual content
        if (showContentSkeleton)
          _buildContentSkeleton(scheme)
        else
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
            onUpdated: (updated) => setState(() => post = updated),
          ),
        ),
      ],
    );
  }
}
