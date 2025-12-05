import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/widgets/theme/comic_card.dart';
import 'package:philgo/widgets/theme/comic_snackbar.dart';

class LanguageScreen extends StatefulWidget {
  static const String routeName = '/language';

  const LanguageScreen({super.key});

  /// 언어 설정 화면으로 이동
  static Future<T?> push<T>(BuildContext context) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => const LanguageScreen()),
    );
  }

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'zh', 'name': '中文'},
  ];

  @override
  void initState() {
    super.initState();
    final appState = AppState.of(context);
    if (appState.locale != null) {
      _selectedLanguage = appState.locale!.languageCode;
    }
  }

  void _saveLanguage() {
    if (_selectedLanguage == null) return;

    final appState = AppState.of(context);
    final newLocale = Locale(_selectedLanguage!);
    appState.setLocale(newLocale);

    // Use the newly selected locale for the snackbar message
    final lo = lookupLo(newLocale);

    // Comic Design: Use Comic SnackBar for consistent styling
    showComicInfoSnackBar(context, lo.languageChanged);

    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      /// AppBar
      appBar: AppBar(
        title: Text(
          Lo.of(context)!.languageSettings,
          style: theme.textTheme.titleLarge,
        ),
        // Comic Design: AppBar with 2.0px bottom border
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 2, color: scheme.outline),
        ),
      ),

      /// Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Language Selection Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Language Options
                ..._languages.map((language) {
                  final isSelected = _selectedLanguage == language['code'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ComicListCard(
                      onTap: () {
                        setState(() {
                          _selectedLanguage = language['code'];
                        });
                        _saveLanguage();
                      },
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          /// Language Icon Badge
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? scheme.primaryContainer
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? scheme.primary
                                    : scheme.outline,
                                width: isSelected ? 2.0 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                language['code']!.toUpperCase(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// Language Name
                          Expanded(
                            child: Text(
                              language['name']!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? scheme.primary
                                    : scheme.onSurface,
                              ),
                            ),
                          ),

                          /// Selection Indicator
                          if (isSelected)
                            FaIcon(
                              FontAwesomeIcons.circleCheck,
                              size: 20,
                              color: scheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
