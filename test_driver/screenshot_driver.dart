import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  // Persist screenshots locally whenever the integration tests request them.
  await integrationDriver(
    onScreenshot: (
      String screenshotName,
      List<int> screenshotBytes, [
      Map<String, Object?>? args,
    ]) async {
      final Directory outputDir =
          Directory('tmp/screenshots')..createSync(recursive: true);
      final File file = File('${outputDir.path}/$screenshotName.png');
      file.writeAsBytesSync(screenshotBytes);
      return true;
    },
  );
}
 
