import 'package:flutter/material.dart';
import 'package:philgo/extensions/nav.context.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_section_header.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 화면 게시판 섹션 위젯 (Home Post Section Widget)
///
/// 특정 게시판의 최근 글을 표시하는 섹션입니다.
/// API에서 최근 글을 가져와서 제목만 간결하게 표시합니다.
///
/// Section displaying latest posts from a specific board.
/// Fetches latest posts from API and displays only titles for simplicity.
///
/// [postId]: 게시판 ID (예: 'freetalk', 'qna')
/// [category]: 서브 카테고리 (옵션)
/// [limit]: 표시할 게시글 수 (기본값: 4)
/// [posts]: 부모로부터 주입받은 게시글 목록 (옵션)
///          - null이면 자체적으로 API 호출하여 데이터 로드
///          - 값이 있으면 API 호출 없이 해당 데이터 사용
class HomePostSection extends StatefulWidget {
  /// 게시판 ID (예: 'freetalk', 'qna')
  /// Board ID (e.g., 'freetalk', 'qna')
  final String postId;

  /// 서브 카테고리 (옵션)
  /// Sub-category (optional)
  final String? category;

  /// 표시할 게시글 수 (기본값: 4)
  /// Number of posts to display (default: 4)
  final int limit;

  /// 부모로부터 주입받은 게시글 목록 (옵션) (Injected posts from parent)
  ///
  /// 부모 위젯(LatestPostsSection)에서 get_latest_posts API를 통해
  /// 한 번에 fetch한 데이터를 전달받습니다.
  /// - null: 자체적으로 postList API 호출
  /// - 값 있음: API 호출 없이 해당 데이터 사용 (성능 최적화)
  final List<Post> posts;

  const HomePostSection({
    super.key,
    required this.postId,
    this.category,
    this.limit = 4,
    required this.posts,
  });

  @override
  State<HomePostSection> createState() => _HomePostSectionState();
}

class _HomePostSectionState extends State<HomePostSection> {
  /// 게시글 목록
  /// Post list
  List<Post>? _posts;

  @override
  void initState() {
    super.initState();

    /// 주입받은 데이터 사용 (Use injected data)
    _posts = widget.posts;
  }

  @override
  void didUpdateWidget(covariant HomePostSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// widget.posts가 변경되면 상태 업데이트 (Update state when widget.posts changes)
    /// 부모에서 데이터가 늦게 로드되는 경우를 대비
    if (widget.posts != oldWidget.posts) {
      setState(() {
        _posts = widget.posts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    /// 섹션 타이틀 (다국어 지원)
    /// Section title (localized)
    final sectionTitle = philgoTr(context, widget.category ?? widget.postId);

    return Padding(
      padding: EdgeInsets.only(
        left: sp.s16,
        right: sp.s16,
        top: sp.s16,
        bottom: sp.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (타이틀 + 더보기)
          /// Section header (title + more button)
          HomeSectionHeader(
            title: sectionTitle,

            /// "더보기" 버튼 클릭 시 해당 게시판으로 이동
            /// Navigate to board when "More" button is tapped
            onMoreTap: () {
              context.openForum(widget.postId, category: widget.category);
            },
          ),

          _buildPostList(sp),
        ],
      ),
    );
  }

  /// 게시글 목록 UI (제목만 표시)
  /// Post list UI (title only)
  Widget _buildPostList(AppSpacing sp) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 게시글 목록 표시 (제목만 표시)
    /// Display post list (title only)
    return Column(
      children: _posts!.map((post) {
        return InkWell(
          /// 게시글 클릭 시 PostViewScreen으로 이동
          /// Navigate to PostViewScreen when post is tapped
          onTap: () => PostViewScreen.push(context, post),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: sp.s4),
            child: Row(
              children: [
                /// 글머리 기호 (bullet point)
                /// Bullet point indicator
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: sp.s8),

                /// 게시글 제목 (제목만 표시)
                /// Post title (title only)
                Expanded(
                  child: Text(
                    post.subject,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
