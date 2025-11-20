import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';

class Globals {
  // This can be the name of the screen that the user is in.
  static String screenName = '';
  // This can be chat room id or post idx.
  static String screenId = '';
}

Lo get T => Lo.of(globalContext)!;

