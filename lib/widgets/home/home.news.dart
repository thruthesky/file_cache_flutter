import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/post/title.only.post.card.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Home news widget displaying posts with category filters

///
/// Features :
/// - Shows minimum 5 posts
/// - 1st post is a highlighted card
/// - 2nd-5th posts show title only
/// - Filter tabs: News, Travel, Info, Reminder, Tip
class HomeNews extends StatefulWidget {
  const HomeNews({super.key});

  @override
  State<HomeNews> createState() => _HomeNewsState();
}

class _HomeNewsState extends State<HomeNews> {
  /// Selected category key
  String _selectedCategory = 'news';

  /// Loading state
  bool _isLoading = false;

  /// Posts list
  List<Post> _posts = [];

  /// Available categories with icons and API configuration
  final Map<String, Map<String, dynamic>> _categoriesConfig = {
    'news': {
      'name': 'News',
      'icon': FontAwesomeIcons.lightNewspaper,
      'postId': 'freetalk',
      'category': '뉴스',
    },
    'travel': {
      'name': 'Travel',
      'icon': FontAwesomeIcons.lightPlane,
      'postId': 'travel',
      'category': '',
    },
    'info': {
      'name': 'Info',
      'icon': FontAwesomeIcons.lightCircleInfo,
      'postId': 'freetalk',
      'category': 'info',
    },
    'reminder': {
      'name': 'Reminder',
      'icon': FontAwesomeIcons.lightBell,
      'postId': 'freetalk',
      'category': '공지사항',
    },
    'tip': {
      'name': 'Tip',
      'icon': FontAwesomeIcons.lightLightbulb,
      'postId': 'freetalk',
      'category': '생활의팁',
    },
  };

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
      final config = _categoriesConfig[_selectedCategory]!;

      // NOTE: will fetch all of the `temp` files due to the env setting.
      final postList = await getPosts(
        postId: config['postId'] as String,
        category: (config['category'] as String).isEmpty
            ? null
            : config['category'] as String,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categoriesConfig.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final categoryKey = _categoriesConfig.keys.elementAt(index);
              final category = _categoriesConfig[categoryKey]!;
              final categoryName = category['name'] as String;
              final categoryIcon = category['icon'] as IconData;
              final isSelected = categoryKey == _selectedCategory;

              return FilterChip(
                avatar: FaIcon(
                  categoryIcon,
                  size: 14,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                label: Text(categoryName),
                selected: isSelected,
                onSelected: (selected) {
                  _selectedCategory = categoryKey;
                  _loadPosts();
                  setState(() {});
                },
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedColor: Theme.of(context).colorScheme.primary,
                checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        /// Posts list
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_posts.isEmpty)
          const EmptyPosts()
        else
          PostsList(posts: _posts),
      ],
    );
  }
}

/// Empty state widget for when no posts are found
class EmptyPosts extends StatelessWidget {
  const EmptyPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            FaIcon(
              FontAwesomeIcons.lightInboxOut,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No posts found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Posts list widget displaying highlighted first post and title-only posts
class PostsList extends StatelessWidget {
  final List<Post> posts;

  const PostsList({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          /// First post - Highlighted card
          HighlightedPostCard(post: posts[0]),

          const SizedBox(height: 16),

          /// Remaining posts - Title only
          ...posts.skip(1).take(4).map((post) => TitleOnlyPostCard(post: post)),
        ],
      ),
    );
  }
}

/// Highlighted post card widget (1st post)
class HighlightedPostCard extends StatelessWidget {
  final Post post;

  const HighlightedPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await PostViewScreen.push(context, post);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Image placeholder or first image from post
              if (post.files.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.files.first,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const PostImagePlaceholder(),
                  ),
                )
              else
                const PostImagePlaceholder(),
              const SizedBox(height: 16),

              /// Title
              Text(
                post.subject,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Image placeholder widget
class PostImagePlaceholder extends StatelessWidget {
  const PostImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.lightImage,
          size: 48,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
