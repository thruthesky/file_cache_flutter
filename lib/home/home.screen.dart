import 'package:flutter/material.dart';
import 'widgets/home_menu_categories.dart';
import 'widgets/home_top_banners.dart';
import 'widgets/home_latest_posts_section.dart';
import 'widgets/home_wing_banners.dart';
import 'widgets/home_popular_post_section.dart';
import 'widgets/home_major_forum_section.dart';
import 'widgets/home_helper_menu_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          /// [메뉴 카테고리] 가로 스크롤 포럼 카테고리 칩
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: HomeMenuCategories(),
              ),
            ),
          ),

          /// [헬퍼 메뉴] 필리핀 생활 필수 바로가기 (가로 스크롤 원형 아이콘)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 8),
              child: HomeHelperMenuSection(),
            ),
          ),

          /// [상단 배너] 좌/우 배너 로테이션
          const SliverToBoxAdapter(child: HomeTopBanners()),

          /// [최신글] 자유게시판 + 질문답변 2단 레이아웃
          const SliverToBoxAdapter(child: HomeLatestPostsSection()),

          /// [날개 배너] 5열 그리드
          const SliverToBoxAdapter(child: HomeWingBanners()),

          /// [인기글] 댓글 많은 게시글
          const SliverToBoxAdapter(child: HomePopularPostSection()),

          /// [주요 게시판] Wrap 레이아웃 포럼 칩
          const SliverToBoxAdapter(child: HomeMajorForumSection()),

          /// 하단 여백
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
