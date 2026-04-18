import 'dart:async';

import 'package:flutter/material.dart';

/// Single-line search field: fires [onDebouncedChanged] after typing pauses.
/// Use across admin / treasury / any list filter instead of submit-only search.
class DebouncedSearchTextField extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onDebouncedChanged;
  final int debounceMs;
  final TextCapitalization textCapitalization;

  const DebouncedSearchTextField({
    super.key,
    this.labelText,
    required this.hintText,
    this.initialValue = '',
    required this.onDebouncedChanged,
    this.debounceMs = 400,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<DebouncedSearchTextField> createState() => _DebouncedSearchTextFieldState();
}

class _DebouncedSearchTextFieldState extends State<DebouncedSearchTextField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant DebouncedSearchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue == oldWidget.initialValue) return;
    _debounce?.cancel();
    if (widget.initialValue.isEmpty) {
      if (_controller.text.isNotEmpty) _controller.clear();
    } else if (widget.initialValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      if (!mounted) return;
      widget.onDebouncedChanged(_controller.text);
    });
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
      builder: (context, value, _) {
        return TextField(
          controller: _controller,
          textCapitalization: widget.textCapitalization,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onDebouncedChanged('');
                    },
                  )
                : null,
          ),
          onSubmitted: (v) {
            _debounce?.cancel();
            widget.onDebouncedChanged(v);
          },
        );
      },
    );
  }
}
