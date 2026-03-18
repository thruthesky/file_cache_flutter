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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          border: Border.all(color: colorScheme.outline, width: dialogBorderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - Comic 스타일
            Container(
              padding: dialogHeaderPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dialogHeaderBorderRadius),
                  topRight: Radius.circular(dialogHeaderBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: dialogHeaderBorderWidth),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightStar,
                    color: colorScheme.primary,
                    size: dialogHeaderIconSize,
                  ),
                  SizedBox(width: dialogItemSpacing),
                  Text('Favorites', style: textTheme.titleMedium),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                    child: Container(
                      padding: dialogCloseButtonPadding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: closeIconSize,
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
                    padding: dialogEmptyPadding,
                    child: Column(
                      children: [
                        Container(
                          padding: dialogEmptyContainerPadding,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(dialogBorderRadius),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: dialogBorderWidth,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.lightFolderOpen,
                            size: dialogEmptyIconSize,
                            color: colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: dialogEmptySpacing),
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
                  constraints: BoxConstraints(maxHeight: dialogListMaxHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    padding: dialogContentPadding,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: dialogItemSpacing),
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      final folderName = folder['folderName'] as String;
                      final count = folder['countFavorites'] as int;

                      return InkWell(
                        onTap: () {
                          // 다이얼로그 닫고 폴더명 반환
                          Navigator.pop(context, folderName);
                        },
                        borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                        child: Container(
                          padding: folderItemPadding,
                          decoration: BoxDecoration(
                            // color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: dialogItemBorderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightFolder,
                                color: colorScheme.primary,
                                size: folderIconSize,
                              ),
                              SizedBox(width: folderIconSpacing),
                              Expanded(
                                child: Text(
                                  folderName,
                                  style: textTheme.bodyLarge,
                                ),
                              ),
                              SizedBox(width: countBadgeSpacing),
                              Container(
                                padding: countBadgePadding,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(countBadgeBorderRadius),
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: countBadgeBorderWidth,
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
