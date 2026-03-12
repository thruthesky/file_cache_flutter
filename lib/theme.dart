import 'package:flutter/material.dart';

ThemeData philgoThemeData(BuildContext context) {
  return Theme.of(context).copyWith(
    colorScheme: Theme.of(context).colorScheme.copyWith(
      primary: const Color(0xFF007AFF), // iOS 스타일의 파란색
      secondary: const Color(0xFF34C759), // iOS 스타일의 녹색
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF007AFF), // iOS 스타일의 파란색
      foregroundColor: Colors.white, // 흰색 텍스트
      elevation: 0, // 그림자 제거
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF007AFF), // iOS 스타일의 파란색
        foregroundColor: Colors.white, // 흰색 텍스트
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 둥근 모서리
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF007AFF), // iOS 스타일의 파란색
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0, // 그림자 제거
      shadowColor: Colors.transparent, // 그림자 색상 제거
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)), // 둥근 모서리
      ),
    ),
  );
}
