import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  static const String routeName = '/web-view';
  static Future push(
    BuildContext ctx, {
    required String url,
    required String title,
  }) => ctx.push(routeName, extra: {'url': url, 'title': title});

  const WebViewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(FontAwesomeIcons.chevronLeft, color: color.onSurface, size: 22),
                Text(
                  // "Back"
                  '돌아가기'.tr(),
                  style: text.bodyMedium?.copyWith(color: color.onSurface),
                ),
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.surfaceDim,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: color.scrim,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: WebViewWidget(
        controller: _controller,
        gestureRecognizers: {
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        },
      ),
    );
  }
}
