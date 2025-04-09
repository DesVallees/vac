// lib/assets/components/search_and_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:vac/assets/dbTypes/filter_options.dart';

class SearchAndFilterBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Map<String, dynamic>> onFiltersChanged;
  final List<FilterOption> availableFilters;
  final Map<String, dynamic> initialFilters; // To show current active filters
  final String initialSearchText;

  const SearchAndFilterBar({
    super.key,
    required this.onSearchChanged,
    required this.onFiltersChanged,
    required this.availableFilters,
    this.initialFilters = const {},
    this.initialSearchText = '',
  });

  @override
  State<SearchAndFilterBar> createState() => _SearchAndFilterBarState();
}

class _SearchAndFilterBarState extends State<SearchAndFilterBar> {
  late final TextEditingController _controller;
  late Map<String, dynamic> _currentFilters;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearchText);
    _currentFilters = Map.from(
        widget.initialFilters); // Initialize with potentially passed-in filters

    // Add listener to notify parent immediately on text change
    // Consider adding debouncing here for performance if needed
    _controller.addListener(() {
      widget.onSearchChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant SearchAndFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal filters if the parent widget provides new initial filters
    // This might happen if filters are reset externally
    if (widget.initialFilters != oldWidget.initialFilters) {
      setState(() {
        _currentFilters = Map.from(widget.initialFilters);
      });
    }
    // Update text field if initial search text changes externally
    if (widget.initialSearchText != oldWidget.initialSearchText &&
        _controller.text != widget.initialSearchText) {
      // Use WidgetsBinding to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Check if widget is still in the tree
          _controller.text = widget.initialSearchText;
          // Move cursor to end
          _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length));
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Use a temporary map to hold changes within the bottom sheet
    Map<String, dynamic> tempFilters = Map.from(_currentFilters);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take more height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Use StatefulBuilder to manage state *within* the bottom sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // Accommodate keyboard
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                // Make content scrollable
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              // Reset temp filters to defaults defined in FilterOption
                              tempFilters.clear();
                              for (var filter in widget.availableFilters) {
                                tempFilters[filter.id] = filter.initialValue;
                              }
                            });
                          },
                          child: const Text('Limpiar'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Build filter controls dynamically
                    ...widget.availableFilters.map((filter) {
                      return _buildFilterControl(
                          filter, tempFilters, setSheetState);
                    }),

                    const SizedBox(height: 20),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Update the main state and notify parent
                          setState(() {
                            _currentFilters = Map.from(tempFilters);
                          });
                          widget.onFiltersChanged(_currentFilters);
                          Navigator.pop(context); // Close bottom sheet
                        },
                        child: const Text('Aplicar Filtros'),
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Helper to build specific filter UI based on type
  Widget _buildFilterControl(FilterOption filter,
      Map<String, dynamic> tempFilters, StateSetter setSheetState) {
    // Ensure initial value exists in tempFilters if not already set
    tempFilters.putIfAbsent(filter.id, () => filter.initialValue);

    switch (filter.type) {
      case FilterType.checkboxes:
        return _buildCheckboxFilter(filter, tempFilters, setSheetState);
      case FilterType.rangeSlider:
        return _buildRangeSliderFilter(filter, tempFilters, setSheetState);
      case FilterType.radioButtons:
        return _buildRadioFilter(filter, tempFilters, setSheetState);
      // Add cases for other filter types here
      default:
        return Text('Tipo de filtro no soportado: ${filter.type}');
    }
  }

  // --- Specific Filter UI Builders ---

  Widget _buildCheckboxFilter(FilterOption filter,
      Map<String, dynamic> tempFilters, StateSetter setSheetState) {
    List<dynamic> selectedValues =
        List.from(tempFilters[filter.id] ?? []); // Ensure it's a list

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(filter.label,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          // Use Wrap for better layout if many options
          spacing: 8.0,
          runSpacing: 0.0,
          children: filter.options!.map((option) {
            final value = option['value'];
            final label = option['label'] as String;
            final isSelected = selectedValues.contains(value);
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setSheetState(() {
                  if (selected) {
                    selectedValues.add(value);
                  } else {
                    selectedValues.remove(value);
                  }
                  tempFilters[filter.id] = selectedValues;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRadioFilter(FilterOption filter,
      Map<String, dynamic> tempFilters, StateSetter setSheetState) {
    dynamic selectedValue = tempFilters[filter.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(filter.label,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Wrap(
          // Use Wrap for better layout if many options
          spacing: 8.0,
          runSpacing: 0.0,
          children: filter.options!.map((option) {
            final value = option['value'];
            final label = option['label'] as String;
            final isSelected = selectedValue == value;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setSheetState(() {
                  // If selected, update the value. If deselected (not typical for radio), clear it.
                  tempFilters[filter.id] =
                      selected ? value : filter.initialValue;
                });
              },
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRangeSliderFilter(FilterOption filter,
      Map<String, dynamic> tempFilters, StateSetter setSheetState) {
    RangeValues currentRange = tempFilters[filter.id] ?? filter.rangeLimits!;
    // Ensure current range is within limits
    currentRange = RangeValues(
      currentRange.start
          .clamp(filter.rangeLimits!.start, filter.rangeLimits!.end),
      currentRange.end
          .clamp(filter.rangeLimits!.start, filter.rangeLimits!.end),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(filter.label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                  '${currentRange.start.round()} - ${currentRange.end.round()}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall) // Display current range
            ],
          ),
        ),
        RangeSlider(
          values: currentRange,
          min: filter.rangeLimits!.start,
          max: filter.rangeLimits!.end,
          divisions: (filter.rangeLimits!.end - filter.rangeLimits!.start)
              .round(), // Adjust divisions as needed
          labels: RangeLabels(
            currentRange.start.round().toString(),
            currentRange.end.round().toString(),
          ),
          onChanged: (RangeValues values) {
            setSheetState(() {
              tempFilters[filter.id] = values;
            });
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Indicate if filters are active
    final bool filtersActive = _currentFilters.entries.any((entry) {
      // Check if the current value is different from the initial value defined in availableFilters
      final initialValue = widget.availableFilters
          .firstWhere((f) => f.id == entry.key,
              orElse: () => FilterOption(
                  id: '',
                  label: '',
                  type: FilterType.checkboxes,
                  initialValue: null)) // Provide a dummy default if not found
          .initialValue;

      // Handle list comparison specifically
      if (entry.value is List && initialValue is List) {
        return !(entry.value as List)
                .toSet()
                .containsAll((initialValue).toSet()) ||
            !(initialValue).toSet().containsAll((entry.value as List).toSet());
      }
      return entry.value != initialValue;
    });

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200], // Slightly lighter grey
        suffixIcon: IconButton(
          icon: Icon(
            Icons.tune,
            // Change color if filters are active
            color: filtersActive ? Theme.of(context).colorScheme.primary : null,
          ),
          tooltip: 'Filtros',
          onPressed: () => _showFilterBottomSheet(context),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 0, horizontal: 15), // Adjust padding
      ),
    );
  }
}
