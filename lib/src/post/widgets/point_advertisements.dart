import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// 포인트 광고 목록 위젯
/// Point Advertisements Widget
///
/// 게시글 목록 상단 (SmallBanners 아래)에 표시되는 포인트 광고 목록입니다.
/// 포인트를 사용하여 게시판 상단에 노출된 광고 게시글을 표시합니다.
///
/// [advertisements]: 포인트 광고 목록 (필수)
/// - PostList.pointAdvertisements 에서 전달받습니다.
/// - 빈 리스트인 경우 빈 위젯(SizedBox.shrink)을 반환합니다.
///
/// [onTap]: 광고 클릭 시 호출되는 콜백 (필수)
/// - 광고의 clickUrl (link 또는 viewUrl)을 파라미터로 전달합니다.
/// - 외부 링크 열기, 내부 라우팅 등을 처리할 수 있습니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// PointAdvertisements(
///   advertisements: postList.pointAdvertisements,
///   onTap: (url) => openUrl(context, url),
/// )
/// ```
///
/// ### UI 구조 (Layout):
/// ```
/// ┌──────────────────────────────────────┐
/// │ [160x80 이미지] │ [제목 (최대 1줄)]    │
/// │                │ [조회수 · D-n 뱃지]   │
/// └──────────────────────────────────────┘
/// ```
class PointAdvertisements extends StatelessWidget {
  /// 포인트 광고 목록 (필수)
  /// Point advertisement list (required)
  final List<PointAdvertisement> advertisements;

  /// 광고 클릭 시 호출되는 콜백
  /// Callback when advertisement is tapped
  ///
  /// clickUrl (link 또는 viewUrl)을 파라미터로 전달합니다.
  /// Receives clickUrl (link or viewUrl) as parameter.
  final void Function(String url) onTap;

  const PointAdvertisements({
    super.key,
    required this.advertisements,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// 디버그: 광고 위젯 빌드 확인
    // d('[PointAdvertisements] build - 광고 개수: ${advertisements.length}');

    /// 광고가 없으면 빈 위젯 반환
    /// Return empty widget if no advertisements
    if (advertisements.isEmpty) {
      // d('[PointAdvertisements] 광고 없음 - SizedBox.shrink 반환');
      return const SizedBox.shrink();
    }

    // d('[PointAdvertisements] 광고 표시 중...');
    // for (var ad in advertisements) {
    //   d('[PointAdvertisements] 광고: idx=${ad.idx}, subject=${ad.subject}');
    // }

    return Column(
      children: advertisements.map((ad) {
        return Padding(
          /// 컴팩트한 패딩 (8의 배수)
          /// Compact padding (multiple of 8)
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: _buildAdItem(context, ad),
        );
      }).toList(),
    );
  }

  /// 개별 광고 아이템 빌드 (컴팩트 디자인)
  /// Build individual advertisement item (compact design)
  Widget _buildAdItem(BuildContext context, PointAdvertisement ad) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      /// 광고 클릭 시 콜백 호출
      /// Call callback on advertisement tap
      onTap: () => onTap(ad.clickUrl),

      /// 배경색 없이 Row만 사용 (컴팩트 디자인)
      /// No background color, just Row (compact design)
      child: Row(
        children: [
          /// 이미지가 있으면 왼쪽에 표시
          /// Show image on the left if available
          if (ad.firstImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),

              /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
              /// CachedNetworkImage: Improved performance with image caching
              child: CachedNetworkImage(
                imageUrl: ad.firstImageUrl!,
                width: 72,
                height: 72,
                fit: BoxFit.cover,

                /// 이미지 로드 실패 시 동일 크기의 빈 위젯 반환
                /// Return empty widget with same size on image load error
                errorWidget: (context, url, error) =>
                    const SizedBox(width: 72, height: 72),
              ),
            ),

          const SizedBox(width: 8),

          /// 텍스트 영역 (제목, 조회수, D-day)
          /// Text area (subject, views, D-day)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 제목 (최대 1줄)
                /// Subject (max 1 line)
                Text(
                  ad.subject,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                /// 조회수 · D-day 영역
                /// Views · D-day area
                Row(
                  children: [
                    /// 조회수 텍스트
                    /// Views text
                    Text(
                      '조회 ${_formatNumber(ad.noOfView)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),

                    /// 구분자
                    /// Separator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '·',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    /// D-day 텍스트 (뱃지 대신 간단한 텍스트)
                    /// D-day text (simple text instead of badge)
                    Text(
                      'D-${ad.remainingDays}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 숫자 포맷팅 (1000 → 1K, 1000000 → 1M)
  /// Format number (1000 → 1K, 1000000 → 1M)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
