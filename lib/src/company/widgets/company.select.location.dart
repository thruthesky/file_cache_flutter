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
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Comic Design: Label with Comic styling
        Text(
          widget.label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 8),

        /// Comic Design: TextField with Comic styling
        TextFormField(
          controller: widget.controller,
          readOnly: true,
          onTap: _openLocationModal,
          decoration: InputDecoration(
            hintText: 'Select location',
            filled: true,
            fillColor: scheme.surface,
            // Comic Design: 1.0px border with borderRadius 12
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.outline, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: scheme.primary, width: 1.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: scheme.outline.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
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
        // Comic Design: Rounded top corners with 12px radius
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        // Comic Design: 2.0px border on top, left, and right
        border: Border(
          top: BorderSide(color: scheme.outline, width: 2.0),
          left: BorderSide(color: scheme.outline, width: 2.0),
          right: BorderSide(color: scheme.outline, width: 2.0),
        ),
      ),
      child: Column(
        children: [
          /// Comic Design: Drag handle indicator
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          /// Header
          Padding(
            padding: EdgeInsets.all(16),
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

          /// Comic Design: Search box with Comic styling
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search location...',
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
                fillColor: scheme.surface,
                // Comic Design: 1.0px border with borderRadius 12
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outline, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.outline, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary, width: 1.0),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Container(
                          // Comic Design: Card with 1.5px border (list item style)
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: scheme.outline,
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => widget.onLocationSelected(location),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
