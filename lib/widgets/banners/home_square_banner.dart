import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:philgo/api/banner.api.dart';
import 'package:philgo/models/banner.model.dart';
import 'dart:developer';

class HomeSquareBanner extends StatefulWidget {
  final String? category;
  const HomeSquareBanner({super.key, this.category});

  @override
  State<HomeSquareBanner> createState() => _HomeSquareBannerState();
}

class _HomeSquareBannerState extends State<HomeSquareBanner> {
  List<BannerModel> banners = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBanners();
  }

  Future<void> loadBanners() async {
    // Note: We use getWingBanners API but display them as "Square" banners in the main feed.
    final result = await BannerApi.getWingBanners(category: widget.category);
    log(
      'Square(Wing) Banners Loaded: ${result['left']?.length} left, ${result['right']?.length} right',
    );

    if (mounted) {
      setState(() {
        // Combine left and right banners
        banners = [...result['left']!, ...result['right']!];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const SizedBox.shrink();

    // DEBUG: Fallback if empty
    if (banners.isEmpty) {
      return Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.blue.withOpacity(0.2),
        child: const Center(
          child: Text('HomeSquareBanner (Wing Data): No Data'),
        ),
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
                // Adjust fit/height as needed.
                // Often 'contain' is better if aspect ratios vary,
                // but 'cover' with a specific aspect ratio container is more uniform.
                fit: BoxFit.contain,
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
