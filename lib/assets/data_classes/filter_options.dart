// lib/assets/components/filter_options.dart
import 'package:flutter/material.dart';

/// Enum defining the type of UI control for a filter.
enum FilterType {
  checkboxes, // Multiple selection
  radioButtons, // Single selection
  rangeSlider, // For numerical ranges (e.g., price, age)
  // Add other types as needed (e.g., dropdown, dateRange)
}

/// Represents a single filter option available to the user.
class FilterOption {
  final String
      id; // Unique identifier (e.g., 'category', 'minAge', 'priceRange')
  final String
      label; // User-facing label (e.g., 'Categoría', 'Edad Mínima', 'Rango de Precio')
  final FilterType type;
  final List<Map<String, dynamic>>?
      options; // Options for checkboxes/radio (e.g., [{'label': 'Vacuna', 'value': 'vaccine'}, ...])
  final RangeValues?
      rangeLimits; // Min/max possible values for rangeSlider (e.g., RangeValues(0, 100))
  final dynamic
      initialValue; // Default value (e.g., [], '', RangeValues(0, 100))

  FilterOption({
    required this.id,
    required this.label,
    required this.type,
    this.options, // Required for checkboxes/radio
    this.rangeLimits, // Required for rangeSlider
    this.initialValue,
  }) {
    // Basic validation
    if ((type == FilterType.checkboxes || type == FilterType.radioButtons) &&
        options == null) {
      throw ArgumentError(
          'Options must be provided for checkboxes or radioButtons type.');
    }
    if (type == FilterType.rangeSlider && rangeLimits == null) {
      throw ArgumentError(
          'Range limits must be provided for rangeSlider type.');
    }
  }
}
