import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/user/user.service.dart';

/// 즐겨찾기 폴더 목록 다이얼로그
/// 사용자의 즐겨찾기 폴더와 각 폴더의 북마크 개수를 표시
/// Comic 스타일 적용: 2.0 테두리, 그림자 없음, 둥근 모서리
class FavoriteFoldersDialog extends StatelessWidget {
  const FavoriteFoldersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final chatTheme = ChatThemeData.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: chatTheme.dialog.elevation,
      child: Container(
        constraints: BoxConstraints(maxWidth: chatTheme.dialog.maxWidth),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
          border: Border.all(color: colorScheme.outline, width: chatTheme.dialog.borderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - Comic 스타일
            Container(
              padding: chatTheme.dialog.headerPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(chatTheme.dialog.headerBorderRadius),
                  topRight: Radius.circular(chatTheme.dialog.headerBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: chatTheme.dialog.headerBorderWidth),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightStar,
                    color: colorScheme.primary,
                    size: chatTheme.dialog.headerIconSize,
                  ),
                  SizedBox(width: chatTheme.dialog.itemSpacing),
                  Text('Favorites', style: textTheme.titleMedium),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(chatTheme.dialog.closeButtonBorderRadius),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(chatTheme.dialog.closeButtonBorderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: chatTheme.dialog.closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: chatTheme.dialog.closeIconSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 폴더 목록 - Comic 스타일
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: UserService.instance.favoriteFoldersStream,
              builder: (context, folders, child) {
                // 폴더가 없는 경우 - Comic 스타일
                if (folders.isEmpty) {
                  return Padding(
                    padding: chatTheme.dialog.emptyPadding,
                    child: Column(
                      children: [
                        Container(
                          padding: chatTheme.dialog.emptyContainerPadding,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: chatTheme.dialog.borderWidth,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.lightFolderOpen,
                            size: chatTheme.dialog.emptyIconSize,
                            color: colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: chatTheme.dialog.emptySpacing),
                        Text(
                          'No favorites yet',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 폴더 목록 표시 - Comic 스타일
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: chatTheme.dialog.listMaxHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    padding: chatTheme.dialog.contentPadding,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: chatTheme.dialog.itemSpacing),
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      final folderName = folder['folderName'] as String;
                      final count = folder['countFavorites'] as int;

                      return InkWell(
                        onTap: () {
                          // 다이얼로그 닫고 폴더명 반환
                          Navigator.pop(context, folderName);
                        },
                        borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                        child: Container(
                          padding: chatTheme.dialog.folderItemPadding,
                          decoration: BoxDecoration(
                            // color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: chatTheme.dialog.itemBorderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightFolder,
                                color: colorScheme.primary,
                                size: chatTheme.dialog.folderIconSize,
                              ),
                              SizedBox(width: chatTheme.dialog.folderIconSpacing),
                              Expanded(
                                child: Text(
                                  folderName,
                                  style: textTheme.bodyLarge,
                                ),
                              ),
                              SizedBox(width: chatTheme.dialog.countBadgeSpacing),
                              Container(
                                padding: chatTheme.dialog.countBadgePadding,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(chatTheme.dialog.countBadgeBorderRadius),
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: chatTheme.dialog.countBadgeBorderWidth,
                                  ),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
