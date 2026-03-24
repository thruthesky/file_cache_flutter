import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/bookmark/bookmark_group.model.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/globals.dart';

/// 즐겨찾기 폴더 목록 다이얼로그
/// 사용자의 즐겨찾기 폴더와 각 폴더의 북마크 개수를 표시
/// Comic 스타일 적용: 2.0 테두리, 그림자 없음, 둥근 모서리
class FavoriteFoldersDialog extends StatelessWidget {
  const FavoriteFoldersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          border: Border.all(color: color.outline, width: dialogBorderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - Comic 스타일
            Container(
              padding: dialogHeaderPadding,
              decoration: BoxDecoration(
                color: color.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dialogHeaderBorderRadius),
                  topRight: Radius.circular(dialogHeaderBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(color: color.outline, width: dialogHeaderBorderWidth),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightStar,
                    color: color.primary,
                    size: dialogHeaderIconSize,
                  ),
                  SizedBox(width: dialogItemSpacing),
                  // "Favorites"
                  Text('즐겨찾기'.tr(), style: text.titleMedium),
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                    child: Container(
                      padding: dialogCloseButtonPadding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                        border: Border.all(
                          color: color.outline,
                          width: closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: closeIconSize,
                        color: color.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 폴더 목록 - Comic 스타일
            ValueListenableBuilder<List<BookmarkGroupModel>>(
              valueListenable: BookmarkService.instance.bookmarkGroups,
              builder: (context, groups, child) {
                // 폴더가 없는 경우 - Comic 스타일
                if (groups.isEmpty) {
                  return Padding(
                    padding: dialogEmptyPadding,
                    child: Column(
                      children: [
                        Container(
                          padding: dialogEmptyContainerPadding,
                          decoration: BoxDecoration(
                            color: color.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(dialogBorderRadius),
                            border: Border.all(
                              color: color.outline,
                              width: dialogBorderWidth,
                            ),
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.lightFolderOpen,
                            size: dialogEmptyIconSize,
                            color: color.outline,
                          ),
                        ),
                        SizedBox(height: dialogEmptySpacing),
                        Text(
                          // "No favorites yet"
                          '즐겨찾기가 없습니다'.tr(),
                          style: text.bodyLarge?.copyWith(
                            color: color.outline,
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
                    itemCount: groups.length,
                    padding: dialogContentPadding,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: dialogItemSpacing),
                    itemBuilder: (context, index) {
                      final group = groups[index];

                      return InkWell(
                        onTap: () {
                          Navigator.pop(context, group);
                        },
                        borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                        child: Container(
                          padding: folderItemPadding,
                          decoration: BoxDecoration(
                            // color: color.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                            border: Border.all(
                              color: color.outline,
                              width: dialogItemBorderWidth,
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightFolder,
                                color: color.primary,
                                size: folderIconSize,
                              ),
                              SizedBox(width: folderIconSpacing),
                              Expanded(
                                child: Text(
                                  group.name,
                                  style: text.bodyLarge,
                                ),
                              ),
                              SizedBox(width: countBadgeSpacing),
                              Container(
                                padding: countBadgePadding,
                                decoration: BoxDecoration(
                                  color: color.primaryContainer,
                                  borderRadius: BorderRadius.circular(countBadgeBorderRadius),
                                  border: Border.all(
                                    color: color.primary,
                                    width: countBadgeBorderWidth,
                                  ),
                                ),
                                child: Text(
                                  group.count.toString(),
                                  style: text.labelLarge?.copyWith(
                                    color: color.primary,
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
