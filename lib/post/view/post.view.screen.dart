import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/update/post.update.screen.dart';
import 'package:philgo/post/view/widgets/post.action.btn.dart';
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

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _loadFullPost();
  }

  Future<void> _loadFullPost() async {
    try {
      final fullPost = await PostService.get(_post.idx);
      if (!mounted) return;
      setState(() {
        _post = fullPost;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: $e')),
      );
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      _post.subject,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 메타 정보 (날짜, 카테고리)
                    _buildMeta(theme, scheme),
                    const SizedBox(height: 16),

                    Divider(color: scheme.outlineVariant),
                    const SizedBox(height: 16),

                    // 대표 이미지
                    if (_post.imageUrl != null &&
                        _post.imageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.fitWidth,
                          placeholder: (_, _) => Container(
                            height: 200,
                            color: scheme.surfaceContainerHigh,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 본문
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_error != null)
                      Text('내용을 불러올 수 없습니다',
                          style: TextStyle(color: scheme.error))
                    else
                      SelectableLinkify(
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
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),

                    const SizedBox(height: 16),

                    // 첨부 파일
                    PostViewFiles(post: _post, scheme: scheme),

                    const SizedBox(height: 8),

                    // 액션 버튼
                    PostActionButtons(
                      post: _post,
                      isMine: isMine,
                      onEdit: _editPost,
                      onDelete: _deletePost,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(ThemeData theme, ColorScheme scheme) {
    return Row(
      children: [
        FaIcon(FontAwesomeIcons.lightClock,
            size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          _formatFullDate(_post.stamp),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        if (_post.category.isNotEmpty) ...[
          const SizedBox(width: 16),
          FaIcon(FontAwesomeIcons.lightTag,
              size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            _post.category,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
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
// PostViewFiles
// ---------------------------------------------------------------------------

/// 게시글 첨부 파일(이미지/비디오/유튜브)을 전체 너비로 세로 나열하는 위젯
class PostViewFiles extends StatelessWidget {
  final Post post;
  final ColorScheme scheme;

  const PostViewFiles({super.key, required this.post, required this.scheme});

  List<String> get _urls {
    final urls = <String>[];
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      urls.add(post.imageUrl!);
    }
    if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
      urls.add(post.videoUrl!);
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final url in urls) _buildMediaItem(toAbsoluteUrl(url)),
      ],
    );
  }

  Widget _buildMediaItem(String absoluteUrl) {
    final type = getMediaType(absoluteUrl);

    switch (type) {
      case MediaType.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: absoluteUrl,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              placeholder: (_, _) => Container(
                height: 200,
                color: scheme.surfaceContainerHigh,
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
        );

      case MediaType.youtube:
        final videoId = getYouTubeVideoId(absoluteUrl);
        final thumbUrl = videoId != null
            ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
            : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (thumbUrl != null)
                  CachedNetworkImage(
                    imageUrl: thumbUrl,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    placeholder: (_, _) => Container(
                      height: 200,
                      color: scheme.surfaceContainerHigh,
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 200,
                      color: scheme.surfaceContainerHigh,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    color: scheme.surfaceContainerHigh,
                  ),
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.black38,
                ),
                FaIcon(FontAwesomeIcons.youtube, size: 56, color: Colors.red),
              ],
            ),
          ),
        );

      case MediaType.video:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 200,
              color: scheme.surfaceContainerHigh,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.circlePlay,
                  size: 56,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );

      case MediaType.unknown:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// PostActionButtons
// ---------------------------------------------------------------------------

/// 게시글 하단 액션 버튼 행
///
/// 좌측: 좋아요 · 댓글
/// 우측(isMine): 수정 · 삭제 / 내 글이 아닌 경우: 신고 · 차단
class PostActionButtons extends StatelessWidget {
  final Post post;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PostActionButtons({
    super.key,
    required this.post,
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 좋아요
        PostActionBtn(
          icon: FontAwesomeIcons.lightThumbsUp,
          label: '${post.good > 0 ? post.good : ''}',
          color: scheme.onSurfaceVariant,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        // 댓글
        PostActionBtn(
          icon: FontAwesomeIcons.lightComment,
          label: '${post.noOfComment > 0 ? post.noOfComment : ''}',
          color: scheme.onSurfaceVariant,
          onTap: () {},
        ),

        const Spacer(),

        if (isMine) ...[
          // 수정
          PostActionBtn(
            icon: FontAwesomeIcons.lightPenToSquare,
            label: '수정',
            color: scheme.onSurfaceVariant,
            onTap: onEdit,
          ),
          const SizedBox(width: 8),
          // 삭제
          PostActionBtn(
            icon: FontAwesomeIcons.lightTrashCan,
            label: '삭제',
            color: scheme.error,
            onTap: onDelete,
          ),
        ] else ...[
          // 신고
          PostActionBtn(
            icon: FontAwesomeIcons.lightFlag,
            label: '신고',
            color: scheme.onSurfaceVariant,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          // 차단
          PostActionBtn(
            icon: FontAwesomeIcons.lightBan,
            label: '차단',
            color: scheme.onSurfaceVariant,
            onTap: () {},
          ),
        ],
      ],
    );
  }
}

