class Company {
  final int idx;
  final int idx_member;
  final String name;
  final String title;
  final String description;
  final String category;
  final String location;
  final String address;
  final int created_at;
  final int updated_at;
  final String phone_number;
  final String mobile_number;
  final String mobile_number_call_type;
  final String kakaotalk_id;
  final String kakaotalk_qr_code_url;
  final String kakaotalk_qr_code;
  final String telegram_id;
  final String status;
  final String logo_url;
  final String business_license_url;
  final String photo_url;
  final String title_image_url;
  final String family_site_domain;
  final String family_site_custom_domain;
  final String family_site_name;
  final String family_site_description;
  final String family_site_logo_url;
  final String ad_title;
  final String ad_description;
  final int ad_begin_date;
  final int ad_end_date;
  final String ad_click_url;

  /// Whether the QR code is enabled/approved by admin for this company.
  /// Returned by the get_company API as `qr_code_enabled`.
  /// When true, the QR code button is visible to all users on the company view screen.
  final bool qr_code_enabled;

  Company({
    required this.idx,
    required this.idx_member,
    required this.name,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.address,
    required this.created_at,
    required this.updated_at,
    required this.phone_number,
    required this.mobile_number,
    required this.mobile_number_call_type,
    required this.kakaotalk_id,
    required this.kakaotalk_qr_code_url,
    required this.kakaotalk_qr_code,
    required this.telegram_id,
    required this.status,
    required this.logo_url,
    required this.business_license_url,
    required this.photo_url,
    required this.title_image_url,
    required this.family_site_domain,
    required this.family_site_custom_domain,
    required this.family_site_name,
    required this.family_site_description,
    required this.family_site_logo_url,
    required this.ad_title,
    required this.ad_description,
    required this.ad_begin_date,
    required this.ad_end_date,
    required this.ad_click_url,
    required this.qr_code_enabled,
  });

  /// Create Company instance from JSON map
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      idx: json['idx'] as int? ?? 0,
      idx_member: json['idx_member'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      location: json['location'] as String? ?? '',
      address: json['address'] as String? ?? '',
      created_at: json['created_at'] as int? ?? 0,
      updated_at: json['updated_at'] as int? ?? 0,
      phone_number: json['phone_number'] as String? ?? '',
      mobile_number: json['mobile_number'] as String? ?? '',
      mobile_number_call_type: json['mobile_number_call_type'] as String? ?? '',
      kakaotalk_id: json['kakaotalk_id'] as String? ?? '',
      kakaotalk_qr_code_url: json['kakaotalk_qr_code_url'] as String? ?? '',
      kakaotalk_qr_code: json['kakaotalk_qr_code'] as String? ?? '',
      telegram_id: json['telegram_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      logo_url: json['logo_url'] as String? ?? '',
      business_license_url: json['business_license_url'] as String? ?? '',
      photo_url: json['photo_url'] as String? ?? '',
      title_image_url: json['title_image_url'] as String? ?? '',
      family_site_domain: json['family_site_domain'] as String? ?? '',
      family_site_custom_domain:
          json['family_site_custom_domain'] as String? ?? '',
      family_site_name: json['family_site_name'] as String? ?? '',
      family_site_description: json['family_site_description'] as String? ?? '',
      family_site_logo_url: json['family_site_logo_url'] as String? ?? '',
      ad_title: json['ad_title'] as String? ?? '',
      ad_description: json['ad_description'] as String? ?? '',
      ad_begin_date: json['ad_begin_date'] as int? ?? 0,
      ad_end_date: json['ad_end_date'] as int? ?? 0,
      ad_click_url: json['ad_click_url'] as String? ?? '',
      /// API returns `show_qr_code` as int (1 = enabled, 0 = disabled)
      qr_code_enabled: json['show_qr_code'] == 1 || json['show_qr_code'] == true,
    );
  }

