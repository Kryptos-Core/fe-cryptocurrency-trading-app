import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formatter for amount input fields. Adds thousands separators (e.g. 10,000.5)
/// while allowing decimal input. Use [parseAmountInput] to get numeric value.
class AmountInputFormatter extends TextInputFormatter {
  static final NumberFormat _intFormat = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Split into integer and decimal parts
    final parts = text.split('.');
    final hasDecimal = parts.length > 1;
    final intPart = parts[0].replaceAll(RegExp(r'[^0-9]'), '');
    final decPart = hasDecimal
        ? parts.sublist(1).join('').replaceAll(RegExp(r'[^0-9]'), '')
        : '';

    // Limit decimal to 18 digits
    final decLimited = decPart.length > 18 ? decPart.substring(0, 18) : decPart;

    String formatted;
    if (intPart.isEmpty && decLimited.isEmpty) {
      return oldValue;
    }
    if (intPart.isEmpty) {
      formatted = decLimited.isEmpty ? '0' : '0.$decLimited';
    } else {
      final num = int.tryParse(intPart);
      if (num == null) return oldValue;
      formatted = _intFormat.format(num);
      if (hasDecimal) {
        formatted = '$formatted.$decLimited';
      }
    }

    // Preserve cursor position (adjust for added/removed separators)
    final cursorDelta = formatted.length - newValue.text.length;
    var newOffset = newValue.selection.end + cursorDelta;
    if (newOffset < 0) newOffset = 0;
    if (newOffset > formatted.length) newOffset = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Chuỗi thập phân thuần (không dấu phẩy nghìn) → [TextEditingValue] đã format.
  ///
  /// Dùng khi gán [TextEditingController.value] từ ticker / MAX / sổ lệnh.
  static TextEditingValue valueFromPlainDecimal(String plain) {
    final trimmed = plain.replaceAll(',', '').trim();
    if (trimmed.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final formatter = AmountInputFormatter();
    return formatter.formatEditUpdate(
      const TextEditingValue(),
      TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      ),
    );
  }
}

/// Strips thousands separators from formatted amount for parsing/API.
String parseAmountInput(String input) {
  return input.replaceAll(',', '').trim();
}
