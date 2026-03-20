import 'dart:io';

import 'package:flutter/foundation.dart';

/// Get device type string
String getDeviceType() {
  if (kIsWeb) {
    return 'web';
  } else if (Platform.isAndroid) {
    return 'android';
  } else if (Platform.isIOS) {
    return 'ios';
  } else {
    return 'unknown';
  }
}
