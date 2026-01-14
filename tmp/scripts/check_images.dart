// check_images.dart
// travel_spots.json 파일의 모든 imageUrl을 검증하는 스크립트
//
// 각 이미지 URL에 HEAD 요청을 보내 HTTP 상태 코드를 확인합니다.
// HTTP 200이 아닌 경우 깨진 이미지로 판단합니다.
//
// 사용법:
//   dart run tmp/scripts/check_images.dart
//
// 옵션:
//   --verbose     : 모든 URL의 상태를 출력 (기본: 실패한 URL만 출력)
//   --timeout 10  : 요청 타임아웃 초 (기본: 10초)
//   --output file : 결과를 JSON 파일로 저장
//   --help        : 도움말 표시

import 'dart:convert';
import 'dart:io';

/// 이미지 검증 결과를 저장하는 클래스
class ImageCheckResult {
  final String name;
  final String city;
  final String imageUrl;
  final int statusCode;
  final String? error;
  final bool isValid;

  ImageCheckResult({
    required this.name,
    required this.city,
    required this.imageUrl,
    required this.statusCode,
    this.error,
    required this.isValid,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'city': city,
    'imageUrl': imageUrl,
    'statusCode': statusCode,
    'error': error,
    'isValid': isValid,
  };
}

void main(List<String> args) async {
  // 명령줄 인자 파싱
  bool verbose = false;
  int timeout = 10;
  String? outputFile;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--verbose':
      case '-v':
        verbose = true;
        break;
      case '--timeout':
        if (i + 1 < args.length) {
          timeout = int.tryParse(args[++i]) ?? 10;
        }
        break;
      case '--output':
      case '-o':
        if (i + 1 < args.length) {
          outputFile = args[++i];
        }
        break;
      case '--help':
      case '-h':
        printUsage();
        exit(0);
    }
  }

  // JSON 파일 경로
  final jsonPath = 'lib/philgo_files/travel/travel_spots.json';

  // JSON 파일 읽기
  final file = File(jsonPath);
  if (!file.existsSync()) {
    print('오류: $jsonPath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> items = jsonDecode(jsonString);

  print('=' * 60);
  print('Travel Spots 이미지 URL 검증');
  print('=' * 60);
  print('파일: $jsonPath');
  print('총 항목 수: ${items.length}');
  print('타임아웃: ${timeout}초');
  print('');

  // 결과 저장 리스트
  final List<ImageCheckResult> results = [];
  final List<ImageCheckResult> failedResults = [];

  // HttpClient 생성
  final client = HttpClient();
  client.connectionTimeout = Duration(seconds: timeout);

  int checkedCount = 0;
  int successCount = 0;
  int failCount = 0;

  print('검증 진행 중...');
  print('');

  for (int i = 0; i < items.length; i++) {
    final item = items[i] as Map<String, dynamic>;
    final name = item['name'] as String? ?? '';
    final city = item['city'] as String? ?? '';
    final imageUrl = item['imageUrl'] as String? ?? '';

    if (imageUrl.isEmpty) {
      print('[$i] $name - imageUrl이 비어있음');
      failCount++;
      final result = ImageCheckResult(
        name: name,
        city: city,
        imageUrl: imageUrl,
        statusCode: 0,
        error: 'Empty URL',
        isValid: false,
      );
      results.add(result);
      failedResults.add(result);
      continue;
    }

    checkedCount++;

    try {
      // HEAD 요청으로 이미지 존재 여부 확인
      final uri = Uri.parse(imageUrl);
      final request = await client
          .headUrl(uri)
          .timeout(
            Duration(seconds: timeout),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      // User-Agent 설정 (일부 서버는 User-Agent 없이 차단)
      request.headers.set(
        'User-Agent',
        'Mozilla/5.0 (compatible; ImageChecker/1.0)',
      );

      final response = await request.close().timeout(
        Duration(seconds: timeout),
        onTimeout: () {
          throw TimeoutException('Response timed out');
        },
      );

      final statusCode = response.statusCode;
      final isValid = statusCode == 200;

      final result = ImageCheckResult(
        name: name,
        city: city,
        imageUrl: imageUrl,
        statusCode: statusCode,
        isValid: isValid,
      );
      results.add(result);

      if (isValid) {
        successCount++;
        if (verbose) {
          print('✅ [$i] $name ($city) - HTTP $statusCode');
        }
      } else {
        failCount++;
        failedResults.add(result);
        print('❌ [$i] $name ($city) - HTTP $statusCode');
        print('   URL: $imageUrl');
      }
    } catch (e) {
      failCount++;
      String errorMsg = e.toString();

      // 에러 메시지 간소화
      if (e is TimeoutException) {
        errorMsg = 'Timeout';
      } else if (errorMsg.contains('SocketException')) {
        errorMsg = 'Connection failed';
      } else if (errorMsg.contains('HandshakeException')) {
        errorMsg = 'SSL/TLS error';
      }

      final result = ImageCheckResult(
        name: name,
        city: city,
        imageUrl: imageUrl,
        statusCode: 0,
        error: errorMsg,
        isValid: false,
      );
      results.add(result);
      failedResults.add(result);

      print('❌ [$i] $name ($city) - 오류: $errorMsg');
      print('   URL: $imageUrl');
    }

    // 진행 상황 표시 (10개마다)
    if ((i + 1) % 10 == 0) {
      print('... ${i + 1}/${items.length} 완료');
    }
  }

  client.close();

  // 결과 요약
  print('');
  print('=' * 60);
  print('검증 결과 요약');
  print('=' * 60);
  print('총 항목: ${items.length}');
  print('검증된 URL: $checkedCount');
  print('✅ 성공: $successCount');
  print('❌ 실패: $failCount');
  print('');

  // 실패한 항목 상세 목록
  if (failedResults.isNotEmpty) {
    print('=' * 60);
    print('실패한 이미지 URL 목록 (${failedResults.length}개)');
    print('=' * 60);
    for (int i = 0; i < failedResults.length; i++) {
      final result = failedResults[i];
      print('');
      print('[${i + 1}] ${result.name} (${result.city})');
      print('    URL: ${result.imageUrl}');
      if (result.error != null) {
        print('    오류: ${result.error}');
      } else {
        print('    상태: HTTP ${result.statusCode}');
      }
    }
    print('');
  }

  // 결과를 파일로 저장
  if (outputFile != null) {
    final outputData = {
      'timestamp': DateTime.now().toIso8601String(),
      'totalItems': items.length,
      'successCount': successCount,
      'failCount': failCount,
      'failedItems': failedResults.map((r) => r.toJson()).toList(),
      'allResults': results.map((r) => r.toJson()).toList(),
    };

    final encoder = JsonEncoder.withIndent('  ');
    File(outputFile).writeAsStringSync(encoder.convert(outputData));
    print('결과 저장됨: $outputFile');
  }

  // 종료 코드
  if (failCount > 0) {
    print('');
    print('⚠️  $failCount개의 이미지 URL이 유효하지 않습니다.');
    print('   update_images.dart 스크립트를 사용하여 URL을 업데이트하세요.');
    exit(1);
  } else {
    print('🎉 모든 이미지 URL이 유효합니다!');
    exit(0);
  }
}

/// TimeoutException 클래스
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  @override
  String toString() => message;
}

/// 사용법 출력
void printUsage() {
  print('''
사용법:
  dart run tmp/scripts/check_images.dart [옵션]

설명:
  travel_spots.json 파일의 모든 imageUrl을 검증합니다.
  각 URL에 HTTP HEAD 요청을 보내 이미지가 존재하는지 확인합니다.

옵션:
  --verbose, -v       모든 URL의 상태를 출력 (기본: 실패한 URL만 출력)
  --timeout <초>      요청 타임아웃 (기본: 10초)
  --output, -o <파일> 결과를 JSON 파일로 저장
  --help, -h          이 도움말 표시

예시:
  # 기본 실행 (실패한 URL만 출력)
  dart run tmp/scripts/check_images.dart

  # 모든 URL 상태 출력
  dart run tmp/scripts/check_images.dart --verbose

  # 결과를 파일로 저장
  dart run tmp/scripts/check_images.dart --output tmp/image_check_results.json

  # 타임아웃 20초로 설정
  dart run tmp/scripts/check_images.dart --timeout 20
''');
}
