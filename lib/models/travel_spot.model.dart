/// 여행 명소 데이터 모델 (Travel Spot Data Model)
///
/// travel_spots.json 파일의 여행 명소 정보를 담는 모델입니다.
/// Model containing travel spot information from travel_spots.json file.
class TravelSpot {
  /// 한글 이름 (Korean name)
  final String name;

  /// 영문 이름 (English name)
  final String englishName;

  /// 제목/부제목 (Title/Subtitle)
  final String title;

  /// 설명 (Description)
  final String description;

  /// 도시 (City)
  final String city;

  /// 지역/주 (Province)
  final String province;

  /// 이모지 아이콘 (Emoji Icon)
  final String icon;

  /// 카테고리 (Category)
  final String category;

  const TravelSpot({
    required this.name,
    required this.englishName,
    required this.title,
    required this.description,
    required this.city,
    required this.province,
    required this.icon,
    required this.category,
  });

  /// JSON에서 TravelSpot 객체 생성 (Create TravelSpot from JSON)
  factory TravelSpot.fromJson(Map<String, dynamic> json) {
    return TravelSpot(
      name: json['name'] as String? ?? '',
      englishName: json['english name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      city: json['city'] as String? ?? '',
      province: json['province'] as String? ?? '',
      icon: json['icon'] as String? ?? '📍',
      category: json['category'] as String? ?? '',
    );
  }

  /// TravelSpot 객체를 JSON으로 변환 (Convert TravelSpot to JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'english name': englishName,
      'title': title,
      'description': description,
      'city': city,
      'province': province,
      'icon': icon,
      'category': category,
    };
  }

  /// 검색어가 포함되어 있는지 확인 (Check if search query is contained)
  ///
  /// name, englishName, title, description, city, province, category 필드에서
  /// 검색어를 찾습니다.
  /// Searches for query in name, englishName, title, description, city, province, category fields.
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        englishName.toLowerCase().contains(lowerQuery) ||
        title.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        city.toLowerCase().contains(lowerQuery) ||
        province.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery);
  }

  /// 어떤 필드에서 매칭되었는지 반환 (Returns which field matched)
  ///
  /// 검색 결과에서 어느 필드에서 매칭되었는지 표시하기 위해 사용합니다.
  /// Used to show which field matched in search results.
  List<String> getMatchedFields(String query) {
    final lowerQuery = query.toLowerCase();
    final matchedFields = <String>[];

    if (name.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('name');
    }
    if (englishName.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('englishName');
    }
    if (title.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('title');
    }
    if (description.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('description');
    }
    if (city.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('city');
    }
    if (province.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('province');
    }
    if (category.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('category');
    }

    return matchedFields;
  }
}
