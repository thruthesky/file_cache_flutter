import 'dart:convert';
import 'dart:io';

/// 최종 품질 검증 스크립트
/// 다양한 인덱스의 항목들을 샘플링하여 품질 확인
void main() {
  final json =
      jsonDecode(
            File(
              'lib/philgo_files/travel/travel_spots.json',
            ).readAsStringSync(),
          )
          as List;

  // 다양한 범위에서 샘플 선택
  final sampleIndices = [0, 100, 300, 530, 600, 800, 1000, 1044];

  for (var i in sampleIndices) {
    if (i >= json.length) continue;

    final spot = json[i] as Map<String, dynamic>;
    //    print('=== Index $i: ${spot["name"]} ===');
    //    print('city: ${spot["city"]}, province: ${spot["province"]}');

    final texts = spot['texts'] as List?;
    if (texts != null && texts.isNotEmpty) {
      if (texts[0] is String) {
        final firstText = texts[0].toString();
        // 이모지 확인
        final hasEmoji = RegExp(
          r'[\u{1F300}-\u{1F9FF}]',
          unicode: true,
        ).hasMatch(firstText);
        //        print('형식: 문자열 배열 ✅');
        //        print('이모지: ${hasEmoji ? "있음 ✅" : "없음 ❌"}');
        //        print('texts 개수: ${texts.length}');
        //        print('첫 번째 텍스트 길이: ${firstText.length}자');
        // 첫 100자만 출력
        //        print('미리보기: ${firstText.substring(0, firstText.length > 100 ? 100 : firstText.length)}...');
      } else {
        //        print('형식: 객체 배열 ❌ (변환 필요)');
      }
    } else {
      //      print('texts: 없음 또는 비어있음');
    }
    //    print('');
  }

  // 전체 통계
  int totalChars = 0;
  int minChars = 999999;
  int maxChars = 0;
  String? minItem;
  String? maxItem;

  for (int i = 0; i < json.length; i++) {
    final spot = json[i] as Map<String, dynamic>;
    final texts = spot['texts'] as List?;
    if (texts == null || texts.isEmpty) continue;

    int charCount = 0;
    for (var t in texts) {
      if (t is String) {
        charCount += t.length;
      }
    }

    totalChars += charCount;
    if (charCount < minChars) {
      minChars = charCount;
      minItem = '${spot["name"]} (index $i)';
    }
    if (charCount > maxChars) {
      maxChars = charCount;
      maxItem = '${spot["name"]} (index $i)';
    }
  }

  //  print('=== 전체 통계 ===');
  //  print('전체 항목 수: ${json.length}');
  //  print('전체 텍스트 길이: ${totalChars}자');
  //  print('평균 텍스트 길이: ${(totalChars / json.length).round()}자');
  //  print('최소 텍스트 길이: $minChars자 ($minItem)');
  //  print('최대 텍스트 길이: $maxChars자 ($maxItem)');
}
