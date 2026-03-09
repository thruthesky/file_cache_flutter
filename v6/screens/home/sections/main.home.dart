import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode;
import 'package:philgo/config/app.config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/extensions/nav.context.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/widgets/home/main/latest_posts.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/home_major_forum_section.dart';
import 'package:philgo/widgets/home/home_notice_section.dart';
import 'package:philgo/widgets/home/home_photo_grid_section.dart';
import 'package:philgo/widgets/home/home_popular_post_section.dart';
import 'package:philgo/widgets/home/main/home_helper_menu_section.dart';
import 'package:philgo/widgets/home/main/home_quick_menu_section.dart';
import 'package:philgo/widgets/home/main/home_quick_post_box.dart';
import 'package:philgo/widgets/home/menu/home_menu_categories.dart';
import 'package:philgo/widgets/layout/content_container.dart';
import 'package:philgo/widgets/theme/comic_fab.dart';
import 'package:philgo/screens/company/company.qr_code_scanned.screen.dart';
import 'package:philgo/screens/event/event_entry.screen.dart';
import 'package:philgo/v7_api/models/v7_settings.dart';
import 'package:philgo/v7_api/state/v7_settings_state.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:provider/provider.dart';

/// 메인 홈 화면 (Main Home Screen)
///
/// Composition:
/// - AppBar: User avatar + Settings button
/// - Latest 3 posts and 3 comments in side-by-side 2-column layout
/// - 2x2 Advertisement grid at the bottom
///
/// 구성:
/// - 앱바: 사용자 아바타 + 설정 버튼
/// - 최근 게시글 3개 + 최근 댓글 3개 (좌우 2단 레이아웃)
/// - 하단 광고 배너 2x2 그리드
class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  /// 디버그 카드 접기/펼치기 상태
  bool _debugCardExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    /// CustomScrollView + Sliver 조합 사용
    /// flutter-layout.md 가이드에 따라 복합 스크롤 화면에 적용
    /// 장점: 스크롤 영역 조립 가능, 고급 UX 지원, 대규모 화면 표준 패턴
    /// ContentContainer: 컨텐츠 최대 너비 800px 제한 + 중앙 정렬
    /// ContentContainer: Constrain content to 800px max width + center align
    return Scaffold(
      /// 배경색을 투명하게 설정 (부모 배경 사용)
      /// Set background transparent (use parent background)
      backgroundColor: Colors.transparent,

      /// FAB 영역 - 이벤트 FAB + 글쓰기 FAB 나란히 배치
      /// 이벤트 응모 FAB는 v7 설정의 eventEntryEnabled가 ON일 때만 표시
      /// 오른쪽 하단에 [이벤트] [글쓰기] 순서로 표시
      floatingActionButton: Selector<V7SettingsState, bool>(
        selector: (_, state) => state.settings?.eventEntryEnabled ?? false,
        builder: (context, eventEnabled, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 이벤트 응모 FAB - eventEntryEnabled ON일 때만 표시
              /// 연한 빨간 배경 + 펄스 애니메이션으로 강조
              if (eventEnabled) ...[
                ComicFab(
                  onPressed: () => EventEntryScreen.push(context),
                  tooltip: '이벤트',
                  heroTag: 'event_fab',
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  borderColor: Theme.of(context).colorScheme.errorContainer,
                  child: const FaIcon(FontAwesomeIcons.gift),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.08, 1.08),
                      duration: 800.ms,
                      curve: Curves.easeInOut,
                    )
                    .shimmer(
                      duration: 1500.ms,
                      color: Theme.of(context).colorScheme.onError.withAlpha(60),
                    ),
                const SizedBox(width: 8),
              ],

              /// 글쓰기 FAB - 카테고리 선택 다이얼로그 표시
              ComicFab(
                onPressed: () => showPostCategoryDialog(context),
                tooltip: '글쓰기',
                heroTag: 'write_fab',
                child: const FaIcon(FontAwesomeIcons.plus),
              ),
            ],
          );
        },
      ),
      body: ContentContainer(
        child: CustomScrollView(
          slivers: [
            /// [메뉴 섹션] - 홈 메뉴 카테고리 표시
            /// Home Menu Section - Display home menu categories
            /// PhilgoCategory.homeMenuCategories() 를 반복하여 메뉴 아이템 생성
            SliverToBoxAdapter(
              child: SafeArea(bottom: false, child: const HomeMenuCategories()),
            ),

            /// [디버그/관리자 전용] QR 스캔 테스트 + v7 설정 정보 통합 카드
            /// kDebugMode이거나 관리자인 경우에만 표시, 접기/펼치기 가능
            SliverToBoxAdapter(
              child: Selector<PhilgoState, bool>(
                selector: (_, state) => state.isAdmin,
                builder: (context, isAdmin, _) {
                  /// kDebugMode 또는 관리자일 때만 표시
                  if (!kDebugMode && !isAdmin) return const SizedBox.shrink();
                  final scheme = Theme.of(context).colorScheme;
                  final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onErrorContainer,
                  );
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 헤더 (탭하면 접기/펼치기)
                        GestureDetector(
                          onTap: () => setState(() => _debugCardExpanded = !_debugCardExpanded),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.bug, size: 10, color: scheme.onErrorContainer),
                                const SizedBox(width: 6),
                                Text('DEBUG', style: labelStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                                const SizedBox(width: 6),
                                Text(
                                  kDebugMode && isAdmin ? '(디버그+관리자)' : kDebugMode ? '(디버그)' : '(관리자)',
                                  style: labelStyle?.copyWith(fontSize: 9),
                                ),
                                const Spacer(),
                                /// V7 API 엔드포인트 주소 + 세팅 로딩 상태 (헤더 오른쪽 표시)
                                Selector<V7SettingsState, ({V7Settings? settings, String? error})>(
                                  selector: (_, state) => (settings: state.settings, error: state.error),
                                  builder: (context, data, _) {
                                    /// 세팅 로딩 상태 아이콘: 성공 ✓ / 실패 ✗ / 로딩중 …
                                    final String status;
                                    if (data.error != null) {
                                      status = ' ✗';
                                    } else if (data.settings != null) {
                                      status = ' ✓';
                                    } else {
                                      status = ' …';
                                    }
                                    return Flexible(
                                      child: Text(
                                        '${PhilgoConfig.v7ApiEndpoint}$status',
                                        style: labelStyle?.copyWith(fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                FaIcon(
                                  _debugCardExpanded ? FontAwesomeIcons.chevronUp : FontAwesomeIcons.chevronDown,
                                  size: 10,
                                  color: scheme.onErrorContainer,
                                ),
                              ],
                            ),
                          ),
                        ),

                        /// 펼쳐진 상세 내용
                        if (_debugCardExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: Builder(
                              builder: (context) {
                                final philgoState = PhilgoState.of(context);
                                final ps = philgoState.setting;
                                final u = philgoState.user;
                                final sectionStyle = labelStyle?.copyWith(fontWeight: FontWeight.bold);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// ── 환경 정보 ──
                                    Text('── 환경 ──', style: sectionStyle),
                                    Text(
                                      'ENV: ${PhilgoConfig.getEnv}'
                                      '  |  Debug: $kDebugMode'
                                      '  |  Platform: $defaultTargetPlatform',
                                      style: labelStyle,
                                    ),
                                    const SizedBox(height: 4),

                                    /// ── URL 정보 ──
                                    Text('── URL ──', style: sectionStyle),
                                    Text(
                                      'v7 API: ${PhilgoConfig.v7ApiEndpoint}\n'
                                      'PHP API: ${PhilgoConfig.phpApiUrl}\n'
                                      'File: ${PhilgoConfig.fileServerUrl}',
                                      style: labelStyle,
                                    ),
                                    const SizedBox(height: 4),

                                    /// ── 사용자 정보 ──
                                    Text('── 사용자 ──', style: sectionStyle),
                                    if (u != null)
                                      Text(
                                        'UID: ${u.uid}\n'
                                        'idx: ${u.idx}  |  닉네임: ${u.nickname}\n'
                                        'Lv: ${u.level}  |  Point: ${u.point}'
                                        '  |  글: ${u.noOfPost}  |  댓글: ${u.noOfComment}\n'
                                        'Admin: ${philgoState.isAdmin}',
                                        style: labelStyle,
                                      )
                                    else
                                      Text('로그인 안됨 (loading: ${philgoState.loading})', style: labelStyle),
                                    const SizedBox(height: 4),

                                    /// ── PhilGo 설정 ──
                                    Text('── PhilGo 설정 ──', style: sectionStyle),
                                    if (ps != null) ...[
                                      Text(
                                        'Admin UIDs: ${ps.adminUids.length}명\n'
                                        '광고 카테고리: ${ps.point.advertisingPostCategories.join(", ")}\n'
                                        '광고 일수: ${ps.point.advertisementDays.join(", ")}\n'
                                        '시간당 비용: ${ps.point.advCostPerHour}P\n'
                                        '은행: ${ps.bankInfo.banks.keys.join(", ")}',
                                        style: labelStyle,
                                      ),
                                    ] else
                                      Text('PhilGo 설정: 로딩 중...', style: labelStyle),
                                    const SizedBox(height: 4),

                                    /// ── V7 설정 ──
                                    Selector<V7SettingsState, ({V7Settings? settings, String? error})>(
                                      selector: (_, state) => (settings: state.settings, error: state.error),
                                      builder: (context, data, _) {
                                        final s = data.settings;
                                        final err = data.error;
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('── V7 설정 ──', style: sectionStyle),
                                            if (err != null)
                                              Text('에러: $err', style: labelStyle?.copyWith(color: scheme.error))
                                            else if (s == null)
                                              Text('로딩 중...', style: labelStyle)
                                            else
                                              Text(
                                                'Android: ${s.appVersionAndroid}+${s.appVersionAndroidBuild}'
                                                '  |  iOS: ${s.appVersionIos}+${s.appVersionIosBuild}\n'
                                                'QR: ${s.companyQrEventEnabled ? "ON" : "OFF"}'
                                                '  |  Event: ${s.eventEntryEnabled ? "ON" : "OFF"}'
                                                '  |  Coupons: ${s.availableStarbucksCoupons}\n'
                                                '갱신 주기: ${AppConfig.v7SettingsRefreshInterval.inSeconds}초',
                                                style: labelStyle,
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 4),

                                    /// ── 이벤트 스핀 확률 (서버 settings.get) ──
                                    Selector<V7SettingsState, V7Settings?>(
                                      selector: (_, state) => state.settings,
                                      builder: (context, s, _) {
                                        if (s == null || s.spinSections.isEmpty) {
                                          return Text('── 이벤트 스핀 확률 ──\n로딩 중...', style: sectionStyle);
                                        }
                                        final totalWeight = s.spinSections.fold<int>(0, (sum, sec) => sum + sec.weight);
                                        final lines = <String>[];
                                        for (final sec in s.spinSections) {
                                          lines.add('${sec.label}: ${sec.percent}% (w:${sec.weight})');
                                        }
                                        /// 3개씩 묶어서 줄바꿈
                                        final buf = StringBuffer();
                                        for (var i = 0; i < lines.length; i++) {
                                          buf.write(lines[i]);
                                          if (i < lines.length - 1) {
                                            buf.write((i + 1) % 3 == 0 ? '\n' : '  |  ');
                                          }
                                        }
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('── 이벤트 스핀 확률 (서버) ──', style: sectionStyle),
                                            Text(buf.toString(), style: labelStyle),
                                            Text(
                                              '총 weight: $totalWeight  |  참가비: ${s.spinCost}P',
                                              style: labelStyle,
                                            ),
                                            Text(
                                              '스타벅스 24h 재당첨 weight: ${s.eventStarbucks24hWeight} (${s.eventStarbucks24hWeight / 10.0}%)',
                                              style: labelStyle,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 4),

                                    /// QR 스캔 테스트 버튼
                                    GestureDetector(
                                      onTap: () {
                                        CompanyQrCodeScannedScreen.push(context, 1025, 'e41aa5ca0d55be94a8a92fab13a0f672');
                                      },
                                      child: Text(
                                        'QR 스캔 테스트 (idx:1025)',
                                        style: labelStyle?.copyWith(decoration: TextDecoration.underline),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// [빠른 글쓰기 박스] - 클릭 시 글쓰기 화면으로 이동
            /// Quick Post Box - Navigate to post creation screen on tap
            /// 가짜 입력 박스로 사용자의 글쓰기 참여를 유도합니다.
            /// Fake input box to encourage user participation in posting.
            const SliverToBoxAdapter(child: HomeQuickPostBox()),

            /// [퀵 메뉴 섹션] - 필리핀 생활 필수 정보 바로가기
            /// Quick Menu Section - Quick access to essential Philippines living info
            /// 환율, 필수정보, 한달살기, 여행 메뉴 표시
            SliverToBoxAdapter(child: const HomeQuickMenuSection()),

            /// [Top Banners]
            /// 상단 배너 - 전체 페이지 배너 표시
            /// Top banners - display all page banners
            SliverToBoxAdapter(
              child: TopBanners(onTap: (url) => openBannerUrl(context, url)),
            ),

            /// [게시판 섹션 - 2단 레이아웃]
            /// Forum Sections - 2-column layout
            /// 왼쪽: 자유게시판, 오른쪽: 질문과 답변
            /// Left: Freetalk, Right: QnA
            SliverToBoxAdapter(child: LatestPostsSection()),

            /// [Square Banners]
            /// 사각 배너 - 1줄에 4개씩 그리드로 표시
            /// Square banners - display 4 per row in grid
            // SliverToBoxAdapter(child: const WingBanners()),
            SliverToBoxAdapter(
              child: WingBanners(onTap: (url) => openBannerUrl(context, url)),
            ),

            /// [인기글 섹션] - 최근 7일간 댓글 많은 글 5개 표시
            /// Popular Posts Section - Display top 5 posts with most comments in last 7 days
            SliverToBoxAdapter(
              child: HomePopularPostSection(
                limit: 3,
                withinDays: 7,
                onMoreTap: () {
                  /// ForumHome으로 이동 (인기글은 전체 게시판 대상)
                  /// Navigate to ForumHome (popular posts from all boards)
                  final navState = NavigationState.of(context, listen: false);
                  navState.setHomeNavigation(HomeNavigationItem.forum);
                },
                onPostTap: (post) {
                  /// PostViewScreen으로 이동
                  /// Navigate to PostViewScreen
                  PostViewScreen.push(context, post);
                },
              ),
            ),

            /// [최근 사진 섹션] - 장터 게시판에서 사진 16개 (4x4 그리드)
            /// Recent Photos Section - 16 photos from buyandsell board (4x4 grid)
            SliverToBoxAdapter(
              child: HomePhotoGridSection(
                postId: 'buyandsell',
                limit: 16,
                crossAxisCount: 4,
                onMoreTap: () {
                  context.openForum('buyandsell');
                },
                onPhotoTap: (post) {
                  /// PostViewScreen으로 이동
                  /// Navigate to PostViewScreen
                  PostViewScreen.push(context, post);
                },
              ),
            ),

            /// [공지사항 섹션] - 최근 공지사항 3개 표시
            /// Notice Section - Display 3 recent notices
            SliverToBoxAdapter(
              child: HomeNoticeSection(
                limit: 3,
                onMoreTap: () {
                  /// NoticeScreen으로 이동 (공지사항 전체 목록)
                  /// Navigate to NoticeScreen (full notice list)
                  NoticeScreen.push(context);
                },
                onNoticeTap: (notice) async {
                  /// PostViewScreen으로 이동 (공지사항 상세 보기)
                  /// Navigate to PostViewScreen (notice detail view)
                  /// Notice.idx로 Post를 가져온 후 이동
                  /// Fetch Post by Notice.idx and navigate
                  try {
                    final post = await getPost(notice.idx);
                    if (context.mounted) {
                      PostViewScreen.push(context, post);
                    }
                  } catch (e) {
                    debugPrint('공지사항 로드 실패: $e');
                  }
                },
              ),
            ),

            /// [주요 게시판 섹션] - 주요 게시판 목록을 Wrap 형태로 표시
            /// Major Forum Section - Display major forums in Wrap layout
            SliverToBoxAdapter(
              child: HomeMajorForumSection(
                onForumTap: (postId, category) {
                  /// 해당 게시판으로 이동
                  /// Navigate to the corresponding forum
                  if (category != null) {
                    context.openForum(postId, category: category);
                  } else {
                    context.openForum(postId);
                  }
                },
              ),
            ),

            /// [퀵메뉴 섹션] - 필리핀 생활 필수 바로가기 메뉴 (Wrap 형식)
            /// Quick Helper Menu Section - Essential shortcuts for Philippine life (Wrap layout)
            /// 대사관, 한인회, 경찰서, e트래블, 여행비자, 그랩 택시, 에어비앤비, 환율, 날씨, 긴급연락처, 초보필독
            const SliverToBoxAdapter(child: HomeHelperMenuSection()),

            /// Bottom spacing (하단 여백)
            SliverToBoxAdapter(child: SizedBox(height: sp.s24)),
          ],
        ),
      ),
    );
  }

}
