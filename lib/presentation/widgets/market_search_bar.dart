import 'dart:async';

import 'package:flutter/material.dart';

/// Search field with debounced callbacks so parent rebuilds do not drop focus.
class MarketSearchBar extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final void Function(String) onDebouncedSearch;

  const MarketSearchBar({
    super.key,
    required this.hintText,
    required this.initialValue,
    required this.onDebouncedSearch,
  });

  @override
  MarketSearchBarState createState() => MarketSearchBarState();
}

class MarketSearchBarState extends State<MarketSearchBar> {
  static const _debounceMs = 400;
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant MarketSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == '' && _controller.text.isNotEmpty) {
      _controller.clear();
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      if (!mounted) return;
      widget.onDebouncedSearch(_controller.text);
    });
  }

  void clear() {
    _controller.clear();
    widget.onDebouncedSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (context, value, child) {
        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onDebouncedSearch('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            isDense: true,
          ),
          textCapitalization: TextCapitalization.characters,
          onSubmitted: widget.onDebouncedSearch,
        );
      },
    );
  }
}
