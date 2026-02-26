import 'dart:convert';
import 'dart:io';
import 'dart:async';

// ==========================================
// 설정 (Configuration)
// ==========================================
const String apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // 여기에 Gemini API 키를 입력하세요.
const String modelName = 'gemini-1.5-flash'; // 또는 gemini-1.5-pro
const String filePath =
    '/Users/thruthesky/apps/flutter/philgo_app/lib/philgo_files/travel/travel_spots.json';
const int batchSize = 10;

// ==========================================
// 메인 함수
// ==========================================
void main() async {
  final file = File(filePath);
  if (!await file.exists()) {
    print(
      '오류: 파일을 찾을 수 없습니다: \$filePath',
    ); // Corrected string interpolation escape
    return;
  }

  // 1. 파일 읽기
  //  print('파일을 읽는 중...');
  final content = await file.readAsString();
  final List<dynamic> spots = json.decode(content);
  //  print('총 ${spots.length}개의 여행 항목을 찾았습니다.');

  // 2. 작업 시작 (배치 처리)
  int updatedCount = 0;
  List<Future<void>> futures = [];

  // 이미 업데이트된 항목을 건너뛰기 위한 로직 (예: 'enhanced' 필드 확인)
  // 현재는 모든 항목을 대상으로 하되, 텍스트 길이가 짧은 것만 할 수도 있습니다.
  // 여기서는 예시로 앞에서부터 순차적으로 처리합니다.

  for (var i = 0; i < spots.length; i++) {
    final spot = spots[i];

    // 이미 처리된 항목인지 확인 (이 플래그는 업데이트 후 추가됨)
    if (spot['isEnhanced'] == true) {
      continue;
    }

    // 병렬 처리를 위한 Future 추가
    futures.add(_processSpot(spot, i));

    // 배치가 다 찼거나 마지막 항목이면 실행
    if (futures.length >= batchSize || i == spots.length - 1) {
      //      print('>>> 배치 처리 시작 (항목 $i 까지)...');
      await Future.wait(futures);
      futures.clear();

      // 배치 처리 후 파일 저장 (데이터 안전을 위해 주기적으로 저장)
      await _saveFile(file, spots);
      updatedCount += batchSize;
      //      print('>>> 현재까지 약 $updatedCount 개 항목 처리 완료 및 저장.');
    }
  }

  //  print('모든 작업이 완료되었습니다.');
}

// ==========================================
// 개별 항목 처리 함수
// ==========================================
Future<void> _processSpot(Map<String, dynamic> spot, int index) async {
  final String name = spot['name'] ?? 'Unknown';
  final String englishName = spot['english name'] ?? '';
  final String city = spot['city'] ?? '';
  final String province = spot['province'] ?? '';

  //  print('[$index] 처리 중: $name ($englishName) - $city, $province...');

  try {
    // API 호출하여 정보 가져오기
    final enhancedData = await _fetchEnhancedInfo(spot);

    if (enhancedData != null) {
      // 데이터 업데이트
      spot['description'] = enhancedData['description'];
      spot['texts'] = enhancedData['texts'];
      spot['isEnhanced'] = true; // 처리 완료 플래그
      // 필요한 경우 title, city, province 등도 업데이트 가능
      if (enhancedData['title'] != null) spot['title'] = enhancedData['title'];

      //      print('[$index] 업데이트 완료: $name');
    } else {
      //      print('[$index] 데이터 가져오기 실패: $name');
    }
  } catch (e) {
    //    print('[$index] 오류 발생 ($name): $e');
  }
}

// ==========================================
// 파일 저장 함수
// ==========================================
Future<void> _saveFile(File file, List<dynamic> data) async {
  const encoder = JsonEncoder.withIndent('    ');
  await file.writeAsString(encoder.convert(data));
}

// ==========================================
// AI API 호출 함수 (Gemini 예시)
// ==========================================
Future<Map<String, dynamic>?> _fetchEnhancedInfo(
  Map<String, dynamic> originalSpot,
) async {
  if (apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
    // API 키가 없을 경우 가짜 데이터 반환 또는 오류 (실제 실행 시 사용자에게 알림)
    // 여기서는 시뮬레이션을 위해 주석 처리하거나, 실제 사용 시에는 return null;
    //    print('경고: API 키가 설정되지 않았습니다.');
    return null;
  }

  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
  );

  final prompt =
      '''
다음 여행지에 대한 정보를 인터넷 검색 결과에 기반하여 풍부하게 보강해주세요.
답변은 반드시 JSON 형식이어야 합니다.

**대상 여행지**:
- 이름: ${originalSpot['name']}
- 영어 이름: ${originalSpot['english name']}
- 기존 설명: ${originalSpot['description']}
- 도시/주: ${originalSpot['city']}, ${originalSpot['province']}

**요청 사항**:
1. `description`: 기존 설명보다 2배 이상 상세하게 작성하세요.
2. `title`: 매력적인 짧은 타이틀을 작성하세요.
3. `texts`: 마크다운 형식의 문자열 배열로, 상세 정보를 구조화해서 작성하세요.
   - 각 항목에 적절한 이모지를 풍부하게 사용하세요.
   - 역사, 특징, 방문 팁, 가는 방법 등을 포함하세요.
   - 가독성 있게 예쁘게 꾸며주세요.
4. 출력 JSON 형식:
{
  "title": "...",
  "description": "...",
  "texts": ["Markdown string 1", "Markdown string 2", ...]
}
''';

  final payload = {
    "contents": [
      {
        "parts": [
          {"text": prompt},
        ],
      },
    ],
    "generationConfig": {"response_mime_type": "application/json"},
  };

  try {
    final client = HttpClient();
    final request = await client.postUrl(url);
    request.headers.set('Content-Type', 'application/json');
    request.write(json.encode(payload));

    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = json.decode(responseBody);

      // Gemini 응답 파싱
      final candidates = jsonResponse['candidates'];
      if (candidates != null && candidates.isNotEmpty) {
        final contentParts = candidates[0]['content']['parts'];
        if (contentParts != null && contentParts.isNotEmpty) {
          var text = contentParts[0]['text'].toString();
          // 마크다운 코드 블록 제거 (```json ... ```)
          text = text.replaceAll(RegExp(r'^```json\s*', multiLine: true), '');
          text = text.replaceAll(RegExp(r'^```\s*', multiLine: true), '');
          // 앞뒤 공백 제거
          text = text.trim();

          return json.decode(text);
        }
      }
    } else {
      //      print('API Error: ${response.statusCode}');
    }
  } catch (e) {
    //    print('Exception during API call: $e');
  }

  return null;
}
