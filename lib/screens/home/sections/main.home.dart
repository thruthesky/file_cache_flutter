import 'package:flutter/material.dart';
import 'package:philgo/widgets/home/home.news.dart';
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
                  const PhilGoLogoTriangles(size: 40),
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
                const SizedBox(height: 16),

                /// User stats widget
                const UserStats(),

                const SizedBox(height: 16),

                const HomeNews(),

                /// Bottom spacing
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
