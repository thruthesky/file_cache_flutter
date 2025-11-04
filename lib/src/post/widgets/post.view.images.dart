import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostViewImages extends StatelessWidget {
  const PostViewImages({super.key, required this.files});

  final List<String> files;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: files.asMap().entries.map((entry) {
        final imageUrl = entry.value;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightImage,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
