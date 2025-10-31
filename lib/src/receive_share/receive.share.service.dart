import 'dart:developer';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ReceiveShareService {
  static ReceiveShareService? _instance;
  static ReceiveShareService get instance {
    _instance ??= ReceiveShareService._();
    return _instance!;
  }

  ReceiveShareService._();

  Function(PostCategoryItem category, List<SharedMediaFile> data)?
  onCategorySelect;

  void initialize({
    required Function(List<SharedMediaFile> data) onData,
    // Set category if not yet set in Config.categories
    // Store on different holder if plan to support limited category
    List<PostCategoryItem>? categories,
    // Callback when category is tap from the received category selection
    Function(PostCategoryItem category, List<SharedMediaFile> data)?
    onCategorySelect,
  }) {
    if (categories != null) {
      Config.categories = categories;
    }

    if (onCategorySelect != null) {
      this.onCategorySelect = onCategorySelect;
    }

    // Listen to media sharing coming from outside the app while the app is in the memory.
    ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> data) {
        if (data.isNotEmpty) {
          log(
            data.map((f) => f.toMap()).toString(),
            name: 'ReceiveSharingIntent:Stream:App in memory',
          );
          // List<XFile> files = value.map((f) => XFile(f.path)).toList();
          // onValue(files: files);
          onData(data);
        }
      },
      onError: (err) {
        log(
          "getIntentDataStream error: $err",
          name: 'ReceiveSharingIntent:Error',
        );
      },
    );

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((
      List<SharedMediaFile> data,
    ) {
      log(
        data.map((f) => f.toMap()).toString(),
        name: 'ReceiveSharingIntent:InitialMedia:App closed',
      );
      onData(data);

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }
}
