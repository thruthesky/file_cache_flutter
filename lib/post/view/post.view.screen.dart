import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/bookmark/widgets/bookmark_group_picker.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/update/post.update.screen.dart';
import 'package:philgo/post/view/widgets/comment.list.view.dart';
import 'package:philgo/post/view/widgets/post.action.bar.dart';
import 'package:philgo/post/view/widgets/post.view.content.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/post/view/widgets/post_comment_bar.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/user/widgets/login_required_dialog.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';
import 'package:philgo/user/widgets/user_avatar.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:provider/provider.dart';

/// 게시글 상세 보기 화면
class PostViewScreen extends StatefulWidget {
  static const String routeName = '/post/view';

  /// PostViewScreen으로 이동 (삭제 결과 자동 처리 포함)
  static Future<dynamic> push(BuildContext ctx, Post post) async {
    final result = await ctx.push<dynamic>(routeName, extra: post);
    return result;
  }

  final Post post;

  const PostViewScreen({super.key, required this.post});

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  late Post _post;
  bool _isLoading = true;
  String? _error;
  bool _postChanged = false;

  // 좋아요 상태
  bool _liked = false;
  late int _goodCount;

  // 댓글
  List<Post> _comments = [];
  bool _commentsLoading = true;

  // 답글 대상 댓글 (null이면 최상위 댓글 모드)
  Post? _replyToComment;

