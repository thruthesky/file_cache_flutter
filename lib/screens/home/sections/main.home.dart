import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/widgets/home/home.news.dart';
import 'package:philgo/widgets/home/latest.posts.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/home/user.stats.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Fixed header bar with Philgo branding (고정 헤더 바 - Philgo 브랜딩)
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  /// Philgo icon (Philgo 아이콘)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: const PhilGoLogoTriangles(size: 40),
                  ),
                  const SizedBox(width: 8),

                  /// PHILGO text (PHILGO 텍스트)
                  Text(
                    'PHILGO',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 8),

                /// User stats widget
                const UserStats(),

                const SizedBox(height: 8),

                const HomeNews(),

                const SizedBox(height: 8),

                /// Community posts section (커뮤니티 게시물 섹션)
                const LatestPosts(
                  titleName: 'Community',
                  postId: 'freetalk',
                  icon: FontAwesomeIcons.lightComments,
                ),

                const SizedBox(height: 8),

                /// QnA posts section (질문답변 게시물 섹션)
                const LatestPosts(
                  titleName: 'QnA',
                  postId: 'qna',
                  icon: FontAwesomeIcons.lightCircleQuestion,
                ),

                /// Bottom spacing
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
