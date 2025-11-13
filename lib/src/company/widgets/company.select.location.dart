import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Company Location Selection Widget
///
/// A button-style field that opens a searchable modal bottom sheet
/// to select a location from a predefined list
class CompanySelectLocation extends StatefulWidget {
  const CompanySelectLocation({
    super.key,
    required this.label,
    this.controller,
    this.onLocationSelected,
  });

  final String label;
  final TextEditingController? controller;
  final void Function(String)? onLocationSelected;

  @override
  State<CompanySelectLocation> createState() => _CompanySelectLocationState();
}

class _CompanySelectLocationState extends State<CompanySelectLocation> {
  void _openLocationModal() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _LocationSearchModal(
          locations: locations,
          onLocationSelected: (location) {
            if (widget.controller != null) {
              widget.controller!.text = location;
            }
            if (widget.onLocationSelected != null) {
              widget.onLocationSelected!(location);
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFieldSet(
      controller: widget.controller,
      label: widget.label,
      hintText: 'Select location',
      prefixFaIconData: FontAwesomeIcons.lightMapPin,
      readOnly: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      onTap: _openLocationModal,
    );
  }
}

/// Location Search Modal Bottom Sheet
class _LocationSearchModal extends StatefulWidget {
  const _LocationSearchModal({
    required this.locations,
    required this.onLocationSelected,
  });

  final List<String> locations;
  final void Function(String) onLocationSelected;

  @override
  State<_LocationSearchModal> createState() => _LocationSearchModalState();
}

class _LocationSearchModalState extends State<_LocationSearchModal> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = widget.locations;
    _searchController.addListener(_filterLocations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredLocations = widget.locations;
    } else {
      _filteredLocations = widget.locations
          .where((location) => location.toLowerCase().contains(query))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          /// Modal handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          /// Header
          Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: FaIcon(
                    FontAwesomeIcons.xmark,
                    size: 20,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          /// Search box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search location...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(12),
                  child: FaIcon(
                    FontAwesomeIcons.lightMagnifyingGlass,
                    size: 20,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: FaIcon(
                          FontAwesomeIcons.xmark,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          /// Location list
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightLocationCrosshairs,
                          size: 48,
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No locations found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredLocations.length,
                    padding: EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return InkWell(
                        onTap: () => widget.onLocationSelected(location),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: FaIcon(
                                  FontAwesomeIcons.lightLocationDot,
                                  size: 16,
                                  color: scheme.primary,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  location,
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ),
                              FaIcon(
                                FontAwesomeIcons.lightChevronRight,
                                size: 16,
                                color: scheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
