import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

import 'sections/user.posts.dart';

/// Displays user activity (posts) for any user
/// Can be used for the current user or any other user
class UserActivityScreen extends StatefulWidget {
  static const String routeName = '/user-activity';

  /// Push this screen with a specific user
  static Future<void> push(BuildContext context, {required String uid}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => UserActivityScreen(uid: uid)),
    );
  }

  /// Push this screen for the current logged-in user
  static Future<void> pushMy(BuildContext context) {
    final currentUser = context.read<AppState>().user;
    if (currentUser == null) {
      throw Exception('User must be logged in');
    }
    return push(context, uid: currentUser.uid);
  }

  final String uid;

  const UserActivityScreen({super.key, required this.uid});

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 20;

  /// Pagination controller
  late PagingController<int, Post> _postsPagingController;

  /// User data
  User? _user;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();

    _postsPagingController = PagingController(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: _fetchPostsPage,
    );

    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userData = await func(
        'get_user_public_profile',
        data: {'firebase_uid': widget.uid},
      );
      if (mounted) {
        setState(() {
          _user = User.fromJson(userData);
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _postsPagingController.dispose();
    super.dispose();
  }

  Future<List<Post>> _fetchPostsPage(int pageKey) async {
    final posts = await getLatestByUser(
      firebase_uid: widget.uid,
      page: pageKey,
      limit: _pageSize,
    );

    return posts;
  }

  /// Get the appropriate title based on whether it's current user or another user
  String _getTitle(User? user) {
    final currentUser = context.read<AppState>().user;
    final isCurrentUser = currentUser?.uid == widget.uid;

    if (isCurrentUser) {
      return '${currentUser!.nickname}\'s Posts';
    } else if (user != null) {
      // Use the user's nickname or name
      final userName = user.nickname.isNotEmpty
          ? user.nickname
          : user.name.isNotEmpty
          ? user.name
          : 'User';
      return '$userName\'s Posts';
    } else {
      return 'User\'s Posts';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
        title: _isLoadingUser
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Loading...', style: theme.textTheme.titleLarge),
                ],
              )
            : Text(_getTitle(_user), style: theme.textTheme.titleLarge),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: UserPostsList(
        pagingController: _postsPagingController,
        errorBuilder: _buildErrorWidget,
        emptyBuilder: _buildEmptyStateWidget,
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    return _ErrorWidget(message: message, onRetry: onRetry);
  }

  Widget _buildEmptyStateWidget(
    BuildContext context,
    IconData icon,
    String message,
  ) {
    return _EmptyStateWidget(icon: icon, message: message);
  }
}

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.lightTriangleExclamation,
            size: 48,
            color: scheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: Text(T.cancel)),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStateWidget({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(icon, size: 64, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
