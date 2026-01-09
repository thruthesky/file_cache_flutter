import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// eTravel 정보 화면 (E-Travel Screen)
///
/// 필리핀 전자여행허가(e-Travel) 정보를 제공합니다.
/// 기존 종이 서류(입국신고서·건강신고서·세관신고서)를 대체하는 온라인 신고 시스템입니다.
/// Provides comprehensive information about Philippine e-Travel registration.
///
/// ### 사용법 (Usage):
/// ```dart
/// ETravelScreen.push(context);
/// ```
class ETravelScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/ETravel';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const ETravelScreen({super.key});

  @override
  State<ETravelScreen> createState() => _ETravelScreenState();
}

class _ETravelScreenState extends State<ETravelScreen> {
  /// [eTravel 공식 웹사이트 URL - Official eTravel Website URL]
  static const String _officialUrl = 'https://etravel.gov.ph';

  /// [작성 순서 데이터 - Registration Steps Data]
  ///
  /// eTravel 등록 시 필요한 단계별 안내입니다.
  /// Step-by-step guide for eTravel registration.
  static const List<Map<String, dynamic>> _registrationSteps = [
    {
      'step': 1,
      'title': '계정 만들기 (처음만)',
      'items': [
        '📧 이메일 입력',
        '🔑 비밀번호 생성',
        '🔓 이메일 인증(OTP) 완료',
      ],
    },
    {
      'step': 2,
      'title': '개인 정보 입력',
      'items': [
        '📍 여권상의 영문 이름 그대로',
        '📍 국적: South Korea',
        '📍 여권 번호, 생년월일 등 정확히 입력',
      ],
    },
    {
      'step': 3,
      'title': '여행 정보 입력',
      'items': [
        '✈️ 입국 목적 (예: Holiday / Vacation)',
        '🗓 필리핀 도착 예정일',
        '📍 항공사명 + 편명 (예: Philippine Airlines PR123)',
        '🏨 체류지 영문 주소 (호텔/숙소)',
      ],
    },
    {
      'step': 4,
      'title': '건강 선언',
      'items': [
        '❓ 최근 30일간 방문한 국가',
        '❓ 이상 증상 여부',
        '→ 문제가 없으면 \'No\' 체크',
      ],
    },
    {
      'step': 5,
      'title': '세관 신고',
      'items': [
        '💼 신고할 물품이 있으면 체크',
        '📦 없으면 \'Nothing to declare\' 선택',
      ],
    },
    {
      'step': 6,
      'title': '제출 & QR 코드 확인',
      'items': [
        '🔍 입력 후 제출 버튼 클릭',
        '📸 "QR 코드"가 화면에 표시됨',
        '👉 스크린샷 또는 다운로드 필수',
      ],
    },
  ];

  /// [실수 방지 포인트 - Mistake Prevention Tips]
  ///
  /// 부모님·시니어를 위한 중요한 주의사항입니다.
  /// Important tips to prevent common mistakes.
  static const List<Map<String, String>> _mistakeTips = [
    {
      'title': '너무 일찍 작성하면 무효',
      'content': '"출발 4일 전"은 안 돼요! 72시간 이내에만 작성하세요.',
      'icon': '⏰',
    },
    {
      'title': '여권 정보는 한 글자도 틀리면 안 돼요',
      'content': '이름, 번호, 생일 → 반드시 여권 그대로 입력',
      'icon': '📕',
    },
    {
      'title': '체류지 주소는 정확히!',
      'content': '호텔, 숙소 주소 → 영문 전체 입력 (예: Hotel XYZ, 123 Rizal Ave, Manila)',
      'icon': '🏨',
    },
    {
      'title': 'QR 코드는 저장하세요',
      'content': '화면 저장 + 이메일 저장 + 출력 가능 → 공항에서 인터넷이 안 될 때 꼭 필요합니다',
      'icon': '📱',
    },
    {
      'title': '가족/아이도 각자 QR',
      'content': '영유아도 각자 등록 필요합니다',
      'icon': '👶',
    },
  ];

