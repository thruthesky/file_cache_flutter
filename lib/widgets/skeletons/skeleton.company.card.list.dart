import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Skeleton Company Card used in company list screen
class SkeletonCompanyCardList extends StatelessWidget {
  const SkeletonCompanyCardList({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 헤더 스켈레톤
          Container(
                width: 200,
                height: 20,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                duration: 1500.ms,
                color: scheme.surface.withValues(alpha: 0.5),
              ),
          const SizedBox(height: 16), // Match CompanyListGrid spacing
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 이미지 스켈레톤 (16:9 비율 - CompanyCard와 동일)
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(color: scheme.surfaceContainer),
                        ),
                        // 회사 이름 스켈레톤 (CompanyCard와 동일 구조)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 1500.ms,
                    color: scheme.surface.withValues(alpha: 0.5),
                    delay: Duration(milliseconds: index * 100),
                  );
            },
          ),
        ],
      ),
    );
  }
}
