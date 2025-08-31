import 'package:flutter/material.dart';
import 'dart:async';

class CustomSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final String initialSearchText;
  final String hintText;

  const CustomSearchBar({
    super.key,
    required this.onSearchChanged,
    this.onSearchSubmitted,
    this.initialSearchText = '',
    this.hintText = 'Buscar vacunas, artículos, servicios...',
  });

  @override
  State<CustomSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<CustomSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSearchText);

    // Add listener to notify parent on text change with debouncing
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSearchText != oldWidget.initialSearchText &&
        _controller.text != widget.initialSearchText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.text = widget.initialSearchText;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set a new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onSearchChanged(_controller.text);
      }
    });
  }

  void _onSearchSubmitted() {
    // Cancel any pending debounced search
    _debounceTimer?.cancel();

    if (widget.onSearchSubmitted != null) {
      widget.onSearchSubmitted!();
    }
    // Hide keyboard
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: (_) => _onSearchSubmitted(),
        textInputAction: TextInputAction.search,
        enableInteractiveSelection: true,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
            size: 24,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _clearSearch,
                  tooltip: 'Limpiar búsqueda',
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          fontSize: 16,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
