import 'package:flutter/material.dart';
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
      // Pretendard 폰트 패밀리 적용
      fontFamily: 'Pretendard',
      textTheme: const TextTheme(
        // Display styles - 큰 제목용 (약간 축소)
        displayLarge: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w700, // Bold
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w600, // SemiBold
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w600, // SemiBold
          height: 1.22,
        ),
        // Headline styles - 헤드라인 (약간 축소)
        headlineLarge: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w700, // Bold
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600, // SemiBold
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600, // SemiBold
          height: 1.33,
        ),
        // Title styles - 타이틀 (약간 축소)
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600, // SemiBold
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600, // SemiBold - 더 강조
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600, // SemiBold - 더 강조
          letterSpacing: 0.1,
          height: 1.43,
        ),
        // Body styles - 본문 (약간 축소)
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400, // Regular
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400, // Regular
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400, // Regular
          letterSpacing: 0.4,
          height: 1.33,
        ),
        // Label styles - 버튼, 작은 라벨 (약간 축소)
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600, // SemiBold - 버튼 강조
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500, // Medium
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500, // Medium - 더 강조
          letterSpacing: 0.5,
          height: 1.45,
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
