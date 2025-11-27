import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo/globals.dart';

/// 즐겨찾기 폴더 목록 다이얼로그
/// 사용자의 즐겨찾기 폴더와 각 폴더의 북마크 개수를 표시
class FavoriteFoldersDialog extends StatelessWidget {
  const FavoriteFoldersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.sharpSolidStar,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    T.bookmarked_folders,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.lightXmark),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            /// 폴더 목록
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: UserService.instance.favoriteFoldersStream,
              builder: (context, folders, child) {
                // 폴더가 없는 경우
                if (folders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightFolderOpen,
                          size: 48,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          T.no_bookmarked_folders,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                // 폴더 목록 표시
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: folders.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    itemBuilder: (context, index) {
                      final folder = folders[index];
                      final folderName = folder['folderName'] as String;
                      final count = folder['countFavorites'] as int;

                      return ListTile(
                        leading: FaIcon(
                          FontAwesomeIcons.lightFolder,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(folderName),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            count.toString(),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        onTap: () {
                          // 다이얼로그 닫고 폴더명 반환
                          Navigator.pop(context, folderName);
                        },
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
