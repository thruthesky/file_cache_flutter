import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

String philgoUrl() => PhilgoConfig.philgoUrl;
String bannerPageUrl() =>
    '${PhilgoConfig.philgoUrl}page/advertisement/banner.php?view_mode=webview&device=mobile';

String pointPageUrl() =>
    '${PhilgoConfig.philgoUrl}page/advertisement/point.php?view_mode=webview&device=mobile';

String termsPageUrl({bool webView = true}) =>
    '${PhilgoConfig.philgoUrl}page/advertisement/terms-and-conditions.php?view_mode=${webView ? 'webview' : ''}';

String privacyPageUrl({bool webView = true}) =>
    '${PhilgoConfig.philgoUrl}page/advertisement/privacy.php?view_mode=${webView ? 'webview' : ''}';

String thumbnail_image_url(String url) {
  if (url.contains('?')) {
    return '$url&size=thumbnail';
  } else {
    return '$url?size=thumbnail';
  }
}
