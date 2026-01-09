import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 정보 아이템 데이터 클래스 (Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _InfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 중고차 가격 정보 데이터 클래스 (Used Car Price Data Class)
///
/// 모델별 중고차 가격 정보를 담습니다.
/// Contains price information for each used car model.
class _CarPriceItem {
  /// 모델명 (Model name)
  final String model;

  /// 브랜드 (Brand)
  final String brand;

  /// 차종 (Vehicle type)
  final String type;

  /// 가격대 (Price range)
  final String price;

  const _CarPriceItem({
    required this.model,
    required this.brand,
    required this.type,
    required this.price,
  });
}

/// 단계별 가이드 데이터 클래스 (Step Guide Data Class)
///
/// 명의 이전 절차 등 단계별 안내를 담습니다.
/// Contains step-by-step guide information.
class _StepItem {
  /// 단계 번호 (Step number)
  final int step;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
  });
}

/// 자동차 구매 정보 화면 (Car Purchase Screen)
///
/// 필리핀 중고 자동차 구매 가이드를 제공합니다.
/// Provides a comprehensive guide for buying used cars in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// CarPurchaseScreen.push(context);
/// ```
class CarPurchaseScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/CarPurchase';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CarPurchaseScreen({super.key});

  @override
  State<CarPurchaseScreen> createState() => _CarPurchaseScreenState();
}

class _CarPurchaseScreenState extends State<CarPurchaseScreen> {
  /// 중고차 가격 정보 (Used car price information)
  static const List<_CarPriceItem> _carPrices = [
    _CarPriceItem(
      model: '비오스 (Vios)',
      brand: '토요타',
      type: '소형 세단',
      price: '₱300,000 ~ ₱600,000',
    ),
    _CarPriceItem(
      model: '인노바 (Innova)',
      brand: '토요타',
      type: 'MPV (7인승)',
      price: '₱500,000 ~ ₱800,000',
    ),
    _CarPriceItem(
      model: '포츄너 (Fortuner)',
      brand: '토요타',
      type: '중형 SUV',
      price: '₱800,000 ~ ₱1,200,000',
    ),
    _CarPriceItem(
      model: '몬테로스포츠',
      brand: '미쓰비시',
      type: '중형 SUV',
      price: '₱700,000 ~ ₱1,100,000',
    ),
    _CarPriceItem(
      model: '시티 (City)',
      brand: '혼다',
      type: '소형 세단',
      price: '₱300,000 ~ ₱500,000',
    ),
    _CarPriceItem(
      model: '스타렉스',
      brand: '현대',
      type: '승합/밴',
      price: '₱500,000 ~ ₱1,000,000',
    ),
  ];

