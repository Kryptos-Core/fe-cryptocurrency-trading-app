import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Filter option for transaction list.
class TransactionFilterOption {
  final String value;
  final String label;
  final IconData icon;

  const TransactionFilterOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// Declarative filter bar using Material 3 FilterChip.
/// Horizontal scrolling when many options, selected state with visual feedback.
class TransactionFilterBar extends StatelessWidget {
  final List<TransactionFilterOption> filters;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const TransactionFilterBar({
    super.key,
    required this.filters,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedValue == filter.value;

          return FilterChip(
            selected: isSelected,
            label: Text(filter.label),
            avatar: Icon(
              filter.icon,
              size: 16,
              color: isSelected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
            ),
            onSelected: (selected) {
              onChanged(selected ? filter.value : null);
            },
            backgroundColor: scheme.surfaceContainerLow,
            selectedColor: scheme.secondaryContainer,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? scheme.secondary : scheme.outlineVariant,
                width: 1,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          );
        },
      ),
    );
  }
}

/// Builds the standard wallet transaction filter options using i18n labels.
/// Designed for use in both [TransactionFilterBar] (chip-style) and
/// [AppDropdownField] (dropdown-style) by returning a list of [TransactionFilterOption].
/// The "ALL" option is always first; ONCHAIN is always last.
List<TransactionFilterOption> buildWalletLedgerFilters(AppLocalizations l10n) {
  return [
    TransactionFilterOption(
      value: 'ALL',
      label: l10n.walletFilterAll,
      icon: Icons.list_alt_rounded,
    ),
    TransactionFilterOption(
      value: 'DEPOSIT',
      label: l10n.walletFilterDeposit,
      icon: Icons.arrow_downward_rounded,
    ),
    TransactionFilterOption(
      value: 'WITHDRAW',
      label: l10n.walletFilterWithdraw,
      icon: Icons.arrow_upward_rounded,
    ),
    TransactionFilterOption(
      value: 'TRADE',
      label: l10n.walletFilterTrade,
      icon: Icons.swap_horiz_rounded,
    ),
    TransactionFilterOption(
      value: 'ORDER',
      label: l10n.walletFilterOrder,
      icon: Icons.shopping_cart_outlined,
    ),
    TransactionFilterOption(
      value: 'TRANSFER',
      label: l10n.walletFilterTransfer,
      icon: Icons.people_outline_rounded,
    ),
    TransactionFilterOption(
      value: 'ADJUST',
      label: l10n.walletFilterAdjust,
      icon: Icons.tune_rounded,
    ),
    TransactionFilterOption(
      value: 'ONCHAIN',
      label: l10n.walletFilterOnchain,
      icon: Icons.cloud_sync_outlined,
    ),
  ];
}

/// Returns the subset of filters that apply to ledger entries (non-ONCHAIN).
/// ONCHAIN maps to the three external refType values server-side.
List<TransactionFilterOption> buildWalletLedgerFiltersForLedger(AppLocalizations l10n) {
  return buildWalletLedgerFilters(l10n)
      .where((f) => f.value != 'ONCHAIN')
      .toList();
}

/// Converts a server-side refType string to the UI filter value.
/// EXTERNAL_DEPOSIT / EXTERNAL_WITHDRAWAL / EXTERNAL_SYNC → 'ONCHAIN'
String uiFilterValueFromRefType(String refType) {
  switch (refType.toUpperCase()) {
    case 'EXTERNAL_DEPOSIT':
    case 'EXTERNAL_WITHDRAWAL':
    case 'EXTERNAL_SYNC':
      return 'ONCHAIN';
    default:
      return refType.toUpperCase();
  }
}

/// Converts a UI filter value back to the server-side refType values it represents.
/// Returns null for 'ALL' (no filter), or a set of server values for specific types.
Set<String>? serverRefTypesFromUiFilter(String? uiValue) {
  if (uiValue == null || uiValue == 'ALL') return null;
  if (uiValue == 'ONCHAIN') {
    return {'EXTERNAL_DEPOSIT', 'EXTERNAL_WITHDRAWAL', 'EXTERNAL_SYNC'};
  }
  return {uiValue};
}
