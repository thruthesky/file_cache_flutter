import 'package:flutter/material.dart';
import 'philgo_tr.dart';

/// PhilGo 다국어 번역 헬퍼 함수 (PhilGo Localization Helper Function)
///
/// 사용법 (Usage):
/// ```dart
/// philgoTr(context, 'qna')       // → "묻고 답하기" (한국어)
/// philgoTr(context, 'freetalk')  // → "자유게시판" (한국어)
/// philgoTr(context, 'discussion') // → "토론" (한국어)
/// ```
///
/// [context] BuildContext - 다국어 설정을 가져오기 위한 컨텍스트
/// [key] 번역 키 (예: 'qna', 'freetalk', 'discussion')
///
/// 지원하지 않는 키는 원본 key를 그대로 반환합니다.
/// Returns original key for unsupported keys.
///
/// PhilgoTr이 설정되지 않은 경우에도 원본 key를 반환합니다.
/// Also returns original key if PhilgoTr is not configured.
String philgoTr(BuildContext context, String key) {
  final tr = PhilgoTr.of(context);

  /// PhilgoTr이 null인 경우 (다국어 설정이 안 된 경우) 원본 키 반환
  /// Returns original key if PhilgoTr is null (localization not configured)
  if (tr == null) return key;

  return _getTranslation(tr, key);
}

/// 번역 키에 해당하는 다국어 텍스트 반환
/// Returns localized text for the given translation key
///
/// [tr] PhilgoTr 인스턴스 - 현재 로케일의 번역 클래스
/// [key] 번역 키 (메인 카테고리 또는 서브 카테고리)
///
/// 지원하지 않는 키는 원본 key를 반환
/// Returns original key for unsupported keys
String _getTranslation(PhilgoTr tr, String key) {
  return _buildTranslationMap(tr)[key] ?? key;
}

/// 번역 맵 생성
/// Builds translation map for categories and sub-categories
///
/// [tr] PhilgoTr 인스턴스 - 현재 로케일의 번역 클래스
///
/// 메인 카테고리 25개와 서브 카테고리 32개를 포함하는 맵을 반환합니다.
/// Returns a map containing 25 main categories and 32 sub-categories.
///
/// 새 카테고리 추가 시 이 함수에만 추가하면 됩니다.
/// When adding new categories, only this function needs to be updated.
Map<String, String> _buildTranslationMap(PhilgoTr tr) {
  return {
    // ========================================
    // 공통 (Common)
    // ========================================
    'all': tr.categoryAll,

    // ========================================
    // 메인 카테고리 (Main Categories) - 25개
    // ========================================
    'freetalk': tr.categoryFreetalk,
    'qna': tr.categoryQna,
    'buyandsell': tr.categoryBuyandsell,
    'blog': tr.categoryBlog,
    'boarding_house': tr.categoryBoardingHouse,
    'caution': tr.categoryCaution,
    'lookfor': tr.categoryLookfor,
    'food_delivery': tr.categoryFoodDelivery,
    'greeting': tr.categoryGreeting,
    'wanted': tr.categoryWanted,
    'business': tr.categoryBusiness,
    'massage': tr.categoryMassage,
    'rest': tr.categoryRest,
    'school': tr.categorySchool,
    'study': tr.categoryStudy,
    'travel': tr.categoryTravel,
    'youtube': tr.categoryYoutube,
    'momcafe': tr.categoryMomcafe,
    'news': tr.categoryNews,
    'newcomer': tr.categoryNewcomer,
    'nature': tr.categoryNature,
    'company_info': tr.categoryCompanyInfo,
    'english_biz': tr.categoryEnglishBiz,
    'temp': tr.categoryTemp,
    'travel_good': tr.categoryTravelGood,

    // ========================================
    // 서브 카테고리 (Sub Categories) - 32개
    // ========================================

    // 토론/정보 관련 (Discussion/Info related)
    'discussion': tr.subCategoryDiscussion,
    '백과': tr.subCategoryEncyclopedia,
    '취미': tr.subCategoryHobby,
    'info': tr.subCategoryInfo,

    // 커뮤니티 관련 (Community related)
    '코필커플': tr.subCategoryKoPhCouple,
    '코피노': tr.subCategoryKopino,
    '이민': tr.subCategoryImmigration,
    '사진': tr.subCategoryPhoto,
    '생활의팁': tr.subCategoryLifeTips,
    '행방불명': tr.subCategoryMissing,
    '국제결혼': tr.subCategoryIntlMarriage,
    '모임': tr.subCategoryMeeting,

    // 콘텐츠 관련 (Content related)
    'column': tr.subCategoryColumn,
    '먹방': tr.subCategoryMukbang,
    '뉴스': tr.categoryNews,
    '공지사항': tr.subCategoryNotice,
    '경험담': tr.subCategoryExperience,
    '공부': tr.subCategoryStudyLearn,
    '태풍': tr.subCategoryTyphoon,

    // 비즈니스 관련 (Business related)
    '사업/동업구함': tr.subCategoryBusinessPartner,
    '컴퓨터/인터넷': tr.subCategoryComputer,
    '페소환전': tr.subCategoryExchange,
    '핸드폰': tr.subCategoryPhone,
    '호텔': tr.subCategoryHotel,

    // 생활/쇼핑 관련 (Living/Shopping related)
    '가전/생활용품': tr.subCategoryAppliances,
    '골프': tr.subCategoryGolf,
    'promotion': tr.subCategoryPromotion,
    '개인장터': tr.subCategoryPersonalMarket,

    // 부동산/렌탈 관련 (Real Estate/Rental related)
    'real_estate': tr.subCategoryRealEstate,
    '주택임대': tr.subCategoryHouseRental,
    '렌트카': tr.subCategoryCarRental,
    '중고차': tr.subCategoryUsedCar,

    // 지역 카테고리 (Region categories)
    '마닐라': tr.subCategoryManila,
    '세부': tr.subCategoryCebu,
    '앙헬레스': tr.subCategoryAngeles,

    // 구인구직 카테고리 (Wanted categories)
    'hiring': tr.subCategoryHiring,
    'looking': tr.subCategoryLooking,

    // 카테고리 선택 안내 (Category selection prompt)
    'selectCategory': tr.selectCategory,
    'selectHiringOrLooking': tr.selectHiringOrLooking,
  };
}
