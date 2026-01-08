import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/services/post_content/post_content.service.dart';
import 'package:philgo_api/philgo_api.dart';

/// 필고 게시글 내용을 표시하는 재사용 가능한 위젯 (Reusable Post Content Viewer Widget)
///
/// PostContentService를 사용하여 게시글을 로드하고,
/// PostViewContent 위젯으로 내용을 렌더링합니다.
///
/// ### 기능 (Features):
/// - 로딩 상태 표시 (Loading indicator)
/// - 에러 처리 및 재시도 버튼 (Error handling with retry button)
/// - 새로고침 기능 (Pull to refresh)
/// - HTML/Markdown/일반 텍스트 자동 렌더링 (Auto-render HTML/Markdown/Plain text)
/// - 이미지 갤러리 표시 (Image gallery display)
///
/// ### 사용법 (Usage):
/// ```dart
/// PostContentViewer(
///   postId: PostContentMapping.orRenewal,
///   showImages: true,
/// )
/// ```
class PostContentViewer extends StatefulWidget {
  /// 게시글 번호 (Post ID - idx)
  final int postId;

  /// 이미지 표시 여부 (Show images)
  /// 기본값: true
  final bool showImages;

  /// 본문 패딩 (Content padding)
  /// 기본값: EdgeInsets.all(16)
  final EdgeInsets contentPadding;

  const PostContentViewer({
    super.key,
    required this.postId,
    this.showImages = true,
    this.contentPadding = const EdgeInsets.all(16),
  });

  @override
  State<PostContentViewer> createState() => _PostContentViewerState();
}

class _PostContentViewerState extends State<PostContentViewer> {
  /// 게시글 데이터 (Post data)
  Post? _post;

  /// 로딩 상태 (Loading state)
  bool _isLoading = true;

  /// 에러 메시지 (Error message)
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void didUpdateWidget(covariant PostContentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    /// postId가 변경되면 새로 로드 (Reload if postId changes)
    if (oldWidget.postId != widget.postId) {
      _loadPost();
    }
  }

  /// 게시글 로드 (Load post)
  Future<void> _loadPost({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final post = await PostContentService.instance.loadPost(
        widget.postId,
        forceRefresh: forceRefresh,
      );

      if (mounted) {
        setState(() {
          _post = post;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    /// 로딩 상태 (Loading state)
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
      );
    }

    /// 에러 상태 (Error state)
    if (_errorMessage != null) {
      return _buildErrorWidget(context, theme, scheme, l10n);
    }

    /// 게시글이 없는 경우 (No post)
    if (_post == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.error,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    /// 게시글 표시 (Display post)
    return RefreshIndicator(
      onRefresh: () => _loadPost(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 본문 내용 (Content)
            PostViewContent(
              isLoading: false,
              post: _post!,
              padding: widget.contentPadding,
            ),

            /// 이미지 갤러리 (Image gallery)
            if (widget.showImages && _post!.files.isNotEmpty)
              Padding(
                padding: widget.contentPadding,
                child: PostViewImages(
                  files: _post!.files,
                  postIdx: _post!.idx,
                ),
              ),

            /// 하단 여백 (Bottom padding)
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 에러 위젯 빌드 (Build error widget)
  Widget _buildErrorWidget(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    Lo l10n,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 에러 아이콘 (Error icon)
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: scheme.error,
            ),
            const SizedBox(height: 16),

            /// 에러 메시지 (Error message)
            Text(
              l10n.error,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            /// 상세 에러 메시지 (Detailed error message)
            Text(
              _errorMessage ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),

            /// 재시도 버튼 (Retry button)
            FilledButton.icon(
              onPressed: () => _loadPost(forceRefresh: true),
              icon: const FaIcon(FontAwesomeIcons.arrowsRotate, size: 16),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
