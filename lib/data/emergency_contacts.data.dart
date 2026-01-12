import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/data/models/contact_item.model.dart';

/// 필리핀 긴급 연락처 데이터 (Philippines Emergency Contacts Data)
///
/// 긴급 번호, 대사관, 한인회, 경찰서, 병원, 기타 기관 연락처를 포함합니다.
/// Includes emergency numbers, embassy, Korean associations,
/// police stations, hospitals, and other agencies.
class EmergencyContactsData {
  EmergencyContactsData._();

  /// 필리핀 긴급 번호 (Philippine Emergency Numbers)
  static const List<ContactItem> emergencyNumbers = [
    ContactItem(
      icon: FontAwesomeIcons.lightPhoneVolume,
      name: '긴급 핫라인 (National Emergency)',
      phones: ['911'],
      description: '경찰, 소방, 앰뷸런스 통합',
      isEmergency: true,
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShieldHalved,
      name: '필리핀 국립경찰 (PNP)',
      phones: ['117', '(02) 8722-0650', '0917-847-5757'],
      description: 'Text hotline: 0917-847-5757',
      isEmergency: true,
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightFireExtinguisher,
      name: '필리핀 소방청 (BFP)',
      phones: ['116', '(02) 8426-0219', '(02) 8426-0246'],
      isEmergency: true,
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightTruckMedical,
      name: '앰뷸런스',
      phones: ['911', '112'],
      isEmergency: true,
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightKitMedical,
      name: '필리핀 적십자 (Red Cross)',
      phones: ['143'],
      isEmergency: true,
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightTrafficLight,
      name: '메트로마닐라개발청 (MMDA)',
      phones: ['136'],
      description: '교통사고, 도로 긴급상황',
    ),
  ];

  /// 대한민국 공관 (Korean Embassy/Consulate)
  static const List<ContactItem> koreanEmbassy = [
    ContactItem(
      icon: FontAwesomeIcons.lightHeadset,
      name: '외교부 영사 콜센터 (24시간)',
      phones: ['00800-2100-0404', '+82-2-3210-0404'],
      description: '해외에서: 00800-2100-0404 (무료)\n유료: +82-2-3210-0404',
      isEmergency: true,
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightLandmarkFlag,
      name: '주필리핀 대한민국 대사관',
      phones: ['+63-2-8856-9210', '+63-917-817-5703'],
      description:
          '대표전화 (근무시간)\n긴급당직번호: +63-917-817-5703\nFAX: +63-2-8856-9008, 9019\n경찰 긴급전화: 117, 166(세부, 보라카이, 바기오 등)',
      address:
          '122 Upper McKinley Road, McKinley Town Center,\nFort Bonifacio, Taguig City 1634, Philippines',
      email: 'philippines@mofa.go.kr',
      website: 'http://overseas.mofa.go.kr/ph-ko/index.do',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightBuilding,
      name: '주세부 대한민국 분관',
      phones: ['+63-32-231-1516', '+63-917-808-3907'],
      description: '대표전화 (근무시간)\n긴급당직 (근무시간 외)',
      address:
          '12th Floor Chinabank Corporate Center,\nCebu Business Park, Mabolo, Cebu City',
      email: 'phi_cebu2015@mofa.go.kr',
      website: 'http://overseas.mofa.go.kr/ph-cebu-ko/index.do',
    ),
  ];

  /// 한인회 연락처 (Korean Association)
  ///
  /// 필리핀한인총연합회(UKCA)는 전국 단위 연합회로
  /// 각 지역 한인회·교민 단체를 아우르는 역할을 합니다.
  /// UKCA (United Korean Community Association) is a nationwide federation
  /// that encompasses regional Korean associations and expatriate organizations.
  static const List<ContactItem> koreanAssociation = [
    /// 필리핀한인총연합회 (UKCA - United Korean Community Association)
    /// 전국 단위 연합회로 교민 공지, 커뮤니티 정보 제공, 각종 공공사업/행사 지원
    ContactItem(
      icon: FontAwesomeIcons.lightPeopleGroup,
      name: '필리핀한인총연합회 (UKCA)',
      phones: ['+63-2-8886-4848', '+63-917-886-4848'],
      description:
          '필리핀 내 여러 지역 한인회·교민 단체를 아우르는 전국 단위 연합회\n'
          '교민 공지, 커뮤니티 정보 제공, 각종 공공사업/행사 등 지원\n'
          '긴급연락: +63-917-886-4848',
      address:
          'Suite 1104 Antel 2000 Corporate Center,\n121 Valero St., Salcedo Village, Makati City',
      email: 'ukca@korea.com.ph',
      isEmergency: true,
    ),

    /// 세부 한인회 (Cebu Korean Association - CKA)
    /// 코로나 시기 귀국 지원, 세부 지역 경제·투자 관련 대외 협력 등 활동
    ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '세부 한인회 (CKA)',
      phones: ['+63-32-505-5761'],
      description: '세부 지역 한인 커뮤니티 지원\n귀국 지원, 경제·투자 관련 대외 협력 등',
      address: '2/F, AMON Building, Salinas Drive,\nLahug, Cebu City 6000',
      email: 'cebukoreanassociation@gmail.com',
    ),

