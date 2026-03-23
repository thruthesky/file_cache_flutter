import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/chat/chat.screen.dart';
import 'package:philgo/common_widgets/app_fab.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/company/list/company.list.screen.dart';
import 'package:philgo/event/company_event.screen.dart';
import 'package:philgo/event/event_entry.screen.dart';
import 'package:philgo/home/home.screen.dart';
import 'package:philgo/menu/menu.screen.dart';
import 'package:philgo/post/create/post.create.screen.dart';
import 'package:philgo/post/list/forum.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post_category_bottom_sheet.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/widgets/login_required_dialog.dart';
import 'package:provider/provider.dart';

class AppScreen extends StatefulWidget {
  static const String routeName = '/';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  bool _isFabExpanded = false;

  void _toggleFab() {
    setState(() => _isFabExpanded = !_isFabExpanded);
  }

  void _closeFab() {
    if (_isFabExpanded) setState(() => _isFabExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.select<AppNavigationState, int>(
      (state) => state.currentIndex,
    );
    // 채팅 탭(index 3)에서는 FAB 숨김
    final showFab = currentIndex != 3;

    // 탭 변경 시 FAB 메뉴 자동 닫기
    if (!showFab && _isFabExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _closeFab());
    }

    return Scaffold(
      body: Stack(
        children: [
          // 메인 콘텐츠
          IndexedStack(
            index: currentIndex,
            children: const [
              HomeScreen(),
              ForumScreen(),
              CompanyListScreen(),
              ChatScreen(),
              MenuScreen(),
            ],
          ),

          // FAB 오버레이 (반투명 배경)
          if (showFab && _isFabExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFab,
                child: const ColoredBox(color: Color(0x40000000)),
              ),
            ),

          // FAB
          if (showFab)
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildFab(context, currentIndex),
            ),
        ],
      ),
      bottomNavigationBar: Selector<AppNavigationState, int>(
        selector: (_, state) => state.currentIndex,
        builder: (context, currentIndex, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) {
              _closeFab();
              switch (index) {
                case 0:
                  AppNavigationState.of(context).openHomeScreen();
                  break;
                case 1:
                  AppNavigationState.of(context).openForumScreen();
                  break;
                case 2:
                  AppNavigationState.of(context).openChatScreen();
                  break;
                case 3:
                  AppNavigationState.of(context).openCompanyScreen();
                  break;
                case 4:
                  AppNavigationState.of(context).openMenuScreen();
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const FaIcon(FontAwesomeIcons.lightHouse),
                label: '홈'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(FontAwesomeIcons.lightClipboard),
                label: '게시판'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(FontAwesomeIcons.lightBuilding),
                label: '업소록'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(FontAwesomeIcons.lightCommentDots),
                label: '채팅'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(FontAwesomeIcons.lightBars),
                label: '메뉴'.tr(),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 현재 탭에 맞는 FAB 구성
  Widget _buildFab(BuildContext context, int currentIndex) {
    final eventEnabled = context.select<SettingsState, bool>(
      (state) => state.settings?.eventEntryEnabled ?? false,
    );

    return AppFab(
      menuItems: _getMenuItems(context, currentIndex),
      isExpanded: _isFabExpanded,
      onToggle: _toggleFab,
      onClose: _closeFab,
      showEventButton: eventEnabled && UserService.isLoggedIn,
      onEventTap: () => EventEntryScreen.push(context),
    );
  }

  /// 탭별 팝업 메뉴 아이템 목록
  List<AppFabMenuItem> _getMenuItems(BuildContext context, int currentIndex) {
    if (!UserService.isLoggedIn) {
      return [
        AppFabMenuItem(
          icon: FontAwesomeIcons.lightRightToBracket,
          label: '로그인'.tr(),
          onTap: () => UserLoginScreen.push(context),
        ),
      ];
    }

    switch (currentIndex) {
      case 0: // 홈
      case 4: // 메뉴
        return [
          AppFabMenuItem(
            icon: FontAwesomeIcons.lightPen,
            label: '글쓰기'.tr(),
            onTap: () => _openPostWrite(context),
          ),
          AppFabMenuItem(
            icon: FontAwesomeIcons.lightQrcode,
            label: '업소이벤트'.tr(),
            onTap: () => CompanyEventScreen.push(context),
          ),
        ];
      case 1: // 게시판
        return [
          AppFabMenuItem(
            icon: FontAwesomeIcons.lightPen,
            label: '글쓰기'.tr(),
            onTap: () => _openPostCreateForForum(context),
          ),
          AppFabMenuItem(
            icon: FontAwesomeIcons.lightQrcode,
            label: '업소이벤트'.tr(),
            onTap: () => CompanyEventScreen.push(context),
          ),
        ];
      case 2: // 업소록
        return [
          _buildCompanyEditMenuItem(context),
          AppFabMenuItem(
            icon: FontAwesomeIcons.lightQrcode,
            label: '업소이벤트'.tr(),
            onTap: () => CompanyEventScreen.push(context),
          ),
        ];
      default:
        return [];
    }
  }

  /// 업소 등록/수정 메뉴 아이템
  AppFabMenuItem _buildCompanyEditMenuItem(BuildContext context) {
    final myCompany = CompanyService.instance.companyNotifier.value;
    final hasCompany = myCompany != null && myCompany.name.isNotEmpty;

    return AppFabMenuItem(
      icon: hasCompany
          ? FontAwesomeIcons.lightPenToSquare
          : FontAwesomeIcons.lightPlus,
      label: hasCompany ? '업소 수정'.tr() : '업소 등록'.tr(),
      onTap: () {
        if (!UserService.isLoggedIn) {
          LoginRequiredDialog.show(context);
          return;
        }
        final company = CompanyService.instance.companyNotifier.value;
        if (company != null) {
          CompanyEditScreen.push(context, company: company);
        }
      },
    );
  }

  /// 홈/메뉴에서 글쓰기 (게시판 선택 바텀시트)
  void _openPostWrite(BuildContext context) {
    if (!UserService.isLoggedIn) {
      LoginRequiredDialog.show(context);
      return;
    }
    showPostCategoryBottomSheet(
      context,
      onSelected: (postId, category) async {
        final result = await Navigator.of(context).push<dynamic>(
          MaterialPageRoute(
            builder: (_) =>
                PostCreateScreen(postId: postId, category: category),
          ),
        );
        if (result is Post && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PostViewScreen(post: result)),
          );
        }
      },
    );
  }

  /// 게시판에서 글쓰기 (현재 선택된 게시판)
  void _openPostCreateForForum(BuildContext context) {
    if (!UserService.isLoggedIn) {
      LoginRequiredDialog.show(context);
      return;
    }
    final nav = AppNavigationState.of(context);
    Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => PostCreateScreen(
          postId: nav.selectedPostId,
          category: nav.selectedCategory,
        ),
      ),
    );
  }
}
