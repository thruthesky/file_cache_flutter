import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'company.image.placeholder.dart';

/// Company Card Widget
/// Visually aligned with PostCard for masonry layouts:
/// - Dynamic height based on image aspect ratio
/// - Gradient overlay with company name
/// - Comic design border + rounded corners
class CompanyCard extends StatefulWidget {
  const CompanyCard({
    super.key,
    required this.name,
    required this.categoryIcon,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final IconData categoryIcon;
  final String? imageUrl;
  final VoidCallback? onTap;

  static const double minImageHeight = 140.0;
  static const double maxImageHeight = 300.0;
  static final Map<String, double> _heightCache = {};

  @override
  State<CompanyCard> createState() => _CompanyCardState();
}

class _CompanyCardState extends State<CompanyCard> {
  double? get _cachedHeight =>
      widget.imageUrl != null ? CompanyCard._heightCache[widget.imageUrl!] : null;

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
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outline, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: hasImage ? _buildImageContent(theme, scheme) : _buildFallback(theme, scheme),
      ),
    );
  }

  Widget _buildFallback(ThemeData theme, ColorScheme scheme) {
    return SizedBox(
      height: CompanyCard.minImageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CompanyImagePlaceholder(icon: widget.categoryIcon),
          _buildOverlay(theme),
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
          return _buildImageContainer(imageProvider, _cachedHeight!, theme, scheme);
        }

        return Image(
          image: imageProvider,
          fit: BoxFit.cover,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null && _cachedHeight == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                imageProvider.resolve(const ImageConfiguration()).addListener(
                  ImageStreamListener((info, _) {
                    if (!mounted || _cachedHeight != null) return;
                    final aspectRatio = info.image.width / info.image.height;
                    final screenWidth = MediaQuery.of(context).size.width;
                    final cardWidth = (screenWidth - 24) / 2;
                    final calculatedHeight =
                        (cardWidth / aspectRatio).clamp(
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
          _buildOverlay(theme),
        ],
      ),
    );
  }

  Widget _buildOverlay(ThemeData theme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.65),
              Colors.black.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Text(
          widget.name,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
