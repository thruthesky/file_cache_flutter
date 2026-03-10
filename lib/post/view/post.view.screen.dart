import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/update/post.update.screen.dart';
import 'package:philgo/post/view/widgets/post.action.bar.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 게시글 상세 보기 화면
class PostViewScreen extends StatefulWidget {
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
  bool _commentsLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _goodCount = _post.good;
    _loadFullPost();
  }

  Future<void> _loadFullPost() async {
    try {
      final fullPost = await PostService.get(_post.idx);
      if (!mounted) return;
      setState(() {
        _post = fullPost;
        _goodCount = fullPost.good;
        _isLoading = false;
      });
      _loadComments();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    try {
      final comments = await PostService.listComments(_post.idx);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _commentsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _commentsLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    final result = await PostService.like(_post.idx);
    if (!mounted) return;
    setState(() {
      _liked = result.liked;
      _goodCount = result.good;
    });
  }

  Future<void> _editPost() async {
    final result = await Navigator.of(context).push<Post>(
      MaterialPageRoute(builder: (_) => PostUpdateScreen(post: _post)),
    );
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

    try {
      await PostService.delete(_post.idx);
      if (!mounted) return;
      Navigator.of(context).pop('deleted');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('삭제 실패: $e')));
    }
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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              elevation: 0,
              scrolledUnderElevation: 1,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? Text(
                            '내용을 불러올 수 없습니다',
                            style: TextStyle(color: scheme.error),
                          )
                        : SelectableLinkify(
                            text: _post.content,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                              height: 1.6,
                            ),
                            linkStyle: TextStyle(
                              color: scheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                            onOpen: (link) async {
                              final uri = Uri.tryParse(link.url);
                              if (uri != null && await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
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
                    ),
                  ),

                  Divider(
                    color: scheme.outlineVariant,
                    height: 32,
                    indent: 16,
                    endIndent: 16,
                  ),

                  // ── 댓글 ──────────────────────────────────────────
                  if (_commentsLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    for (final comment in _comments)
                      _CommentTile(
                        comment: comment,
                        scheme: scheme,
                        theme: theme,
                      ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(Post post, ThemeData theme, ColorScheme scheme) {
    return Row(
      children: [
        FaIcon(
          FontAwesomeIcons.lightClock,
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          _formatFullDate(post.stamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        if (post.category.isNotEmpty) ...[
          const SizedBox(width: 16),
          FaIcon(
            FontAwesomeIcons.lightTag,
            size: 14,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            post.category,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _formatFullDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// 댓글 타일 — 원글과 동일 포맷: 파일 상단 → 내용 → 액션 바
// ---------------------------------------------------------------------------

class _CommentTile extends StatefulWidget {
  final Post comment;
  final ColorScheme scheme;
  final ThemeData theme;

  const _CommentTile({
    required this.comment,
    required this.scheme,
    required this.theme,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _liked = false;
  late int _goodCount;

  @override
  void initState() {
    super.initState();
    _goodCount = widget.comment.good;
  }

  Future<void> _toggleLike() async {
    try {
      final result = await PostService.like(widget.comment.idx);
      if (!mounted) return;
      setState(() {
        _liked = result.liked;
        _goodCount = result.good;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final scheme = widget.scheme;
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메타 (날짜)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightUser,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(comment.stamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // 첨부 파일 (전체 너비)
        PostViewFiles(post: comment),

        // 내용
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            comment.content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
        ),

        // 액션 바 (좋아요만 — isMine은 false로 단순화, 신고/차단 표시)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PostActionBar(
            post: comment,
            isMine: false,
            liked: _liked,
            goodCount: _goodCount,
            onLike: _toggleLike,
            onEdit: () {},
            onDelete: () {},
          ),
        ),

        Divider(
          color: scheme.outlineVariant,
          height: 24,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

