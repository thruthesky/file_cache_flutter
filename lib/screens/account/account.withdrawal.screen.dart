import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/widgets/intro.header.dart';
import 'package:philgo/widgets/information.box.dart';
import 'package:url_launcher/url_launcher.dart';

/// Account withdrawal screen
class AccountWithdrawalScreen extends StatefulWidget {
  static const String routeName = '/account-withdrawal';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const AccountWithdrawalScreen({super.key});

  @override
  State<AccountWithdrawalScreen> createState() =>
      _AccountWithdrawalScreenState();
}

class _AccountWithdrawalScreenState extends State<AccountWithdrawalScreen> {
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
        title: Text(T.accountWithdrawalTitle),
        backgroundColor: scheme.primaryContainer,
      ),
      // Body
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Intro section
            IntroHeader(
              introTitle: T.withdrawalIntroTitle,
              introDescription: T.withdrawalIntroSubtitle,
              introIcon: FontAwesomeIcons.lightUserXmark,
            ),
            SizedBox(height: sp.s32),

            /// Step 1: Data to be deleted
            SectionTitleWidget(
              title: '1. ${T.withdrawalStep1Title}',
              isAnimated: _isAnimated,
              delay: 0,
            ),
            SizedBox(height: sp.s16),
            DataCategoryWidget(
              icon: FontAwesomeIcons.lightCreditCard,
              title: T.withdrawalAccountInfoTitle,
              description: T.withdrawalAccountInfoDesc,
              isAnimated: _isAnimated,
              index: 0,
            ),
            DataCategoryWidget(
              icon: FontAwesomeIcons.lightChartColumn,
              title: T.withdrawalUsageHistoryTitle,
              description: T.withdrawalUsageHistoryDesc,
              isAnimated: _isAnimated,
              index: 1,
            ),
            DataCategoryWidget(
              icon: FontAwesomeIcons.lightCloud,
              title: T.withdrawalAdditionalDataTitle,
              description: T.withdrawalAdditionalDataDesc,
              isAnimated: _isAnimated,
              index: 2,
            ),
            SizedBox(height: sp.s8),
            InformationBox(
                  message: T.withdrawalPaymentNote,
                  icon: FontAwesomeIcons.lightCircleInfo,
                  bgColor: scheme.secondaryContainer.withValues(alpha: 0.3),
                )
                .animate(target: _isAnimated ? 1 : 0)
                .fadeIn(duration: 600.ms, delay: 600.ms)
                .slideX(begin: 0.1, end: 0),
            SizedBox(height: sp.s32),

            /// Step 2: Deletion method
            SectionTitleWidget(
              title: '2. ${T.withdrawalStep2Title}',
              isAnimated: _isAnimated,
              delay: 100,
            ),
            SizedBox(height: sp.s16),
            EmailRequestWidget(isAnimated: _isAnimated),
            SizedBox(height: sp.s32),

            /// Step 3: Processing & timeline
            SectionTitleWidget(
              title: '3. ${T.withdrawalStep3Title}',
              isAnimated: _isAnimated,
              delay: 200,
            ),
            SizedBox(height: sp.s16),
            ProcessingInfoWidget(
              text: T.withdrawalProcessingDesc,
              isAnimated: _isAnimated,
            ),
            SizedBox(height: sp.s8),
            InformationBox(
                  message: T.withdrawalIrreversibleNote,
                  icon: FontAwesomeIcons.lightTriangleExclamation,
                  bgColor: scheme.errorContainer.withValues(alpha: 0.3),
                )
                .animate(target: _isAnimated ? 1 : 0)
                .fadeIn(duration: 600.ms, delay: 900.ms)
                .slideX(begin: 0.1, end: 0),
            SizedBox(height: sp.s32),

            /// Step 4: Data retention exceptions
            SectionTitleWidget(
              title: '4. ${T.withdrawalStep4Title}',
              isAnimated: _isAnimated,
              delay: 300,
            ),
            SizedBox(height: sp.s16),
            RetentionInfoWidget(
              text: T.withdrawalRetentionDesc,
              isAnimated: _isAnimated,
            ),
            SizedBox(height: sp.s32),

            /// Step 5: Contact
            SectionTitleWidget(
              title: '5. ${T.withdrawalStep5Title}',
              isAnimated: _isAnimated,
              delay: 400,
            ),
            SizedBox(height: sp.s16),
            ContactInfoWidget(
              text: T.withdrawalContactDesc,
              isAnimated: _isAnimated,
            ),
            SizedBox(height: sp.s32),

            /// Request withdrawal button
            RequestWithdrawalButtonWidget(isAnimated: _isAnimated),
          ],
        ),
      ),
    );
  }
}

/// Section title widget
/// Displays a simple section title matching the guide screen style
class SectionTitleWidget extends StatelessWidget {
  final String title;
  final bool isAnimated;
  final int delay;

  const SectionTitleWidget({
    super.key,
    required this.title,
    required this.isAnimated,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: delay.ms)
        .slideY(begin: -0.1, end: 0);
  }
}

class DataCategoryWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isAnimated;
  final int index;

  const DataCategoryWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isAnimated,
    required this.index,
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

/// Email request widget
///
/// Displays email request information for account withdrawal
/// Matches the guide screen card style
class EmailRequestWidget extends StatelessWidget {
  final bool isAnimated;

  const EmailRequestWidget({super.key, required this.isAnimated});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
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
                child: Icon(
                  FontAwesomeIcons.lightEnvelope,
                  color: scheme.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Text(
                  T.withdrawalEmailRequest,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 700.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Processing info widget
///
/// Displays processing timeline information
/// Matches the guide screen card style
class ProcessingInfoWidget extends StatelessWidget {
  final String text;
  final bool isAnimated;

  const ProcessingInfoWidget({
    super.key,
    required this.text,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 800.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Retention info widget
///
/// Displays data retention exception information
/// Matches the guide screen card style
class RetentionInfoWidget extends StatelessWidget {
  final String text;
  final bool isAnimated;

  const RetentionInfoWidget({
    super.key,
    required this.text,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FontAwesomeIcons.lightShieldCheck,
                  color: scheme.tertiary,
                  size: 28,
                ),
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 1000.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Contact info widget
///
/// Displays contact information with email link
/// Matches the guide screen card style
class ContactInfoWidget extends StatelessWidget {
  final String text;
  final bool isAnimated;

  const ContactInfoWidget({
    super.key,
    required this.text,
    required this.isAnimated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FontAwesomeIcons.lightCircleQuestion,
                  color: scheme.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 1100.ms)
        .slideX(begin: -0.1, end: 0);
  }
}

/// Request withdrawal button widget
///
/// A button that allows users to send an email to request account withdrawal
class RequestWithdrawalButtonWidget extends StatelessWidget {
  final bool isAnimated;

  const RequestWithdrawalButtonWidget({super.key, required this.isAnimated});

  Future<void> _sendWithdrawalEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'philgohelp@gmail.com',
      query:
          'subject=${Uri.encodeComponent('Account Withdrawal Request')}&body=${Uri.encodeComponent('I would like to request account withdrawal.\n\nPlease delete all my personal data.\n\nThank you.')}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch email app')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _sendWithdrawalEmail(context),
            icon: const Icon(FontAwesomeIcons.lightEnvelope),
            label: Text(T.requestWithdrawal),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: sp.s16),
            ),
          ),
        )
        .animate(target: isAnimated ? 1 : 0)
        .fadeIn(duration: 600.ms, delay: 1200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}
