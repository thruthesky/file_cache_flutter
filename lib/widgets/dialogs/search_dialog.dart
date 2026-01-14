import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 검색 다이얼로그 위젯 (Search Dialog Widget)
/// 검색어를 입력받아 반환하는 모달 다이얼로그
/// Comic 스타일 적용: 2.0 테두리, 그림자 없음, 둥근 모서리
/// 세련된 애니메이션과 그라데이션 효과 적용
class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  /// 다이얼로그 표시 정적 메서드
  /// 검색어를 입력받아 String?으로 반환
  /// 취소 시 null 반환
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
  /// 검색어 입력 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 포커스 노드 - 다이얼로그 열릴 때 자동 포커스
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 다이얼로그 열릴 때 자동으로 키보드 표시
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

  /// 검색 실행 - 검색어가 있으면 반환
  void _onSearch() {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      Navigator.pop(context, searchTerm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lo = Lo.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline, width: 2.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - 그라데이션 배경과 아이콘 강조
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primaryContainer,
                    colorScheme.primaryContainer.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: 2.0),
                ),
              ),
              child: Row(
                children: [
                  /// 검색 아이콘 - 원형 배경으로 강조
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.lightMagnifyingGlass,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    lo.searchHint,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),

                  /// 닫기 버튼 - 호버 효과가 있는 원형 버튼
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
                            color: colorScheme.outline.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.lightXmark,
                          size: 14,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),

            /// 검색어 입력 영역 - 충분한 여백과 세련된 스타일
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// 검색어 입력 필드 - 큰 사이즈와 부드러운 스타일
                  TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: '${lo.searchHint}...',
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14),
                        child: FaIcon(
                          FontAwesomeIcons.lightMagnifyingGlass,
                          size: 20,
                          color: colorScheme.primary.withValues(alpha: 0.7),
                        ),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2.5,
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                  ).animate().fadeIn(duration: 250.ms, delay: 100.ms).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: 250.ms,
                    curve: Curves.easeOut,
                  ),
                  const SizedBox(height: 20),

                  /// 액션 버튼 영역 - 균형잡힌 레이아웃
                  Row(
                    children: [
                      /// 취소 버튼 - 세련된 아웃라인 스타일
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.outline.withValues(
                                    alpha: 0.5,
                                  ),
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
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      lo.cancel,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
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

                      /// 검색 버튼 - 강조된 Primary 스타일
                      Expanded(
                        flex: 2,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _onSearch,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.primary.withValues(alpha: 0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colorScheme.primary,
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
                                      color: colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      lo.searchHint,
                                      style: textTheme.labelLarge?.copyWith(
                                        color: colorScheme.onPrimary,
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
                  ).animate().fadeIn(duration: 250.ms, delay: 200.ms).slideY(
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
      ).animate().scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: 200.ms,
        curve: Curves.easeOut,
      ).fadeIn(duration: 200.ms),
    );
  }
}
