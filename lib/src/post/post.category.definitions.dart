import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class PostCategoryItem {
  final String postId;
  final String? category;

  PostCategoryItem({required this.postId, this.category});

  String get postIdOrCategory {
    if (category == null || category!.isEmpty) {
      return postId;
    }
    return '$category';
  }

  /// 동적 키를 사용한 번역 반환
  ///
  /// BuildContext를 받아서 현재 언어에 맞는 번역을 반환합니다.
  /// category가 있으면 category를 번역하고, 없으면 postId를 번역합니다.
  String getLabel(BuildContext context) {
    // category가 있으면 category를 번역, 없으면 postId를 번역
    final keyToTranslate = category ?? postId;
    return _getTranslation(context, keyToTranslate);
  }

  /// 동적 키를 switch문으로 매핑하는 헬퍼 함수
  ///
  /// 각 카테고리 키에 대해 적절한 번역을 반환합니다.
  /// 현재는 LibTr에 카테고리 관련 번역이 없으므로,
  /// 기본적으로 키를 사람이 읽을 수 있는 형태로 변환합니다.
  String _getTranslation(BuildContext context, String key) {
    final lo = LibTr.of(context);

    // LibTr이 null인 경우 원본 키 반환
    if (lo == null) return _formatKey(key);

    // 현재 언어 코드 확인
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;

    key = key.toLowerCase();

    // 언어별 직접 번역 제공
    switch (key) {
      // 주요 카테고리들
      case 'freetalk':
      case 'community':
        switch (languageCode) {
          case 'ko':
            return '커뮤니티';
          case 'zh':
            return '社区';
          case 'ja':
            return 'コミュニティ';
          default:
            return 'Community';
        }
      case 'qna':
        switch (languageCode) {
          case 'ko':
            return '질문답변';
          case 'zh':
            return '问答';
          case 'ja':
            return 'Q&A';
          default:
            return 'Q&A';
        }
      case 'discussion':
        switch (languageCode) {
          case 'ko':
            return '자유토론';
          case 'zh':
            return '讨论';
          case 'ja':
            return 'ディスカッション';
          default:
            return 'Discussion';
        }
      case 'business':
        switch (languageCode) {
          case 'ko':
            return '비즈니스';
          case 'zh':
            return '商业';
          case 'ja':
            return 'ビジネス';
          default:
            return 'Business';
        }
      case 'buyandsell':
        switch (languageCode) {
          case 'ko':
            return '사고팔기';
          case 'zh':
            return '买卖';
          case 'ja':
            return '売買';
          default:
            return 'Buy & Sell';
        }
      case 'hotel':
        switch (languageCode) {
          case 'ko':
            return '호텔';
          case 'zh':
            return '酒店';
          case 'ja':
            return 'ホテル';
          default:
            return 'Hotel';
        }
      case 'wanted':
      case 'jobs':
        switch (languageCode) {
          case 'ko':
            return '구인구직';
          case 'zh':
            return '招聘';
          case 'ja':
            return '求人';
          default:
            return 'Jobs';
        }

      // 서브 카테고리들
      case '렌트카':
        switch (languageCode) {
          case 'ko':
            return '렌트카';
          case 'zh':
            return '租车';
          case 'ja':
            return 'レンタカー';
          default:
            return 'Rent a Car';
        }

      case 'temp':
        switch (languageCode) {
          case 'ko':
            return '임시게시판';
          case 'zh':
            return 'Temp';
          case 'ja':
            return 'Temp';
          default:
            return 'Temp';
        }

      // 번역이 정의되지 않은 경우 포맷팅된 키 반환
      default:
        return _formatKey(key);
    }
  }

  /// 키를 사람이 읽을 수 있는 형태로 포맷팅
  ///
  /// 예: 'buyandsell' -> 'Buy And Sell'
  String _formatKey(String key) {
    // camelCase나 snake_case를 띄어쓰기로 변환
    final formatted = key
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .replaceAll('_', ' ')
        .replaceAll('-', ' ');

    // 첫 글자 대문자로
    if (formatted.isNotEmpty) {
      return formatted[0].toUpperCase() + formatted.substring(1);
    }
    return formatted;
  }

  @override
  String toString() {
    return "PostCategoryItem(postId: $postId, category: $category)";
  }
}
