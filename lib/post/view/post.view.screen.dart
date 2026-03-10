import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/post/list/display_thumbnail.dart';
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
            // 앱바 — 제목 대신 popup 메뉴로 카테고리 선택, isMine이면 수정/삭제 표시
            SliverAppBar(
              pinned: true,
              backgroundColor: scheme.surface,
              foregroundColor: scheme.onSurface,
              elevation: 0,
              scrolledUnderElevation: 1,
              title: _CategoryPopup(post: _post),
              actions: [
                if (isMine)
                  PopupMenuButton<String>(
                    icon: FaIcon(
                      FontAwesomeIcons.lightEllipsisVertical,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') _editPost();
                      if (value == 'delete') _deletePost();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.lightPenToSquare,
                                size: 16, color: scheme.onSurface),
                            const SizedBox(width: 10),
                            const Text('수정'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            FaIcon(FontAwesomeIcons.lightTrashCan,
                                size: 16, color: scheme.error),
                            const SizedBox(width: 10),
                            Text('삭제',
                                style: TextStyle(color: scheme.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
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

                    // 첨부 파일 (이미지/비디오/유튜브)
                    PostFilesWidget(post: _post, scheme: scheme),
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

  /// Unix timestamp → 전체 날짜 문자열
  String _formatFullDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// AppBar 제목 영역에 표시되는 카테고리 팝업 선택 위젯
class _CategoryPopup extends StatelessWidget {
  final Post post;

  const _CategoryPopup({required this.post});

  String get _label {
    // postId + category로 현재 카테고리 라벨 찾기
    for (final cat in forumCategories) {
      final (postId, category, label) = cat;
      if (postId == post.postId &&
          (category == null ? post.category.isEmpty : category == post.category)) {
        return label;
      }
    }
    // 못 찾으면 postId 표시
    return post.postId;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 4),
          FaIcon(FontAwesomeIcons.lightChevronDown,
              size: 14, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        children: [
          for (final cat in forumCategories)
            ListTile(
              title: Text(cat.$3),
              onTap: () => Navigator.pop(ctx),
            ),
        ],
      ),
    );
  }
}

/// 게시글 첨부 파일(이미지/비디오/유튜브) 표시 위젯
///
/// [DisplayThumbnail]과 동일한 미디어 타입 판별 로직을 사용한다.
class PostFilesWidget extends StatelessWidget {
  final Post post;
  final ColorScheme scheme;

  const PostFilesWidget({super.key, required this.post, required this.scheme});

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

  String _toAbsolute(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    return '$v7BaseUrl$url';
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final url in urls)
              GestureDetector(
                onTap: () => _openUrl(context, _toAbsolute(url)),
                child: DisplayThumbnail(
                  url: url,
                  scheme: scheme,
                  size: 100,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
