import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

String philgoUrl() => Config.philgoUrl;
String bannerPageUrl() =>
    '${Config.philgoUrl}page/advertisement/banner.php?view_mode=webview&device=mobile';

String pointPageUrl() =>
    '${Config.philgoUrl}page/advertisement/point.php?view_mode=webview&device=mobile';

String termsPageUrl({bool webView = true}) =>
    '${Config.philgoUrl}page/advertisement/terms-and-conditions.php?view_mode=${webView ? 'webview' : ''}';

String privacyPageUrl({bool webView = true}) =>
    '${Config.philgoUrl}page/advertisement/privacy.php?view_mode=${webView ? 'webview' : ''}';

String thumbnail_image_url(String url) {
  if (url.contains('?')) {
    return '$url&size=thumbnail';
  } else {
    return '$url?size=thumbnail';
  }
}
