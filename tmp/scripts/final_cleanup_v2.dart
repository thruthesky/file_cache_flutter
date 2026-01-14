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
    'Hibok-Hibok': '히복히복',
    'Bataan': '바탄',
    'Batelian': '바텔리안',
    'Batorampon': '바토람폰',
    'Batulao': '바투라오',
    'Baya': '바야',
    'Bayabas': '바야바스',
    'Bayaguitos': '바야기토스',
    'Bee Hive': '비 하이브',
    'Bernacci': '베르나치',
    'Bigain Hill': '비가인 힐',
    'Bigong': '비공',
    'Biliran': '빌리란',
    'Binaca': '비나카',
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
    'Bubongna': '부봉나',
    'Buboy': '부보이',
    'Bucas': '부카스',
    'Bud Dajo': '부드 다호',
    'Buga': '부가',
    'Bulalo': '불랄로',
    'Bulan': '불란',
    'Bulbul': '불불',
    'Bulibu': '불리부',
    'Bulusan': '불루산',
    'Bunsulan Hills': '분술란 힐즈',
    'Burburungan': '부르부룽안',
    'Burnay': '부르나이',
    'Busa': '부사',
    'Butay': '부타이',
    'Butung': '부퉁',
    'Cabalian': '카발리안',
    'Cabaluyan': '카발루얀',
    'Cabugao': '카부가오',
    'Caburauan': '카부라우안',
    'Cabuyao': '카부야오',
    'Kabuyao': '카부야오',
    'Cadig': '카딕',
    'Cagua': '카구아',
    'Cahelietan': '카헬리에탄',
    'Calabugao': '칼라부가오',
    'Caladang': '칼라당',
    'Calandang': '칼라당',
    'Calavite': '칼라비테',
    'Candalaga': '칸달라가',
    'Calayan': '칼라얀',
    'Calibugon': '칼리부곤',
    'Calinigan': '칼리니간',
    'Calomutan': '칼로무탄',
    'Camiguin': '카미긴',
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
    'Cinco Picos': '싱코 피코스',
    'Cleopatra Needle': '클레오파트라 니들',
    'Codiapi': '코디아피',
    'Coloumotan': '콜로무탄',
    'Cone': '콘',
    'Culasi': '쿨라시',
    'Conical': '코니컬',
    'Costa Rica': '코스타 리카',
    'Cresta': '크레스타',
    'Crista': '크레스타',
    'Cuadrado': '콰드라도',
    'Quadrado': '콰드라도',
    'Cudtingan': '쿠딩안',
    'Cudting': '쿠딩',
    'Cuernos de Negros': '쿠에르노스 데 네그로스',
    'Talinis': '탈리니스',
    'Dagot': '다곳',
    'Culangalan': '쿨랑알란',
    'Cuyapo': '쿠야포',
    'Daclan': '다클란',
    'Dagumbaan': '다굼바안',
    'Dakes': '다케스',
    'Shekes': '세케스',
    'Dakiwagan': '다키와간',
    'Dakula': '다쿨라',
    'Dakut': '다컷',
    'Dalimonoc': '달리모녹',
    'Dalupiri': '달루피리',
    'Danao': '다나오',
    'Dapiak': '다피악',
    'Data': '다타',
    'Deugurug': '데우구루그',
    'Didicas': '디디카스',
    'Diffun': '디푼',
    'Diogo': '디오고',
    'Dit': '딧',
    'Dome': '돔',
    'Dulang-dulang': '둘랑둘랑',
    'Dumali': '두말리',
    'Dumapata': '두마파타',
    'Dupungan': '두풍안',
    'Elizario': '엘리자리오',
    'Gadungan': '가둥안',
    'Gedgedayan': '겟게다얀',
    'Guimba': '구임바',
    'Guiting-Guiting': '기팅기팅',
    'Guitinguitin': '기팅기팅',
    'Gunansan': '구난산',
    'Gurain': '구라인',
    'Hagdanan': '학다난',
    'Halcon': '할콘',
    'Hamiguitan': '하미기탄',
    'Hamiquitan': '하미기탄',
    'Hilonghilong': '힐롱힐롱',
    'Homahan': '호마한',
    'Iba': '이바',
    'Iglit': '이글릿',
    'Imbing': '임빙',
    'Imoc': '이목',
    'Inayawan': '이나야완',
    'Iniaoan': '이니아오안',
    'Irada': '이라다',
    'Iraya': '이라야',
    'Irid': '이리드',
    'Iriga': '이리가',
    'SM': 'SM',
    'City': '시티',
    'North': '노스',
    'EDSA': '에드사',
    'Lanang': '라낭',
    'Premier': '프리미어',
    'Megamall': '메가몰',
    'Bacolod': '바콜로드',
    'Cebu': '세부',
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

    // 2. Transliterate if has English
    if (englishRegex.hasMatch(nameToProcess)) {
      String newName = nameToProcess;

      // Sorted by length descending to avoid partial matches
      final sortedKeys = translationMap.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

      for (var key in sortedKeys) {
        // Use word boundary for exact matches if possible, but for place names partial is often ok
        // Let's use word boundary for things like "SM", "City", "North"
        if (key.length <= 3) {
          newName = newName.replaceAll(
            RegExp('\\b$key\\b', caseSensitive: false),
            translationMap[key]!,
          );
        } else {
          newName = newName.replaceAll(
            RegExp(key, caseSensitive: false),
            translationMap[key]!,
          );
        }
      }

      // Final cleanup of English helper words
      newName = newName
          .replaceAll(
            RegExp(
              r'\b(Mount|Island|Volcano|Peak|Lake|Falls|River|Park|Beach|Range|Mountains|Hills|Point|Ridge|de|de\s+Babuyanes)\b',
              caseSensitive: false,
            ),
            '',
          )
          .trim();

      // Add "산" back if it was a mountain and we removed "Mount"
      if (item['category'] == '산/화산' &&
          !newName.endsWith('산') &&
          !newName.endsWith('화산') &&
          !newName.endsWith('봉')) {
        newName = '$newName 산';
      }

      if (currentNameRaw != newName &&
          (RegExp(r'[가-힣]').hasMatch(newName) ||
              !englishRegex.hasMatch(newName))) {
        print('Final Updating: "$currentNameRaw" -> "$newName"');
        item['name'] = newName;
        modifiedCount++;
      }
    } else if (currentNameRaw != nameToProcess) {
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
