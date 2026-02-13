import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Full screen image viewer with pinch-to-zoom functionality
class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigate to previous image
  void _goToPreviousImage() {
    if (_currentIndex > 0) {
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to next image
  void _goToNextImage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          /// Main image viewer with zoom capability and navigation buttons
          Expanded(
            child: Stack(
              children: [
                // PageView for swiping between images
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return _buildImagePage(widget.imageUrls[index]);
                  },
                ),
                // Left navigation button
                if (_currentIndex > 0)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationButton(
                        icon: Icons.chevron_left,
                        onPressed: _goToPreviousImage,
                      ),
                    ),
                  ),
                // Right navigation button
                if (_currentIndex < widget.imageUrls.length - 1)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _buildNavigationButton(
                        icon: Icons.chevron_right,
                        onPressed: _goToNextImage,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          /// Bottom thumbnail navigation bar
          _buildThumbnailBar(),
        ],
      ),
    );
  }

  Widget _buildImagePage(String imageUrl) {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the bottom thumbnail navigation bar
  Widget _buildThumbnailBar() {
    return Container(
      height: 80,
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return _buildThumbnailItem(index);
        },
      ),
    );
  }

  /// Builds navigation button for left/right navigation
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 150),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(
          minWidth: 56,
          minHeight: 56,
        ),
      ),
    );
  }

  /// Builds individual thumbnail item with selection indicator
  Widget _buildThumbnailItem(int index) {
    final isSelected = index == _currentIndex;

    return GestureDetector(
      onTap: () {
        // Navigate to selected image
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrls[index],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
