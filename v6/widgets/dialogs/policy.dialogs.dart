import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/widgets/theme/comic_card.dart';
import 'package:philgo_api/philgo_api.dart';

/// 이용약관 바텀시트 모달을 표시하는 함수
///
/// [context]를 받아서 이용약관 내용을 API에서 가져와 바텀시트로 표시합니다.
/// 로딩 중에는 CircularProgressIndicator를 표시합니다.
Future<void> showTermsAndConditions(BuildContext context) async {
  // 로딩 다이얼로그 표시
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(child: CircularProgressIndicator());
    },
  );

  try {
    final String privacyData = await philgoApiGetTermsAndConditions();

    if (context.mounted) Navigator.of(context).pop();

    // 이용약관 내용을 바텀시트로 표시
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  // Comic theme: add border to bottom sheet
                  border: Border.all(color: scheme.outline, width: 2.0),
                ),
                child: Column(
                  children: [
                    /// 드래그 핸들
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    /// 헤더
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              Lo.of(context)!.termsOfService,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.lightXmark,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 내용
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ComicCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            privacyData.replaceAll('\\n', '\n'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  } catch (e) {
    // 로딩 다이얼로그 닫기
    if (context.mounted) Navigator.of(context).pop();

    // 에러 처리 - 에러 메시지 표시
    if (context.mounted) {
      showErrorSnackBar(context, e.toString());
    }
  }
}

/// 개인정보 처리 정책 바텀시트 모달을 표시하는 함수
///
/// [context]를 받아서 개인정보 처리 정책 내용을 API에서 가져와 바텀시트로 표시합니다.
/// 로딩 중에는 CircularProgressIndicator를 표시합니다.
Future<void> showPrivacyPolicy(BuildContext context) async {
  // 로딩 다이얼로그 표시
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(child: CircularProgressIndicator());
    },
  );

  try {
    // API 호출하여 개인정보 처리 정책 가져오기
    final termsData = await philgoApiGetPrivacyPolicy();

    // 로딩 다이얼로그 닫기
    if (context.mounted) Navigator.of(context).pop();

    // 개인정보 처리 정책 내용을 바텀시트로 표시
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;

          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  // Comic theme: add border to bottom sheet
                  border: Border.all(color: scheme.outline, width: 2.0),
                ),
                child: Column(
                  children: [
                    /// 드래그 핸들
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    /// 헤더
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              Lo.of(context)!.privacyPolicy,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const FaIcon(
                              FontAwesomeIcons.lightXmark,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 내용
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: ComicCard(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            termsData.replaceAll('\\n', '\n'),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  } catch (e) {
    // 로딩 다이얼로그 닫기
    if (context.mounted) Navigator.of(context).pop();

    // 에러 처리 - 에러 메시지 표시
    if (context.mounted) {
      showErrorSnackBar(context, e.toString());
    }
  }
}
