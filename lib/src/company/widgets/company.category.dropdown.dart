import 'package:flutter/material.dart';

/// Category Dropdown Field with Custom Input Option
///
/// A combined dropdown and text field widget for category selection.
/// Allows users to either select from predefined categories or enter a custom category.
class CategoryDropdownField extends StatefulWidget {
  const CategoryDropdownField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.validator,
    this.hintText,
    this.categoryNames,
  });

  /// Initial category value (can be predefined or custom)
  final String? initialValue;

  /// Callback when category changes
  final void Function(String? category) onChanged;

  /// Optional validator for the field
  final String? Function(String?)? validator;

  final String label;

  /// Hint text for the dropdown (i18n)
  final String? hintText;

  /// Localized category names map (id -> displayName) for i18n support.
  /// If not provided, falls back to default English names.
  final Map<String, String>? categoryNames;

  @override
  State<CategoryDropdownField> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends State<CategoryDropdownField> {
  final TextEditingController _customCategoryController =
      TextEditingController();

  String? _selectedCategory;
  bool _isCustomCategory = false;

  /// Available predefined category IDs
  static const List<String> _categoryIds = [
    'public-office', 'education', 'food', 'transport',
    'hospital', 'mart', 'bank', 'gadget',
    'travel-agency', 'hotel', 'rentcar', 'beauty',
    'real-estate', 'ktv', 'spa', 'etc',
  ];

  /// Default English category names (fallback when categoryNames is null)
  static const Map<String, String> _defaultNames = {
    'public-office': 'Public Office', 'education': 'Education',
    'food': 'Food', 'transport': 'Transport',
    'hospital': 'Hospital', 'mart': 'Mart',
    'bank': 'Bank', 'gadget': 'Gadget',
    'travel-agency': 'Travel Agency', 'hotel': 'Hotel',
    'rentcar': 'Rent Car', 'beauty': 'Beauty',
    'real-estate': 'Real Estate', 'ktv': 'KTV',
    'spa': 'Spa', 'etc': 'ETC',
  };

  /// Get display name for a category ID, using i18n names if available
  String _getDisplayName(String id) {
    return widget.categoryNames?[id] ?? _defaultNames[id] ?? id;
  }

  @override
  void initState() {
    super.initState();

    // Initialize with the provided value
    final initialValue = widget.initialValue;

    if (initialValue != null && initialValue.isNotEmpty) {
      if (_categoryIds.contains(initialValue)) {
        // Predefined category
        _selectedCategory = initialValue;
        _isCustomCategory = false;
      } else {
        // Custom category
        _selectedCategory = 'custom';
        _customCategoryController.text = initialValue;
        _isCustomCategory = true;
      }
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  /// Get the current category value
  String? get currentValue {
    if (_selectedCategory == null) return null;
    if (_isCustomCategory) {
      final customText = _customCategoryController.text.trim();
      return customText.isEmpty ? null : customText;
    }
    return _selectedCategory;
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

        /// Comic Design: Dropdown with Comic styling
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: _categoryIds.map((id) {
            return DropdownMenuItem<String>(
              value: id,
              child: Text(_getDisplayName(id)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;

              widget.onChanged(currentValue);
            });
          },
          validator: (value) {
            if (widget.validator != null) {
              return widget.validator!(currentValue);
            }
            return null;
          },
        ),
      ],
    );
  }
}
