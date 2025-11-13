import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignScreen extends StatefulWidget {
  static const String routeName = '/design';
  static Function(BuildContext ctx, String _) push = (ctx, roomId) =>
      ctx.push(routeName);
  static Function(BuildContext ctx, String _) go = (ctx, roomId) =>
      ctx.go(routeName);
  const DesignScreen({super.key});

  @override
  State<DesignScreen> createState() => _DesignScreenState();
}

class _DesignScreenState extends State<DesignScreen> {
  bool _useDefaultTheme = true;

  /// 새로운 테마 생성 (Inter 폰트 사용)
  ThemeData _createNewTheme() {
    final newColorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 95, 188, 241),
      brightness: Brightness.light,
    );

    final typography = Typography.material2021();
    final baseTextTheme = typography.black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: newColorScheme,
      // Inter 폰트 적용
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        // Display styles
        displayLarge: GoogleFonts.inter(
          fontSize: 52,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        // Headline styles
        headlineLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
        // Title styles
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        // Body styles
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        // Label styles
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.5,
        ),
      ),
      // Flat Design - ElevatedButton Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: newColorScheme.primary,
              foregroundColor: newColorScheme.onPrimary,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600, // 더 굵은 폰트
                fontSize: 16,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.black.withValues(alpha: 0.15);
                }
                if (states.contains(WidgetState.hovered)) {
                  return Colors.black.withValues(alpha: 0.08);
                }
                return null;
              }),
            ),
      ),
      // Flat Design - Card Theme
      cardTheme: const CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      // Flat Design - AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _useDefaultTheme ? Theme.of(context) : _createNewTheme();
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Design Theme Test'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButton<bool>(
                value: _useDefaultTheme,
                icon: const Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                underline: Container(height: 0),
                dropdownColor: colorScheme.surface,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                items: const [
                  DropdownMenuItem<bool>(
                    value: true,
                    child: Row(
                      children: [
                        Icon(Icons.palette, size: 20),
                        SizedBox(width: 8),
                        Text('Default Theme'),
                      ],
                    ),
                  ),
                  DropdownMenuItem<bool>(
                    value: false,
                    child: Row(
                      children: [
                        Icon(Icons.color_lens, size: 20),
                        SizedBox(width: 8),
                        Text('New Theme'),
                      ],
                    ),
                  ),
                ],
                onChanged: (bool? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _useDefaultTheme = newValue;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 현재 테마 정보 표시
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _useDefaultTheme ? Icons.palette : Icons.color_lens,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _useDefaultTheme ? 'Default Theme' : 'New Theme',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _useDefaultTheme
                                ? 'Blue seed color, Inter font (Global)'
                                : 'Blue (lighter) seed color, Inter font',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              /// Display 스타일 섹션
              Text('Display Styles', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Display Large', style: textTheme.displayLarge),
              Text('Display Medium', style: textTheme.displayMedium),
              Text('Display Small', style: textTheme.displaySmall),
              const Divider(height: 32),

              /// Headline 스타일 섹션
              Text('Headline Styles', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Headline Large', style: textTheme.headlineLarge),
              Text('Headline Medium', style: textTheme.headlineMedium),
              Text('Headline Small', style: textTheme.headlineSmall),
              const Divider(height: 32),

              /// Title 스타일 섹션
              Text('Title Styles', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Title Large', style: textTheme.titleLarge),
              Text('Title Medium', style: textTheme.titleMedium),
              Text('Title Small', style: textTheme.titleSmall),
              const Divider(height: 32),

              /// Body 스타일 섹션
              Text('Body Styles', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Body Large', style: textTheme.bodyLarge),
              Text('Body Medium', style: textTheme.bodyMedium),
              Text('Body Small', style: textTheme.bodySmall),
              const Divider(height: 32),

              /// Label 스타일 섹션
              Text('Label Styles', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Label Large', style: textTheme.labelLarge),
              Text('Label Medium', style: textTheme.labelMedium),
              Text('Label Small', style: textTheme.labelSmall),
              const Divider(height: 32),

              /// Color Scheme 섹션
              Text('Color Scheme', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildColorBox('Primary', colorScheme.primary),
              _buildColorBox('On Primary', colorScheme.onPrimary),
              _buildColorBox('Primary Container', colorScheme.primaryContainer),
              _buildColorBox(
                'On Primary Container',
                colorScheme.onPrimaryContainer,
              ),
              _buildColorBox('Secondary', colorScheme.secondary),
              _buildColorBox('On Secondary', colorScheme.onSecondary),
              _buildColorBox('Surface', colorScheme.surface),
              _buildColorBox('On Surface', colorScheme.onSurface),
              const Divider(height: 32),

              /// 버튼 예제 섹션
              Text('Button Examples', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated Button'),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {},
                child: const Text('Filled Button'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined Button'),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () {}, child: const Text('Text Button')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
