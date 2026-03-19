import 'package:flutter/material.dart';
import 'package:philgo/router.dart';

class Globals {
  // This can be the name of the screen that the user is in.
  static String screenName = '';
  // This can be chat room id or post idx.
  static String screenId = '';
}

ColorScheme get color => Theme.of(globalContext).colorScheme;
TextTheme get text => Theme.of(globalContext).textTheme;

bool isDeveloperModeEnabled = false;
