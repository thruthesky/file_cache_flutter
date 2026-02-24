import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'company.image.placeholder.dart';

/// Company Card Widget (업체 카드 위젯)
///
/// Masonry 레이아웃에 최적화된 업체 카드입니다.
/// - 이미지 비율에 따른 동적 높이 조절
/// - 카테고리 아이콘 + 업체명 오버레이
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
  static const double minImageHeight = 140.0;
  static const double maxImageHeight = 300.0;

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
        child: hasImage
            ? _buildImageContent(theme, scheme)
            : _buildFallback(theme, scheme),
      ),
    );
  }

  /// Fallback UI (이미지가 없을 때)
  ///
  /// 그라데이션 배경 + 큰 카테고리 아이콘 + 업체명을 표시합니다.
  /// Beautiful fallback with gradient background, large category icon, and company name
  Widget _buildFallback(ThemeData theme, ColorScheme scheme) {
    return Container(
      /// 이미지가 없을 때 최소 높이 적용
      height: CompanyCard.minImageHeight,
      width: double.infinity,

      /// 그라데이션 배경 (primary 색상 기반)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.08),
            scheme.primary.withValues(alpha: 0.15),
            scheme.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          /// 중앙의 큰 카테고리 아이콘
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Center(
              child: FaIcon(
                widget.categoryIcon,
                size: 48,
                color: scheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ),

          /// 하단 업체명 + 카테고리 아이콘
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    scheme.surface.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Row(
                children: [
                  /// 카테고리 아이콘 (작은 사이즈)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: FaIcon(
                        widget.categoryIcon,
                        size: 14,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  /// 업체명
                  Expanded(
                    child: Text(
                      widget.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme, ColorScheme scheme) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl!,
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) {
        if (_cachedHeight != null) {
          return _buildImageContainer(
            imageProvider,
            _cachedHeight!,
            theme,
            scheme,
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

  Widget _buildImageContainer(
    ImageProvider imageProvider,
    double height,
    ThemeData theme,
    ColorScheme scheme,
  ) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: imageProvider, fit: BoxFit.cover),
          _buildOverlay(theme, scheme),
        ],
      ),
    );
  }

  /// 이미지 오버레이 (Image Overlay)
  ///
  /// 그라데이션 배경 위에 카테고리 아이콘 + 업체명을 표시합니다.
  /// Shows category icon + company name on gradient background
  Widget _buildOverlay(ThemeData theme, ColorScheme scheme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 20, 12, 14),
        decoration: BoxDecoration(
          /// Theme-based gradient overlay for image readability
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              scheme.scrim.withValues(alpha: 0.5),
              scheme.scrim.withValues(alpha: 0.75),
            ],
          ),
        ),
        child: Row(
          children: [
            /// 카테고리 아이콘 배지 (반투명 배경)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: scheme.surface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: FaIcon(
                  widget.categoryIcon,
                  size: 14,
                  color: scheme.surface,
                ),
              ),
            ),
            const SizedBox(width: 8),

            /// 업체명
            Expanded(
              child: Text(
                widget.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.surface,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: scheme.scrim.withValues(alpha: 0.5),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
