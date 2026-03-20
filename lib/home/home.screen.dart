import 'package:flutter/material.dart';
import 'widgets/home_menu_categories.dart';
import 'widgets/home_top_banners.dart';
import 'widgets/home_latest_posts_section.dart';
import 'widgets/home_wing_banners.dart';
import 'widgets/home_popular_post_section.dart';
import 'widgets/home_major_forum_section.dart';
import 'widgets/home_helper_menu_section.dart';
import 'widgets/home_notices_section.dart';
import 'widgets/home_dev_mode_banner.dart';
import 'widgets/home_quick_post_box.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// 섹션 간 여백
  static const _sectionGap = SliverToBoxAdapter(child: SizedBox(height: 16));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// [메뉴 카테고리] 가로 스크롤 텍스트 카테고리
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: HomeMenuCategories(),
              ),
            ),
          ),

          /// [가짜 글쓰기 입력창] 클릭 시 게시판 선택 후 글 작성
          const SliverToBoxAdapter(child: HomeQuickPostBox()),

          /// [개발 모드] API 연결 상태 표시 (디버그 모드에서만)
          const SliverToBoxAdapter(child: HomeDevModeBanner()),

          /// [헬퍼 메뉴] 필리핀 생활 필수 바로가기 (둥근 사각형 아이콘 그리드)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: HomeHelperMenuSection(),
            ),
          ),

          _sectionGap,

          /// [상단 배너] 좌/우 배너 로테이션
          const SliverToBoxAdapter(child: HomeTopBanners()),

          _sectionGap,

          /// [최신글] 6개 게시판 캐러셀 (2열 × 3페이지)
          const SliverToBoxAdapter(child: HomeLatestPostsSection()),

          _sectionGap,

          /// [날개 배너] 5열 그리드
          const SliverToBoxAdapter(child: HomeWingBanners()),

          _sectionGap,

          /// [공지사항] 최신 공지
          const SliverToBoxAdapter(child: HomeNoticesSection()),

          _sectionGap,

          /// [인기글] 댓글 많은 게시글
          const SliverToBoxAdapter(child: HomePopularPostSection()),

          _sectionGap,

          /// [주요 게시판] Wrap 레이아웃 포럼 칩
          const SliverToBoxAdapter(child: HomeMajorForumSection()),

          /// 하단 여백
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
