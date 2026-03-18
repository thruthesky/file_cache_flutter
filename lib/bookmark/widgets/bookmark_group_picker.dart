import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/bookmark/bookmark_group.model.dart';
import 'package:philgo/globals.dart';

/// 북마크 그룹 선택 바텀시트
///
/// 북마크를 추가할 그룹을 선택하거나, 이미 북마크된 항목을 해제한다.
/// [isBookmarked]가 true이면 '북마크 해제' 버튼을 상단에 표시한다.
///
/// 반환값:
/// - `null`: 취소 (아무것도 선택하지 않음)
/// - [BookmarkGroupPickerResult] with [removed] = true: 북마크 해제
/// - [BookmarkGroupPickerResult] with [groupName]: 선택한 그룹명
class BookmarkGroupPickerResult {
  final bool removed;
  final String? groupName;

  const BookmarkGroupPickerResult({this.removed = false, this.groupName});
}

/// 바텀시트를 표시하고 결과를 반환한다.
Future<BookmarkGroupPickerResult?> showBookmarkGroupPicker({
  required BuildContext context,
  required bool isBookmarked,
}) {
  return showModalBottomSheet<BookmarkGroupPickerResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _BookmarkGroupPickerSheet(isBookmarked: isBookmarked),
  );
}

class _BookmarkGroupPickerSheet extends StatelessWidget {
  final bool isBookmarked;

  const _BookmarkGroupPickerSheet({required this.isBookmarked});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<BookmarkGroupModel>>(
      valueListenable: BookmarkService.instance.bookmarkGroups,
      builder: (context, groups, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 드래그 핸들
                Center(
                  child: Container(
                    width: 32,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: color.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    '북마크'.tr(),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.onSurface,
                    ),
                  ),
                ),

                // 북마크 해제 버튼 (이미 북마크된 경우)
                if (isBookmarked)
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.lightBookmarkSlash,
                      size: 18,
                      color: color.error,
                    ),
                    title: Text(
                      '북마크 해제'.tr(),
                      style: text.bodyMedium?.copyWith(color: color.error),
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      const BookmarkGroupPickerResult(removed: true),
                    ),
                  ),

                if (isBookmarked)
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: color.outlineVariant,
                  ),

                // 'default' 그룹 (DB에 없을 때만 표시)
                if (!groups.any((g) => g.name == 'default'))
                  ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.lightFolder,
                      size: 18,
                      color: color.onSurfaceVariant,
                    ),
                    title: Text(
                      'default',
                      style: text.bodyMedium?.copyWith(color: color.onSurface),
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      const BookmarkGroupPickerResult(groupName: ''),
                    ),
                  ),

                // 사용자 그룹 목록
                ...groups.map(
                  (group) => ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.lightFolder,
                      size: 18,
                      color: color.onSurfaceVariant,
                    ),
                    title: Text(
                      group.name,
                      style: text.bodyMedium?.copyWith(color: color.onSurface),
                    ),
                    trailing: Text(
                      '${group.count}',
                      style: text.labelSmall?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      BookmarkGroupPickerResult(groupName: group.name),
                    ),
                  ),
                ),

                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: color.outlineVariant,
                ),

                // 새 그룹 생성 버튼
                ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.lightPlus,
                    size: 18,
                    color: color.primary,
                  ),
                  title: Text(
                    '그룹 생성'.tr(),
                    style: text.bodyMedium?.copyWith(color: color.primary),
                  ),
                  onTap: () => _createNewGroup(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createNewGroup(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('그룹 생성'.tr()),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '그룹 이름'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('취소'.tr()),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx, text);
              },
              child: Text('생성'.tr()),
            ),
          ],
        );
      },
    );
    if (name == null || !context.mounted) return;

    await BookmarkService.instance.createGroup(name: name);
    if (!context.mounted) return;
    // 새 그룹으로 바로 북마크
    Navigator.pop(
      context,
      BookmarkGroupPickerResult(groupName: name),
    );
  }
}
