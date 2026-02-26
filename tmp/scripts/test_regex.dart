import 'dart:convert';
import 'dart:io';

void main() {
  final firstText = "# SM 시티 바콜로드 (SM City Bacolod)\n\n**SM 시티 바콜로드**...";
  final nameInTextsRegex = RegExp(r'^#\s*([^(]+)');
  final match = nameInTextsRegex.firstMatch(firstText);
  if (match != null) {
    //    print('Match: "${match.group(1)?.trim()}"');
  } else {
    //    print('No match');
  }
}