  // 북마크 상태 (캐시에서 초기화)
  bool _bookmarked = false;
  Set<int> _bookmarkedCommentIdxs = {};

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _goodCount = _post.good;
    _loadPost();
  }

  Future<void> _loadPost() async {
    final fullPost = await PostService.get(_post.idx);
    if (!mounted) return;
    setState(() {
      _post = fullPost;
      _goodCount = fullPost.good;
      _isLoading = false;
    });
    _loadComments();
  }

  Future<void> _loadComments() async {
    final comments = await PostService.listComments(_post.idx);
    if (!mounted) return;
    setState(() {
      _comments = comments;
      _commentsLoading = false;
    });
  }

  Future<void> _toggleLike() async {
    try {
      final result = await PostService.like(_post.idx);
      if (!mounted) return;
      setState(() {
        _liked = result.liked;
        _goodCount = result.good;
      });
    } catch (e) {
      showErrorSnackBar(context, '$e');
    }
  }

  Future<void> _editPost() async {
    final result = await PostUpdateScreen.push(context, _post);
    if (result != null && mounted) {
      setState(() {
        _post = result;
        _postChanged = true;
      });
    }
  }

  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await PostService.delete(_post.idx);
    if (!mounted) return;
    Navigator.of(context).pop('deleted');
  }

  // ── 북마크 ──────────────────────────────────────────

  Future<void> _toggleBookmark() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      LoginRequiredDialog.show(context);
      return;
    }
    final result = await showBookmarkGroupPicker(
      context: context,
      isBookmarked: _bookmarked,
    );
    if (result == null || !mounted) return;

    if (result.removed) {
      await BookmarkService.instance.remove(
        entityType: 'post',
        entityIdx: _post.idx,
      );
      if (!mounted) return;
      setState(() => _bookmarked = false);
    } else {
      await BookmarkService.instance.add(
        entityType: 'post',
        entityIdx: _post.idx,
        groupName: result.groupName ?? '',
      );
      if (!mounted) return;
      setState(() => _bookmarked = true);
    }
  }

  Future<void> _toggleCommentBookmark(int commentIdx) async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      LoginRequiredDialog.show(context);
      return;
    }
    final isBookmarked = _bookmarkedCommentIdxs.contains(commentIdx);
    final result = await showBookmarkGroupPicker(
      context: context,
      isBookmarked: isBookmarked,
    );
    if (result == null || !mounted) return;

    if (result.removed) {
      await BookmarkService.instance.remove(
        entityType: 'comment',
        entityIdx: commentIdx,
      );
      if (!mounted) return;
      setState(() {
        _bookmarkedCommentIdxs = _bookmarkedCommentIdxs
            .where((idx) => idx != commentIdx)
            .toSet();
      });
    } else {
      await BookmarkService.instance.add(
        entityType: 'comment',
        entityIdx: commentIdx,
        groupName: result.groupName ?? '',
      );
      if (!mounted) return;
      setState(() {
        _bookmarkedCommentIdxs = {..._bookmarkedCommentIdxs, commentIdx};
      });
    }
  }

  // ── 댓글 CRUD ──────────────────────────────────────────

  /// 댓글/대댓글 생성
  Future<void> _createComment(
    String content,
    int? idxParent,
    List<FileUploadModel> files,
  ) async {
    final newComment = await PostService.createComment(
      idxRoot: _post.idx,
      content: content,
      idxParent: idxParent,
    );
    _postChanged = true;
    if (!mounted) return;
    setState(() {
      _comments = [..._comments, newComment];
      _post = _post.copyWith(noOfComment: _comments.length);
      _replyToComment = null;
    });
  }

  /// 댓글 수정
  Future<void> _editComment(Post comment, String content) async {
    final updated = await PostService.updateComment(
      idx: comment.idx,
      content: content,
    );
    _postChanged = true;
    if (!mounted) return;
    setState(() {
      _comments = _comments
          .map((c) => c.idx == updated.idx ? updated : c)
          .toList();
    });
  }

  /// 댓글 삭제
  Future<void> _deleteComment(Post comment) async {
    await PostService.deleteComment(comment.idx);
    _postChanged = true;
    if (!mounted) return;
    setState(() {
      _comments = _comments.where((c) => c.idx != comment.idx).toList();
      _post = _post.copyWith(noOfComment: _comments.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final userState = Provider.of<UserState>(context, listen: false);
    final isMine = userState.isLoggedIn && userState.idx == _post.idxMember;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_postChanged ? _post : null);
      },
      child: Scaffold(
        backgroundColor: scheme.surface,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: scheme.surface,
                    foregroundColor: scheme.onSurface,
                    elevation: 0,
                    scrolledUnderElevation: 1,
                    actions: [
                      if (!_isLoading)
                        PopupMenuButton<String>(
                          icon: FaIcon(
                            FontAwesomeIcons.lightEllipsisVertical,
                            size: 18,
                            color: scheme.onSurface,
                          ),
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _editPost();
                              case 'delete':
                                _deletePost();
                              case 'block':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('차단 기능은 준비 중입니다.'),
                                  ),
                                );
                              case 'report':
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('신고 기능은 준비 중입니다.'),
                                  ),
                                );
                            }
                          },
                          itemBuilder: (ctx) {
                            final popScheme = Theme.of(ctx).colorScheme;
                            return isMine
                                ? [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.lightPenToSquare,
                                            size: 15,
                                            color: popScheme.onSurface,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('수정'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.lightTrashCan,
                                            size: 15,
                                            color: popScheme.error,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '삭제',
                                            style: TextStyle(
                                              color: popScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                : [
                                    PopupMenuItem(
                                      value: 'block',
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.lightBan,
                                            size: 15,
                                            color: popScheme.onSurface,
                                          ),
                                          const SizedBox(width: 10),
                                          const Text('차단'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'report',
                                      child: Row(
                                        children: [
                                          FaIcon(
                                            FontAwesomeIcons.lightFlag,
                                            size: 15,
                                            color: popScheme.error,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '신고',
                                            style: TextStyle(
                                              color: popScheme.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                          },
                        ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 원글 ──────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _post.subject,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildMeta(_post, theme, scheme),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // 첨부 파일 (전체 너비)
                        PostViewFiles(post: _post),

                        // 본문
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              '내용을 불러올 수 없습니다',
                              style: TextStyle(color: scheme.error),
                            ),
                          )
                        else
                          PostViewContent(
                            post: _post,
                            isLoading: _isLoading,
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          ),

                        // 원글 액션 바
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: PostActionBar(
                            post: _post,
                            isMine: isMine,
                            liked: _liked,
                            goodCount: _goodCount,
                            onLike: _toggleLike,
                            onEdit: _editPost,
                            onDelete: _deletePost,
                            bookmarked: _bookmarked,
                            onBookmark: _toggleBookmark,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ── 댓글 ──────────────────────────────────────────
                        CommentListView(
                          comments: _comments,
                          isLoading: _commentsLoading,
                          noOfComment: _post.noOfComment,
                          idxRoot: _post.idx,
                          onEditComment: _editComment,
                          onDeleteComment: _deleteComment,
                          onReplyTap: (comment) {
                            setState(() => _replyToComment = comment);
                          },
                          bookmarkedCommentIdxs: _bookmarkedCommentIdxs,
                          onToggleBookmark: _toggleCommentBookmark,
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            PostCommentBar(
              idxRoot: _post.idx,
              replyTo: _replyToComment,
              onCancelReply: () => setState(() => _replyToComment = null),
              onSubmit: _createComment,
            ),
          ],
        ),
      ),
    );
  }

  void _openUserProfile(int idxMember) {
    if (idxMember == 0) return;
    OtherUserScreen.pushByIdx(context, idxMember);
  }

  Widget _buildMeta(Post post, ThemeData theme, ColorScheme scheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 아바타
        GestureDetector(
          onTap: () => _openUserProfile(post.idxMember),
          child: UserAvatar(photoUrl: post.userPhotoUrl, radius: 16),
        ),
        const SizedBox(width: 10),
        // 이름 + 날짜 컬럼
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _openUserProfile(post.idxMember),
                child: Text(
                  post.userName.isNotEmpty ? post.userName : '이름없음'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightClock,
                    size: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formatDate(
                      context,
                      DateTime.fromMillisecondsSinceEpoch(post.stamp),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  if (post.category.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    FaIcon(
                      FontAwesomeIcons.lightTag,
                      size: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
