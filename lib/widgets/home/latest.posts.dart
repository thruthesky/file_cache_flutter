import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Latest posts widget displaying posts from a specific category
///
/// Features:
/// - Fetches 5 latest posts from specified postId and category
/// - Shows loading state while fetching
/// - Shows empty state when no posts found
/// - Displays posts in a card list format
class LatestPosts extends StatefulWidget {
  final String category;
  final String postId;
  final String titleName;
  final IconData? icon;

  const LatestPosts({
    super.key,
    this.category = '',
    this.postId = '',
    required this.titleName,
    this.icon,
  });

  @override
  State<LatestPosts> createState() => _LatestPostsState();
}

class _LatestPostsState extends State<LatestPosts> {
  /// Loading state
  bool _isLoading = false;

  /// Posts list
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  /// Load posts from API
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final postList = await getPosts(
        postId: widget.postId,
        category: widget.category.isEmpty ? null : widget.category,
        limit: 5,
      );

      _posts = postList.posts;
    } catch (e) {
      debugPrint('Error loading posts: $e');
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section header with icon, title, and View All button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                /// Icon
                if (widget.icon != null) ...[
                  FaIcon(
                    widget.icon,
                    size: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                ],

                /// Title
                Text(
                  widget.titleName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                const Spacer(),

                /// View All button
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full category view
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      FaIcon(
                        FontAwesomeIcons.lightChevronRight,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          /// Posts content area
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_posts.isEmpty)
            const EmptyPostList()
          else
            LatestPostsList(posts: _posts),
        ],
      ),
    );
  }
}

/// Posts list widget displaying posts in card format with PostListTile
class LatestPostsList extends StatelessWidget {
  final List<Post> posts;

  const LatestPostsList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts.asMap().entries.map((entry) {
        final index = entry.key;
        final post = entry.value;

        return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: PostListTile(
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
