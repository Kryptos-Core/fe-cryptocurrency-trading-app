import 'package:flutter/material.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';

/// Status filter values for the currency list.
enum CurrencyStatusFilter {
  /// Default: hide inactive currencies.
  activeOnly,

  /// Show every currency regardless of active flag.
  all,

  /// Show only inactive currencies.
  inactiveOnly,
}

/// Trading filter values for the currency list.
enum CurrencyTradingFilter {
  /// Default: include tradable and non-tradable.
  all,

  /// Show only currencies flagged as tradable.
  tradableOnly,

  /// Show only paused (non-tradable) currencies.
  pausedOnly,
}

/// Two-row filter bar used by the currencies list screen.
///
/// Layout: a Status row (All/Active/Inactive) and a Trading row
/// (All/Tradable/Paused) followed by a result counter and a clear-filters
/// action. Visual style mirrors `admin_currencies_screen.dart` so operators
/// see consistent filter affordances across the app.
class CurrenciesFilterBar extends StatelessWidget {
  const CurrenciesFilterBar({
    super.key,
    required this.statusFilter,
    required this.tradingFilter,
    required this.onStatusFilterChanged,
    required this.onTradingFilterChanged,
    required this.onClearFilters,
    required this.shownCount,
    required this.totalCount,
    required this.hasActiveFilter,
  });

  final CurrencyStatusFilter statusFilter;
  final CurrencyTradingFilter tradingFilter;
  final ValueChanged<CurrencyStatusFilter> onStatusFilterChanged;
  final ValueChanged<CurrencyTradingFilter> onTradingFilterChanged;
  final VoidCallback onClearFilters;
  final int shownCount;
  final int totalCount;
  final bool hasActiveFilter;

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(
                  label: l10n.currenciesFilterAll,
                  selected: statusFilter == CurrencyStatusFilter.all,
                  onTap: () => onStatusFilterChanged(
                    CurrencyStatusFilter.all,
                  ),
                ),
                const SizedBox(width: 6),
                _chip(
                  label: l10n.active,
                  selected:
                      statusFilter == CurrencyStatusFilter.activeOnly,
                  onTap: () => onStatusFilterChanged(
                    CurrencyStatusFilter.activeOnly,
                  ),
                ),
                const SizedBox(width: 6),
                _chip(
                  label: l10n.inactive,
                  selected:
                      statusFilter == CurrencyStatusFilter.inactiveOnly,
                  onTap: () => onStatusFilterChanged(
                    CurrencyStatusFilter.inactiveOnly,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(
                  label: l10n.currenciesFilterAll,
                  selected:
                      tradingFilter == CurrencyTradingFilter.all,
                  onTap: () => onTradingFilterChanged(
                    CurrencyTradingFilter.all,
                  ),
                ),
                const SizedBox(width: 6),
                _chip(
                  label: l10n.currenciesTradable,
                  selected:
                      tradingFilter == CurrencyTradingFilter.tradableOnly,
                  onTap: () => onTradingFilterChanged(
                    CurrencyTradingFilter.tradableOnly,
                  ),
                ),
                const SizedBox(width: 6),
                _chip(
                  label: l10n.currenciesPaused,
                  selected:
                      tradingFilter == CurrencyTradingFilter.pausedOnly,
                  onTap: () => onTradingFilterChanged(
                    CurrencyTradingFilter.pausedOnly,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.insights_outlined,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.currenciesResultCounter(shownCount, totalCount),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (hasActiveFilter)
                TextButton.icon(
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  label: Text(l10n.currenciesClearFilters),
                  onPressed: onClearFilters,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
