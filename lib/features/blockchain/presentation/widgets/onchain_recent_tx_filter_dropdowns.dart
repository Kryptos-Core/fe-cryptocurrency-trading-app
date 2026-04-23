import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/onchain_transaction.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/widgets/onchain_network_dropdown_menu_child.dart';
import 'package:flutter/material.dart';

class OnchainRecentTxFilterDropdowns extends StatelessWidget {
  const OnchainRecentTxFilterDropdowns({
    super.key,
    required this.networks,
    required this.selectedNetwork,
    required this.onNetworkChanged,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final List<BlockchainNetwork> networks;
  final BlockchainNetwork? selectedNetwork;
  final ValueChanged<BlockchainNetwork?> onNetworkChanged;
  final OnchainTxType? selectedType;
  final ValueChanged<OnchainTxType?> onTypeChanged;

  static const List<OnchainTxType> _filterableTypes = [
    OnchainTxType.deposit,
    OnchainTxType.withdrawal,
    OnchainTxType.transfer,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final safeNetwork =
        selectedNetwork != null && networks.contains(selectedNetwork)
            ? selectedNetwork
            : null;
    final safeType =
        selectedType != null && _filterableTypes.contains(selectedType)
            ? selectedType
            : null;

    final networkField = AppDropdownField<BlockchainNetwork?>(
      value: safeNetwork,
      labelText: l10n.networkLabel,
      hintText: l10n.allNetworks,
      dense: true,
      menuMaxHeight: 320,
      items: [
        DropdownMenuItem<BlockchainNetwork?>(
          value: null,
          child: Text(
            l10n.allNetworks,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ...networks.map(
          (network) => DropdownMenuItem<BlockchainNetwork?>(
            value: network,
            child: OnchainNetworkDropdownMenuChild(
              network: network,
              l10n: l10n,
            ),
          ),
        ),
      ],
      onChanged: onNetworkChanged,
    );

    final typeField = AppDropdownField<OnchainTxType?>(
      value: safeType,
      labelText: l10n.type,
      hintText: l10n.allTypes,
      dense: true,
      menuMaxHeight: 320,
      items: [
        DropdownMenuItem<OnchainTxType?>(
          value: null,
          child: Text(
            l10n.allTypes,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem<OnchainTxType?>(
          value: OnchainTxType.deposit,
          child: Text(
            l10n.txTypeDeposits,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem<OnchainTxType?>(
          value: OnchainTxType.withdrawal,
          child: Text(
            l10n.txTypeWithdrawals,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DropdownMenuItem<OnchainTxType?>(
          value: OnchainTxType.transfer,
          child: Text(
            l10n.txTypeTransfers,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      onChanged: onTypeChanged,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        if (isWide) {
          return Row(
            children: [
              Expanded(child: networkField),
              const SizedBox(width: 12),
              Expanded(child: typeField),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            networkField,
            const SizedBox(height: 12),
            typeField,
          ],
        );
      },
    );
  }
}
