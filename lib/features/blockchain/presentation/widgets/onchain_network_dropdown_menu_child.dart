import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Hàng label mạng + tùy chọn nhãn Sandbox cho testnet (dropdown deposit / withdraw).
///
/// Khi màn hình đã có [OnchainSandboxOperatorBanner], đặt [suppressSandboxSuffix]
/// để tránh lặp chữ “Sandbox” cạnh từng dòng.
class OnchainNetworkDropdownMenuChild extends StatelessWidget {
  const OnchainNetworkDropdownMenuChild({
    super.key,
    required this.network,
    required this.l10n,
    this.suppressSandboxSuffix = false,
  });

  final BlockchainNetwork network;
  final AppLocalizations l10n;

  /// Nếu true: không hiển thị [l10n.onchainSandboxShort] cạnh testnet (banner đã giải thích).
  final bool suppressSandboxSuffix;

  @override
  Widget build(BuildContext context) {
    final showSuffix = network.isSandbox && !suppressSandboxSuffix;
    final picker = context.watch<OnchainChainPickerProvider?>();
    return Row(
      children: [
        Expanded(
          child: Text(
            picker?.displayLabelForNetwork(network) ?? network.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showSuffix)
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


