import 'dart:convert';
import 'dart:io';

/// 문자열 형식이지만 이모지가 없는 17개 항목의 현재 상태 확인
void main() {
  final json =
      jsonDecode(
            File(
              'lib/philgo_files/travel/travel_spots.json',
            ).readAsStringSync(),
          )
          as List;

  // 이모지 없는 문자열 형식 항목들의 인덱스
  final indices = [
    560,
    567,
    571,
    572,
    573,
    574,
    575,
    576,
    577,
    578,
    579,
    580,
    581,
    582,
    583,
    584,
    585,
  ];

  for (var i in indices) {
    final spot = json[i] as Map<String, dynamic>;
    //    print('=== Index $i ===');
    //    print('name: ${spot["name"]}');
    //    print('englishName: ${spot["englishName"] ?? spot["english name"]}');
    //    print('city: ${spot["city"]}, province: ${spot["province"]}');
    //    print('title: ${spot["title"]}');
    //    print('description: ${spot["description"]}');

    final texts = spot['texts'];
    if (texts != null && texts is List && texts.isNotEmpty) {
      //      print('texts count: ${texts.length}');
      final firstText = texts[0].toString();
      //      print('texts[0] (first 200 chars): ${firstText.substring(0, firstText.length > 200 ? 200 : firstText.length)}');
    }
    //    print('');
  }
}
