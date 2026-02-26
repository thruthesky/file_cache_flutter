import 'dart:convert';
import 'dart:io';

void main() async {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final spots = jsonDecode(await jsonFile.readAsString()) as List;

  // 가장 부실한 항목 확인 (인덱스 739, 733, 724, 738, 712)
  for (var idx in [739, 733, 724, 738, 712, 725, 662, 530, 531, 532]) {
    final spot = spots[idx];
    //    print('[$idx] ${spot['name']} (${spot['english name']})');
    //    print('   province: ${spot['province']}');
    //    print('   texts: ${spot['texts']}');
    //    print('');
  }
}
