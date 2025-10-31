import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class Config {
  const Config._();

  static List<PostCategoryItem> categories = [];

  static BuildContext? _globalContext;

  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  static BuildContext get globalContext {
    if (_globalContext == null) {
      throw Exception(
        'Global context is not set. Please call setGlobalContext() first.',
      );
    }
    return _globalContext!;
  }

  static const prod = "prod";
  static const dev = "dev";

  /// The environment variable to determine the current environment.
  /// It can be set at compile time using `--dart-define=ENV=dev` or `--dart-define=ENV=prod`.
  /// If not set, it defaults to `prod`.
  static const String getEnv = String.fromEnvironment(
    "ENV",
    defaultValue: prod,
  );

  /// Returns true if the current environment is development.
  /// This is determined by the `ENV` environment variable.
  /// If the variable is set to `dev`, it returns true; otherwise, it returns false.
  static bool get isDevelopment => getEnv == dev;

  /// Returns true if the current environment is production.
  /// This is determined by the `ENV` environment variable.
  /// If the variable is set to `prod`, it returns true; otherwise, it returns
  static bool get isProduction => getEnv == prod;

  // philgo.com is the main site.
  // URL must end with a slash (/).
  static String philgoUrl = 'https://philgo.com/';

  static String get phpApiUrl {
    return 'https://local.philgo.com:444/func.php';
  }

  /// Returns the file server URL based on the environment.
  /// If the environment variable `FILE_SERVER_URL` is set, it returns that value.
  /// If the environment is development, it returns a local URL.
  /// Otherwise, it defaults to 'https://file.philgo.com/v5-files/'.
  /// This URL is used for file uploads and downloads in the application.
  static String get fileServerUrl {
    return 'https://local.philgo.com/v5-files/';
  }
}
