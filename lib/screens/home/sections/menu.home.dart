import 'package:flutter/material.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/widgets/home/menu/menu.list.dart';

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      children: [
        /// Top SafeArea
        SafeArea(child: Container()),

        /// Menu title
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                Lo.of(context)!.menu,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        /// Scrollable menu content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: MenuList(spacing: 8),
          ),
        ),
      ],
    );
  }
}
