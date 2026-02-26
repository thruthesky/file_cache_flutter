import 'dart:convert';
import 'dart:io';

void main() {
  final List json = jsonDecode(
    File('lib/philgo_files/travel/travel_spots.json').readAsStringSync(),
  );
  for (int i = 738; i <= 745; i++) {
    final spot = json[i] as Map<String, dynamic>;
    //    print('$i: ${spot["name"]} | ${spot["englishName"]} | ${spot["city"]} | ${spot["province"]}');
  }
}
