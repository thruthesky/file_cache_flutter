// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// 실제 HTTP 404 오류가 있는 9개 URL을 수정하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_final_404.dart
/// ```

// 404 오류 URL 수정 매핑 (인덱스 -> 새 URL)
final Map<int, String> fixMappings = {
  // [331] 바야기토스 산 - Negros Oriental 이미지
  331:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Apo_island_-_panoramio.jpg/960px-Apo_island_-_panoramio.jpg',

  // [335] 비공 산 - Zamboanga Peninsula 이미지
  335:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Regatta2017.jpg/960px-Regatta2017.jpg',

  // [381] 칸달라가 산 - Bukidnon 이미지
  381:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c2/Mt._Kalatungan_Sunrise.jpg/960px-Mt._Kalatungan_Sunrise.jpg',

  // [444] 도르스트 산 - Pampanga 이미지 (Pinatubo)
  444:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Crater_Lake_at_the_Mount_Pinatubo_Caldera_in_the_Philippines_%283%29.jpg/960px-Crater_Lake_at_the_Mount_Pinatubo_Caldera_in_the_Philippines_%283%29.jpg',

  // [462] 힐롱힐롱 산 - Agusan del Norte 이미지
  462:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Agusan_del_Norte_Provincial_Capitol%2C_Butuan_City_%28Original_Work%29.jpg/960px-Agusan_del_Norte_Provincial_Capitol%2C_Butuan_City_%28Original_Work%29.jpg',

  // [673] 만타 포인트 카미긴 - Camiguin 이미지
  673:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Timpoong_and_Hibok-Hibok_Natural_Monument_in_Camiguin_-_Allan_Jay_Quesada.jpg/960px-Timpoong_and_Hibok-Hibok_Natural_Monument_in_Camiguin_-_Allan_Jay_Quesada.jpg',

  // [674] 카갈로간 폭포 - Eastern Visayas 이미지
  674:
      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/San_Juanico_Bridge_%28001%29_2023-11-18.jpg/960px-San_Juanico_Bridge_%28001%29_2023-11-18.jpg',

  // [675] 울루간 베이 - Puerto Princesa 이미지
  675: 'https://upload.wikimedia.org/wikipedia/en/0/01/Dos_Palmas_RP.JPG',

  // [676] 아포 리프 - Apo Reef 이미지
  676: 'https://upload.wikimedia.org/wikipedia/commons/4/41/Apo_reef.jpg',
};

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

  //  print('======================================');
  //  print('📋 HTTP 404 오류 URL 수정 도구');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  int updated = 0;

  for (final entry in fixMappings.entries) {
    final index = entry.key;
    final newUrl = entry.value;
    final name = travelSpots[index]['name']?.toString() ?? '';
    final oldUrl = travelSpots[index]['imageUrl']?.toString() ?? '';

    travelSpots[index]['imageUrl'] = newUrl;
    //    print('✅ [$index] $name');
    //    print('   이전: $oldUrl');
    //    print('   변경: $newUrl\n');
    updated++;
  }

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  //  print('======================================');
  //  print('📊 결과 요약');
  //  print('======================================');
  //  print('✅ 업데이트 완료: $updated개');
  //  print('\n📁 $jsonFilePath 파일이 수정되었습니다.');
}
