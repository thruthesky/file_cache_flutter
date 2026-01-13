/// 축제 데이터 모델 (Festival Data Model)
///
/// festivals.json 파일의 축제 정보를 담는 모델입니다.
/// Model containing festival information from festivals.json file.
class Festival {
  /// 지역 (Region) - 마닐라, 세부, 팜팡가 등
  final String region;

  /// 세부 위치 (Location) - 도시, 구
  final String location;

  /// 행사명 (Festival name)
  final String name;

  /// 영문 행사명 (English festival name)
  final String englishName;

  /// 개최 월 (Month) - 0은 연중 개최
  final int month;

  /// 비고 (Note/Description)
  final String note;

  /// 분류 (Category) - 종교, 문화, 음악 등
  final String category;

  const Festival({
    required this.region,
    required this.location,
    required this.name,
    required this.englishName,
    required this.month,
    required this.note,
    required this.category,
  });

  /// JSON에서 Festival 객체 생성 (Create Festival from JSON)
  factory Festival.fromJson(Map<String, dynamic> json) {
    return Festival(
      region: json['region'] as String? ?? '',
      location: json['location'] as String? ?? '',
      name: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      month: json['month'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  /// Festival 객체를 JSON으로 변환 (Convert Festival to JSON)
  Map<String, dynamic> toJson() {
    return {
      'region': region,
      'location': location,
      'name': name,
      'englishName': englishName,
      'month': month,
      'note': note,
      'category': category,
    };
  }

  /// 월 이름 반환 (Get month name in Korean)
  String get monthName {
    if (month == 0) return '연중';
    const monthNames = [
      '',
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ];
    return monthNames[month];
  }

  /// 검색어가 포함되어 있는지 확인 (Check if search query is contained)
  ///
  /// name, englishName, location, region, note, category 필드에서
  /// 검색어를 찾습니다.
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        englishName.toLowerCase().contains(lowerQuery) ||
        location.toLowerCase().contains(lowerQuery) ||
        region.toLowerCase().contains(lowerQuery) ||
        note.toLowerCase().contains(lowerQuery) ||
        category.toLowerCase().contains(lowerQuery);
  }

  /// 어떤 필드에서 매칭되었는지 반환 (Returns which field matched)
  List<String> getMatchedFields(String query) {
    final lowerQuery = query.toLowerCase();
    final matchedFields = <String>[];

    if (name.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('name');
    }
    if (englishName.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('englishName');
    }
    if (location.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('location');
    }
    if (region.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('region');
    }
    if (note.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('note');
    }
    if (category.toLowerCase().contains(lowerQuery)) {
      matchedFields.add('category');
    }

    return matchedFields;
  }
}
