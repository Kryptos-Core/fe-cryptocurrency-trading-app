import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final String? hintText;
  final double menuMaxHeight;
  final EdgeInsetsGeometry contentPadding;

  /// Tighter field (e.g. AppBar toolbars) — smaller vertical padding and [isDense].
  final bool dense;

  const AppDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.menuMaxHeight = 300,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = dense
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : contentPadding;

    return DropdownButtonFormField<T>(
      key: ValueKey<T?>(value),
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: menuMaxHeight,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: effectivePadding,
        isDense: dense,
        labelText: labelText,
      ),
      hint: hintText != null ? Text(hintText!) : null,
      items: items,
      onChanged: onChanged,
    );
  }
}
