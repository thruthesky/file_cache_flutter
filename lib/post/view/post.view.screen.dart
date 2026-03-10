import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/update/post.update.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// 게시글 상세 보기 화면
///
/// v6 PostViewScreen의 핵심 로직을 v7에 적용.
/// CustomScrollView + Sliver 기반 레이아웃.
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

  /// 서버에서 최신 게시글 데이터 로드 (조회수 증가 포함)
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

  /// 게시글 수정 화면 열기
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

  /// 게시글 삭제
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
            // 앱바
            SliverAppBar(
              pinned: true,
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              elevation: 0,
              scrolledUnderElevation: 1,
              title: Text(
                _post.postId,
                style: theme.textTheme.titleMedium,
              ),
              actions: [
                if (isMine) ...[
                  IconButton(
                    onPressed: _editPost,
                    icon: FaIcon(
                      FontAwesomeIcons.lightPenToSquare,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    onPressed: _deletePost,
                    icon: FaIcon(
                      FontAwesomeIcons.lightTrashCan,
                      size: 18,
                      color: scheme.error,
                    ),
                  ),
                ],
              ],
            ),

            // 본문
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

                    // 메타 정보 (작성자, 날짜)
                    _buildMeta(theme, scheme),
                    const SizedBox(height: 16),

                    Divider(color: scheme.outlineVariant),
                    const SizedBox(height: 16),

                    // 본문 이미지 (있으면)
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
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          ),
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 본문 내용
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

                    const SizedBox(height: 24),

                    // 통계 및 액션 버튼
                    _buildStats(theme, scheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메타 정보 (날짜, 카테고리)
  Widget _buildMeta(ThemeData theme, ColorScheme scheme) {
    return Row(
      children: [
        // 날짜
        FaIcon(FontAwesomeIcons.lightClock,
            size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          _formatFullDate(_post.stamp),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        // 카테고리
        if (_post.category.isNotEmpty) ...[
          const SizedBox(width: 16),
          FaIcon(FontAwesomeIcons.lightTag,
              size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            _post.category,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  /// 통계 바 (조회수, 댓글, 좋아요)
  Widget _buildStats(ThemeData theme, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            FontAwesomeIcons.lightEye,
            '${_post.noOfView}',
            '조회',
            scheme,
            theme,
          ),
          _statItem(
            FontAwesomeIcons.lightComment,
            '${_post.noOfComment}',
            '댓글',
            scheme,
            theme,
          ),
          _statItem(
            FontAwesomeIcons.lightThumbsUp,
            '${_post.good}',
            '좋아요',
            scheme,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    IconData icon,
    String value,
    String label,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return Column(
      children: [
        FaIcon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }

  /// Unix timestamp → 전체 날짜 문자열
  String _formatFullDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
