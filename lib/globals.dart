import 'package:flutter/material.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';

class Globals {
  // This can be the name of the screen that the user is in.
  static String screenName = '';
  // This can be chat room id or post idx.
  static String screenId = '';
}

Lo get T => Lo.of(globalContext)!;

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.s4 = 4,
    this.s8 = 8,
    this.s12 = 12,
    this.s16 = 16,
    this.s20 = 20,
    this.s24 = 24,
    this.s32 = 32,
    this.s40 = 40,
    this.s48 = 48,
  });

  final double s4;
  final double s8;
  final double s12;
  final double s16;
  final double s20;
  final double s24;
  final double s32;
  final double s40;
  final double s48;

  @override
  AppSpacing copyWith({
    double? s4,
    double? s8,
    double? s12,
    double? s16,
    double? s20,
    double? s24,
    double? s32,
    double? s40,
    double? s48,
  }) {
    return AppSpacing(
      s4: s4 ?? this.s4,
      s8: s8 ?? this.s8,
      s12: s12 ?? this.s12,
      s16: s16 ?? this.s16,
      s20: s20 ?? this.s20,
      s24: s24 ?? this.s24,
      s32: s32 ?? this.s32,
      s40: s40 ?? this.s40,
      s48: s48 ?? this.s48,
    );
  }

  @override
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this;
    double internalLerp(double a, double b) => a + (b - a) * t;
    return AppSpacing(
      s4: internalLerp(s4, other.s4),
      s8: internalLerp(s8, other.s8),
      s12: internalLerp(s12, other.s12),
      s16: internalLerp(s16, other.s16),
      s20: internalLerp(s20, other.s20),
      s24: internalLerp(s24, other.s24),
      s32: internalLerp(s32, other.s32),
      s40: internalLerp(s40, other.s40),
      s48: internalLerp(s48, other.s48),
    );
  }
}
