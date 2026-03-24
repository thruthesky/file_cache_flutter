import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';

/// 검색 다이얼로그 - Comic 스타일
/// 검색어를 입력받아 String?으로 반환
class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  /// 다이얼로그 표시. 검색어 반환, 취소 시 null
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => const SearchDialog(),
    );
  }

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch() {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      Navigator.pop(context, searchTerm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.outline, width: 2.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더 - 그라데이션 배경
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.primaryContainer,
                    color.primaryContainer.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(
                  bottom: BorderSide(color: color.outline, width: 2.0),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.lightMagnifyingGlass,
                      color: color.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    // "Search"
                    '검색'.tr(),
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.outline.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.lightXmark,
                          size: 14,
                          color: color.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),

            // 검색어 입력 영역
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: text.bodyLarge,
                    decoration: InputDecoration(
                      // "Search"
                      hintText: '${'검색'.tr()}...',
                      hintStyle: text.bodyLarge?.copyWith(
                        color: color.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14),
                        child: FaIcon(
                          FontAwesomeIcons.lightMagnifyingGlass,
                          size: 20,
                          color: color.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      filled: true,
                      fillColor: color.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: color.outline, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: color.outline.withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: color.primary, width: 2.5),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                  )
                      .animate()
                      .fadeIn(duration: 250.ms, delay: 100.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 250.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: 20),

                  // 버튼 영역
                  Row(
                    children: [
                      // 취소 버튼
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      color.outline.withValues(alpha: 0.5),
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightXmark,
                                      size: 14,
                                      color: color.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      // "Cancel"
                                      '취소'.tr(),
                                      style: text.labelLarge?.copyWith(
                                        color: color.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // 검색 버튼
                      Expanded(
                        flex: 2,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onSearch,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.primary,
                                    color.primary.withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: color.primary,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.lightMagnifyingGlass,
                                      size: 16,
                                      color: color.onPrimary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      // "Search"
                                      '검색'.tr(),
                                      style: text.labelLarge?.copyWith(
                                        color: color.onPrimary,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 250.ms, delay: 200.ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 250.ms,
                        curve: Curves.easeOut,
                      ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 200.ms),
    );
  }
}
