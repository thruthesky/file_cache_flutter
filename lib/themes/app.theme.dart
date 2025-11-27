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
      // Flat 2.0 Design - 회색 배경색 (surface container)
      scaffoldBackgroundColor: cs.surfaceContainerLow,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 52),
        displayMedium: TextStyle(fontSize: 42),
        displaySmall: TextStyle(fontSize: 34),
        headlineLarge: TextStyle(fontSize: 30),
        headlineMedium: TextStyle(fontSize: 26, letterSpacing: -0.10),
        headlineSmall: TextStyle(letterSpacing: -0.10),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.10),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: -0.10,
        ),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.10),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.10,
          height: 1.20,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.10,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.10,
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
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: cs.surfaceContainerLow,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          height: 2.0,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          height: 2.0,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.10,
        ),
        type: BottomNavigationBarType.fixed, // 고정 타입
        backgroundColor: cs.surface, // 흰색 배경
        selectedItemColor: cs.primary, // 선택된 아이템 색상
        unselectedItemColor: cs.onSurfaceVariant, // 선택 안된 아이템 색상
        elevation: 0, // Flat 디자인
        /// Flat 2.0 - 미묘한 상단 테두리
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      chipTheme: ChipThemeData(showCheckmark: false),
      // Flat Design - FloatingActionButton Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0, // Flat 디자인 - 그림자 제거
        highlightElevation: 0,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Spacing Tokens 등록 (8 배수 기반)
      extensions: const <ThemeExtension<dynamic>>[AppSpacing()],
    );
  }
}
