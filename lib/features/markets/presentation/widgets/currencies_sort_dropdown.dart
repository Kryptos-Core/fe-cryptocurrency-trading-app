import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/currencies_provider.dart';
import 'package:flutter/material.dart';

/// Compact sort dropdown used in the currencies list toolbar.
///
/// Mirrors the dense dropdown pattern from `markets_list_screen.dart` and
/// `treasury_chain_dropdown.dart` so operators can switch sort order
/// without taking up horizontal space.
class CurrenciesSortDropdown extends StatelessWidget {
  const CurrenciesSortDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CurrencySortMode value;
  final ValueChanged<CurrencySortMode> onChanged;

  String _labelFor(AppLocalizations l10n, CurrencySortMode mode) {
    return switch (mode) {
      CurrencySortMode.topVolume => l10n.currenciesSortTopVolume,
      CurrencySortMode.topGainers => l10n.currenciesSortTopGainers,
      CurrencySortMode.topLosers => l10n.currenciesSortTopLosers,
      CurrencySortMode.alphabet => l10n.currenciesSortAlphabet,
    };
  }

  IconData _iconFor(CurrencySortMode mode) {
    return switch (mode) {
      CurrencySortMode.topVolume => Icons.bar_chart,
      CurrencySortMode.topGainers => Icons.trending_up,
      CurrencySortMode.topLosers => Icons.trending_down,
      CurrencySortMode.alphabet => Icons.sort_by_alpha,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<CurrencySortMode>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        prefixIcon: Icon(_iconFor(value), size: 18),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: CurrencySortMode.values
          .map(
            (mode) => DropdownMenuItem<CurrencySortMode>(
              value: mode,
              child: Row(
                children: [
                  Icon(_iconFor(mode), size: 16),
                  const SizedBox(width: 8),
                  Text(_labelFor(l10n, mode)),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (mode) {
        if (mode != null) onChanged(mode);
      },
    );
  }
}
