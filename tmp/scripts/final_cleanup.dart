import 'dart:convert';
import 'dart:io';

void main() async {
  final filePath =
      '/Users/thruthesky/apps/flutter/philgo_app/lib/philgo_files/travel/travel_spots.json';
  final file = File(filePath);
  if (!await file.exists()) {
    print('File not found');
    return;
  }

  final content = await file.readAsString();
  final List<dynamic> data = json.decode(content);

  final englishRegex = RegExp(r'[a-zA-Z]');
  final emojiRegex = RegExp(
    r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2000}-\u{206F}]',
    unicode: true,
  );

  final Map<String, String> translationMap = {
    'Bacolod': '바콜로드',
    'Cebu': '세부',
    'North EDSA': '노스 에드사',
    'EDSA': '에드사',
    'Lanang Premier': '라낭 프리미어',
    'Megamall': '메가몰',
    'Galleria': '갤러리아',
    'Manila': '마닐라',
    'Bigong': '비공',
    'Binangonan': '비낭고난',
    'Binhagan': '빈하간',
    'Binmaca': '빈마카',
    'Bintuod': '빈투오드',
    'Binuluan': '비눌루안',
    'Bitanjuan': '비탄주안',
    'Bolokbok': '볼록복',
    'Bonbon': '본본',
    'Borogyod': '보로교드',
    'Bosa': '보사',
    'Buagan': '부아간',
    'Bucas': '부카스',
    'Buga': '부가',
    'Bulalo': '불랄로',
    'Bulan': '불란',
    'Burburungan': '부르부룽안',
    'Burnay': '부르나이',
    'Busa': '부사',
    'Butay': '부타이',
    'Butung': '부퉁',
    'Cabaluyan': '카발루얀',
    'Cabugao': '카부가오',
    'Caburauan': '카부라우안',
    'Cadig': '카딕',
    'Cahelietan': '카헬리에탄',
    'Calabugao': '칼라부가오',
    'Candalaga': '칸달라가',
    'Calayan': '칼라얀',
    'Calibugon': '칼리부곤',
    'Calomutan': '칼로무탄',
    'Camingingel': '카밍인겔',
    'Campana': '캄파나',
    'Canandag': '카난다그',
    'Cancanajag': '칸카나학',
    'Caniapasan': '카니아파산',
    'Cantoloc': '칸톨록',
    'Capinyayan': '카핀야얀',
    'Capotoan': '카포토안',
    'Capual': '카푸알',
    'Caraycaray': '카라이카라이',
    'Cariliao': '카릴리아오',
    'Carling': '칼링',
    'Carranglan': '카랑란',
    'Casiama': '카시아마',
    'Catala': '카탈라',
    'Cataluan': '카탈루안',
    'Catmon': '캇몬',
    'Caual': '카우알',
    'Cayudungan': '카유둥안',
    'Cetaceo': '세타세오',
    'Chumanchil': '추만칠',
    'Codiapi': '코디아피',
    'Coloumotan': '콜로무탄',
    'Cone': '콘',
    'Culasi': '쿨라시',
    'Costa Rica': '코스타 리카',
    'Cresta': '크레스타',
    'Cuadrado': '콰드라도',
    'Cudtingan': '쿠딩안',
    'Dagot': '다곳',
    'Culangalan': '쿨랑알란',
    'Cuyapo': '쿠야포',
    'Daclan': '다클란',
    'Dagumbaan': '다굼바안',
    'Dakes': '다케스',
    'Dakula': '다쿨라',
    'Dakut': '다컷',
    'Dalimonoc': '달리모녹',
    'Dalupiri': '달루피리',
    'Danao': '다나오',
    'Dapiak': '다피악',
    'Deugurug': '데우구루그',
    'Didicas': '디디카스',
    'Diffun': '디푼',
    'Diogo': '디오고',
    'Dit': '딧',
    'Gedgedayan': '겟게다얀',
    'Hibok-Hibok': '히복히복',
    'Bataan': '바탄',
    'Batulao': '바투라오',
    'Batelian': '바텔리안',
    'Batorampon': '바토람폰',
    'Baya': '바야',
    'Bayabas': '바야바스',
    'Bayaguitos': '바야기토스',
    'Bernacci': '베르나치',
    'Biliran': '빌리란',
    'Binaca': '비나카',
    'Binangonan': '비낭고난',
    'Binhagan': '빈하간',
    'Binmaca': '빈마카',
    'Bintuod': '빈투오드',
    'Binuluan': '비눌루안',
    'Bitanjuan': '비탄주안',
  };

  int modifiedCount = 0;

  for (var i = 0; i < data.length; i++) {
    final item = data[i];
    final String currentNameRaw = (item['name'] ?? '').toString();

    // 1. Clean up characters like #, *, emoji
    String nameToProcess = currentNameRaw
        .replaceAll('#', '')
        .replaceAll('*', '')
        .replaceAll(emojiRegex, '')
        .trim();

    if (englishRegex.hasMatch(nameToProcess)) {
      String newName = nameToProcess;

      // Sorted by length descending to avoid partial matches (e.g. "Bacolod" before "Baco")
      final sortedKeys = translationMap.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

      for (var key in sortedKeys) {
        if (newName.toLowerCase().contains(key.toLowerCase())) {
          // Case insensitive replace but keep special chars like /
          newName = newName.replaceAll(
            RegExp(key, caseSensitive: false),
            translationMap[key]!,
          );
        }
      }

      if (currentNameRaw != newName && !englishRegex.hasMatch(newName)) {
        print('Final Updating: "$currentNameRaw" -> "$newName"');
        item['name'] = newName;
        modifiedCount++;
      }
    } else if (currentNameRaw != nameToProcess) {
      // Also clean up non-English items that have # or emoji
      print('Cleaning up: "$currentNameRaw" -> "$nameToProcess"');
      item['name'] = nameToProcess;
      modifiedCount++;
    }
  }

  if (modifiedCount > 0) {
    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(data));
    print('Updated $modifiedCount items.');
  } else {
    print('No items updated.');
  }
}
