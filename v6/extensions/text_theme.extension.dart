import 'package:flutter/material.dart';

extension TextThemeExtension on BuildContext {
  ThemeData get postTitleTheme => Theme.of(this).copyWith(
    textTheme: Theme.of(this).textTheme.copyWith(
      titleLarge: Theme.of(this).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 19,
      ),
    ),
  );
}
