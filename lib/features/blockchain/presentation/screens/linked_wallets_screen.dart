import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/linked_wallet.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/linked_wallet_status.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/providers/blockchain_provider.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/widgets/link_wallet_dialog.dart';

class LinkedWalletsScreen extends StatefulWidget {
  const LinkedWalletsScreen({super.key});

  @override
  State<LinkedWalletsScreen> createState() => _LinkedWalletsScreenState();
}

class _LinkedWalletsScreenState extends State<LinkedWalletsScreen> {
  String _formatAddress(String address) {
    if (address.length <= 14) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 6)}';
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Color _statusBgColor(LinkedWalletStatus status) {
    switch (status) {
      case LinkedWalletStatus.verified:
        return const Color(0xFFEAF8F1);
      case LinkedWalletStatus.pending:
        return const Color(0xFFFFF6E8);
      case LinkedWalletStatus.revoked:
        return const Color(0xFFFDECEF);
      case LinkedWalletStatus.unknown:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _statusTextColor(LinkedWalletStatus status) {
    switch (status) {
      case LinkedWalletStatus.verified:
        return const Color(0xFF0F8A49);
      case LinkedWalletStatus.pending:
        return const Color(0xFFB56900);
      case LinkedWalletStatus.revoked:
        return const Color(0xFFB3261E);
      case LinkedWalletStatus.unknown:
        return const Color(0xFF64748B);
    }
  }

  Future<void> _copyAddress(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    showAppSnackBar(
      context,
      message: l10n.addressCopied,
      type: SnackBarType.info,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 120,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 72,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 180,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.blueGrey.shade400),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add_link),
                label: Text(AppLocalizations.of(context).linkFirstWallet),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockchainProvider>().fetchLinkedWallets();
    });
  }

  Future<void> _showLinkDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const LinkWalletDialog(),
    );
  }

  Future<void> _unlinkWallet(LinkedWallet wallet) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(dialogL10n.unlinkWalletTitle),
          content: Text(dialogL10n.confirmUnlinkWallet(wallet.address)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(dialogL10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(dialogL10n.unlinkAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<BlockchainProvider>();
    final ok = await provider.unlinkWallet(wallet.linkId);
    if (!mounted) return;

    showAppSnackBar(
      context,
      message: ok
          ? l10n.walletUnlinkedSuccess
          : (provider.error ?? l10n.failedToUnlinkWallet),
      type: ok ? SnackBarType.success : SnackBarType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLinkDialog,
        icon: const Icon(Icons.add_link),
        label: Text(AppLocalizations.of(context).linkWallet),
      ),
      body: Consumer<BlockchainProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.linkedWallets.isEmpty) {
            return _buildSkeletonList();
          }

          if (provider.error != null && provider.linkedWallets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      provider.error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: provider.fetchLinkedWallets,
                      child: Text(AppLocalizations.of(context).retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.linkedWallets.isEmpty) {
            final l10n = AppLocalizations.of(context);
            return _buildEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.noLinkedWalletsTitle,
              message: l10n.noLinkedWalletsMessage,
              onPressed: _showLinkDialog,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.fetchLinkedWallets,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: provider.linkedWallets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final wallet = provider.linkedWallets[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                wallet.chain.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBgColor(wallet.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                wallet.status.apiValue,
                                style: TextStyle(
                                  color: _statusTextColor(wallet.status),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                _formatAddress(wallet.address),
                              ),
                            ),
                            IconButton(
                              tooltip:
                                  AppLocalizations.of(context).copyFullAddress,
                              icon: const Icon(Icons.copy, size: 18),
                              onPressed: () => _copyAddress(wallet.address),
                            ),
                          ],
                        ),
                        if (wallet.label != null &&
                            wallet.label!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(AppLocalizations.of(context)
                              .walletLabelPrefix(wallet.label!)),
                        ],
                        if (wallet.linkedAt != null) ...[
                          const SizedBox(height: 6),
                          Text(AppLocalizations.of(context)
                              .linkedAtPrefix(_formatDate(wallet.linkedAt!))),
                        ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: provider.isSubmitting
                                ? null
                                : () => _unlinkWallet(wallet),
                            icon: const Icon(Icons.link_off),
                            label:
                                Text(AppLocalizations.of(context).unlinkAction),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
