import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/src/post/models/point_advertisement.model.dart';

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
    /// 광고가 없으면 빈 위젯 반환
    /// Return empty widget if no advertisements
    if (advertisements.isEmpty) return const SizedBox.shrink();

    return Column(
      children: advertisements.map((ad) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: _buildAdItem(context, ad),
        );
      }).toList(),
    );
  }

  /// 개별 광고 아이템 빌드
  /// Build individual advertisement item
  Widget _buildAdItem(BuildContext context, PointAdvertisement ad) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      /// 광고 클릭 시 콜백 호출
      /// Call callback on advertisement tap
      onTap: () => onTap(ad.clickUrl),
      child: Container(
        /// Flat design: elevation 0, 배경색만으로 구분
        /// Flat design: no elevation, distinguish by background color
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            /// 이미지가 있으면 왼쪽에 표시
            /// Show image on the left if available
            if (ad.firstImageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),

                /// CachedNetworkImage: 이미지 캐싱으로 성능 향상
                /// CachedNetworkImage: Improved performance with image caching
                child: CachedNetworkImage(
                  imageUrl: ad.firstImageUrl!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,

                  /// 이미지 로드 실패 시 동일 크기의 빈 위젯 반환
                  /// Return empty widget with same size on image load error
                  errorWidget: (context, url, error) =>
                      const SizedBox(width: 160, height: 80),
                ),
              ),

            /// 텍스트 영역 (제목, 조회수, D-day)
            /// Text area (subject, views, D-day)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 제목 (최대 1줄)
                    /// Subject (max 1 line)
                    Text(
                      ad.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    /// 조회수 · D-day 영역
                    /// Views · D-day area
                    Row(
                      children: [
                        /// 조회수 텍스트
                        /// Views text
                        Text(
                          '조회 ${_formatNumber(ad.noOfView)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),

                        /// 구분자
                        /// Separator
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '·',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),

                        /// D-day 뱃지
                        /// D-day badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'D-${ad.remainingDays}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
