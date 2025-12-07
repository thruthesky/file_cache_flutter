import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:philgo/api/banner.api.dart';
import 'package:philgo/models/banner.model.dart';

class HomeTopBanner extends StatefulWidget {
  final String? category;
  const HomeTopBanner({super.key, this.category});

  @override
  State<HomeTopBanner> createState() => _HomeTopBannerState();
}

class _HomeTopBannerState extends State<HomeTopBanner> {
  List<BannerModel> banners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBanners();
  }

  Future<void> loadBanners() async {
    final result = await BannerApi.getTopBanners(category: widget.category);
    // log('Top Banners Loaded: ${result['left']?.length} left, ${result['right']?.length} right');
    if (mounted) {
      setState(() {
        // Combine left and right banners for mobile/vertical display
        banners = [...result['left']!, ...result['right']!];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    // DEBUG: If empty, show a placeholder to verify widget integration
    if (banners.isEmpty) {
      // return const SizedBox.shrink(); // Original code
      return Container(
        width: double.infinity,
        height: 50,
        color: Colors.red.withOpacity(0.2),
        child: const Center(child: Text('HomeTopBanner: No Data')),
      );
    }

    return Column(
      children: banners.map((banner) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () async {
              if (banner.link.isNotEmpty) {
                final uri = Uri.tryParse(banner.link);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                banner.url,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
