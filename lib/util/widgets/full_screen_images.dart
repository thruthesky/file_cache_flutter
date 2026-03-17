import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Image lightbox widget for viewing images in fullscreen
///
/// Supports:
/// - Pinch to zoom
/// - Double tap to zoom
/// - Swipe between images
/// - Page indicator
class FullScreenImages extends StatefulWidget {
  const FullScreenImages({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  @override
  State<FullScreenImages> createState() => _FullScreenImagesState();
}

class _FullScreenImagesState extends State<FullScreenImages> {
  late PageController _pageController;
  late int _currentIndex;
  final TransformationController _transformationController =
      TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isCurrentlyZoomed = scale > 1.0;
    if (isCurrentlyZoomed != _isZoomed) {
      setState(() {
        _isZoomed = isCurrentlyZoomed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image viewer
          PageView.builder(
            controller: _pageController,
            physics: _isZoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _transformationController.value = Matrix4.identity();
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return _buildImageViewer(widget.imageUrls[index]);
            },
          ),

          if (widget.imageUrls.length > 1 && !_isZoomed && _currentIndex > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationArrow(
                  icon: FontAwesomeIcons.lightChevronLeft,
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ),

          if (widget.imageUrls.length > 1 &&
              !_isZoomed &&
              _currentIndex < widget.imageUrls.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationArrow(
                  icon: FontAwesomeIcons.lightChevronRight,
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
            ),

          // Top bar with close button and page indicator
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      if (widget.imageUrls.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${widget.imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom thumbnail strip (only if multiple images and not zoomed)
          if (widget.imageUrls.length > 1 && !_isZoomed)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) {
                        final isActive = index == _currentIndex;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 76,
                            height: 76,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrls[index],
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => Container(
                                  color: Colors.grey.shade800,
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white54,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  color: Colors.grey.shade800,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 24,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageViewer(String imageUrl) {
    return GestureDetector(
      onDoubleTapDown: (details) {
        final currentScale = _transformationController.value
            .getMaxScaleOnAxis();
        if (currentScale > 1.0) {
          _transformationController.value = Matrix4.identity();
        } else {
          final position = details.localPosition;
          const zoomScale = 2.0;
          _transformationController.value = Matrix4.identity()
            ..translate(
              -position.dx * (zoomScale - 1),
              -position.dy * (zoomScale - 1),
            )
            ..scale(zoomScale);
        }
      },
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            errorWidget: (_, _, _) => const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(child: FaIcon(icon, color: Colors.white, size: 20)),
        ),
      ),
    );
  }
}

/// Helper function to show image lightbox
void showFullScreenImages({
  required BuildContext context,
  required List<String> imageUrls,
  int initialIndex = 0,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) =>
          FullScreenImages(imageUrls: imageUrls, initialIndex: initialIndex),
    ),
  );
}