  /// [한국인 여행자의 장점 - Benefits for Korean Travelers]
  static const List<String> _koreanBenefits = [
    '한국어 안내 및 쉬운 작성',
    '종이 서류 작성 완전 폐지',
    '빠른 입국 심사 가능',
    '무료 등록 + 간단 절차',
    '불필요한 줄 설 필요 없음',
  ];

  /// [출발 전 체크리스트 - Pre-Departure Checklist]
  static const List<String> _checklist = [
    '출발 72시간 이내 작성',
    '공식 사이트에서만 등록',
    '여권 정보 정확히 입력',
    'QR 코드 스크린샷 저장',
    '체류지 주소 영문으로 기재',
  ];

  /// 공식 웹사이트 열기 (Open official website)
  Future<void> _launchOfficialSite() async {
    final uri = Uri.parse(_officialUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
              FontAwesomeIcons.lightPassport,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.immigrationETravel),
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

            /// [eTravel이란? 섹션 - What is eTravel Section]
            _buildWhatIsETravel(context),

            SizedBox(height: sp.s24),

            /// [등록 대상 섹션 - Who Should Register Section]
            _buildWhoShouldRegister(context),

            SizedBox(height: sp.s24),

            /// [등록 시기 섹션 - Registration Timing Section]
            _buildRegistrationTiming(context),

            SizedBox(height: sp.s24),

            /// [등록 방법 섹션 - Registration Method Section]
            _buildRegistrationMethod(context),

            SizedBox(height: sp.s24),

            /// [작성 순서 섹션 - Registration Steps Section]
            _buildSectionHeader(
              context,
              emoji: '✍️',
              title: '작성 순서 (쉽게 보는 단계)',
            ),
            SizedBox(height: sp.s12),
            _buildRegistrationSteps(context),

            SizedBox(height: sp.s24),

            /// [QR 코드 종류 섹션 - QR Code Types Section]
            _buildQRCodeTypes(context),

            SizedBox(height: sp.s24),

            /// [공항에서 보여주는 곳 섹션 - Where to Show Section]
            _buildWhereToShow(context),

            SizedBox(height: sp.s24),

            /// [실수 방지 포인트 섹션 - Mistake Prevention Section]
            _buildSectionHeader(
              context,
              emoji: '🔎',
              title: '실수 방지 포인트 (부모님·시니어용)',
            ),
            SizedBox(height: sp.s12),
            _buildMistakeTips(context),

            SizedBox(height: sp.s24),

            /// [한국인 여행자의 장점 섹션 - Korean Benefits Section]
            _buildKoreanBenefits(context),

            SizedBox(height: sp.s24),

            /// [출발 전 체크리스트 섹션 - Checklist Section]
            _buildChecklist(context),

            SizedBox(height: sp.s24),

            /// [기타 참고 섹션 - Additional Notes Section]
            _buildAdditionalNotes(context),

            SizedBox(height: sp.s24),

            /// [공식 참고 섹션 - Official Reference Section]
            _buildOfficialReference(context),

            SizedBox(height: sp.s24),

            /// [마무리 메시지 - Closing Message]
            _buildClosingMessage(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 히어로 배너 빌드 (Build hero banner)
  ///
  /// eTravel 안내의 메인 배너를 생성합니다.
  /// Creates the main banner for eTravel guide.
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
              Text(
                '🇵🇭',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '✈️',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 eTravel\n전자 입국 신고서 종합 안내',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '한국인 · 첫 필리핀 입국자 · 부모님/시니어 친화 버전',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: sp.s16),
          Text(
            'QR 코드 한 장으로 입국 심사와 검사가 간소화됩니다',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header with emoji)
  ///
  /// 각 섹션의 제목을 이모지와 함께 표시합니다.
  /// Displays section titles with emojis.
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
        Text(
          emoji,
          style: theme.textTheme.titleLarge,
        ),
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

  /// eTravel이란? 섹션 빌드 (Build What is eTravel section)
  Widget _buildWhatIsETravel(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '🧾', title: 'eTravel이란?'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📌 eTravel은 필리핀 정부가 운영하는 전자 신고 시스템입니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sp.s12),

              /// [신고 항목 목록 - Declaration Items]
              _buildCheckItem(context, '입국 신고서'),
              _buildCheckItem(context, '건강 선언'),
              _buildCheckItem(context, '세관 신고'),

              SizedBox(height: sp.s12),
              Text(
                '위 세 가지를 종이 없이 온라인으로 한 번에 작성합니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: sp.s16),

              /// [공식 웹사이트 안내 - Official Website Info]
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightGlobe,
                          size: 16,
                          color: scheme.primary,
                        ),
                        SizedBox(width: sp.s8),
                        Text(
                          '등록은 무료이며, 공식 사이트에서만 가능합니다:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s8),
                    GestureDetector(
                      onTap: _launchOfficialSite,
                      child: Text(
                        '➡ https://etravel.gov.ph',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sp.s12),

              /// [경고 메시지 - Warning Message]
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('‼️', style: theme.textTheme.bodyMedium),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        '결제 또는 수수료 요구 사이트는 사기입니다. 절대 입력하지 마세요.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 체크 아이템 빌드 (Build check item)
  Widget _buildCheckItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: sp.s4),
      child: Row(
        children: [
          Text('✔', style: TextStyle(color: scheme.primary)),
          SizedBox(width: sp.s8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 등록 대상 섹션 빌드 (Build Who Should Register section)
  Widget _buildWhoShouldRegister(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '📌', title: '누가 등록해야 하나요?'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckItem(context, '필리핀에 입국하는 모든 여행자'),
              _buildCheckItem(context, '한국인 포함 외국인'),
              _buildCheckItem(context, '영유아, 아동 포함 전원 등록 필요'),
              SizedBox(height: sp.s12),
              Text(
                '※ 외교관, 일부 공식 비자 소지자는 예외일 수 있으나, 대부분의 여행객은 반드시 등록해야 합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 등록 시기 섹션 빌드 (Build Registration Timing section)
  Widget _buildRegistrationTiming(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '📅', title: '등록 시기'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.tertiaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.tertiaryContainer,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🕒', style: theme.textTheme.titleLarge),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      '출발 72시간(3일) 이내만 가능',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                '72시간 이전에 작성하면 무효 처리되어 다시 작성해야 합니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: sp.s12),
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text('✔', style: TextStyle(color: scheme.primary)),
                    SizedBox(width: sp.s8),
                    Text(
                      '추천 등록 시점: 출발 2~3일 전',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 등록 방법 섹션 빌드 (Build Registration Method section)
  Widget _buildRegistrationMethod(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '📱', title: '등록 방법'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightDesktop,
                    size: 18,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '🖥 공식 사이트 접속',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              GestureDetector(
                onTap: _launchOfficialSite,
                child: Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightArrowUpRightFromSquare,
                        size: 14,
                        color: scheme.primary,
                      ),
                      SizedBox(width: sp.s8),
                      Text(
                        'https://etravel.gov.ph',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sp.s12),
              Text(
                '(인터넷 연결 필요)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: sp.s8),
              Text(
                '앱 설치는 선택사항이며, 웹 브라우저로도 충분히 작성 가능합니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 작성 순서 섹션 빌드 (Build Registration Steps section)
  Widget _buildRegistrationSteps(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _registrationSteps.map((step) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// [단계 헤더 - Step Header]
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${step['step']}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      step['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),

              /// [단계 항목 목록 - Step Items]
              ...(step['items'] as List<String>).map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s4, left: sp.s8),
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// QR 코드 종류 섹션 빌드 (Build QR Code Types section)
  Widget _buildQRCodeTypes(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '🛂', title: 'QR 코드 종류와 의미'),
        SizedBox(height: sp.s12),

        /// [녹색 QR 코드 - Green QR Code]
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🟩', style: theme.textTheme.titleLarge),
                  SizedBox(width: sp.s8),
                  Text(
                    '녹색 QR 코드',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                '✔ 정보가 정확하고 이상 없음',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              Text(
                '✔ 바로 입국 심사로 이동 가능',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// [빨간색 QR 코드 - Red QR Code]
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.errorContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.errorContainer,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🟥', style: theme.textTheme.titleLarge),
                  SizedBox(width: sp.s8),
                  Text(
                    '빨간색 QR 코드',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                '✔ 정보 누락 또는 확인이 필요함',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              Text(
                '✔ 공항 검역(BOQ) 직원이 추가 확인 후 통과',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: sp.s8),
              Text(
                '👉 빨간 QR이라도 입국 자체가 거부되는 것은 아닙니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 공항에서 보여주는 곳 섹션 빌드 (Build Where to Show section)
  Widget _buildWhereToShow(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '✈️', title: '공항에서 보여주는 곳'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightPlaneDeparture,
                    size: 16,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '항공사 체크인 데스크',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightPlaneArrival,
                    size: 16,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Text(
                    '필리핀 도착 후 검역/입국 심사',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡', style: theme.textTheme.bodyMedium),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        '오프라인 상태에서도 제시할 수 있도록 스크린샷 저장 권장.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 실수 방지 포인트 섹션 빌드 (Build Mistake Tips section)
  Widget _buildMistakeTips(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _mistakeTips.asMap().entries.map((entry) {
        final index = entry.key;
        final tip = entry.value;
        final colors = [
          scheme.primaryContainer,
          scheme.secondaryContainer,
          scheme.tertiaryContainer,
          scheme.primaryContainer,
          scheme.secondaryContainer,
        ];

        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: colors[index % colors.length].withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors[index % colors.length],
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '❗️${index + 1}.',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      tip['title']!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(tip['icon']!, style: theme.textTheme.titleMedium),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                tip['content']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 한국인 여행자의 장점 섹션 빌드 (Build Korean Benefits section)
  Widget _buildKoreanBenefits(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '🌟', title: '한국인 여행자의 장점'),
        SizedBox(height: sp.s12),
        Container(
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _koreanBenefits.map((benefit) {
              return Padding(
                padding: EdgeInsets.only(bottom: sp.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✔', style: TextStyle(color: scheme.primary)),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 출발 전 체크리스트 섹션 빌드 (Build Checklist section)
  Widget _buildChecklist(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '📝', title: '출발 전 체크리스트'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _checklist.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: sp.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('☑', style: TextStyle(color: scheme.primary)),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 기타 참고 섹션 빌드 (Build Additional Notes section)
  Widget _buildAdditionalNotes(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '🧑‍⚖️', title: '기타 참고'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckItem(context, 'eTravel은 입국 신고서입니다.'),
              _buildCheckItem(context, '비자 요건과는 별개입니다.'),
              _buildCheckItem(context, '항공사 체크인 시 QR 코드 제시를 요구할 수 있습니다.'),
            ],
          ),
        ),
      ],
    );
  }

  /// 공식 참고 섹션 빌드 (Build Official Reference section)
  Widget _buildOfficialReference(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, emoji: '📌', title: '공식 참고'),
        SizedBox(height: sp.s12),
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.secondaryContainer,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _launchOfficialSite,
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightGlobe,
                      size: 16,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        'eTravel 공식 웹사이트: https://etravel.gov.ph',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sp.s8),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCircleQuestion,
                    size: 16,
                    color: scheme.secondary,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      'FAQ 및 등록 안내: 공식 eTravel FAQ 페이지',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 마무리 메시지 빌드 (Build Closing Message)
  Widget _buildClosingMessage(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('✈️', style: theme.textTheme.headlineMedium),
              SizedBox(width: sp.s8),
              Text('🇵🇭', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            'eTravel 등록을 미리 준비하면\n필리핀 입국이 훨씬 빠르고 편리합니다.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '출발 전에 꼭 작성하시고\n즐거운 여행 되시기 바랍니다!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
