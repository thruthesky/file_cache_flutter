import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/headers/forum_header.notification_menu_item.dart';
import 'package:philgo_api/philgo_api.dart';

class ForumHeaderNotificationIconButton extends StatelessWidget {
  const ForumHeaderNotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            /// Flat design - elevation 0
            elevation: 0,
            backgroundColor: scheme.surface,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: 400,
              ),
              padding: EdgeInsets.all(sp.s16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 다이얼로그 헤더
                  /// Dialog header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Lo.of(context)!.notification,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.lightXmark,
                          color: scheme.onSurface,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  SizedBox(height: sp.s16),

                  /// 카테고리 목록
                  /// Category list - Using ListView.builder for lazy loading
                  /// This prevents creating all widgets at once, improving performance
                  /// and preventing crashes when list items exceed 25
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final categories = PhilgoCategory.menuCategories(
                          includeTemp: isDeveloperModeEnabled,
                        );
                        return ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final (postId, subCategory) = categories[index];
                            return ForumHeaderNotificationMenuItem(
                              key: ValueKey('$postId${subCategory ?? ''}'),
                              postId: postId,
                              subCategory: subCategory,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: FaIcon(
          FontAwesomeIcons.solidBellRing,
          size: 12,
          color: scheme.primary,
        ),
      ),
    );
  }
}
