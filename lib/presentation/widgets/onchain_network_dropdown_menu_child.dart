import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Hàng label mạng + nhãn Sandbox cho testnet (dropdown deposit / withdraw).
class OnchainNetworkDropdownMenuChild extends StatelessWidget {
  const OnchainNetworkDropdownMenuChild({
    super.key,
    required this.network,
    required this.l10n,
  });

  final BlockchainNetwork network;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            network.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (network.isSandbox)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              l10n.onchainSandboxShort,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade800,
              ),
            ),
          ),
      ],
    );
  }
}
