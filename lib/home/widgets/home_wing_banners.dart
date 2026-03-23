import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:philgo/advertisement/advertisement.model.dart';
import 'package:philgo/advertisement/advertisement.service.dart';
import 'package:philgo/advertisement/advertisement.view.screen.dart';
import 'package:philgo/globals.dart';
import 'package:url_launcher/url_launcher.dart';

/// 홈 날개 배너 - 5열 그리드 (패딩 없음)
///
/// v7 advertisement.wingBanners API로 배너를 가져와 정사각형 그리드로 표시한다.
class HomeWingBanners extends StatefulWidget {
  const HomeWingBanners({super.key});

  @override
  State<HomeWingBanners> createState() => _HomeWingBannersState();
}

class _HomeWingBannersState extends State<HomeWingBanners> {
  List<BannerModel> _banners = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final result = await AdvertisementService.wingBanners();
      if (!mounted) return;
      setState(() {
        _banners = result.all;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _banners.isEmpty) return const SizedBox.shrink();

    const crossAxisCount = 5;
    const spacing = 2.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final itemSize =
        (screenWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: _banners.map((banner) {
          return GestureDetector(
            onTap: () => _openBannerUrl(banner.clickUrl),
            child: SizedBox(
              width: itemSize,
              height: itemSize,
              child: CachedNetworkImage(
                imageUrl: banner.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: color.surfaceContainerLow),
                errorWidget: (_, _, _) => Container(
                  color: color.surfaceContainerLow,
                  child: Icon(Icons.image_not_supported,
                      size: 16, color: color.outline),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _openBannerUrl(String url) {
    if (url.isEmpty) return;

    // 숫자만이면 post idx → AdvertisementViewScreen
    if (RegExp(r'^\d+$').hasMatch(url)) {
      final idx = int.tryParse(url);
      if (idx != null && idx > 0) {
        AdvertisementViewScreen.push(context, idx: idx);
        return;
      }
    }

    // idx=xxx 패턴이면 post idx 추출
    final match = RegExp(r'idx=(\d+)').firstMatch(url);
    if (match != null) {
      final idx = int.tryParse(match.group(1) ?? '');
      if (idx != null && idx > 0) {
        AdvertisementViewScreen.push(context, idx: idx);
        return;
      }
    }

    // 일반 URL → 외부 브라우저
    final uri = Uri.tryParse(url);
    if (uri != null) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
