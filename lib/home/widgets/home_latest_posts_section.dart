import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';

/// 홈 최신글 섹션 - 주요 게시판의 최신글을 CarouselView로 표시
///
/// 6개 게시판에서 각 4개씩 최신글을 가져와 3페이지 캐러셀로 표시한다.
/// 각 페이지는 좌/우 2열 레이아웃이다. 7초마다 자동 스크롤.
class HomeLatestPostsSection extends StatefulWidget {
  const HomeLatestPostsSection({super.key, this.forums = _defaultForums});

  /// 캐러셀에 표시할 게시판 목록 (postId, category, label)
  final List<(String, String?, String)> forums;

  static const _defaultForums = <(String, String?, String)>[
    ('freetalk', null, '자유게시판'),
    ('qna', null, '질문답변'),
    ('buyandsell', null, '사고팔기'),
    ('wanted', null, '구인구직'),
    ('travel', null, '여행'),
    ('massage', null, '마사지'),
  ];

  @override
  State<HomeLatestPostsSection> createState() => _HomeLatestPostsSectionState();
}

class _HomeLatestPostsSectionState extends State<HomeLatestPostsSection> {
  List<(String, String?, String)> get _forums => widget.forums;

  final Map<int, List<Post>> _postsMap = {};
  bool _loading = true;
  int _currentIndex = 0;
  final CarouselController _controller = CarouselController();
  Timer? _autoSlideTimer;

  int get _pageCount => (_forums.length / 2).ceil();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScrollChanged);
    _loadPosts();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _controller.removeListener(_onScrollChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onScrollChanged() {
    if (!_controller.hasClients) return;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final offset = _controller.offset;
    final newIndex = (offset / screenWidth).round().clamp(0, _pageCount - 1);
    if (newIndex != _currentIndex) {
      setState(() => _currentIndex = newIndex);
    }
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % _pageCount;
      _animateToIndex(nextIndex);
    });
  }

  void _stopAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  void _animateToIndex(int index) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    _controller.animateTo(
      index * screenWidth,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loadPosts() async {
    try {
      final results = await Future.wait(
        _forums.map(
          (f) => PostService.list(postId: f.$1, category: f.$2, limit: 4),
        ),
      );
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < results.length; i++) {
          _postsMap[i] = results[i].posts;
        }
        _loading = false;
      });
      _startAutoSlideTimer();
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (_postsMap.isEmpty) return const SizedBox.shrink();

    final screenWidth = MediaQuery.sizeOf(context).width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Listener(
          onPointerDown: (_) => _stopAutoSlideTimer(),
          child: SizedBox(
            height: 150,
            child: CarouselView(
              enableSplash: false,
              controller: _controller,
              itemExtent: screenWidth,
              shrinkExtent: screenWidth * 0.85,
              itemSnapping: true,
              padding: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(),
              children: List.generate(_pageCount, _buildPage),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pageCount, (i) {
            final isSelected = i == _currentIndex;
            return GestureDetector(
              onTap: () {
                _animateToIndex(i);
                _stopAutoSlideTimer();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isSelected ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.primary
                      : color.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPage(int pageIndex) {
    final leftIdx = pageIndex * 2;
    final rightIdx = pageIndex * 2 + 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildForumColumn(
              _forums[leftIdx].$3.tr(),
              _forums[leftIdx].$1,
              _forums[leftIdx].$2,
              _postsMap[leftIdx] ?? [],
            ),
          ),
          const SizedBox(width: 12),
          if (rightIdx < _forums.length)
            Expanded(
              child: _buildForumColumn(
                _forums[rightIdx].$3.tr(),
                _forums[rightIdx].$1,
                _forums[rightIdx].$2,
                _postsMap[rightIdx] ?? [],
              ),
            )
          else
            const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _buildForumColumn(
    String title,
    String postId,
    String? category,
    List<Post> posts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            GestureDetector(
              onTap: () {
                AppNavigationState.of(
                  context,
                ).openForumScreen(postId: postId, category: category);
              },
              child: Text(
                // "More"
                '더보기'.tr(),
                style: text.labelSmall?.copyWith(color: color.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...posts.map((post) => _buildPostTile(post)),
      ],
    );
  }

  Widget _buildPostTile(Post post) {
    return InkWell(
      onTap: () => PostViewScreen.push(context, post),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                post.subject,
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (post.noOfComment > 0) ...[
              const SizedBox(width: 4),
              FaIcon(FontAwesomeIcons.comment, size: 10, color: color.outline),
              const SizedBox(width: 2),
              Text(
                '${post.noOfComment}',
                style: text.labelSmall?.copyWith(color: color.outline),
              ),
            ],
            const SizedBox(width: 4),
            FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 8,
              color: color.outline.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
