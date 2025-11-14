import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      // AppBar
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.of(context).canPop()
              ? Navigator.of(context).pop()
              : context.go(HomeScreen.routeName),
        ),
        title: Text(T.appGuideTitle),
        backgroundColor: scheme.primaryContainer,
      ),
      // Body
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Welcome message section
            WelcomeSectionWidget(isAnimated: _isAnimated),
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

/// Welcome section widget
///
/// Displays a welcome message with an animated waving hand icon
class WelcomeSectionWidget extends StatelessWidget {
  final bool isAnimated;

  const WelcomeSectionWidget({super.key, required this.isAnimated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.lightHandWave,
            size: 48,
            color: scheme.primary,
          ).animate(target: isAnimated ? 1 : 0).fadeIn(duration: 600.ms),
          SizedBox(height: sp.s16),
          Text(
                T.guideWelcomeTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
                textAlign: TextAlign.center,
              )
              .animate(target: isAnimated ? 1 : 0)
              .fadeIn(duration: 600.ms, delay: 100.ms),
          SizedBox(height: sp.s8),
          Text(
                T.guideWelcomeSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              )
              .animate(target: isAnimated ? 1 : 0)
              .fadeIn(duration: 600.ms, delay: 200.ms),
        ],
      ),
    );
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
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.primary, size: 28),
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