  /// 중고차 구입 경로 정보 (Purchase channel information)
  static const List<_InfoItem> _purchaseChannels = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '딜러십 매장 이용',
      description:
          '차량 매물을 다양하게 보유하고 서류 이전 등 절차를 대행해주는 경우가 많아 초보자도 비교적 안심하고 구매할 수 있습니다. 다만 개인 거래보다 가격이 조금 높게 책정되는 경향이 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMobileScreen,
      title: '페이스북 마켓플레이스',
      description:
          '필리핀 중고차 거래의 중심 플랫폼입니다. 하지만 사고 차량이나 침수 이력 은폐, 실제 소유주가 아닌 브로커, 서류 미비 차량, 광고와 실제 상태 불일치 등 위험 요소가 많으므로 각별한 주의가 필요합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightPeopleGroup,
      title: '한인 커뮤니티 활용',
      description:
          '필고 장터 등 한인 커뮤니티에서 신뢰할 만한 중고차 매물이나 구매 대행 서비스가 공유됩니다. 언어 장벽을 낮추고 비교적 안전하게 거래할 수 있으니 활용을 고려해보세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightStore,
      title: '오프라인 중고차 매장',
      description:
          '마닐라의 Carland Auto Exchange(파사이 소재) 등이 대표적입니다. 토요타·미쓰비시 등 메이커의 인증 중고차 프로그램도 있습니다. 다만 매장이라고 무조건 안전한 것은 아니므로 동일한 점검이 필요합니다.',
    ),
  ];

  /// 주의해야 할 판매자 유형 (Seller types to watch out)
  static const List<_InfoItem> _sellerWarnings = [
    _InfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '"급매 - 싸게 팝니다" 주의',
      description: '이런 광고 문구는 일단 의심하는 것이 안전합니다. 지나치게 싼 가격은 문제가 있을 가능성이 높습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBan,
      title: '시운전 거부하는 판매자',
      description: '"바쁘다", "연료 없다"는 이유로 시운전을 피하면 구매하지 마세요. 숨기고 싶은 문제가 있을 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFileCircleXmark,
      title: '"서류는 나중에"라고 하는 판매자',
      description:
          '명의이전 비용을 별도로 요구하거나 OR/CR 원본을 나중에 준다고 하면 문제가 없는지 면밀히 확인해야 합니다.',
    ),
  ];

  /// 차량 상태 점검 체크리스트 (Vehicle inspection checklist)
  static const List<_InfoItem> _inspectionChecklist = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCarSide,
      title: '외관 및 사고 흔적',
      description:
          '차체 패널 간 단차나 도색 상태를 살펴 사고 수리 이력을 추정합니다. 문 단차가 크거나 페인트 색상이 미세하게 다르면 사고 후 수리차량일 수 있습니다. 패널 정렬 불량이나 용접자국도 확인하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightWater,
      title: '침수 차량 여부',
      description:
          '필리핀은 침수 피해가 잦기 때문에 침수 이력 차량은 반드시 걸러야 합니다. 실내 바닥이나 시트 아래 프레임의 녹, 안전벨트 끝부분 흙탕물 자국, 곰팡이 냄새를 확인하세요. 침수차는 시간이 지나면 전기계통 등의 고장이 계속 발생합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRoad,
      title: '시운전 필수',
      description:
          '시운전은 선택이 아니라 필수입니다. 엔진 시동 소리가 규칙적인지, 가속 시 이상한 진동이나 소음이 없는지, 자동변속 충격은 없는지 확인합니다. 브레이크 제동 시 한쪽으로 쏠림이 없는지, 핸들이 떨리지 않는지도 중요합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightEngine,
      title: '엔진 상태 점검',
      description:
          '보닛을 열고 엔진오일 캡과 게이지를 확인합니다. 오일에 물기가 섞였거나 슬러지가 심하면 엔진 내부 문제를 의심해야 합니다. 냉각수 탱크의 물색, 배터리 단자 부식 여부도 함께 점검하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCarTunnel,
      title: '하부 및 기타',
      description:
          '차 아래를 들여다봐 오일이나 냉각수 누유가 있는지, 머플러나 서스펜션 부품에 심한 녹이나 파손이 없는지 살핍니다. 타이어 마모 상태도 점검하여 추가 교체비용 여부를 예측하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightScrewdriverWrench,
      title: '전문 정비업체 점검',
      description:
          '차량 인수 전 공식 서비스센터나 신뢰할 만한 정비소의 점검 서비스를 받아보는 것이 가장 확실합니다. 1~2천 페소(약 2~4만원) 정도 비용으로 큰 문제를 미리 걸러낼 수 있습니다.',
    ),
  ];

  /// 서류 확인 사항 (Document verification)
  static const List<_InfoItem> _documentChecklist = [
    _InfoItem(
      icon: FontAwesomeIcons.lightFileContract,
      title: 'OR/CR 원본 확인',
      description:
          'OR(Official Receipt)과 CR(Certificate of Registration)은 LTO에서 발행한 차량 등록증과 등록 영수증입니다. 원본 OR/CR 서류가 없는 차량은 절대 구매하지 않습니다. 차대번호(VIN), 엔진번호가 차량 실물과 일치하는지 대조해야 합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUserCheck,
      title: '소유자 일치 여부',
      description:
          'CR상에 기재된 소유주가 누구인지 확인합니다. 판매자가 등록증상의 이름과 다를 경우, 정식 양도 위임장이나 공증된 위임 서류를 요구하여 법적 권한을 증명받아야 합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBuildingColumns,
      title: '차량 저당 상태 확인',
      description:
          'CR 상단이나 뒷면에 "ENCUMBERED"라고 표시된 차량은 금융기관에 저당권이 설정된 상태입니다. 이러한 차량을 구매할 때는 저당 해지 증명서(Cancellation of Chattel Mortgage)를 받아야 안전합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFileCircleQuestion,
      title: 'Open Deed of Sale 주의',
      description:
          '오픈 디드(Open DOS) 상태의 차량은 명의 이전이 완료되지 않은 중고차입니다. LTO 규정 위반이며 권장되지 않습니다. 최종 이전을 위해 등록증상 마지막 소유자의 협조가 반드시 필요해지므로 가능하면 피하는 것이 좋습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightReceipt,
      title: '벌금 및 과태료 확인',
      description:
          'LTO에 차량 번호로 조회하면 과태료나 "Alarm" 기록이 있는지 알 수 있습니다. 미납 벌금이 남아 있으면 새 소유주가 대신 납부해야 하는 상황이 생길 수 있으므로 사전에 확인하세요.',
    ),
  ];

  /// 구매 계약과 결제 정보 (Purchase contract and payment)
  static const List<_InfoItem> _purchaseContract = [
    _InfoItem(
      icon: FontAwesomeIcons.lightFileSignature,
      title: '계약서 작성 및 공증',
      description:
          '가격 합의 후 매매 계약서(Deed of Sale)를 작성합니다. 판매자와 구매자의 인적사항, 차량 정보(VIN, 엔진번호 등), 거래 금액을 기재하고 양측이 서명합니다. 공증인(Notary Public) 앞에서 서명을 하고 공증을 받는 것이 필수입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBillTransfer,
      title: '결제 방식',
      description:
          '일반적으로 계약서 공증 후 대금을 지급하는 것이 안전합니다. 현금으로 지불하거나 계좌이체로 대금을 치릅니다. 고액 현금 거래 시 범죄 위험이 있으므로 은행 내 거래나 캐셔 수표 사용도 고려됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightKey,
      title: '차량 및 서류 인도',
      description:
          '대금 지급과 동시에 차량 열쇠 및 관련 서류 일체(OR/CR 원본 등)를 인도받습니다. 거래 당일 판매자 본인 확인을 위해 신분증 2장에 서명한 사본을 받아두면 추후 명의이전 시 대비할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldHalved,
      title: '보험 및 임시운행 주의',
      description:
          '공식 등록 이전까지는 차량이 명의상 이전되지 않은 상태입니다. 기본 보험(TPL)이 유효한지 확인하고, 판매자 이름으로 발급된 차량 보험이 있다면 양도를 받거나 임시 보험에 가입하세요. 명의이전 전 사고가 나면 법적으로 복잡해집니다.',
    ),
  ];

  /// 명의 이전 절차 (Ownership transfer steps)
  static const List<_StepItem> _transferSteps = [
    _StepItem(
      step: 1,
      title: '준비 서류',
      description:
          '판매자: OR/CR 원본 및 복사본, 공증 완료된 Deed of Sale 원본, 신분증 사본 2부, 폴리스 클리어런스(지역에 따라 요구)\n\n구매자: 신분증 사본, ACR I-Card 또는 여권 비자면 사본(외국인), TIN(Tax Identification No.), 배기가스 검사 결과지, 새 보험 증권',
    ),
    _StepItem(
      step: 2,
      title: '차량 검사 및 보험',
      description:
          'LTO 인증 검사센터에서 배기가스 검사(Emission Test) 합격 증명서가 필요합니다. 제3자 책임보험(TPL) 가입 증서도 준비해야 합니다. 소형차 기준 약 ₱1,000 내외로 1년치 TPL 보험을 구매할 수 있습니다.',
    ),
    _StepItem(
      step: 3,
      title: 'LTO 방문 접수',
      description:
          '서류를 모두 갖추고 가까운 LTO 지국을 방문해 이전 등록 신청서를 작성합니다. 창구에 준비한 서류 일체를 제출하면 담당 직원이 검토하고 접수를 진행합니다.',
    ),
    _StepItem(
      step: 4,
      title: '수수료 납부',
      description:
          '차량 이전 등록 수수료는 일반적으로 ₱1,500~₱3,000 정도입니다. 연간 차량 등록세가 미납된 상태라면 해당 금액과 벌금을 추가로 납부해야 합니다.',
    ),
    _StepItem(
      step: 5,
      title: '신규 OR/CR 발급',
      description:
          '절차 완료 후 신규 소유자 명의의 OR/CR을 발급받습니다. 보통 임시 증명서를 먼저 주고, 정식 OR/CR은 1~2주 후에 찾으러 오라고 안내합니다. 이렇게 하면 법적으로 차량 소유자가 구매자로 완전히 변경됩니다.',
    ),
  ];

  /// 보험 및 차량 유지 정보 (Insurance and vehicle maintenance)
  static const List<_InfoItem> _insuranceMaintenance = [
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '종합 자동차보험 권장',
      description:
          '강제 책임보험(TPL)만으로는 사고 시 보상이 극히 제한적입니다. 종합보험은 대인·대물 배상, 자기차량 손해, 도난, 자연재해(홍수 등)까지 폭넓게 보장합니다. 차량 가치 ₱1,000,000인 승용차의 경우 연간 보험료가 약 ₱30,000~₱50,000선입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarDays,
      title: '연간 차량 등록 갱신',
      description:
          '연간 차량 등록 갱신 비용이 일종의 도로세 역할을 합니다. 일반 승용차의 경우 ₱2,000~₱4,000 정도입니다. 차량 번호판 끝자리 번호에 해당하는 달에 등록을 갱신해야 하며, 기간을 놓치면 벌금이 부과됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightGasPump,
      title: '유류비 및 유지비',
      description:
          '2025년 현재 휘발유 리터당 약 60페소, 경유 55페소 내외입니다. 정기 오일교환 등 소모품 교체 비용, 주차비 등도 고려해야 합니다. 콘도 거주 시 월 주차비가 별도로 들 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '고속도로 하이패스(RFID)',
      description:
          '필리핀 유료 고속도로는 남북으로 운영사가 달라 Autosweep(남부 SLEX 등)과 Easytrip(북부 NLEX 등) 두 종류의 RFID 스티커를 차량에 각각 부착해야 합니다. 톨게이트나 지정부스에서 OR/CR 사본과 운전자 신분증, 차량을 가져가면 현장에서 10~20분 내에 부착해줍니다.',
    ),
  ];

  /// 핵심 요약 포인트 (Key summary points)
  static const List<String> _keySummary = [
    '가격이 지나치게 싼 차량보다는 문제 없는 차량을 선택',
    '직접 눈으로 확인하고 시운전하며 전문가 점검 받기',
    'OR/CR 원본이 없는 차량은 절대 구매하지 않기',
    '계약서는 반드시 공증받고 동시에 차량과 서류 인도',
    '20일 이내에 LTO 명의 이전 등록 완료하기',
    '종합보험 가입으로 만일의 사태에 대비',
    'Acts of Nature 담보 추가로 침수 위험 대비',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightCarOn,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.carPurchase),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [히어로 배너 섹션 - Hero Banner Section]
            _buildHeroBanner(context),

            SizedBox(height: sp.s24),

            /// [주요 중고차 모델과 예산 섹션 - Popular Models Section]
            _buildSectionHeader(
              context,
              emoji: '🏷️',
              title: '주요 중고차 모델과 예산',
            ),
            SizedBox(height: sp.s12),
            _buildPopularModelsSection(context),
            SizedBox(height: sp.s12),
            _buildPriceTable(context),
            SizedBox(height: sp.s12),
            _buildPriceNote(context),

            SizedBox(height: sp.s24),

            /// [중고차 구입 경로 섹션 - Purchase Channel Section]
            _buildSectionHeader(
              context,
              emoji: '🔍',
              title: '중고차 구입 경로: 딜러 vs 개인',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _purchaseChannels, scheme.primaryContainer),
            SizedBox(height: sp.s16),
            _buildWarningSection(context),

            SizedBox(height: sp.s24),

            /// [차량 상태 점검 섹션 - Vehicle Inspection Section]
            _buildSectionHeader(
              context,
              emoji: '✅',
              title: '차량 상태 점검',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
                context, _inspectionChecklist, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [서류 확인 섹션 - Document Verification Section]
            _buildSectionHeader(
              context,
              emoji: '📋',
              title: '서류 확인 사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _documentChecklist, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// [구매 계약과 결제 섹션 - Purchase Contract Section]
            _buildSectionHeader(
              context,
              emoji: '💵',
              title: '구매 계약과 결제',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _purchaseContract, scheme.primaryContainer),
            SizedBox(height: sp.s12),
            _buildForeignerNote(context),

            SizedBox(height: sp.s24),

            /// [명의 이전 절차 섹션 - Ownership Transfer Section]
            _buildSectionHeader(
              context,
              emoji: '📝',
              title: '명의 이전 절차 (LTO 차량 등록)',
            ),
            SizedBox(height: sp.s12),
            _buildTransferNotice(context),
            SizedBox(height: sp.s12),
            _buildStepGuide(context, _transferSteps),

            SizedBox(height: sp.s24),

            /// [보험 및 차량 유지 섹션 - Insurance Section]
            _buildSectionHeader(
              context,
              emoji: '🌐',
              title: '보험 가입 및 차량 유지',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
                context, _insuranceMaintenance, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [핵심 요약 섹션 - Summary Section]
            _buildSummarySection(context),

            SizedBox(height: sp.s24),

            /// [도움말 배너 - Help Banner]
            _buildHelpBanner(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 히어로 배너 빌드 (Build hero banner)
  Widget _buildHeroBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🇵🇭', style: theme.textTheme.headlineMedium),
              SizedBox(width: sp.s8),
              Text('🚗', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 중고 자동차\n구매 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '필리핀 거주자를 위한 중고차 구매 방법과\n필요한 행정 절차를 상세히 안내합니다',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: sp.s12),
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: [
              _buildBannerChip(context, '🚙 일본차 위주'),
              _buildBannerChip(context, '📋 OR/CR 필수'),
              _buildBannerChip(context, '⚠️ 침수차 주의'),
            ],
          ),
        ],
      ),
    );
  }

  /// 배너 칩 빌드 (Build banner chip)
  Widget _buildBannerChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header with emoji)
  Widget _buildSectionHeader(
    BuildContext context, {
    required String emoji,
    required String title,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Text(emoji, style: theme.textTheme.titleLarge),
        SizedBox(width: sp.s8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 인기 모델 섹션 설명 (Popular models description)
  Widget _buildPopularModelsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCarSide,
                size: 18,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '필리핀 중고차 시장의 특징',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀에서는 일본차 위주의 시장이 형성되어 있습니다. 특히 토요타는 시장 점유율 40% 이상으로 1위를 차지하며, Vios, Innova, Hilux, Fortuner 등이 인기 모델입니다.\n\n이런 인기 모델들은 부품 수급과 정비가 용이하여 중고차로도 선호됩니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 가격 테이블 빌드 (Build price table)
  Widget _buildPriceTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _carPrices.asMap().entries.map((entry) {
          final index = entry.key;
          final car = entry.value;
          final isFirst = index == 0;
          final isLast = index == _carPrices.length - 1;

          return Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(12) : Radius.zero,
                bottom: isLast ? const Radius.circular(12) : Radius.zero,
              ),
              border: !isLast
                  ? Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.brand} ${car.model}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        car.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    car.price,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 가격 참고 사항 빌드 (Build price note)
  Widget _buildPriceNote(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleInfo,
            size: 16,
            color: scheme.tertiary,
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              '위 가격대는 5~10년 내외의 중고차를 기준으로 한 평균적인 범위입니다. 연식이 오래되거나 주행거리가 많으면 더욱 저렴해질 수 있고, 신차급 중고차나 인기 SUV/픽업 트럭은 100만 페소를 넘기도 합니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onTertiaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 카드 목록 빌드 (Build info cards list)
  Widget _buildInfoCards(
    BuildContext context,
    List<_InfoItem> items,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: items.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    item.icon,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 주의 섹션 빌드 (Build warning section)
  Widget _buildWarningSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightTriangleExclamation,
                size: 18,
                color: scheme.error,
              ),
              SizedBox(width: sp.s8),
              Text(
                '이런 판매자는 피하세요!',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._sellerWarnings.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('❌', style: theme.textTheme.bodyMedium),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(height: sp.s4),
                        Text(
                          item.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 외국인 참고사항 빌드 (Build foreigner note)
  Widget _buildForeignerNote(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightPassport,
                size: 18,
                color: scheme.secondary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '외국인 차량 구매 안내',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '외국인이라도 관광비자 등 비이민 비자 상태에서 차량 구입이 가능합니다. 필리핀 법은 차량 소유에 국적 제한을 두지 않습니다.\n\n현금 구매의 경우 여권과 현지 연락처만으로도 구매 및 등록이 가능합니다. 다만 할부 금융을 이용하려면 일정 기간 체류 기록이나 신용이 요구되어 어려울 수 있습니다.\n\n차량 구매 시 필리핀 운전면허증이 반드시 필요한 것은 아니지만, 향후 보험 가입과 차량 운행을 위해서는 국제면허나 현지 면허를 조속히 취득하는 것이 바람직합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSecondaryContainer,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 명의 이전 안내 빌드 (Build transfer notice)
  Widget _buildTransferNotice(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightClock,
                size: 18,
                color: scheme.error,
              ),
              SizedBox(width: sp.s8),
              Text(
                '중요: 20일 이내 명의 이전 필수',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '법적으로 중고 차량 매매 후 20일 이내에 이전 등록을 신청하도록 규정하고 있습니다. 명의 이전을 하지 않으면 사고 발생 시 법적 책임이나 과태료 등이 여전히 이전 소유주에게 남아 문제가 됩니다.\n\n명의 이전 절차는 구매자(신규 소유주)가 직접 진행하는 것이 원칙입니다. 판매자는 필요한 서류를 제공하는 것으로 역할이 끝납니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onErrorContainer,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 단계별 가이드 빌드 (Build step guide)
  Widget _buildStepGuide(BuildContext context, List<_StepItem> steps) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: steps.map((step) {
        final isLast = step == steps.last;

        return Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 단계 번호 원형 배지 (Step number badge)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      step.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 핵심 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🚗', style: theme.textTheme.titleLarge),
              SizedBox(width: sp.s8),
              Text('✅', style: theme.textTheme.titleLarge),
              SizedBox(width: sp.s8),
              Text(
                '핵심 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._keySummary.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅', style: theme.textTheme.bodyMedium),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 도움말 배너 빌드 (Build help banner)
  Widget _buildHelpBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 18,
                color: scheme.onTertiaryContainer,
              ),
              SizedBox(width: sp.s8),
              Text(
                '필고(PhilGo) 커뮤니티 활용하기',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 한인 커뮤니티 필고에서는 중고차 매물 정보와 구매 대행 서비스 정보가 공유됩니다. 현지 정보와 실제 이용 후기를 참고하여 더 안전한 중고차 거래가 가능합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onTertiaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Text(
            '🚗🇵🇭 사전 계획과 현지 정보를 활용하여 안전하고 합법적으로 중고차를 구매하세요!',
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
