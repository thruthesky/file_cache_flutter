import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 테마 미리보기 화면
///
/// 앱의 전체 테마 시스템을 시각적으로 확인할 수 있는 화면입니다.
/// - ColorScheme (색상 팔레트)
/// - TextTheme (타이포그래피)
/// - Spacing (간격 토큰)
/// - Components (버튼, 카드, 입력 필드 등)
class ThemePreviewScreen extends StatefulWidget {
  const ThemePreviewScreen({super.key});

  /// 라우트 이름
  static const String routeName = '/theme-preview';

  /// 화면 푸시 메서드
  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ThemePreviewScreen()),
    );
  }

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  bool _switchValue = false;
  bool _checkboxValue = false;
  int _radioValue = 1;
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Scaffold(
      appBar: AppBar(title: const Text('테마 미리보기')),
      body: ListView(
        padding: EdgeInsets.all(spacing.s16),
        children: [
          // 색상 팔레트 섹션
          _buildSectionTitle('색상 팔레트 (ColorScheme)', theme),
          SizedBox(height: spacing.s16),
          _buildColorPaletteSection(colorScheme, spacing),
          SizedBox(height: spacing.s32),

          // 타이포그래피 섹션
          _buildSectionTitle('타이포그래피 (TextTheme)', theme),
          SizedBox(height: spacing.s16),
          _buildTypographySection(textTheme, spacing),
          SizedBox(height: spacing.s32),

          // 간격 토큰 섹션
          _buildSectionTitle('간격 토큰 (Spacing)', theme),
          SizedBox(height: spacing.s16),
          _buildSpacingSection(spacing, colorScheme),
          SizedBox(height: spacing.s32),

          // 버튼 컴포넌트 섹션
          _buildSectionTitle('버튼 (Buttons)', theme),
          SizedBox(height: spacing.s16),
          _buildButtonsSection(spacing),
          SizedBox(height: spacing.s32),

          // 카드 컴포넌트 섹션
          _buildSectionTitle('카드 (Cards)', theme),
          SizedBox(height: spacing.s16),
          _buildCardsSection(spacing, colorScheme),
          SizedBox(height: spacing.s32),

          // 입력 필드 섹션
          _buildSectionTitle('입력 필드 (Input Fields)', theme),
          SizedBox(height: spacing.s16),
          _buildInputFieldsSection(spacing),
          SizedBox(height: spacing.s32),

          // 선택 컨트롤 섹션
          _buildSectionTitle('선택 컨트롤 (Selection Controls)', theme),
          SizedBox(height: spacing.s16),
          _buildSelectionControlsSection(spacing),
          SizedBox(height: spacing.s32),

          // Chips 섹션
          _buildSectionTitle('칩 (Chips)', theme),
          SizedBox(height: spacing.s16),
          _buildChipsSection(spacing),
          SizedBox(height: spacing.s32),

          // Progress Indicators 섹션
          _buildSectionTitle('진행 표시기 (Progress Indicators)', theme),
          SizedBox(height: spacing.s16),
          _buildProgressIndicatorsSection(spacing, colorScheme),
          SizedBox(height: spacing.s32),

          // ListTiles 섹션
          _buildSectionTitle('리스트 타일 (ListTiles)', theme),
          SizedBox(height: spacing.s16),
          _buildListTilesSection(spacing),
          SizedBox(height: spacing.s32),

          // 대화상자 & 스낵바 섹션
          _buildSectionTitle('대화상자 & 스낵바', theme),
          SizedBox(height: spacing.s16),
          _buildDialogsSection(spacing),
          SizedBox(height: spacing.s48),
        ],
      ),
    );
  }

  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// 색상 팔레트 섹션
  Widget _buildColorPaletteSection(ColorScheme cs, AppSpacing spacing) {
    return Column(
      children: [
        // Primary Colors
        _buildColorCategory('Primary Colors', [
          _ColorItem('primary', cs.primary, cs.onPrimary),
          _ColorItem('onPrimary', cs.onPrimary, cs.primary),
          _ColorItem(
            'primaryContainer',
            cs.primaryContainer,
            cs.onPrimaryContainer,
          ),
          _ColorItem(
            'onPrimaryContainer',
            cs.onPrimaryContainer,
            cs.primaryContainer,
          ),
        ], spacing),
        SizedBox(height: spacing.s16),

        // Secondary Colors
        _buildColorCategory('Secondary Colors', [
          _ColorItem('secondary', cs.secondary, cs.onSecondary),
          _ColorItem('onSecondary', cs.onSecondary, cs.secondary),
          _ColorItem(
            'secondaryContainer',
            cs.secondaryContainer,
            cs.onSecondaryContainer,
          ),
          _ColorItem(
            'onSecondaryContainer',
            cs.onSecondaryContainer,
            cs.secondaryContainer,
          ),
        ], spacing),
        SizedBox(height: spacing.s16),

        // Tertiary Colors
        _buildColorCategory('Tertiary Colors', [
          _ColorItem('tertiary', cs.tertiary, cs.onTertiary),
          _ColorItem('onTertiary', cs.onTertiary, cs.tertiary),
          _ColorItem(
            'tertiaryContainer',
            cs.tertiaryContainer,
            cs.onTertiaryContainer,
          ),
          _ColorItem(
            'onTertiaryContainer',
            cs.onTertiaryContainer,
            cs.tertiaryContainer,
          ),
        ], spacing),
        SizedBox(height: spacing.s16),

        // Error Colors
        _buildColorCategory('Error Colors', [
          _ColorItem('error', cs.error, cs.onError),
          _ColorItem('onError', cs.onError, cs.error),
          _ColorItem('errorContainer', cs.errorContainer, cs.onErrorContainer),
          _ColorItem(
            'onErrorContainer',
            cs.onErrorContainer,
            cs.errorContainer,
          ),
        ], spacing),
        SizedBox(height: spacing.s16),

        // Surface Colors
        _buildColorCategory('Surface Colors', [
          _ColorItem('surface', cs.surface, cs.onSurface),
          _ColorItem('onSurface', cs.onSurface, cs.surface),
          _ColorItem(
            'surfaceVariant',
            cs.surfaceContainerHighest,
            cs.onSurface,
          ),
          _ColorItem('outline', cs.outline, cs.surface),
          _ColorItem('outlineVariant', cs.outlineVariant, cs.surface),
        ], spacing),
      ],
    );
  }

  /// 색상 카테고리 위젯
  Widget _buildColorCategory(
    String title,
    List<_ColorItem> colors,
    AppSpacing spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        SizedBox(height: spacing.s8),
        Wrap(
          spacing: spacing.s8,
          runSpacing: spacing.s8,
          children: colors.map((color) {
            return Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                color: color.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  color.name,
                  style: TextStyle(
                    color: color.textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 타이포그래피 섹션
  Widget _buildTypographySection(TextTheme textTheme, AppSpacing spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Styles
        _buildTextStyleExample(
          'displayLarge',
          textTheme.displayLarge,
          'Display Large',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'displayMedium',
          textTheme.displayMedium,
          'Display Medium',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'displaySmall',
          textTheme.displaySmall,
          'Display Small',
        ),
        SizedBox(height: spacing.s16),

        // Headline Styles
        _buildTextStyleExample(
          'headlineLarge',
          textTheme.headlineLarge,
          'Headline Large',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'headlineMedium',
          textTheme.headlineMedium,
          'Headline Medium',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'headlineSmall',
          textTheme.headlineSmall,
          'Headline Small',
        ),
        SizedBox(height: spacing.s16),

        // Title Styles
        _buildTextStyleExample(
          'titleLarge',
          textTheme.titleLarge,
          'Title Large',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'titleMedium',
          textTheme.titleMedium,
          'Title Medium',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'titleSmall',
          textTheme.titleSmall,
          'Title Small',
        ),
        SizedBox(height: spacing.s16),

        // Body Styles
        _buildTextStyleExample(
          'bodyLarge',
          textTheme.bodyLarge,
          'Body Large - 본문 텍스트 크게',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'bodyMedium',
          textTheme.bodyMedium,
          'Body Medium - 본문 텍스트 중간',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'bodySmall',
          textTheme.bodySmall,
          'Body Small - 본문 텍스트 작게',
        ),
        SizedBox(height: spacing.s16),

        // Label Styles
        _buildTextStyleExample(
          'labelLarge',
          textTheme.labelLarge,
          'Label Large',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'labelMedium',
          textTheme.labelMedium,
          'Label Medium',
        ),
        SizedBox(height: spacing.s8),
        _buildTextStyleExample(
          'labelSmall',
          textTheme.labelSmall,
          'Label Small',
        ),
      ],
    );
  }

  /// 텍스트 스타일 예제 위젯
  Widget _buildTextStyleExample(String name, TextStyle? style, String example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$name (${style?.fontSize?.toInt()}px / ${_fontWeightToString(style?.fontWeight)})',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(example, style: style),
      ],
    );
  }

  /// FontWeight를 문자열로 변환
  String _fontWeightToString(FontWeight? weight) {
    if (weight == null) return 'Regular';
    switch (weight.index) {
      case 0:
        return 'Thin (100)';
      case 1:
        return 'ExtraLight (200)';
      case 2:
        return 'Light (300)';
      case 3:
        return 'Regular (400)';
      case 4:
        return 'Medium (500)';
      case 5:
        return 'SemiBold (600)';
      case 6:
        return 'Bold (700)';
      case 7:
        return 'ExtraBold (800)';
      case 8:
        return 'Black (900)';
      default:
        return 'Regular';
    }
  }

  /// 간격 토큰 섹션
  Widget _buildSpacingSection(AppSpacing spacing, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSpacingItem('s4', spacing.s4, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s8', spacing.s8, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s12', spacing.s12, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s16', spacing.s16, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s20', spacing.s20, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s24', spacing.s24, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s32', spacing.s32, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s40', spacing.s40, colorScheme),
        SizedBox(height: spacing.s8),
        _buildSpacingItem('s48', spacing.s48, colorScheme),
      ],
    );
  }

  /// 간격 아이템 위젯
  Widget _buildSpacingItem(String name, double value, ColorScheme colorScheme) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            name,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
        SizedBox(width: 16),
        Text(
          '${value.toInt()}px',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: value,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 버튼 섹션
  Widget _buildButtonsSection(AppSpacing spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ElevatedButton
        ElevatedButton(onPressed: () {}, child: const Text('ElevatedButton')),
        SizedBox(height: spacing.s8),

        // ElevatedButton (Disabled)
        ElevatedButton(
          onPressed: null,
          child: const Text('ElevatedButton (Disabled)'),
        ),
        SizedBox(height: spacing.s8),

        // FilledButton
        FilledButton(onPressed: () {}, child: const Text('FilledButton')),
        SizedBox(height: spacing.s8),

        // OutlinedButton
        OutlinedButton(onPressed: () {}, child: const Text('OutlinedButton')),
        SizedBox(height: spacing.s8),

        // TextButton
        TextButton(onPressed: () {}, child: const Text('TextButton')),
        SizedBox(height: spacing.s8),

        // IconButton
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('FilledButton.icon'),
            ),
          ],
        ),
      ],
    );
  }

  /// 카드 섹션
  Widget _buildCardsSection(AppSpacing spacing, ColorScheme colorScheme) {
    return Column(
      children: [
        // 기본 Card
        Card(
          child: Padding(
            padding: EdgeInsets.all(spacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기본 카드',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: spacing.s8),
                Text('Flat 디자인 원칙에 따라 elevation: 0으로 설정되어 그림자가 없습니다.'),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.s12),

        // Colored Card
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: EdgeInsets.all(spacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '색상이 있는 카드',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: spacing.s8),
                Text(
                  'primaryContainer 색상을 사용한 카드입니다.',
                  style: TextStyle(color: colorScheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 입력 필드 섹션
  Widget _buildInputFieldsSection(AppSpacing spacing) {
    return Column(
      children: [
        // 기본 TextField
        TextField(
          decoration: InputDecoration(
            labelText: '레이블',
            hintText: '힌트 텍스트를 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: spacing.s16),

        // TextField with prefix icon
        TextField(
          decoration: InputDecoration(
            labelText: '이메일',
            hintText: 'example@email.com',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: spacing.s16),

        // TextField with suffix icon
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: '비밀번호',
            hintText: '비밀번호를 입력하세요',
            suffixIcon: Icon(Icons.visibility_off),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// 선택 컨트롤 섹션
  Widget _buildSelectionControlsSection(AppSpacing spacing) {
    return Column(
      children: [
        // Switch
        SwitchListTile(
          title: const Text('스위치'),
          subtitle: const Text('켜기/끄기 토글'),
          value: _switchValue,
          onChanged: (value) {
            setState(() => _switchValue = value);
          },
        ),

        // Checkbox
        CheckboxListTile(
          title: const Text('체크박스'),
          subtitle: const Text('선택/해제'),
          value: _checkboxValue,
          onChanged: (value) {
            setState(() => _checkboxValue = value ?? false);
          },
        ),

        // Radio buttons
        // ignore: deprecated_member_use
        RadioListTile<int>(
          title: const Text('라디오 버튼 1'),
          value: 1,
          // ignore: deprecated_member_use
          groupValue: _radioValue,
          // ignore: deprecated_member_use
          onChanged: (value) {
            setState(() => _radioValue = value ?? 1);
          },
        ),
        // ignore: deprecated_member_use
        RadioListTile<int>(
          title: const Text('라디오 버튼 2'),
          value: 2,
          // ignore: deprecated_member_use
          groupValue: _radioValue,
          // ignore: deprecated_member_use
          onChanged: (value) {
            setState(() => _radioValue = value ?? 1);
          },
        ),

        // Slider
        ListTile(
          title: const Text('슬라이더'),
          subtitle: Slider(
            value: _sliderValue,
            onChanged: (value) {
              setState(() => _sliderValue = value);
            },
          ),
        ),
      ],
    );
  }

  /// Chips 섹션
  Widget _buildChipsSection(AppSpacing spacing) {
    return Wrap(
      spacing: spacing.s8,
      runSpacing: spacing.s8,
      children: [
        Chip(label: const Text('Chip')),
        Chip(
          avatar: const Icon(Icons.person, size: 18),
          label: const Text('Avatar Chip'),
        ),
        ActionChip(
          avatar: const Icon(Icons.add, size: 18),
          label: const Text('Action Chip'),
          onPressed: () {},
        ),
        FilterChip(
          label: const Text('Filter Chip'),
          selected: true,
          onSelected: (value) {},
        ),
        ChoiceChip(label: const Text('Choice Chip'), selected: false),
      ],
    );
  }

  /// 진행 표시기 섹션
  Widget _buildProgressIndicatorsSection(
    AppSpacing spacing,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: spacing.s8),
                Text('Circular', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(value: 0.7),
                ),
                SizedBox(height: spacing.s8),
                Text('Circular (70%)', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        SizedBox(height: spacing.s16),
        LinearProgressIndicator(),
        SizedBox(height: spacing.s16),
        LinearProgressIndicator(value: 0.7),
      ],
    );
  }

  /// ListTiles 섹션
  Widget _buildListTilesSection(AppSpacing spacing) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('홈'),
            subtitle: Text('메인 화면으로 이동'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('설정'),
            subtitle: Text('앱 설정 관리'),
            trailing: Icon(Icons.chevron_right),
          ),
          Divider(height: 1),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('프로필'),
            subtitle: Text('사용자 프로필 보기'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  /// 대화상자 & 스낵바 섹션
  Widget _buildDialogsSection(AppSpacing spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('대화상자'),
                content: const Text('이것은 샘플 대화상자입니다.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          },
          child: const Text('대화상자 표시'),
        ),
        SizedBox(height: spacing.s8),
        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('스낵바 메시지입니다'),
                action: SnackBarAction(label: '실행 취소', onPressed: () {}),
              ),
            );
          },
          child: const Text('스낵바 표시'),
        ),
        SizedBox(height: spacing.s8),
        OutlinedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: EdgeInsets.all(spacing.s24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bottom Sheet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: spacing.s16),
                    Text('이것은 하단 시트 예제입니다.'),
                    SizedBox(height: spacing.s24),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Text('Bottom Sheet 표시'),
        ),
      ],
    );
  }
}

/// 색상 아이템 데이터 클래스
class _ColorItem {
  final String name;
  final Color backgroundColor;
  final Color textColor;

  _ColorItem(this.name, this.backgroundColor, this.textColor);
}
