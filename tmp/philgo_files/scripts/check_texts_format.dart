import 'dart:convert';
import 'dart:io';

/// 최근 업데이트한 항목들의 texts 형식을 확인하는 스크립트
void main() {
  final json =
      jsonDecode(
            File(
              'lib/philgo_files/travel/travel_spots.json',
            ).readAsStringSync(),
          )
          as List;

  // Check indices 722-724 texts format
  for (int i = 722; i <= 724; i++) {
    final spot = json[i] as Map<String, dynamic>;
    //    print('=== Index $i: ${spot["name"]} ===');
    final texts = spot['texts'];
    if (texts != null && texts is List && texts.isNotEmpty) {
      //      print('texts type: ${texts.runtimeType}');
      //      print('first item type: ${texts[0].runtimeType}');
      if (texts[0] is String) {
        final str = texts[0].toString();
        //        print('First 300 chars: ${str.substring(0, str.length > 300 ? 300 : str.length)}');
      } else if (texts[0] is Map) {
        //        print('Map keys: ${(texts[0] as Map).keys.toList()}');
        //        print('title: ${texts[0]["title"]}');
        //        print('description (first 100 chars): ${texts[0]["description"]?.toString().substring(0, 100)}');
      }
    } else {
      //      print('texts is null or empty');
    }
    //    print('');
  }
}
