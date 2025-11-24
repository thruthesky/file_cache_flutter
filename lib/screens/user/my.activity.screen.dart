import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

import 'sections/my.posts.dart';

class MyActivityScreen extends StatefulWidget {
  static const String routeName = '/my-activity';

  static Future<void> push(BuildContext context) {
    return context.push(routeName);
  }

  const MyActivityScreen({super.key});

  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen>
    with SingleTickerProviderStateMixin {
  static const int _pageSize = 20;

  int? myId;

  /// 페이지네이션 컨트롤러
  late PagingController<int, Post> _postsPagingController;

  @override
  void initState() {
    super.initState(); // initialTab enum의 index를 사용하여 초기 탭 설정

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AppState>().user;
      if (user != null && user.idx != null) {
        myId = user.idx!;
        setState(() {});
      }
    });

    _postsPagingController = PagingController(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: _fetchPostsPage,
    );
  }

  @override
  void dispose() {
    _postsPagingController.dispose();
    super.dispose();
  }

  Future<List<Post>> _fetchPostsPage(int pageKey) async {
    final posts = await getLatestByUser(
      idx_member: myId!,
      page: pageKey,
      limit: _pageSize,
    );

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (myId == null) {
      return Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).canPop()
                ? Navigator.of(context).pop()
                : context.go(HomeScreen.routeName),
          ),
          title: Text(T.myActivity, style: theme.textTheme.headlineMedium),
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
        title: Text(T.myActivity, style: theme.textTheme.headlineMedium),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: MyPostsList(
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
