/// Info 게시글 모델
///
/// v7 `info.getByAccessCode` API 응답을 매핑하는 데이터 클래스.
/// sf_post_data 테이블의 커스텀 필드를 의미 있는 이름으로 접근한다.
class InfoPost {
  final int idx;
  final String name;
  final String englishName;
  final String title;
  final String content;
  final String description;
  final String accessCode;
  final String category;
  final String subCategory;
  final String region;
  final String city;
  final String address;
  final String phone;
  final String phone2;
  final String email;
  final String websiteUrl;
  final String hours;
  final String imageUrl;
  final String fee;
  final String tags;

  /// texts (text_1 JSON) — 각 항목은 기관/장소 정보 Map 또는 마크다운 문자열
  final List<dynamic> texts;

  final int noOfView;
  final int good;
  final int stamp;

  const InfoPost({
    required this.idx,
    required this.name,
    this.englishName = '',
    this.title = '',
    this.content = '',
    this.description = '',
    this.accessCode = '',
    this.category = '',
    this.subCategory = '',
    this.region = '',
    this.city = '',
    this.address = '',
    this.phone = '',
    this.phone2 = '',
    this.email = '',
    this.websiteUrl = '',
    this.hours = '',
    this.imageUrl = '',
    this.fee = '',
    this.tags = '',
    this.texts = const [],
    this.noOfView = 0,
    this.good = 0,
    this.stamp = 0,
  });

  factory InfoPost.fromJson(Map<String, dynamic> json) {
    return InfoPost(
      idx: json['idx'] ?? 0,
      name: json['name'] ?? json['subject'] ?? '',
      englishName: json['english_name'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      description: json['description'] ?? '',
      accessCode: json['access_code'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['sub_category'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      phone2: json['phone2'] ?? '',
      email: json['email'] ?? '',
      websiteUrl: json['website_url'] ?? json['link'] ?? '',
      hours: json['hours'] ?? '',
      imageUrl: json['image_url'] ?? '',
      fee: json['fee'] ?? '',
      tags: json['tags'] ?? '',
      texts: (json['texts'] is List) ? json['texts'] : [],
      noOfView: json['no_of_view'] ?? 0,
      good: json['good'] ?? 0,
      stamp: json['stamp'] ?? 0,
    );
  }
}

/// texts 배열의 각 항목을 표현하는 모델
///
/// texts 항목이 Map(기관/장소 정보)인 경우 필드를 파싱한다.
class InfoTextItem {
  final String name;
  final String englishName;
  final String icon;
  final String badge;
  final String phone;
  final String phone2;
  final String fax;
  final String email;
  final String address;
  final String hours;
  final String detail;
  final String city;
  final String websiteUrl;
  final String description;
  final String tags;
  final String services;

  const InfoTextItem({
    this.name = '',
    this.englishName = '',
    this.icon = '',
    this.badge = '',
    this.phone = '',
    this.phone2 = '',
    this.fax = '',
    this.email = '',
    this.address = '',
    this.hours = '',
    this.detail = '',
    this.city = '',
    this.websiteUrl = '',
    this.description = '',
    this.tags = '',
    this.services = '',
  });

  factory InfoTextItem.fromMap(Map<String, dynamic> map) {
    return InfoTextItem(
      name: _str(map['name']),
      englishName: _str(map['english_name']),
      icon: _str(map['icon']),
      badge: _str(map['badge']),
      phone: _str(map['phone']),
      phone2: _str(map['phone2']),
      fax: _str(map['fax']),
      email: _str(map['email']),
      address: _str(map['address']),
      hours: _str(map['hours']),
      detail: _str(map['detail']),
      city: _str(map['city']),
      websiteUrl: _str(map['website']).isNotEmpty ? _str(map['website']) : _str(map['website_url']),
      description: _str(map['description']),
      tags: _str(map['tags']),
      services: _str(map['services']),
    );
  }

  static String _str(dynamic value) => value?.toString() ?? '';

  bool get hasContactInfo =>
      address.isNotEmpty ||
      phone.isNotEmpty ||
      email.isNotEmpty ||
      hours.isNotEmpty ||
      websiteUrl.isNotEmpty;
}
