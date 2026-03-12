import 'dart:developer';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';
// import 'package:philgo_api/philgo_api.dart';

/// 외부 공유 수신 서비스 (Receive Share Service)
///
/// 다른 앱에서 공유된 파일/텍스트를 수신하고 처리합니다.
/// Receives and processes files/text shared from other apps.
class ReceiveShareService {
  static ReceiveShareService? _instance;
  static ReceiveShareService get instance {
    _instance ??= ReceiveShareService._();
    return _instance!;
  }

  ReceiveShareService._();

  /// 카테고리 선택 콜백 (Category selection callback)
  /// [postId] 메인 카테고리 ID
  /// [category] 서브 카테고리 (null 가능)
  /// [data] 공유된 미디어 파일 목록
  Function(String postId, String? category, List<SharedMediaFile> data)?
  onCategorySelect;

  void initialize({
    required Function(List<SharedMediaFile> data) onData,

    /// 카테고리 postId 목록 (PhilgoConfig.categories에 설정되지 않은 경우)
    /// Category postId list (if not set in PhilgoConfig.categories)
    List<String>? categories,

    /// 카테고리 선택 시 콜백
    /// Callback when category is tapped from the received category selection
    Function(String postId, String? category, List<SharedMediaFile> data)?
    onCategorySelect,
  }) {
    if (categories != null) {
      // PhilgoConfig.categories = categories;
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
      // log(
      //   data.map((f) => f.toMap()).toString(),
      //   name: 'ReceiveSharingIntent:InitialMedia:App closed',
      // );
      onData(data);

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }
}
