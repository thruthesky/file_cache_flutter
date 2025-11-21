import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/user/my.activity.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/widgets/comment.card.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

/// 사용자 최근 댓글 위젯 - 최근 3개의 댓글을 표시
///
/// 기능:
/// - 사용자가 작성한 최근 3개의 댓글 가져오기
/// - 로딩 상태 표시
/// - 댓글이 없을 경우 빈 상태 표시
/// - 댓글을 카드 형식으로 표시
/// - "View All" 버튼으로 MyActivityScreen의 comments 탭으로 이동
/// - 댓글 탭 시 해당 게시글로 이동
class LatestUserComments extends StatefulWidget {
  const LatestUserComments({super.key});

  @override
  State<LatestUserComments> createState() => _LatestUserCommentsState();
}

class _LatestUserCommentsState extends State<LatestUserComments> {
  /// 로딩 상태
  bool _isLoading = false;

  /// 댓글 리스트
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  /// API에서 댓글 불러오기
  Future<void> _loadComments() async {
    final user = AppState.of(context, listen: false).user;

    /// 로그인하지 않은 경우 로딩하지 않음
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await getMyComments(limit: 3);

      _comments = comments;
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Selector<AppState, User?>(
      selector: (_, appState) => appState.user,
      builder: (_, user, __) {
        /// 로그인하지 않은 경우 표시하지 않음
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 섹션 헤더: 제목, View All 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    /// 제목
                    Text(
                      'Latest Comments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),

                    const Spacer(),

                    /// View All 버튼 - MyActivityScreen의 comments 탭으로 이동
                    TextButton(
                      onPressed: () {
                        MyActivityScreen.push(
                          context,
                          initialTab: MyActivityTab.comments,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          FaIcon(
                            FontAwesomeIcons.lightChevronRight,
                            size: 14,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// 댓글 콘텐츠 영역
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_comments.isEmpty)
                _buildEmptyState(theme, scheme)
              else
                _buildCommentsList(),
            ],
          ),
        );
      },
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(ThemeData theme, ColorScheme scheme) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightComment,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 댓글 리스트 위젯
  Widget _buildCommentsList() {
    return Column(
      children: _comments.asMap().entries.map((entry) {
        final index = entry.key;
        final comment = entry.value;

        return CommentCard(
          comment: comment,
          index: index,
          maxLines: 2,
          useFixedHeight: true,
        );
      }).toList(),
    );
  }
}