    /// 중부루손한인회 (Korean Community Association of Central Luzon - KCACL)
    /// 한비(Hanbi) 문화행사, 앙헬레스 Korean Help Desk 설치(치안·신고·안전가이드 지원)
    ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '중부루손한인회 (KCACL)',
      phones: ['+63-45-598-0571', '0917-893-1355'],
      description: '클락·앙헬레스·팜팡가 지역\n'
          '한비(Hanbi) 문화행사 및 한인 커뮤니티 결집\n'
          'Korean Help Desk 운영 (치안·신고·안전가이드 지원)',
    ),

    /// 남부(알라방) 한인회
    ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '남부(알라방) 한인회',
      phones: ['+63-2-7945-0221'],
      description: '알라방·문틴루파 지역 한인 커뮤니티 지원',
    ),

    /// 바기오 한인회 (북부 루손)
    /// 바기오 경찰(BCPO)과 한인 안전·복지 협력(MOA) 체결
    ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '바기오 한인회',
      phones: ['+63-74-423-2099'],
      description: '북부 루손(바기오) 지역\n'
          '바기오 경찰(BCPO)과 한인 안전·복지 협력(MOA) 체결',
    ),

    /// 다바오 한인회 (Davao Korean Association)
    /// Facebook 기반 소식/공지 운영
    ContactItem(
      icon: FontAwesomeIcons.lightUsers,
      name: '다바오 한인회',
      phones: ['+63-82-295-6006', '0906-310-0409'],
      description: 'Facebook 기반 소식/공지 운영\n카카오톡: pf.kakao.com/_xexczrM',
      address:
          '2nd Floor ABC Bldg., Door 1 Acacia St.\n(Fronting STI College) J.P. Laurel Ave.,\nDavao City 8000',
    ),

    /// 한인파출소
    ContactItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      name: '한인파출소',
      phones: ['0915-242-3926'],
      description: '한인 치안 지원',
    ),
  ];

  /// 경찰서 (Police Stations)
  static const List<ContactItem> policeStations = [
    ContactItem(
      icon: FontAwesomeIcons.lightBuildingShield,
      name: '메트로마닐라 수도경찰청',
      phones: ['+63-2-8838-0251'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Manila City 경찰청',
      phones: ['+63-2-8523-5611'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Makati City 경찰서',
      phones: ['+63-2-8843-7971', '+63-2-8887-6642'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Quezon City 경찰청',
      phones: ['+63-2-8925-8417'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Pasay City 경찰서',
      phones: ['+63-2-8831-1359'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Cebu City 경찰서',
      phones: ['+63-32-256-0116'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Davao City 경찰서',
      phones: ['+63-82-224-1313'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Angeles City 경찰서',
      phones: ['+63-908-377-0144'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightShield,
      name: 'Baguio City 경찰서',
      phones: ['+63-74-442-7944'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHandcuffs,
      name: '납치전담 (Anti-Kidnapping)',
      phones: ['+63-2-8724-7378'],
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightCarBurst,
      name: '차량강도 (Highway Patrol)',
      phones: ['+63-2-8723-0401'],
      description: '내선 5379',
    ),
  ];

  /// 병원 (Hospitals)
  static const List<ContactItem> hospitals = [
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Makati Medical Center',
      phones: ['+63-2-8888-8999'],
      address: 'Makati City',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: "St. Luke's Global Hospital",
      phones: ['+63-2-8789-7700'],
      address: 'Fort Bonifacio, Taguig',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Manila Doctors Hospital',
      phones: ['+63-2-8558-0888'],
      address: 'Manila',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Asian Hospital',
      phones: ['+63-2-8771-9000'],
      address: 'Alabang',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Phil. Korean Friendship Hospital',
      phones: ['+63-46-419-1465', '+63-46-419-1714'],
      address: 'Cavite',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Chong Hwa Hospital',
      phones: ['+63-32-253-9409'],
      address: 'Cebu',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: "Davao Doctor's Hospital",
      phones: ['+63-82-222-8000'],
      address: 'Davao',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Baguio General Hospital',
      phones: ['+63-74-442-6230'],
      address: 'Baguio',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHospital,
      name: 'Angeles Medical Center',
      phones: ['+63-45-887-3139'],
      address: 'Angeles City',
    ),
  ];

  /// 기타 기관 (Other Agencies)
  static const List<ContactItem> otherAgencies = [
    ContactItem(
      icon: FontAwesomeIcons.lightPassport,
      name: '필리핀 이민국 (BI)',
      phones: ['(02) 8524-3769', '(02) 8465-2400'],
      description: '비자 연장, 출입국 관련',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightCloudSunRain,
      name: '필리핀 기상청 (PAGASA)',
      phones: ['(02) 8284-0800'],
      description: '태풍, 날씨 정보',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightVolcano,
      name: '화산지진연구소 (PHILVOCS)',
      phones: ['(02) 8426-1468'],
      description: '지진, 화산 정보',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightHouseFloodWater,
      name: '재해위기관리위원회 (NDRRMC)',
      phones: ['(02) 8421-1918', '(02) 8913-2786'],
      description: '자연재해, 재난 대응',
    ),
    ContactItem(
      icon: FontAwesomeIcons.lightCarSide,
      name: '필리핀 교통부 (DOTr)',
      phones: ['7890', '(02) 8790-8300'],
      description: '교통 관련 문의',
    ),
  ];
}
