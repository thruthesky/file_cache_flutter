import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/widgets/home/home.news.dart';
import 'package:philgo/widgets/home/latest.posts.dart';

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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Image.asset('assets/img/logo/philgo_wide_logo.png', height: 32),
              ],
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
