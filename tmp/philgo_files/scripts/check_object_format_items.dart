import 'dart:convert';
import 'dart:io';

/// 객체 배열 형식 항목들의 현재 데이터 구조 확인
void main() {
  final json =
      jsonDecode(
            File(
              'lib/philgo_files/travel/travel_spots.json',
            ).readAsStringSync(),
          )
          as List;

  // 처음 5개 객체 형식 항목 확인 (530-534)
  for (int i = 530; i <= 534; i++) {
    final spot = json[i] as Map<String, dynamic>;
    //    print('=== Index $i ===');
    //    print('name: ${spot["name"]}');
    //    print('englishName: ${spot["englishName"] ?? spot["english name"]}');
    //    print('city: ${spot["city"]}, province: ${spot["province"]}');
    //    print('title: ${spot["title"]}');
    //    print('description (100 chars): ${spot["description"]?.toString().substring(0, spot["description"].toString().length > 100 ? 100 : spot["description"].toString().length)}');

    final texts = spot['texts'];
    if (texts != null && texts is List && texts.isNotEmpty) {
      //      print('texts count: ${texts.length}');
      final firstText = texts[0];
      if (firstText is Map) {
        //        print('texts[0] is Map with keys: ${firstText.keys.toList()}');
        //        print('texts[0].title: ${firstText["title"]}');
        //        print('texts[0].description (100 chars): ${firstText["description"]?.toString().substring(0, firstText["description"].toString().length > 100 ? 100 : firstText["description"].toString().length)}');
      } else if (firstText is String) {
        //        print('texts[0] is String (first 200 chars): ${firstText.substring(0, firstText.length > 200 ? 200 : firstText.length)}');
      }
    }
    //    print('');
  }
}
