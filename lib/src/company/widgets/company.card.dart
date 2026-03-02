import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'company.image.placeholder.dart';

/// Company Card Widget (업체 카드 위젯)
///
/// Masonry 레이아웃에 최적화된 업체 카드입니다.
/// - 이미지 영역과 텍스트 영역 분리 (깔끔한 카드 구조)
/// - 이미지 비율에 따른 동적 높이 조절
/// - 카테고리 아이콘 + 업체명 하단 표시
/// - Comic 디자인 스타일 (surfaceContainerLowest, outlineVariant 테두리)
/// - 이미지가 없을 때 예쁜 fallback UI (그라데이션 배경 + 큰 아이콘)
class CompanyCard extends StatefulWidget {
  const CompanyCard({
    super.key,
    required this.name,
    required this.categoryIcon,
    this.imageUrl,
    this.onTap,
  });

  /// 업체 이름 (Company name)
  final String name;

  /// 카테고리 아이콘 (Category icon)
  final IconData categoryIcon;

  /// 업체 이미지 URL (Company image URL)
  final String? imageUrl;

  /// 카드 탭 콜백 (Card tap callback)
  final VoidCallback? onTap;

  /// 이미지 최소/최대 높이 (Image min/max height)
  static const double minImageHeight = 100.0;
  static const double maxImageHeight = 220.0;

  /// 이미지 높이 캐시 (Image height cache)
  static final Map<String, double> _heightCache = {};

  @override
  State<CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<CompanyCard> {
  double? get _cachedHeight => widget.imageUrl != null
      ? CompanyCard._heightCache[widget.imageUrl!]
      : null;

  void _setCachedHeight(double height) {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      CompanyCard._heightCache[widget.imageUrl!] = height;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        /// Comic Design: elevation 0 (그림자 없음)
        elevation: 0,
        margin: EdgeInsets.zero,

        /// Comic Design: surfaceContainerLowest 배경색
        color: scheme.surfaceContainerLowest,

        /// Comic Design: 둥근 모서리 + 얇은 테두리
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 이미지 영역
            hasImage
                ? _buildImageContent(scheme)
                : _buildFallbackImage(scheme),

            /// 하단 텍스트 영역 (카테고리 아이콘 + 업체명)
            _buildInfoSection(theme, scheme),
          ],
        ),
      ),
    );
  }

  /// 이미지 없을 때 fallback 영역
  /// 그라데이션 배경 + 큰 카테고리 아이콘
  Widget _buildFallbackImage(ColorScheme scheme) {
    return Container(
      height: CompanyCard.minImageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.06),
            scheme.primary.withValues(alpha: 0.12),
            scheme.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: FaIcon(
          widget.categoryIcon,
          size: 40,
          color: scheme.primary.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  /// 하단 정보 섹션 (카테고리 아이콘 배지 + 업체명)
  Widget _buildInfoSection(ThemeData theme, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Row(
        children: [
          /// 카테고리 아이콘 배지
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: FaIcon(
                widget.categoryIcon,
                size: 12,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),

          /// 업체명
          Expanded(
            child: Text(
              widget.name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 콘텐츠 (CachedNetworkImage 사용)
  Widget _buildImageContent(ColorScheme scheme) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) {
        if (_cachedHeight != null) {
          return SizedBox(
            height: _cachedHeight!,
            width: double.infinity,
            child: Image(image: imageProvider, fit: BoxFit.cover),
          );
        }

        return Image(
          image: imageProvider,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null && _cachedHeight == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                imageProvider
                    .resolve(const ImageConfiguration())
                    .addListener(
                      ImageStreamListener((info, _) {
                        if (!mounted || _cachedHeight != null) return;
                        final aspectRatio =
                            info.image.width / info.image.height;
                        final screenWidth = MediaQuery.of(context).size.width;
                        final cardWidth = (screenWidth - 24) / 2;
                        final calculatedHeight = (cardWidth / aspectRatio)
                            .clamp(
                              CompanyCard.minImageHeight,
                              CompanyCard.maxImageHeight,
                            );
                        _setCachedHeight(calculatedHeight);
                        if (mounted) setState(() {});
                      }),
                    );
              });
            }

            return SizedBox(
              height: _cachedHeight ?? CompanyCard.minImageHeight,
              width: double.infinity,
              child: child,
            );
          },
        );
      },
      placeholder: (context, url) => SizedBox(
        height: _cachedHeight ?? CompanyCard.minImageHeight,
        child: Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: scheme.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => SizedBox(
        height: _cachedHeight ?? CompanyCard.minImageHeight,
        child: CompanyImagePlaceholder(icon: widget.categoryIcon),
      ),
    );
  }
}
