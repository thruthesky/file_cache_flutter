import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 그랩 택시 정보 화면 (Grab Taxi Screen)
///
/// 필리핀 그랩 택시 이용 정보를 제공합니다.
/// Provides information about Grab taxi service in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// GrabTaxiScreen.push(context);
/// ```
class GrabTaxiScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/GrabTaxi';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const GrabTaxiScreen({super.key});

  @override
  State<GrabTaxiScreen> createState() => _GrabTaxiScreenState();
}

class _GrabTaxiScreenState extends State<GrabTaxiScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.transportationGrabTaxi,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      /// 그랩 택시 가이드 콘텐츠 (Grab Taxi Guide Content)
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 헤더 섹션 (Header Section)
            _buildHeaderSection(context),
            const SizedBox(height: 24),

            /// 1. 앱 준비하기 섹션 (App Preparation Section)
            _buildAppPreparationSection(context),
            const SizedBox(height: 24),

            /// 2. 차량 호출 가이드 섹션 (Vehicle Booking Guide Section)
            _buildBookingGuideSection(context),
            const SizedBox(height: 24),

            /// 3. 차량 종류 섹션 (Vehicle Types Section)
            _buildVehicleTypesSection(context),
            const SizedBox(height: 24),

            /// 4. 요금 구조 섹션 (Fare Structure Section)
            _buildFareStructureSection(context),
            const SizedBox(height: 24),

            /// 5. 결제 꿀팁 섹션 (Payment Tips Section)
            _buildPaymentTipsSection(context),
            const SizedBox(height: 24),

            /// 6. 이용 가능 지역 섹션 (Available Areas Section)
            _buildAvailableAreasSection(context),
            const SizedBox(height: 24),

            /// 7. 안전 및 분쟁 대처법 섹션 (Safety Tips Section)
            _buildSafetyTipsSection(context),
            const SizedBox(height: 24),

            /// 8. 한국인 여행자 특별 팁 섹션 (Korean Traveler Tips Section)
            _buildKoreanTravelerTipsSection(context),
            const SizedBox(height: 32),

            /// 마무리 메시지 (Closing Message)
            _buildClosingMessage(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 헤더 섹션 빌더 (Header Section Builder)
  Widget _buildHeaderSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '🇵🇭',
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          Text(
            '필리핀 여행의 필수품',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Grab(그랩) 완전 정복 가이드',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '필리핀 여행의 시작과 끝은 Grab(그랩)과 함께한다고 해도 과언이 아닙니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '현지 택시의 바가지요금 스트레스 없이, 안전하고 쾌적하게 이동하고 싶다면 이 가이드를 꼭 저장해두세요! 📝✨',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 앱 준비하기 섹션 빌더 (App Preparation Section Builder)
  Widget _buildAppPreparationSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📱',
      title: '1. Grab 앱 준비하기',
      subtitle: '출국 전 필수!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '필리핀 도착 후 당황하지 않으려면 한국에서 미리 준비하는 것이 좋습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          /// 준비 단계 목록 (Preparation Steps List)
          _buildPreparationStep(
            context,
            step: '1',
            title: '앱 설치',
            description: "iOS / Android 스토어에서 'Grab' 검색 후 다운로드 📥",
          ),
          _buildPreparationStep(
            context,
            step: '2',
            title: '회원가입',
            description:
                '한국 번호(+82)로 인증 가능. (단, 현지 유심 사용 시 기사 통화가 어려울 수 있음)',
          ),
          _buildPreparationStep(
            context,
            step: '3',
            title: '카드 등록',
            description:
                '매우 중요! 💳 한국에서 미리 신용/체크카드 등록을 권장합니다. (현지 유심 교체 후에는 문자인증(OTP) 수신이 어려워 등록이 안 될 수 있음)',
            isImportant: true,
          ),
        ],
      ),
    );
  }

  /// 준비 단계 아이템 빌더 (Preparation Step Item Builder)
  Widget _buildPreparationStep(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
    bool isImportant = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isImportant
            ? scheme.errorContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 차량 호출 가이드 섹션 빌더 (Booking Guide Section Builder)
  Widget _buildBookingGuideSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🚖',
      title: '2. 차량 호출 실전 가이드',
      subtitle: '카카오택시와 비슷해요!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '복잡해 보이지만 카카오택시와 비슷합니다. 차근차근 따라 해보세요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          /// 호출 단계별 가이드 (Step by Step Booking Guide)
          _buildBookingStep(
            context,
            icon: '📍',
            title: '픽업 위치 설정',
            points: [
              'GPS가 튀는 경우가 많으니, 반드시 지도 핀을 확대해서 내가 서 있는 건물 입구나 기둥 번호에 정확히 맞추세요.',
              "공항이나 대형 쇼핑몰은 지정된 'Grab Lounge'나 'Pick-up Point'가 따로 있습니다. (아무 데서나 타면 경찰에게 제지당할 수 있어요 👮‍♂️)",
            ],
          ),
          _buildBookingStep(
            context,
            icon: '🏁',
            title: '목적지 입력',
            points: [
              '주소보다는 정확한 건물명(호텔 이름, 쇼핑몰 명)으로 검색하는 것이 훨씬 정확합니다.',
            ],
          ),
          _buildBookingStep(
            context,
            icon: '🚗',
            title: '차량 선택 및 호출',
            points: [
              '인원과 짐의 양에 맞는 차량을 선택하고 Book GrabCar 버튼 클릭!',
            ],
          ),
          _buildBookingStep(
            context,
            icon: '💨',
            title: '탑승 및 이동',
            points: [
              '차량 번호판을 확인하고 탑승하세요.',
              '"Hello~" 하고 가볍게 인사한 뒤, 앱 내 경로 확인 기능을 켜두세요.',
            ],
          ),
        ],
      ),
    );
  }

  /// 호출 단계 아이템 빌더 (Booking Step Item Builder)
  Widget _buildBookingStep(
    BuildContext context, {
    required String icon,
    required String title,
    required List<String> points,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: theme.textTheme.titleLarge),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 차량 종류 섹션 빌더 (Vehicle Types Section Builder)
  Widget _buildVehicleTypesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🚘',
      title: '3. 나에게 딱 맞는 차량은?',
      subtitle: '차량 종류',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '상황에 맞춰 합리적인 차량을 선택하세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          /// 차량 종류 카드들 (Vehicle Type Cards)
          _buildVehicleTypeCard(
            context,
            icon: '🚗',
            name: 'GrabCar (4-Seater)',
            tag: '추천',
            tagColor: scheme.primary,
            description:
                '가장 일반적인 승용차. 4인까지 탑승 가능하지만 짐이 많다면 2~3인 추천.',
            fare: '확정 요금 (사전 고지)',
          ),
          _buildVehicleTypeCard(
            context,
            icon: '🚐',
            name: 'GrabCar (6-Seater)',
            tag: '가족여행',
            tagColor: scheme.tertiary,
            description: '인원이 4명 이상이거나 골프백/캐리어가 많을 때 필수!',
            fare: '확정 요금 (일반보다 비쌈)',
          ),
          _buildVehicleTypeCard(
            context,
            icon: '🚕',
            name: 'GrabTaxi',
            description:
                '일반 흰색/노란색 택시를 호출. 미터기로 이동하므로 길이 막히면 요금 폭탄 가능성 있음.',
            fare: '미터 요금 + 예약비',
          ),
          _buildVehicleTypeCard(
            context,
            icon: '🐾',
            name: 'GrabPet',
            description: '반려동물과 함께 이동할 때 이용. (전용 시트 구비 등)',
            fare: '확정 요금 (일반보다 비쌈)',
          ),
          const SizedBox(height: 16),

          /// 주의 메시지 (Warning Message)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: theme.textTheme.titleMedium),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '주의: GrabTaxi는 기사가 미터기를 켜지 않으려 하거나 흥정을 시도할 수 있어, 초행길 여행자에게는 GrabCar를 강력 추천합니다!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 차량 종류 카드 빌더 (Vehicle Type Card Builder)
  Widget _buildVehicleTypeCard(
    BuildContext context, {
    required String icon,
    required String name,
    String? tag,
    Color? tagColor,
    required String description,
    required String fare,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: theme.textTheme.headlineSmall),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (tag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: tagColor ?? scheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💰 $fare',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 요금 구조 섹션 빌더 (Fare Structure Section Builder)
  Widget _buildFareStructureSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '💰',
      title: '4. 요금 구조 및 예상 비용',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '필리핀의 교통 체증은 상상을 초월합니다. 출퇴근 시간(7am~9am, 5pm~8pm)이나 비가 올 때는 요금이 1.5배~2배까지 오를 수 있습니다. (Surge Pricing)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),

          /// 평균 요금 섹션 (Average Fare Section)
          Text(
            '💸 평균 요금 (마닐라 기준, 교통 원활 시)',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildFareItem(
            context,
            route: '단거리 (5km 내외)',
            price: '₱150 ~ ₱300',
            krw: '약 3,500원 ~ 7,000원',
          ),
          _buildFareItem(
            context,
            route: '공항 ✈️ → 시내 (마카티/BGC)',
            price: '₱300 ~ ₱600',
            krw: '약 7,000원 ~ 14,000원',
          ),
          _buildFareItem(
            context,
            route: '공항 ✈️ → 먼 거리 (퀘존 등)',
            price: '₱600 ~ ₱1,000 이상',
            krw: '',
          ),
          const SizedBox(height: 20),

          /// 추가 비용 섹션 (Additional Cost Section)
          Text(
            '🛣️ 추가 비용 (별도 지불)',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '고속도로 통행료 (Toll Fee)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "'Skyway'나 'NAIAX' 등 고속도로를 이용하면 통행료는 승객 부담입니다. (기사에게 현금으로 주거나, 기사가 낸 뒤 하차 시 청구함)",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 요금 아이템 빌더 (Fare Item Builder)
  Widget _buildFareItem(
    BuildContext context, {
    required String route,
    required String price,
    required String krw,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              route,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              price,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          if (krw.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              krw,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 결제 꿀팁 섹션 빌더 (Payment Tips Section Builder)
  Widget _buildPaymentTipsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '💳',
      title: '5. 결제 꿀팁',
      subtitle: '현금 vs 카드',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentMethodCard(
            context,
            icon: '💳',
            method: '자동 결제 (카드)',
            tag: '가장 추천! 👍',
            tagColor: scheme.primary,
            pros: '잔돈 시비가 없고, 하차 시 그냥 내리면 됨.',
            cons: '해외 결제 수수료 소액 발생.',
          ),
          _buildPaymentMethodCard(
            context,
            icon: '💵',
            method: '현금 (Cash)',
            pros: '카드가 없을 때 유용.',
            cons:
                '기사가 "잔돈이 없다(No Change)"고 하는 경우가 매우 빈번함. 작은 단위 화폐(20, 50, 100페소) 필수 준비!',
          ),
          _buildPaymentMethodCard(
            context,
            icon: '📱',
            method: 'GCash',
            pros: '현지인처럼 이용 가능.',
            cons: '현지 번호로 가입 및 인증 필요 (장기 체류자 추천).',
          ),
        ],
      ),
    );
  }

  /// 결제 방법 카드 빌더 (Payment Method Card Builder)
  Widget _buildPaymentMethodCard(
    BuildContext context, {
    required String icon,
    required String method,
    String? tag,
    Color? tagColor,
    required String pros,
    required String cons,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: theme.textTheme.titleLarge),
              const SizedBox(width: 12),
              Text(
                method,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (tag != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor ?? scheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '✅',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pros,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cons,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 이용 가능 지역 섹션 빌더 (Available Areas Section Builder)
  Widget _buildAvailableAreasSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📍',
      title: '6. 이용 가능 지역',
      subtitle: '주요 관광지',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '모든 곳에 그랩이 있지는 않습니다! 여행지별 가능 여부를 확인하세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          /// 이용 가능 지역 (Available Areas)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⭕ 이용 가능 (활발함)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAreaItem(context, '마닐라 (Manila)', '전 지역'),
                _buildAreaItem(
                    context, '세부 (Cebu)', '세부 시티, 막탄 공항, 만다우에'),
                _buildAreaItem(
                    context, '클락/앙헬레스 (Pampanga)', '코리아타운, 공항 주변'),
                _buildAreaItem(context, '기타 도시',
                    '바기오, 일로일로, 바콜로드, 다바오, 카가얀데오로'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          /// 이용 불가 지역 (Unavailable Areas)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '❌ 이용 불가 (또는 매우 드묾)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAreaItem(
                    context, '보라카이 (Boracay)', '주로 e-Trike(전기 툭툭) 이용'),
                _buildAreaItem(context, '팔라완 (Palawan)',
                    '푸에르토 프린세사 일부 제외하고는 트라이시클/밴 이용'),
                _buildAreaItem(context, '보홀 (Bohol)',
                    '팡라오 등 관광지는 주로 툭툭이나 개인 밴 렌트 이용'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 지역 아이템 빌더 (Area Item Builder)
  Widget _buildAreaItem(
      BuildContext context, String location, String description) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: '$location: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 안전 및 분쟁 대처법 섹션 빌더 (Safety Tips Section Builder)
  Widget _buildSafetyTipsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🛡️',
      title: '7. 안전 및 분쟁 대처법',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grab은 비교적 안전하지만, 만약을 위해 알아두세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildSafetyTipCard(
            context,
            icon: '📍',
            title: '내 위치 공유 (Share My Ride)',
            description:
                '앱 내 기능으로 친구나 가족에게 실시간 이동 경로를 카톡으로 보낼 수 있습니다.',
          ),
          _buildSafetyTipCard(
            context,
            icon: '🆘',
            title: '비상 버튼',
            description:
                "위급 상황 시 앱 내 'Emergency' 버튼을 누르면 그랩 보안팀/경찰과 연결됩니다.",
          ),
          _buildSafetyTipCard(
            context,
            icon: '🚫',
            title: '사적인 거래 금지',
            description:
                '"앱 취소하고 현금으로 싸게 가자"고 유혹해도 절대 응하지 마세요. 사고 시 보상받을 수 없습니다.',
            isWarning: true,
          ),
        ],
      ),
    );
  }

  /// 안전 팁 카드 빌더 (Safety Tip Card Builder)
  Widget _buildSafetyTipCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    bool isWarning = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning
            ? scheme.errorContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: theme.textTheme.titleLarge),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 한국인 여행자 특별 팁 섹션 빌더 (Korean Traveler Tips Section Builder)
  Widget _buildKoreanTravelerTipsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🇰🇷',
      title: '8. 한국인 여행자를 위한 특별 팁!',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 공항 픽업 팁 (Airport Pickup Tips)
          _buildKoreanTipCard(
            context,
            icon: '✈️',
            title: '공항 픽업 위치 확인',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '마닐라 공항(NAIA)은 터미널마다 그랩 부스(Green Booth) 위치가 다릅니다. 기둥 번호(Pillar Number)를 기사에게 메시지로 보내주면 빨리 만날 수 있어요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '예: "I am at Bay 8, Pillar 12"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 추가 요금 요구 대처 (Handling Extra Fare Requests)
          _buildKoreanTipCard(
            context,
            icon: '😡',
            title: '"Sir, Add 50?" (추가 요금 요구)',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '차가 많이 막히거나 거리가 멀면 기사가 채팅으로 "팁이나 추가 요금(50~100페소)을 더 달라"고 요구할 때가 있습니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'GrabCar는 확정 요금이 원칙입니다. 거절하고 취소해도 되지만, 차가 너무 안 잡히는 급한 상황이라면... 판단은 여행자의 몫입니다. (공식적으로는 불법입니다.)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 취소 수수료 방어 (Cancel Fee Protection)
          _buildKoreanTipCard(
            context,
            icon: '🛡️',
            title: '취소 수수료 방어',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '기사가 오지 않고 "손님이 취소해달라"고 요청하는 경우, 내가 취소하면 수수료가 부과될 수 있습니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '이럴 땐 취소 사유를 "Driver asked to cancel (기사가 취소 요청함)"로 선택해야 수수료를 물지 않습니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 매너 팁 (Manner Tips)
          _buildKoreanTipCard(
            context,
            icon: '💸',
            title: '매너 팁',
            content: Text(
              '필수는 아니지만, 짐을 들어주거나 친절했다면 20~50페소 정도 팁을 주는 것이 관례입니다. 앱 내에서 결제 후 팁 추가도 가능합니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 한국인 팁 카드 빌더 (Korean Tip Card Builder)
  Widget _buildKoreanTipCard(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget content,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: theme.textTheme.titleLarge),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  /// 마무리 메시지 빌더 (Closing Message Builder)
  Widget _buildClosingMessage(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '🌴🥥🌊',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            '즐겁고 안전한 필리핀 여행 되세요!',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 공통 섹션 빌더 (Common Section Builder)
  Widget _buildSection(
    BuildContext context, {
    required String icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (Section Header)
        Row(
          children: [
            Text(icon, style: theme.textTheme.headlineSmall),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        /// 섹션 콘텐츠 (Section Content)
        child,
      ],
    );
  }
}
