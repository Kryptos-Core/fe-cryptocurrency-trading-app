import 'package:flutter/material.dart';

/// Gọn, đồng bộ theme — dùng cho lọc “Giao dịch gần đây” (nạp/rút on-chain).
ChoiceChip onchainTxFilterChip({
  required BuildContext context,
  required String label,
  required bool selected,
  required ValueChanged<bool> onSelected,
}) {
  final cs = Theme.of(context).colorScheme;
  return ChoiceChip(
    label: Text(
      label,
      style: TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? cs.onPrimary : cs.onSurface,
      ),
    ),
    selected: selected,
    onSelected: onSelected,
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    showCheckmark: true,
    checkmarkColor: cs.onPrimary,
    selectedColor: cs.primary,
    backgroundColor: cs.surface,
    side: BorderSide(
      color: selected ? cs.primary : cs.outlineVariant,
      width: 1,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 2),
    labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
  );
}
