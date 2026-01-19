// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';

void main() {
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  final List<dynamic> spots = jsonDecode(jsonFile.readAsStringSync());

  print('texts가 비어있는 항목 목록:\n');

  int count = 0;
  for (int i = 0; i < spots.length; i++) {
    final spot = spots[i];
    final texts = spot['texts'] as List? ?? [];

    if (texts.isEmpty) {
      final name = spot['name']?.toString() ?? '';
      final englishName = spot['english name']?.toString() ?? '';
      final province = spot['province']?.toString() ?? '';
      print('[$i] $name ($englishName) - $province');
      count++;
    }
  }

  print('\n총 $count개 항목');
}
