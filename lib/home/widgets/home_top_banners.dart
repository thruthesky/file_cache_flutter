import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo/advertisement/advertisement.model.dart';
import 'package:philgo/advertisement/advertisement.service.dart';
import 'package:philgo/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 상단 배너 - 좌/우 배너 로테이션
///
/// v7 advertisement.topBanners API로 배너를 가져와 표시한다.
/// 고정되지 않은 배너는 9초마다 자동 로테이션된다.
class HomeTopBanners extends StatefulWidget {
  const HomeTopBanners({super.key});

  @override
  State<HomeTopBanners> createState() => _HomeTopBannersState();
}

class _HomeTopBannersState extends State<HomeTopBanners> {
  TopBannersResult? _result;
  bool _loading = true;
  Timer? _leftTimer;
  Timer? _rightTimer;
  int _leftIndex = 0;
  int _rightIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  @override
  void dispose() {
    _leftTimer?.cancel();
    _rightTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final result = await AdvertisementService.topBanners();
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
      _startRotation();
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startRotation() {
    final result = _result;
    if (result == null) return;

    if (!result.leftFixed && result.left.length > 1) {
      _leftTimer = Timer.periodic(const Duration(seconds: 9), (_) {
        if (mounted) {
          setState(() => _leftIndex = (_leftIndex + 1) % result.left.length);
        }
      });
    }

    if (!result.rightFixed && result.right.length > 1) {
      _rightTimer = Timer.periodic(const Duration(seconds: 9), (_) {
        if (mounted) {
          setState(() => _rightIndex = (_rightIndex + 1) % result.right.length);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final result = _result;
    if (result == null ||
        (result.left.isEmpty && result.right.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (result.left.isNotEmpty)
          Expanded(
            child: _buildBannerSlot(
              result.left,
              _leftIndex % result.left.length,
            ),
          ),
        if (result.left.isNotEmpty && result.right.isNotEmpty)
          const SizedBox(width: 2),
        if (result.right.isNotEmpty)
          Expanded(
            child: _buildBannerSlot(
              result.right,
              _rightIndex % result.right.length,
            ),
          ),
      ],
    );
  }

  Widget _buildBannerSlot(List<BannerModel> banners, int index) {
    final banner = banners[index];
    return GestureDetector(
      onTap: () => _openBannerUrl(banner.clickUrl),
      child: AspectRatio(
        aspectRatio: 3,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: CachedNetworkImage(
            key: ValueKey(banner.idx),
            imageUrl: banner.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: color.surfaceContainerLow),
            errorWidget: (_, __, ___) => Container(
              color: color.surfaceContainerLow,
              child: Icon(Icons.image_not_supported, color: color.outline),
            ),
          ),
        ),
      ),
    );
  }

  void _openBannerUrl(String url) {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
