// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  // 특정 이름으로 검색
  final searchTerms = [
    'Ogtong',
    'Kalanggaman',
    'Siquijor',
    'Virgin Island',
    'Cambugahay',
  ];

  for (int i = 0; i < spots.length; i++) {
    final spot = spots[i];
    final name = spot['name']?.toString() ?? '';
    final englishName = spot['english name']?.toString() ?? '';
    final texts = spot['texts'] as List? ?? [];

    for (final term in searchTerms) {
      if (name.toLowerCase().contains(term.toLowerCase()) ||
          englishName.toLowerCase().contains(term.toLowerCase())) {
        //        print('[$i] $name ($englishName) - texts: ${texts.length}개');
      }
    }
  }
}
