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
    this.hintText = 'Select Category',
  });

  /// Initial category value (can be predefined or custom)
  final String? initialValue;

  /// Callback when category changes
  final void Function(String? category) onChanged;

  /// Optional validator for the field
  final String? Function(String?)? validator;

  final String label;
  final String hintText;

  @override
  State<CategoryDropdownField> createState() => _CategoryDropdownFieldState();
}

class _CategoryDropdownFieldState extends State<CategoryDropdownField> {
  final TextEditingController _customCategoryController =
      TextEditingController();

  String? _selectedCategory;
  bool _isCustomCategory = false;

  /// Available predefined categories
  final List<Map<String, dynamic>> categories = [
    {'id': 'public-office', 'name': 'Public Office'},
    {'id': 'education', 'name': 'Education'},
    {'id': 'food', 'name': 'Food'},
    {'id': 'transport', 'name': 'Transport'},
    {'id': 'hospital', 'name': 'Hospital'},
    {'id': 'mart', 'name': 'Mart'},
    {'id': 'bank', 'name': 'Bank'},
    {'id': 'gadget', 'name': 'Gadget'},
    {'id': 'travel-agency', 'name': 'Travel Agency'},
    {'id': 'hotel', 'name': 'Hotel'},
    {'id': 'rentcar', 'name': 'Rent Car'},
    {'id': 'beauty', 'name': 'Beauty'},
    {'id': 'real-estate', 'name': 'Real Estate'},
    {'id': 'ktv', 'name': 'KTV'},
    {'id': 'spa', 'name': 'Spa'},
    {'id': 'etc', 'name': 'ETC'},
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with the provided value
    final initialValue = widget.initialValue;

    final predefinedCategories = categories
        .map((cat) => cat['id'] as String)
        .toList();

    if (initialValue != null && initialValue.isNotEmpty) {
      if (predefinedCategories.contains(initialValue)) {
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
        /// Label
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        /// Dropdown
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category['id'] as String,
                child: Text(category['name'] as String),
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
        ),
      ],
    );
  }
}
