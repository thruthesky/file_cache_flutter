import 'dart:convert';
import 'dart:io';

/// 변환 결과 확인 스크립트
void main() {
  final json =
      jsonDecode(
            File(
              'lib/philgo_files/travel/travel_spots.json',
            ).readAsStringSync(),
          )
          as List;

  // 이모지 감지 정규표현식
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2300}-\u{23FF}]|[\u{2B50}]|[\u{2934}-\u{2935}]|[\u{25AA}-\u{25AB}]|[\u{25B6}]|[\u{25C0}]|[\u{25FB}-\u{25FE}]|[\u{2614}-\u{2615}]|[\u{2648}-\u{2653}]|[\u{267F}]|[\u{2693}]|[\u{26A1}]|[\u{26AA}-\u{26AB}]|[\u{26BD}-\u{26BE}]|[\u{26C4}-\u{26C5}]|[\u{26CE}]|[\u{26D4}]|[\u{26EA}]|[\u{26F2}-\u{26F3}]|[\u{26F5}]|[\u{26FA}]|[\u{26FD}]|[\u{2702}]|[\u{2705}]|[\u{2708}-\u{270D}]|[\u{270F}]|[\u{2712}]|[\u{2714}]|[\u{2716}]|[\u{271D}]|[\u{2721}]|[\u{2728}]|[\u{2733}-\u{2734}]|[\u{2744}]|[\u{2747}]|[\u{274C}]|[\u{274E}]|[\u{2753}-\u{2755}]|[\u{2757}]|[\u{2763}-\u{2764}]|[\u{2795}-\u{2797}]|[\u{27A1}]|[\u{27B0}]|[\u{1F004}]|[\u{1F0CF}]|[\u{1F170}-\u{1F171}]|[\u{1F17E}-\u{1F17F}]|[\u{1F18E}]|[\u{1F191}-\u{1F19A}]|[\u{1F1E6}-\u{1F1FF}]|[\u{1F201}-\u{1F202}]|[\u{1F21A}]|[\u{1F22F}]|[\u{1F232}-\u{1F23A}]|[\u{1F250}-\u{1F251}]',
    unicode: true,
  );

  int stringFormat = 0;
  int objectFormat = 0;
  int withEmoji = 0;
  int withoutEmoji = 0;

  for (int i = 0; i < json.length; i++) {
    final spot = json[i] as Map<String, dynamic>;
    final texts = spot['texts'] as List<dynamic>?;

    if (texts == null || texts.isEmpty) continue;

    if (texts[0] is String) {
      stringFormat++;
      String allText = texts.join(' ');
      if (emojiRegex.hasMatch(allText)) {
        withEmoji++;
      } else {
        withoutEmoji++;
        //        print('이모지 없음 - Index $i: ${spot["name"]}');
      }
    } else {
      objectFormat++;
    }
  }

  //  print('\n=== 변환 결과 요약 ===');
  //  print('전체 항목 수: ${json.length}');
  //  print('문자열 형식: $stringFormat개');
  //  print('객체 형식 (남음): $objectFormat개');
  //  print('이모지 있음: $withEmoji개');
  //  print('이모지 없음: $withoutEmoji개');

  // 변환된 샘플 확인
  //  print('\n=== 변환된 샘플 확인 (Index 530) ===');
  final sample = json[530] as Map<String, dynamic>;
  //  print('name: ${sample["name"]}');
  final sampleTexts = sample['texts'] as List;
  if (sampleTexts.isNotEmpty && sampleTexts[0] is String) {
    //    print('texts[0] (first 500 chars):');
    final text = sampleTexts[0].toString();
    //    print(text.substring(0, text.length > 500 ? 500 : text.length));
  }
}
