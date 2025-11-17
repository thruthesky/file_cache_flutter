import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:philgo/themes/app.spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme cs = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 37, 112, 244),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      // Roboto TextTheme - Google Fonts 패키지를 통해 적용
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          // Display styles
          displayLarge: TextStyle(
            fontWeight: FontWeight.w700, // Bold
          ),
          displayMedium: TextStyle(
            fontWeight: FontWeight.w600, // SemiBold
          ),
          displaySmall: TextStyle(
            fontWeight: FontWeight.w500, // Medium
          ),
          // Headline styles
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w700, // Bold
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w600, // SemiBold
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w500, // Medium
          ),
          // Title styles
          titleLarge: TextStyle(
            fontWeight: FontWeight.w600, // SemiBold
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w500, // Medium
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w500, // Medium
          ),
          // Body styles
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w400, // Regular
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w400, // Regular
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.w400, // Regular
          ),
          // Label styles
          labelLarge: TextStyle(
            fontWeight: FontWeight.w500, // Medium
          ),
          labelMedium: TextStyle(
            fontWeight: FontWeight.w400, // Regular
          ),
          labelSmall: TextStyle(
            fontWeight: FontWeight.w300, // Light
          ),
        ),
      ),
      // Flat Design - ElevatedButton Theme
      // Flat Design - Card Theme
      cardTheme: const CardThemeData(
        elevation: 0, // Flat 디자인 - 그림자 제거
        shadowColor: Colors.transparent,
      ),
      // Flat Design - AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0, // Flat 디자인 - 그림자 제거
        scrolledUnderElevation: 0, // 스크롤 시에도 elevation 0
        surfaceTintColor: Colors.transparent, // 스크롤 시 회색 틴트 제거 (Material 3)
        centerTitle: false, // 타이틀 왼쪽 정렬
      ),
      chipTheme: ChipThemeData(),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: const IconThemeData(size: 20),
        unselectedIconTheme: const IconThemeData(size: 20),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          height: 2.5,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          height: 2.5,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed, // 고정 타입
      ),

      // Spacing Tokens 등록 (8 배수 기반)
      extensions: const <ThemeExtension<dynamic>>[AppSpacing()],
    );
  }
}
