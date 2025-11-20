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
        // user name
        // user photo
        // no of posts, comments
        // 3 of the user's latest posts and comments
        // advertisement banner
      ],
    );
  }
}
