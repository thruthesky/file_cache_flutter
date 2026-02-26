// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// HTTP 404 오류가 있는 이미지를 Wikipedia 이미지로 교체하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run tmp/scripts/fix_404_images.dart
/// ```

void main() async {
  final jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';
  final failedUrlsPath = 'lib/philgo_files/scripts/real_failed_image_urls.json';

  //  print('======================================');
  //  print('📋 HTTP 404 오류 이미지 URL 교체 도구');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  // 실패한 URL 읽기
  final failedFile = File(failedUrlsPath);
  final failedJsonString = failedFile.readAsStringSync();
  final List<dynamic> failedUrls = jsonDecode(failedJsonString);

  // HTTP 404 오류 URL만 필터링
  final http404Errors = failedUrls.where((item) {
    final statusCode = item['statusCode'] as int? ?? 0;
    return statusCode == 404;
  }).toList();

  //  print('📊 HTTP 404 오류 URL 개수: ${http404Errors.length}개\n');

  final httpClient = HttpClient();
  httpClient.connectionTimeout = const Duration(seconds: 15);

  int updated = 0;
  int failed = 0;

  for (int i = 0; i < http404Errors.length; i++) {
    final item = http404Errors[i];
    final index = item['index'] as int;
    final englishName = item['englishName']?.toString() ?? '';
    final name = item['name']?.toString() ?? '';

    //    print('🔍 [${i + 1}/${http404Errors.length}] $name ($englishName)');

    // 영문명에서 괄호 안의 내용 제거하고 기본 이름만 사용
    String searchName = englishName;
    if (searchName.contains('(')) {
      searchName = searchName.split('(').first.trim();
    }

    // Wikipedia API로 이미지 URL 가져오기
    final wikiTitle = searchName.replaceAll(' ', '_');
    final apiUrl =
        'https://en.wikipedia.org/w/api.php?action=query&titles=$wikiTitle&prop=pageimages&format=json&pithumbsize=800';

    try {
      final uri = Uri.parse(apiUrl);
      final request = await httpClient.getUrl(uri);
      request.headers.add('User-Agent', 'Mozilla/5.0');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody) as Map<String, dynamic>;

        final pages = data['query']?['pages'] as Map<String, dynamic>?;
        if (pages != null && pages.isNotEmpty) {
          final page = pages.values.first as Map<String, dynamic>;

          // 페이지가 존재하지 않으면 (-1) 다른 검색어 시도
          if (page['pageid'] == null || page['pageid'] == -1) {
            // Mount 접두사 없이 시도
            if (searchName.startsWith('Mount ')) {
              searchName = searchName.substring(6);
            }
            // 위치명 + Philippines로 검색 시도
            final altTitle = '${searchName.replaceAll(' ', '_')},_Philippines';
            final altApiUrl =
                'https://en.wikipedia.org/w/api.php?action=query&titles=$altTitle&prop=pageimages&format=json&pithumbsize=800';

            final altRequest = await httpClient.getUrl(Uri.parse(altApiUrl));
            altRequest.headers.add('User-Agent', 'Mozilla/5.0');
            final altResponse = await altRequest.close();

            if (altResponse.statusCode == 200) {
              final altBody = await altResponse.transform(utf8.decoder).join();
              final altData = jsonDecode(altBody) as Map<String, dynamic>;
              final altPages =
                  altData['query']?['pages'] as Map<String, dynamic>?;

              if (altPages != null) {
                final altPage = altPages.values.first as Map<String, dynamic>;
                final altThumbnail =
                    altPage['thumbnail'] as Map<String, dynamic>?;

                if (altThumbnail != null) {
                  final newImageUrl = altThumbnail['source'] as String;
                  if (await _validateImageUrl(httpClient, newImageUrl)) {
                    travelSpots[index]['imageUrl'] = newImageUrl;
                    //                    print('   ✅ 업데이트 (대체 검색): $newImageUrl');
                    updated++;
                    await Future.delayed(const Duration(milliseconds: 500));
                    continue;
                  }
                }
              }
            }

            //            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
            await Future.delayed(const Duration(milliseconds: 500));
            continue;
          }

          final thumbnail = page['thumbnail'] as Map<String, dynamic>?;

          if (thumbnail != null) {
            final newImageUrl = thumbnail['source'] as String;

            // URL 유효성 확인
            if (await _validateImageUrl(httpClient, newImageUrl)) {
              travelSpots[index]['imageUrl'] = newImageUrl;
              //              print('   ✅ 업데이트: $newImageUrl');
              updated++;
            } else {
              //              print('   ❌ 이미지 접근 불가');
              failed++;
            }
          } else {
            //            print('   ⚠️  Wikipedia에 이미지 없음');
            failed++;
          }
        } else {
          //          print('   ⚠️  Wikipedia 페이지를 찾을 수 없음');
          failed++;
        }
      } else {
        //        print('   ❌ API 호출 실패: HTTP ${response.statusCode}');
        failed++;
      }
    } catch (e) {
      //      print('   ❌ 오류: $e');
      failed++;
    }

    // Rate limiting 방지
    await Future.delayed(const Duration(milliseconds: 500));
  }

  httpClient.close();

  // JSON 파일 저장
  final encoder = const JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(travelSpots);
  file.writeAsStringSync(updatedJsonString);

  //  print('\n======================================');
  //  print('📊 결과 요약');
  //  print('======================================');
  //  print('✅ 업데이트 성공: $updated개');
  //  print('❌ 업데이트 실패: $failed개');
  //  print('\n📁 $jsonFilePath 파일이 수정되었습니다.');
}

/// 이미지 URL 유효성 검증
Future<bool> _validateImageUrl(HttpClient client, String url) async {
  try {
    final checkRequest = await client.headUrl(Uri.parse(url));
    checkRequest.headers.add('User-Agent', 'Mozilla/5.0');
    final checkResponse = await checkRequest.close();
    await checkResponse.drain();
    return checkResponse.statusCode >= 200 && checkResponse.statusCode < 400;
  } catch (e) {
    return false;
  }
}
