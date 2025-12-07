import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 포럼 헤더 위젯 (Forum Header Widget)
///
/// 주요 카테고리를 가로 스크롤 가능한 TextButton 목록으로 표시
/// Displays major categories as horizontally scrollable TextButton list
class ForumHeader extends StatefulWidget {
  /// 카테고리 선택 콜백
  /// Callback when category is selected
  final void Function(String postId)? onCategorySelected;

  const ForumHeader({
    super.key,
    this.onCategorySelected,
  });

  @override
  State<ForumHeader> createState() => _ForumHeaderState();
}

class _ForumHeaderState extends State<ForumHeader> {
  /// 현재 선택된 카테고리 ID
  /// Currently selected category ID
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;
    final l10n = Lo.of(context)!;

    return SafeArea(
      child: Row(
        children: [
          /// 카테고리 목록 (가로 스크롤)
          /// Category list (horizontal scroll)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: sp.s8),
              child: Row(
                children: PhilgoCategory.majorCategories().map((postId) {
                  /// 카테고리 다국어 이름 가져오기
                  /// Get localized category name
                  final localizedName = _getLocalizedCategory(l10n, postId);

                  /// 현재 선택된 카테고리 여부
                  /// Whether this category is currently selected
                  final isSelected = _selectedCategory == postId;

                  return Padding(
                    padding: EdgeInsets.only(right: sp.s4),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = postId;
                        });
                        widget.onCategorySelected?.call(postId);
                      },
                      style: TextButton.styleFrom(
                        /// 선택된 카테고리는 primary 색상 배경 적용
                        /// Apply primary background for selected category
                        backgroundColor: isSelected
                            ? scheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        /// 패딩 최소화
                        /// Minimize padding
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s12,
                          vertical: sp.s8,
                        ),
                        /// elevation 0 (Flat Design)
                        elevation: 0,
                      ),
                      child: Text(
                        localizedName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          /// 선택된 카테고리는 primary 색상, 아니면 기본 색상
                          /// Selected category uses primary color, otherwise default
                          color: isSelected
                              ? scheme.primary
                              : scheme.onSurface,
                          /// 선택된 카테고리는 bold
                          /// Selected category is bold
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// 글쓰기 버튼
          /// Create post button
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.lightPlusLarge,
              color: scheme.onSurface,
              size: 20,
            ),
            onPressed: () {
              // TODO: 글쓰기 기능 구현
              // TODO: Implement post creation
            },
          ),
        ],
      ),
    );
  }

  /// 카테고리의 다국어 이름 반환
  /// Returns localized name for category
  ///
  /// [l10n] Lo instance for localization
  /// [postId] Category ID (e.g., 'freetalk', 'buyandsell')
  ///
  /// 지원하지 않는 카테고리는 원본 postId를 반환
  /// Returns original postId for unsupported categories
  String _getLocalizedCategory(Lo l10n, String postId) {
    switch (postId) {
      case 'freetalk':
        return l10n.categoryFreetalk;
      case 'qna':
        return l10n.categoryQna;
      case 'buyandsell':
        return l10n.categoryBuyandsell;
      case 'blog':
        return l10n.categoryBlog;
      case 'boarding_house':
        return l10n.categoryBoardingHouse;
      case 'caution':
        return l10n.categoryCaution;
      case 'lookfor':
        return l10n.categoryLookfor;
      case 'food_delivery':
        return l10n.categoryFoodDelivery;
      case 'greeting':
        return l10n.categoryGreeting;
      case 'wanted':
        return l10n.categoryWanted;
      case 'business':
        return l10n.categoryBusiness;
      case 'massage':
        return l10n.categoryMassage;
      case 'rest':
        return l10n.categoryRest;
      case 'school':
        return l10n.categorySchool;
      case 'study':
        return l10n.categoryStudy;
      case 'travel':
        return l10n.categoryTravel;
      case 'youtube':
        return l10n.categoryYoutube;
      case 'momcafe':
        return l10n.categoryMomcafe;
      case 'news':
        return l10n.categoryNews;
      case 'newcomer':
        return l10n.categoryNewcomer;
      case 'nature':
        return l10n.categoryNature;
      case 'company_info':
        return l10n.categoryCompanyInfo;
      case 'english_biz':
        return l10n.categoryEnglishBiz;
      case 'temp':
        return l10n.categoryTemp;
      case 'travel_good':
        return l10n.categoryTravelGood;
      default:
        return postId;
    }
  }
}
