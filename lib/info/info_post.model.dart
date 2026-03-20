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
  final List<String> texts;
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
    // texts 필드 파싱 (문자열 배열 또는 null)
    List<String> parseTexts(dynamic value) {
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

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
      texts: parseTexts(json['texts']),
      noOfView: json['no_of_view'] ?? 0,
      good: json['good'] ?? 0,
      stamp: json['stamp'] ?? 0,
    );
  }
}
