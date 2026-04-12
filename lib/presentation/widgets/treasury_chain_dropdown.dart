import 'package:flutter/material.dart';

import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/presentation/utils/treasury_dropdown_menu_layout.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';

/// Shared chain selector: [AppDropdownField] + localized labels + stable API values.
///
/// Set [allowAllOption] to add a `null` row (e.g. “All”) for filters.
class TreasuryChainDropdown extends StatelessWidget {
  const TreasuryChainDropdown({
    super.key,
    required this.chains,
    required this.value,
    this.onChanged,
    this.allowAllOption = false,
    this.labelText,
    this.hintText,
    this.allOptionLabel,
    this.menuMaxHeight,
    this.dense = false,
    this.displayLabelForChain,
  });

  final List<String> chains;
  final String? value;
  /// When null, the field is not interactive (e.g. while submitting).
  final ValueChanged<String?>? onChanged;
  final bool allowAllOption;
  final String? labelText;
  final String? hintText;
  final String? allOptionLabel;
  final double? menuMaxHeight;

  /// See [AppDropdownField.dense] — use in tight layouts (e.g. AppBar).
  final bool dense;

  /// When set, overrides [treasuryChainDisplayLabel] per chain (e.g. create-wallet ecosystem labels).
  final String Function(AppLocalizations l10n, String chain)? displayLabelForChain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mh = menuMaxHeight ??
        defaultTreasuryDropdownMenuMaxHeight(MediaQuery.sizeOf(context).height);

    // Avoid DropdownButton assert when API value is not in [chains] (e.g. env drift).
    final safeValue =
        value != null && chains.contains(value) ? value : null;

    final items = <DropdownMenuItem<String?>>[
      if (allowAllOption)
        DropdownMenuItem<String?>(
          value: null,
          child: Text(
            allOptionLabel ?? l10n.treasuryFilterAll,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ...chains.map(
        (v) => DropdownMenuItem<String?>(
          value: v,
          child: Text(
            displayLabelForChain != null
                ? displayLabelForChain!(l10n, v)
                : treasuryChainDisplayLabel(l10n, v),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    return AppDropdownField<String?>(
      value: safeValue,
      labelText: labelText,
      hintText: hintText,
      menuMaxHeight: mh,
      dense: dense,
      items: items,
      onChanged: onChanged,
    );
  }
}
