import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo/widgets/post/title.only.post.card.dart';
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
          /// Section header with icon and title
          Row(
            children: [
              Text(
                widget.titleName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

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

/// Posts list widget displaying posts in card format
class LatestPostsList extends StatelessWidget {
  final List<Post> posts;

  const LatestPostsList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: posts.map((post) => TitleOnlyPostCard(post: post)).toList(),
    );
  }
}
