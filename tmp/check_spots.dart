// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  // 인덱스 743, 744, 745, 746, 747 항목 출력
  for (int i in [743, 744, 745, 746, 747]) {
    final spot = spots[i];
    print('=== [$i] ${spot["name"]} ===');
    print('english name: ${spot["english name"]}');
    print('title: ${spot["title"]}');
    print('description: ${spot["description"]}');
    print('city: ${spot["city"]}');
    print('province: ${spot["province"]}');
    print('texts: ${(spot["texts"] as List).length}개');
    print('');
  }
}
