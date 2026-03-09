import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/intro.header.dart';
import 'package:philgo/widgets/logo/philgo.logo.triangles.dart';
import 'package:philgo/widgets/theme/comic_card.dart';
import 'package:philgo_api/philgo_api.dart';

/// App guide screen
/// A screen that guides users through the main features and usage of the PhilGo app.
class AppGuideScreen extends StatefulWidget {
  static const String routeName = '/app-guide';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const AppGuideScreen({super.key});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isAnimated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      // Comic Design: AppBar with 1.0px bottom border (matches bottom nav)
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
        title: Text(T.appGuideTitle, style: theme.textTheme.titleLarge),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),
      // Body
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Welcome message section
            IntroHeader(
              introTitle: T.guideWelcomeTitle,
              introDescription: T.guideWelcomeSubtitle,
              introWidget: PhilGoLogoTriangles(animated: true, size: 128),
            ),
            SizedBox(height: sp.s32),

            /// How to get started section
            GettingStartedSectionWidget(isAnimated: _isAnimated),
            SizedBox(height: sp.s32),

            /// Key features section
            FeaturesSectionWidget(isAnimated: _isAnimated),
            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }
}

/// Getting started section widget
///
/// Displays a step-by-step guide for new users
class GettingStartedSectionWidget extends StatelessWidget {
  final bool isAnimated;

  const GettingStartedSectionWidget({super.key, required this.isAnimated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final steps = [
      {
        'icon': FontAwesomeIcons.lightCompass,
        'title': T.guideStep2Title,
        'description': T.guideStep2Desc,
      },
      {
        'icon': FontAwesomeIcons.lightPenToSquare,
        'title': T.guideStep3Title,
        'description': T.guideStep3Desc,
      },
      {
        'icon': FontAwesomeIcons.lightUsers,
        'title': T.guideStep4Title,
        'description': T.guideStep4Desc,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.guideGettingStartedTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        SizedBox(height: sp.s16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return GuideStepWidget(
            icon: step['icon'] as IconData,
            title: step['title'] as String,
            description: step['description'] as String,
            index: index,
            isAnimated: isAnimated,
          );
        }),
      ],
    );
  }
}

/// Guide step widget
///
/// A card displaying a single step with icon, title, and description
class GuideStepWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int index;
  final bool isAnimated;

  const GuideStepWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.index,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return ComicListCard(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          child: Row(
            children: [
              /// Icon badge
              IconContainer(
                icon: icon,
                size: 56,
                iconSize: 28,
                borderRadius: 12,
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: (300 + index * 100).ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Features section widget
///
/// Displays the main features of the app with icons and descriptions
class FeaturesSectionWidget extends StatelessWidget {
  final bool isAnimated;

  const FeaturesSectionWidget({super.key, required this.isAnimated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final features = [
      {
        'icon': FontAwesomeIcons.lightComments,
        'title': T.guideFeatureCommunityTitle,
        'description': T.guideFeatureCommunityDesc,
      },
      {
        'icon': FontAwesomeIcons.lightMessage,
        'title': T.guideFeatureChatTitle,
        'description': T.guideFeatureChatDesc,
      },
      {
        'icon': FontAwesomeIcons.lightStore,
        'title': T.guideFeatureDirectoryTitle,
        'description': T.guideFeatureDirectoryDesc,
      },
      {
        'icon': FontAwesomeIcons.lightPenToSquare,
        'title': T.guideFeatureWriteTitle,
        'description': T.guideFeatureWriteDesc,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          T.guideFeaturesTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        SizedBox(height: sp.s16),
        ...features.asMap().entries.map((entry) {
          final index = entry.key;
          final feature = entry.value;
          return FeatureCardWidget(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
            index: index,
            isAnimated: isAnimated,
          );
        }),
      ],
    );
  }
}

/// Feature card widget
///
/// A card displaying a single feature with icon, title, and description
class FeatureCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int index;
  final bool isAnimated;

  const FeatureCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.index,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return ComicListCard(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          child: Row(
            children: [
              IconContainer(
                icon: icon,
                size: 56,
                iconSize: 28,
                borderRadius: 12,
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: (300 + index * 100).ms)
        .slideX(begin: -0.1, end: 0);
  }
}
