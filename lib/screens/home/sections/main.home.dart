import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:provider/provider.dart';
import 'package:v6_apps/v6_apps.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              // 상단에 추가 여백을 두어 화면 상단과의 간격 확보
              // top: 40으로 상단 여백 증가, 나머지는 20 유지
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 홈 화면 타이틀
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.house,
                            color: Theme.of(context).colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🏠 ${Lo.of(context)!.home}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              Text(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                Lo.of(context)!.philgoCommunityTitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 사용자 정보 카드
                  Selector<AppState, User?>(
                    selector: (_, appState) => appState.user,
                    builder: (_, user, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: user == null
                            ? _buildNoUserCard(context)
                            : _buildUserCard(context, user),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 빠른 메뉴
                  Text(
                    '⚡ ${Lo.of(context)!.menu}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ElevatedButton(
                    onPressed: () => NavigationState.of(
                      context,
                      listen: false,
                    ).openOpenChat(),
                    child: Text('Open chat'),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickMenuGrid(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoUserCard(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: FaIcon(
            FontAwesomeIcons.userLarge,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '👋 ${Lo.of(context)!.login}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          Lo.of(context)!.loginWithPhoneHeader,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Row(
      children: [
        // Hero(
        //   tag: 'user_avatar',
        //   child: Container(
        //     padding: const EdgeInsets.all(3),
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         colors: [
        //           Theme.of(context).colorScheme.primary,
        //           Theme.of(context).colorScheme.secondary,
        //         ],
        //         begin: Alignment.topLeft,
        //         end: Alignment.bottomRight,
        //       ),
        //       shape: BoxShape.circle,
        //     ),
        //     child: Container(
        //       padding: const EdgeInsets.all(12),
        //       decoration: BoxDecoration(
        //         color: Theme.of(context).colorScheme.surface,
        //         shape: BoxShape.circle,
        //       ),
        //       child: FaIcon(
        //         FontAwesomeIcons.user,
        //         color: Theme.of(context).colorScheme.primary,
        //         size: 24,
        //       ),
        //     ),
        //   ),
        // ),
        UserAvatar(user: user, size: 50),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('🎉 ', style: Theme.of(context).textTheme.titleLarge),
                  Flexible(
                    child: Text(
                      user.nickname.isNotEmpty ? user.nickname : user.uid,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.envelope,
                    size: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      user.uid,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 레벨 표시 추가
              Row(
                children: [
                  // 레벨 아이콘 - 별 모양으로 표시
                  FaIcon(
                    FontAwesomeIcons.star,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  // 레벨 텍스트 - Lv. 형식으로 표시
                  // null 체크를 추가하여 level이 null인 경우 기본값 1 사용
                  Text(
                    '⭐ Lv. ${user.level ?? 1}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      // primary 색상으로 강조하여 레벨을 눈에 띄게 표시
                      color: Theme.of(context).colorScheme.primary,
                      // 레벨 텍스트를 약간 굵게 표시
                      fontWeight: FontWeight.w600,
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

  Widget _buildQuickMenuGrid(BuildContext context) {
    final menuItems = [
      {
        'icon': FontAwesomeIcons.penToSquare,
        'emoji': '✍️',
        'label': Lo.of(context)!.create,
        'onTap': () => NavigationState.of(
          context,
          listen: false,
        ).setHomeNavigation(HomeNavigationItem.create),
      },
      {
        'icon': FontAwesomeIcons.comments,
        'emoji': '💬',
        'label': Lo.of(context)!.forum,
        'onTap': () => NavigationState.of(
          context,
          listen: false,
        ).setHomeNavigation(HomeNavigationItem.forum),
      },
      {
        'icon': FontAwesomeIcons.comments,
        'emoji': '💬',
        'label': Lo.of(context)!.chat,
        'onTap': () => NavigationState.of(
          context,
          listen: false,
        ).setHomeNavigation(HomeNavigationItem.chat),
      },

      {
        'icon': FontAwesomeIcons.building,
        'emoji': '🏢',
        'label': Lo.of(context)!.company,
        'onTap': () => NavigationState.of(
          context,
          listen: false,
        ).setHomeNavigation(HomeNavigationItem.company),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // 메뉴 액션 처리
                final onTap = item['onTap'];
                if (onTap != null && onTap is Function) {
                  onTap();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['emoji'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item['label'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
