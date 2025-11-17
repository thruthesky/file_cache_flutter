import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Home widget displaying posts with category filters
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
        has_image: true,
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

        /// Posts carousel
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_posts.isEmpty)
          const EmptyPostList()
        else
          PostsCarousel(posts: _posts),
      ],
    );
  }
}

/// Posts carousel widget with full-image cover cards
class PostsCarousel extends StatelessWidget {
  final List<Post> posts;

  const PostsCarousel({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FullImageCard(post: posts[index]),
          );
        },
      ),
    );
  }
}

/// Full image cover card widget
class FullImageCard extends StatelessWidget {
  final Post post;

  const FullImageCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await PostViewScreen.push(context, post);
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// Full background image
            if (post.files.isNotEmpty)
              Image.network(
                post.files.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const PostImagePlaceholder(),
              )
            else
              const PostImagePlaceholder(),

            /// Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),

            /// Content overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Title (max 2 lines)
                    Text(
                      post.subject,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    /// Content preview (max 1 line)
                    if (post.content.isNotEmpty)
                      Text(
                        post.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const SizedBox(height: 12),

                    /// Metadata: likes, views, date
                    Row(
                      children: [
                        /// Likes
                        const FaIcon(
                          FontAwesomeIcons.lightHeart,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.good}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 16),

                        /// Views
                        const FaIcon(
                          FontAwesomeIcons.lightEye,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.no_of_view}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 16),

                        /// Date posted
                        const FaIcon(
                          FontAwesomeIcons.lightClock,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            post.timeString,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
}

/// Image placeholder widget with gradient background
class PostImagePlaceholder extends StatelessWidget {
  const PostImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightImage,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No image available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
