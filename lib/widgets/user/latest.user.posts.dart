import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/user.activity.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/widgets/post/compact.post.list.tile.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

/// 사용자 최근 게시글 위젯 - 최근 3개의 게시글을 표시
///
/// 기능:
/// - 사용자가 작성한 최근 3개의 게시글 가져오기
/// - 로딩 상태 표시
/// - 게시글이 없을 경우 빈 상태 표시
/// - PostListTile을 사용하여 게시글 표시
/// - "View All" 버튼으로 MyActivityScreen으로 이동
class LatestUserPosts extends StatefulWidget {
  const LatestUserPosts({
    super.key,
    this.idx_member,
    this.firebase_uid,
    this.limit = 5,
  });

  final int? idx_member;
  final String? firebase_uid;
  final int limit;

  @override
  State<LatestUserPosts> createState() => _LatestUserPostsState();
}

class _LatestUserPostsState extends State<LatestUserPosts> {
  /// 로딩 상태
  bool _isLoading = false;

  /// 게시글 리스트
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await getLatestByUser(
        idx_member: widget.idx_member,
        firebase_uid: widget.firebase_uid,
        limit: widget.limit,
      );
      log(posts.toString(), name: "_loadPosts::");

      _posts = posts;
    } catch (e) {
      debugPrint('Error loading posts: $e');
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
      builder: (_, user, _) {
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 섹션 헤더: 제목, View All 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      T.latestPosts,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () {
                        if (widget.firebase_uid != null) {
                          UserActivityScreen.push(
                            context,
                            uid: widget.firebase_uid!,
                          );
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            T.viewAll,
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

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_posts.isEmpty)
                _buildEmptyState(theme, scheme)
              else
                _buildPostsList(),
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
          children: [
            FaIcon(
              FontAwesomeIcons.lightPenToSquare,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              T.noPostsYet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 게시글 리스트 위젯 - CompactPostListTile 사용
  Widget _buildPostsList() {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: _posts.asMap().entries.map((entry) {
        final index = entry.key;
        final post = entry.value;

        return Container(
              margin: const EdgeInsets.only(bottom: 12),
              /// Flat 2.0 - 미묘한 그림자 추가 (4% 투명도)
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000), // 4% opacity black
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: CompactPostListTile(
                post: post,
                onTap: () async {
                  await PostViewScreen.push(context, post);
                },
              ),
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideX(
              begin: -0.1,
              end: 0,
              duration: 300.ms,
              delay: (index * 50).ms,
            );
      }).toList(),
    );
  }
}
