import 'package:flutter/material.dart';

import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/constants/treasury_chains.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mh =
        menuMaxHeight ?? MediaQuery.sizeOf(context).height * 0.35;

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
            treasuryChainDisplayLabel(l10n, v),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ];

    return AppDropdownField<String?>(
      value: value,
      labelText: labelText,
      hintText: hintText,
      menuMaxHeight: mh,
      dense: dense,
      items: items,
      onChanged: onChanged,
    );
  }
}
