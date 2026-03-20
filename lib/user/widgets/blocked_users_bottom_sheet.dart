import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/blocked_user.model.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/widgets/blocked_user_tile.dart';
import 'package:philgo/util/util.functions.dart';

/// 차단된 사용자 목록을 바텀시트로 표시한다.
void showBlockedUsersBottomSheet({required BuildContext context}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: color.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _BlockedUsersSheet(),
  );
}

class _BlockedUsersSheet extends StatefulWidget {
  const _BlockedUsersSheet();

  @override
  State<_BlockedUsersSheet> createState() => _BlockedUsersSheetState();
}

class _BlockedUsersSheetState extends State<_BlockedUsersSheet> {
  List<BlockedUserModel>? _users;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final users = await UserService.getBlockedList();
    if (!mounted) return;
    setState(() {
      _users = users;
      _loading = false;
    });
  }

  Future<void> _unblock(BlockedUserModel user) async {
    final name = user.nickname.isNotEmpty ? user.nickname : '이름없음'.tr();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('차단 해제'.tr()),
        content: Text('{name}님의 차단을 해제하시겠습니까?'.tr(namedArgs: {'name': name})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('취소'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('차단 해제'.tr()),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await UserService.unblock(idxBlockee: user.idxBlockee);
    if (!mounted) return;
    setState(() {
      _users?.removeWhere((u) => u.idxBlockee == user.idxBlockee);
    });
    showSuccessSnackBar(context, '차단이 해제되었습니다'.tr());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '차단된 사용자'.tr(),
                    style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.lightXmark,
                      size: 18,
                      color: color.onSurface,
                    ),
                    tooltip: '닫기'.tr(),
                  ),
                ],
              ),
            ),

            // 리스트
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _users!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightUserSlash,
                            size: 40,
                            color: color.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '차단된 사용자가 없습니다'.tr(),
                            style: text.bodyMedium?.copyWith(
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _users!.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 68,
                        color: color.outlineVariant.withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final user = _users![index];
                        return BlockedUserTile(
                          user: user,
                          onUnblock: () => _unblock(user),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
