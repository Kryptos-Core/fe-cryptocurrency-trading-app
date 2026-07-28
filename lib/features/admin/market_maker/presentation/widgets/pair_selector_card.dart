import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_config_model.dart';

import 'market_maker_section.dart';

/// Section wrapper for the Market Maker pair dropdown.
/// Combines [MarketMakerSectionHeader] + [MarketMakerCard] + dropdown field,
/// so the calling screen renders a single complete section.
class MarketMakerPairSelectorCard extends StatelessWidget {
  const MarketMakerPairSelectorCard({
    super.key,
    required this.pairs,
    required this.selectedPairId,
    required this.onChanged,
  });

  final List<MarketMakerPairOption> pairs;
  final String? selectedPairId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final menuHeight = MediaQuery.sizeOf(context).height * 0.35;
    final items = pairs
        .map(
          (p) => DropdownMenuItem<String>(
            value: p.pairId,
            child: Text(p.symbol, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketMakerSectionHeader(title: l10n.marketMakerSectionPair),
        MarketMakerCard(
          child: AppDropdownField<String>(
            key: ValueKey<String?>(selectedPairId),
            value: selectedPairId,
            labelText: l10n.marketMakerFieldPair,
            menuMaxHeight: menuHeight,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}