import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  static const String routeName = '/language';

  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  /// 선택된 언어 코드
  String? _selectedLanguage;

  /// 지원하는 언어 목록
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'zh', 'name': '中文'},
  ];

  /// 언어 저장 함수
  void _saveLanguage() {
    if (_selectedLanguage == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language saved: $_selectedLanguage'),
        duration: const Duration(seconds: 2),
      ),
    );

    // 이전 화면으로 돌아가기
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      /// AppBar
      appBar: AppBar(title: const Text('Language Settings')),

      /// Body
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text('Select Language'),
                icon: Icon(Icons.arrow_drop_down, color: scheme.onSurface),
                items: _languages.map((language) {
                  return DropdownMenuItem<String>(
                    value: language['code'],
                    child: Row(
                      children: [
                        /// 언어 아이콘
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              language['code']!.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        /// 언어 이름
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                language['name']!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),

      /// Bottom Navigation Bar with Save Button
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: scheme.surface),
          child: FilledButton(
            onPressed: _selectedLanguage != null ? _saveLanguage : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 56),
            ),
            child: const Text(
              'Save Language',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
