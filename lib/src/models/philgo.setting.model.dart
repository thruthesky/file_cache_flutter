import 'dart:convert';

/// 개별 은행 계좌 정보 모델
///
/// API 응답에서 각 은행(kb, bdo 등)의 계좌 정보를 담는 엔티티
class BankAccount {
  /// 은행 이름 (예: "국민은행", "BDO")
  final String name;

  /// 계좌 번호
  final String accountNo;

  /// 예금주 이름
  final String accountName;

  BankAccount({
    required this.name,
    required this.accountNo,
    required this.accountName,
  });

  /// JSON Map으로부터 BankAccount 객체 생성
  factory BankAccount.fromJson(Map<dynamic, dynamic> json) {
    return BankAccount(
      name: json['name'] ?? '',
      accountNo: json['account_no'] ?? '',
      accountName: json['account_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'account_no': accountNo,
      'account_name': accountName,
    };
  }

  @override
  String toString() {
    return 'BankAccount(name: $name, accountNo: $accountNo, accountName: $accountName)';
  }
}

/// 은행 정보 컬렉션 모델
///
/// API 응답의 bank_info 필드를 파싱하여 은행별 계좌 정보를 Map으로 관리
class PhilgoSettingBankInfo {
  /// 은행 코드(kb, bdo 등)를 키로 하는 계좌 정보 Map
  final Map<String, BankAccount> banks;

  PhilgoSettingBankInfo(this.banks);

  /// JSON Map으로부터 PhilgoSettingBankInfo 객체 생성
  factory PhilgoSettingBankInfo.fromJson(Map<dynamic, dynamic> json) {
    final Map<String, BankAccount> banksMap = {};
    json.forEach((key, value) {
      if (value is Map) {
        banksMap[key.toString()] = BankAccount.fromJson(value);
      }
    });
    return PhilgoSettingBankInfo(banksMap);
  }

  /// 특정 은행 코드로 계좌 정보 조회
  BankAccount? getBank(String code) => banks[code];

  /// 국민은행 계좌 정보 (편의 getter)
  BankAccount? get kb => banks['kb'];

  /// BDO 계좌 정보 (편의 getter)
  BankAccount? get bdo => banks['bdo'];

  Map<String, dynamic> toJson() {
    return banks.map((key, value) => MapEntry(key, value.toJson()));
  }

  @override
  String toString() {
    return 'PhilgoSettingBankInfo($banks)';
  }
}

/// 포인트 설정 모델
///
/// API 응답의 point 필드를 파싱하여 광고 관련 설정 정보를 관리
class PhilgoSettingPoint {
  /// 광고 게시물 카테고리 목록
  final List<String> advertisingPostCategories;

  /// 광고 가능 일수 목록 (예: [3, 5, 7, 10, 15, 30, 60, 90, 180, 365])
  final List<int> advertisementDays;

  /// 시간당 광고 비용 (포인트)
  final int advCostPerHour;

  PhilgoSettingPoint({
    required this.advertisingPostCategories,
    required this.advertisementDays,
    required this.advCostPerHour,
  });

  /// JSON Map으로부터 PhilgoSettingPoint 객체 생성
  factory PhilgoSettingPoint.fromJson(Map<dynamic, dynamic> json) {
    return PhilgoSettingPoint(
      advertisingPostCategories: List<String>.from(
        json['advertising_post_categories'] ?? [],
      ),
      advertisementDays: List<int>.from(
        json['advertisement_days'] ?? [],
      ),
      advCostPerHour: json['adv_cost_per_hour'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'advertising_post_categories': advertisingPostCategories,
      'advertisement_days': advertisementDays,
      'adv_cost_per_hour': advCostPerHour,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

/// PhilGo 설정 메인 모델
///
/// API의 설정 응답을 파싱하여 은행 정보, 포인트 설정, 관리자 목록을 관리
class PhilgoSetting {
  /// 은행 정보 (kb, bdo 등 은행별 계좌 정보)
  final PhilgoSettingBankInfo bankInfo;

  /// 포인트 설정 (광고 카테고리, 광고 일수, 시간당 비용 등)
  final PhilgoSettingPoint point;

  /// 관리자 UID 목록 (Admin user UIDs)
  /// 이 목록에 포함된 사용자는 관리자로 간주되어 글쓰기/댓글 작성이 제한됨
  final List<String> adminUids;

  PhilgoSetting({
    required this.bankInfo,
    required this.point,
    required this.adminUids,
  });

  /// JSON Map으로부터 PhilgoSetting 객체 생성
  factory PhilgoSetting.fromJson(Map<dynamic, dynamic> json) {
    return PhilgoSetting(
      bankInfo: PhilgoSettingBankInfo.fromJson(
        json['bank_info'] ?? {},
      ),
      point: PhilgoSettingPoint.fromJson(
        json['point'] ?? {},
      ),
      adminUids: List<String>.from(json['admin_uids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_info': bankInfo.toJson(),
      'point': point.toJson(),
      'admin_uids': adminUids,
    };
  }

  @override
  String toString() {
    return 'PhilgoSetting(${jsonEncode(toJson())})';
  }
}
