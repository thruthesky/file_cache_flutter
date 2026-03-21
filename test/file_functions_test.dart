/// 파일 관련 함수 Unit Test
/// Unit Test for file functions (getFileExtension, detectFileType, isOldImageFile)
///
/// 참고: https://docs.flutter.dev/cookbook/testing/unit/introduction
/// Reference: https://docs.flutter.dev/cookbook/testing/unit/introduction
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:philgo_api/src/functions/file.functions.dart';

void main() {
  /// getFileExtension 함수 테스트 그룹
  /// Test group for getFileExtension function
  group('getFileExtension', () {
    /// 테스트 1: 일반 이미지 URL에서 확장자 추출
    /// Test 1: Extract extension from normal image URL
    test('일반 이미지 URL에서 jpg 확장자 추출', () {
      final result = getFileExtension('https://example.com/image.jpg');
      expect(result, 'jpg');
    });

    /// 테스트 2: 쿼리 스트링이 있는 URL에서 확장자 추출
    /// Test 2: Extract extension from URL with query string
    test('쿼리 스트링이 있는 URL에서 확장자 추출', () {
      final result =
          getFileExtension('https://example.com/image.jpg?size=large');
      expect(result, 'jpg');
    });

    /// 테스트 3: 해시가 있는 URL에서 확장자 추출
    /// Test 3: Extract extension from URL with hash
    test('해시가 있는 URL에서 확장자 추출', () {
      final result = getFileExtension('https://example.com/video.mp4#t=10');
      expect(result, 'mp4');
    });

    /// 테스트 4: 로컬 파일 경로에서 확장자 추출
    /// Test 4: Extract extension from local file path
    test('로컬 파일 경로에서 확장자 추출', () {
      final result = getFileExtension('/path/to/document.pdf');
      expect(result, 'pdf');
    });

    /// 테스트 5: 확장자가 없는 URL
    /// Test 5: URL without extension
    test('확장자가 없는 URL은 빈 문자열 반환', () {
      final result = getFileExtension('https://example.com/file');
      expect(result, '');
    });

    /// 테스트 6: 대문자 확장자 처리
    /// Test 6: Handle uppercase extension
    test('대문자 확장자도 소문자로 반환', () {
      final result = getFileExtension('https://example.com/IMAGE.JPG');
      expect(result, 'jpg');
    });

    /// 테스트 7: jpeg 확장자 정확히 추출
    /// Test 7: Extract jpeg extension correctly
    test('jpeg 확장자 정확히 추출', () {
      final result = getFileExtension('https://example.com/photo.jpeg');
      expect(result, 'jpeg');
    });

    /// 테스트 8: 다양한 확장자 테스트
    /// Test 8: Test various extensions
    test('다양한 확장자 테스트', () {
      expect(getFileExtension('file.png'), 'png');
      expect(getFileExtension('file.gif'), 'gif');
      expect(getFileExtension('file.webp'), 'webp');
      expect(getFileExtension('file.mp4'), 'mp4');
      expect(getFileExtension('file.mov'), 'mov');
      expect(getFileExtension('file.pdf'), 'pdf');
      expect(getFileExtension('file.zip'), 'zip');
      expect(getFileExtension('file.json'), 'json');
    });
  });

  /// detectFileType 함수 테스트 그룹
  /// Test group for detectFileType function
  group('detectFileType', () {
    /// 테스트 1: 이미지 파일 타입 감지
    /// Test 1: Detect image file type
    test('이미지 파일 타입 감지', () {
      expect(
        detectFileType('https://example.com/photo.jpg'),
        UploadFileType.image,
      );
      expect(
        detectFileType('https://example.com/photo.jpeg'),
        UploadFileType.image,
      );
      expect(
        detectFileType('https://example.com/photo.png'),
        UploadFileType.image,
      );
      expect(
        detectFileType('https://example.com/photo.gif'),
        UploadFileType.image,
      );
      expect(
        detectFileType('https://example.com/photo.webp'),
        UploadFileType.image,
      );
    });

    /// 테스트 2: 비디오 파일 타입 감지
    /// Test 2: Detect video file type
    test('비디오 파일 타입 감지', () {
      expect(
        detectFileType('https://example.com/video.mp4'),
        UploadFileType.video,
      );
      expect(
        detectFileType('https://example.com/video.mov'),
        UploadFileType.video,
      );
      expect(
        detectFileType('https://example.com/video.avi'),
        UploadFileType.video,
      );
      expect(
        detectFileType('https://example.com/video.mkv'),
        UploadFileType.video,
      );
      expect(
        detectFileType('https://example.com/video.webm'),
        UploadFileType.video,
      );
    });

    /// 테스트 3: 일반 파일 타입 감지 (이미지/비디오가 아닌 경우)
    /// Test 3: Detect file type (non-image/video)
    test('일반 파일 타입 감지', () {
      expect(
        detectFileType('https://example.com/document.pdf'),
        UploadFileType.file,
      );
      expect(
        detectFileType('https://example.com/archive.zip'),
        UploadFileType.file,
      );
      expect(
        detectFileType('https://example.com/data.json'),
        UploadFileType.file,
      );
    });

    /// 테스트 4: PhilGo v4 이미지 파일 감지 (7자리 숫자)
    /// Test 4: Detect PhilGo v4 image file (7-digit numeric)
    test('PhilGo v4 이미지 파일 감지 (7자리 숫자)', () {
      expect(
        detectFileType('https://file.philgo.com/data/upload/5/1234567'),
        UploadFileType.image,
      );
      expect(
        detectFileType('https://file.philgo.com/data/upload/5/1234567?abc=def'),
        UploadFileType.image,
      );
    });

    /// 테스트 5: 쿼리 스트링이 있는 이미지 URL
    /// Test 5: Image URL with query string
    test('쿼리 스트링이 있는 이미지 URL', () {
      expect(
        detectFileType('https://example.com/image.jpg?size=large&quality=high'),
        UploadFileType.image,
      );
    });

    /// 테스트 6: 확장자가 없는 URL (PhilGo v4도 아닌 경우)
    /// Test 6: URL without extension (not PhilGo v4 either)
    test('확장자가 없는 일반 URL은 file 타입', () {
      expect(
        detectFileType('https://example.com/somefile'),
        UploadFileType.file,
      );
    });
  });

  /// isOldImageFile 함수 테스트 그룹
  /// Test group for isOldImageFile function
  group('isOldImageFile', () {
    /// 테스트 1: PhilGo v4 이미지 파일 (7자리 숫자)
    /// Test 1: PhilGo v4 image file (7-digit numeric)
    test('7자리 숫자 파일명은 true 반환', () {
      expect(
        isOldImageFile('https://file.philgo.com/data/upload/5/1234567'),
        true,
      );
    });

    /// 테스트 2: 쿼리 스트링이 있는 PhilGo v4 파일
    /// Test 2: PhilGo v4 file with query string
    test('쿼리 스트링이 있어도 7자리 숫자면 true', () {
      expect(
        isOldImageFile('https://file.philgo.com/data/upload/5/1234567?abc=def'),
        true,
      );
    });

    /// 테스트 3: 해시가 있는 PhilGo v4 파일
    /// Test 3: PhilGo v4 file with hash
    test('해시가 있어도 7자리 숫자면 true', () {
      expect(
        isOldImageFile('https://file.philgo.com/data/upload/5/1234567#section'),
        true,
      );
    });

    /// 테스트 4: 6자리 숫자는 false
    /// Test 4: 6-digit number returns false
    test('6자리 숫자는 false 반환', () {
      expect(
        isOldImageFile('https://file.philgo.com/data/upload/3/283626'),
        false,
      );
    });

    /// 테스트 5: 8자리 숫자는 false
    /// Test 5: 8-digit number returns false
    test('8자리 숫자는 false 반환', () {
      expect(
        isOldImageFile('https://file.philgo.com/data/upload/5/12345678'),
        false,
      );
    });

    /// 테스트 6: 일반 이미지 URL은 false
    /// Test 6: Normal image URL returns false
    test('일반 이미지 URL은 false 반환', () {
      expect(isOldImageFile('https://example.com/image.jpg'), false);
    });

    /// 테스트 7: 숫자가 아닌 7자리 문자열은 false
    /// Test 7: 7-character non-numeric string returns false
    test('숫자가 아닌 7자리는 false 반환', () {
      expect(
        isOldImageFile('https://file.philgo.com/data/upload/5/abc1234'),
        false,
      );
    });

    /// 테스트 8: 빈 문자열은 false
    /// Test 8: Empty string returns false
    test('빈 문자열은 false 반환', () {
      expect(isOldImageFile(''), false);
    });
  });

  /// 상수 테스트 그룹
  /// Test group for constants
  group('Extension Constants', () {
    /// 테스트 1: kImageExtensions 상수 확인
    /// Test 1: Verify kImageExtensions constant
    test('kImageExtensions 상수에 주요 이미지 확장자 포함', () {
      expect(kImageExtensions.contains('jpg'), true);
      expect(kImageExtensions.contains('jpeg'), true);
      expect(kImageExtensions.contains('png'), true);
      expect(kImageExtensions.contains('gif'), true);
    });

    /// 테스트 2: kVideoExtensions 상수 확인
    /// Test 2: Verify kVideoExtensions constant
    test('kVideoExtensions 상수에 주요 비디오 확장자 포함', () {
      expect(kVideoExtensions.contains('mp4'), true);
      expect(kVideoExtensions.contains('mov'), true);
      expect(kVideoExtensions.contains('avi'), true);
    });

    /// 테스트 3: kAllKnownExtensions에 모든 확장자 포함
    /// Test 3: Verify kAllKnownExtensions contains all extensions
    test('kAllKnownExtensions에 모든 카테고리 확장자 포함', () {
      // 이미지
      expect(kAllKnownExtensions.contains('jpg'), true);
      // 비디오
      expect(kAllKnownExtensions.contains('mp4'), true);
      // 오디오
      expect(kAllKnownExtensions.contains('mp3'), true);
      // 문서
      expect(kAllKnownExtensions.contains('pdf'), true);
      // 압축
      expect(kAllKnownExtensions.contains('zip'), true);
      // 웹/데이터
      expect(kAllKnownExtensions.contains('json'), true);
    });
  });
}
