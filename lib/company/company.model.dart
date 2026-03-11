import 'package:philgo/api/api.service.dart';

/// 업소록 데이터 모델
///
/// v7 API `company.*` 엔드포인트의 응답 데이터를 담는 모델 클래스.
///
/// 상태(status) 코드:
/// - `''`  : 신규 (처음 생성)
/// - `'p'` : 심사중 (관리자 검토 대기)
/// - `'a'` : 승인됨
class CompanyModel {
  final int idx;
  final int idxMember;
  final String name;
  final String title;
  final String description;
  final String category;
  final String location;
  final String address;
  final String phoneNumber;
  final String mobileNumber;
  final String kakaotalkId;
  final String telegramId;
  final String logoUrl;
  final String photoUrl;
  final String titleImageUrl;
  final String status;
  final int showQrCode;

  const CompanyModel({
    required this.idx,
    required this.idxMember,
    required this.name,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.address,
    required this.phoneNumber,
    required this.mobileNumber,
    required this.kakaotalkId,
    required this.telegramId,
    required this.logoUrl,
    required this.photoUrl,
    required this.titleImageUrl,
    required this.status,
    required this.showQrCode,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      idx: ApiService.toInt(json['idx']),
      idxMember: ApiService.toInt(json['idx_member']),
      name: (json['name'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      phoneNumber: (json['phone_number'] as String?) ?? '',
      mobileNumber: (json['mobile_number'] as String?) ?? '',
      kakaotalkId: (json['kakaotalk_id'] as String?) ?? '',
      telegramId: (json['telegram_id'] as String?) ?? '',
      logoUrl: (json['logo_url'] as String?) ?? '',
      photoUrl: (json['photo_url'] as String?) ?? '',
      titleImageUrl: (json['title_image_url'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      showQrCode: ApiService.toInt(json['show_qr_code']),
    );
  }

  /// 대표 이미지 URL
  ///
  /// title_image_url → photo_url → logo_url 순서로 반환하며,
  /// 모두 비어 있으면 빈 문자열을 반환한다.
  String get primaryImageUrl {
    if (titleImageUrl.isNotEmpty) return titleImageUrl;
    if (photoUrl.isNotEmpty) return photoUrl;
    if (logoUrl.isNotEmpty) return logoUrl;
    return '';
  }

  /// QR 코드 활성화 여부
  bool get qrCodeEnabled => status == 'a' && showQrCode == 1;
}