  /// Convert Company instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'idx_member': idx_member,
      'name': name,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'address': address,
      'created_at': created_at,
      'updated_at': updated_at,
      'phone_number': phone_number,
      'mobile_number': mobile_number,
      'mobile_number_call_type': mobile_number_call_type,
      'kakaotalk_id': kakaotalk_id,
      'kakaotalk_qr_code_url': kakaotalk_qr_code_url,
      'kakaotalk_qr_code': kakaotalk_qr_code,
      'telegram_id': telegram_id,
      'status': status,
      'logo_url': logo_url,
      'business_license_url': business_license_url,
      'photo_url': photo_url,
      'title_image_url': title_image_url,
      'family_site_domain': family_site_domain,
      'family_site_custom_domain': family_site_custom_domain,
      'family_site_name': family_site_name,
      'family_site_description': family_site_description,
      'family_site_logo_url': family_site_logo_url,
      'ad_title': ad_title,
      'ad_description': ad_description,
      'ad_begin_date': ad_begin_date,
      'ad_end_date': ad_end_date,
      'ad_click_url': ad_click_url,
      'qr_code_enabled': qr_code_enabled,
    };
  }

  /// Create a copy of Company with modified fields
  Company copyWith({
    int? idx,
    int? idx_member,
    String? name,
    String? title,
    String? description,
    String? category,
    String? location,
    String? address,
    int? created_at,
    int? updated_at,
    String? phone_number,
    String? mobile_number,
    String? mobile_number_call_type,
    String? kakaotalk_id,
    String? kakaotalk_qr_code_url,
    String? kakaotalk_qr_code,
    String? telegram_id,
    String? status,
    String? logo_url,
    String? business_license_url,
    String? photo_url,
    String? title_image_url,
    String? family_site_domain,
    String? family_site_custom_domain,
    String? family_site_name,
    String? family_site_description,
    String? family_site_logo_url,
    String? ad_title,
    String? ad_description,
    int? ad_begin_date,
    int? ad_end_date,
    String? ad_click_url,
    bool? qr_code_enabled,
  }) {
    return Company(
      idx: idx ?? this.idx,
      idx_member: idx_member ?? this.idx_member,
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      address: address ?? this.address,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
      phone_number: phone_number ?? this.phone_number,
      mobile_number: mobile_number ?? this.mobile_number,
      mobile_number_call_type:
          mobile_number_call_type ?? this.mobile_number_call_type,
      kakaotalk_id: kakaotalk_id ?? this.kakaotalk_id,
      kakaotalk_qr_code_url:
          kakaotalk_qr_code_url ?? this.kakaotalk_qr_code_url,
      kakaotalk_qr_code: kakaotalk_qr_code ?? this.kakaotalk_qr_code,
      telegram_id: telegram_id ?? this.telegram_id,
      status: status ?? this.status,
      logo_url: logo_url ?? this.logo_url,
      business_license_url: business_license_url ?? this.business_license_url,
      photo_url: photo_url ?? this.photo_url,
      title_image_url: title_image_url ?? this.title_image_url,
      family_site_domain: family_site_domain ?? this.family_site_domain,
      family_site_custom_domain:
          family_site_custom_domain ?? this.family_site_custom_domain,
      family_site_name: family_site_name ?? this.family_site_name,
      family_site_description:
          family_site_description ?? this.family_site_description,
      family_site_logo_url: family_site_logo_url ?? this.family_site_logo_url,
      ad_title: ad_title ?? this.ad_title,
      ad_description: ad_description ?? this.ad_description,
      ad_begin_date: ad_begin_date ?? this.ad_begin_date,
      ad_end_date: ad_end_date ?? this.ad_end_date,
      ad_click_url: ad_click_url ?? this.ad_click_url,
      qr_code_enabled: qr_code_enabled ?? this.qr_code_enabled,
    );
  }

  @override
  String toString() {
    return 'Company(idx: $idx, name: $name, title: $title, category: $category, status: $status, qr_code_enabled: $qr_code_enabled)';
  }
}
