import 'package:flutter/material.dart';
import 'package:crypto_trading_app/core/services/wallet_signing/wallet_extension_precheck_service.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';

enum _WindowsExtensionCheckAction {
  ready,
  install,
  cancel,
}

class WindowsExtensionPrecheckCard extends StatefulWidget {
  final BlockchainNetwork network;
  final bool isPrechecked;
  final bool enabled;
  final WalletExtensionPrecheckService precheckService;
  final ValueChanged<bool> onPrecheckChanged;

  const WindowsExtensionPrecheckCard({
    super.key,
    required this.network,
    required this.isPrechecked,
    required this.enabled,
    required this.precheckService,
    required this.onPrecheckChanged,
  });

  @override
  State<WindowsExtensionPrecheckCard> createState() =>
      WindowsExtensionPrecheckCardState();
}

class WindowsExtensionPrecheckCardState
    extends State<WindowsExtensionPrecheckCard> {
  Future<bool> runPrecheckFlow() async {
    final target = widget.precheckService.targetForNetwork(widget.network);
    if (target == null) {
      return true;
    }

    final l10n = AppLocalizations.of(context);
    final extensionName = target.name;
    await widget.precheckService.openExtensionInstallPage(widget.network);

    if (!mounted) return false;

    final action = await showDialog<_WindowsExtensionCheckAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.walletExtensionCheckTitle(extensionName)),
          content: Text(
            l10n.walletExtensionCheckMessage(extensionName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext)
                  .pop(_WindowsExtensionCheckAction.cancel),
              child: Text(l10n.walletExtensionCheckClose),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext)
                  .pop(_WindowsExtensionCheckAction.install),
              child: Text(l10n.walletExtensionInstallAction(extensionName)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext)
                  .pop(_WindowsExtensionCheckAction.ready),
              child: Text(l10n.walletExtensionReadyAction),
            ),
          ],
        );
      },
    );

    if (action == _WindowsExtensionCheckAction.ready) {
      widget.onPrecheckChanged(true);
      return true;
    }

    if (action == _WindowsExtensionCheckAction.install) {
      await widget.precheckService.openExtensionInstallPage(widget.network);
      if (!mounted) return false;
      showAppSnackBar(
        context,
        message: l10n.walletExtensionInstallOpenedInfo(extensionName),
        type: SnackBarType.info,
      );
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isPrechecked
                ? Colors.green.shade50
                : Colors.orange.shade50,
            border: Border.all(
              color: widget.isPrechecked
                  ? Colors.green.shade200
                  : Colors.orange.shade200,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.isPrechecked
                    ? Icons.verified_outlined
                    : Icons.extension_outlined,
                size: 18,
                color: widget.isPrechecked
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isPrechecked
                      ? l10n.walletWindowsPrecheckReady
                      : l10n.walletWindowsPrecheckRequired,
                  style: const TextStyle(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: widget.enabled ? runPrecheckFlow : null,
            icon: const Icon(Icons.open_in_browser),
            label: Text(widget.isPrechecked
                ? l10n.walletWindowsPrecheckRecheck
                : l10n.walletWindowsPrecheckCheck),
          ),
        ),
      ],
    );
  }
}
