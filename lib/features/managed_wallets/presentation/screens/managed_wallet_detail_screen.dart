import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/features/blockchain/domain/entities/blockchain/blockchain_network.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet.dart';
import 'package:crypto_trading_app/features/managed_wallets/domain/entities/managed_wallet/managed_wallet_transaction.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/providers/managed_wallets_provider.dart';
import 'package:crypto_trading_app/features/managed_wallets/presentation/screens/widgets/send_trx_sheet.dart';

class ManagedWalletDetailScreen extends StatefulWidget {
  final ManagedWallet wallet;

  const ManagedWalletDetailScreen({super.key, required this.wallet});

  @override
  State<ManagedWalletDetailScreen> createState() => _ManagedWalletDetailScreenState();
}

class _ManagedWalletDetailScreenState extends State<ManagedWalletDetailScreen> {
  late ManagedWallet _wallet;

  @override
  void initState() {
    super.initState();
    _wallet = widget.wallet;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<ManagedWalletsProvider>();
    await Future.wait([
      provider.fetchWalletDetail(_wallet.walletId),
      provider.fetchWalletTransactions(_wallet.walletId),
    ]);
  }

  Future<void> _setDefault() async {
    final provider = context.read<ManagedWalletsProvider>();
    final error = await provider.setDepositDefault(_wallet.walletId);
    if (!mounted) return;
    if (error == null) {
      showAppSnackBar(context, message: AppLocalizations.of(context).walletSetAsDefault, type: SnackBarType.success);
      setState(() {
        _wallet = ManagedWallet(
          walletId: _wallet.walletId,
          userId: _wallet.userId,
          chain: _wallet.chain,
          address: _wallet.address,
          label: _wallet.label,
          isDefaultDeposit: true,
          defaultSetAt: DateTime.now(),
          isActive: _wallet.isActive,
          createdAt: _wallet.createdAt,
          updatedAt: _wallet.updatedAt,
        );
      });
    } else {
      showAppSnackBar(context, message: error, type: SnackBarType.error);
    }
  }

  Future<void> _confirmClearDefault() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.managedWalletClearDefaultDepositTitle),
        content: Text(l10n.managedWalletClearDefaultDepositBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.managedWalletClearDefaultDepositAction),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final provider = context.read<ManagedWalletsProvider>();
    final error = await provider.clearDepositDefault(_wallet.walletId);
    if (!mounted) return;
    if (error == null) {
      showAppSnackBar(
        context,
        message: l10n.managedWalletClearDefaultDepositSuccess,
        type: SnackBarType.success,
      );
      setState(() {
        _wallet = ManagedWallet(
          walletId: _wallet.walletId,
          userId: _wallet.userId,
          chain: _wallet.chain,
          address: _wallet.address,
          label: _wallet.label,
          isDefaultDeposit: false,
          defaultSetAt: null,
          isActive: _wallet.isActive,
          createdAt: _wallet.createdAt,
          updatedAt: _wallet.updatedAt,
        );
      });
    } else {
      showAppSnackBar(context, message: error, type: SnackBarType.error);
    }
  }

  Future<void> _deactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          icon: const Icon(Icons.warning_amber_outlined),
          title: Text(l10n.deactivateWalletTitle),
          content: Text(l10n.deactivateWalletContent),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.deactivateWalletAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<ManagedWalletsProvider>();
    final error = await provider.deactivateWallet(_wallet.walletId);
    if (!mounted) return;

    if (error == null) {
      showAppSnackBar(context, message: AppLocalizations.of(context).walletDeactivated, type: SnackBarType.success);
      Navigator.pop(context);
    } else {
      showAppSnackBar(context, message: error, type: SnackBarType.error);
    }
  }

  Future<void> _openSendSheet() async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SendTrxSheet(wallet: _wallet),
    );
    if (sent == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                _wallet.truncatedAddress,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _ChainAppBarBadge(apiValue: _wallet.chain.apiValue),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: AppLocalizations.of(context).refresh,
          ),
          if (_wallet.isActive)
            PopupMenuButton<_Action>(
              onSelected: (action) {
                if (action == _Action.deactivate) _deactivate();
              },
                itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: _Action.deactivate,
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Theme.of(ctx).colorScheme.error, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(ctx).deactivateWalletAction,
                        style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Consumer<ManagedWalletsProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _BalanceCard(
                  balance: provider.selectedBalance != null
                      ? FormatUtils.formatDecimalAmountDisplay(provider.selectedBalance!.balance)
                      : '—',
                  symbol: provider.selectedBalance?.symbol ?? 'TRX',
                  isLoading: provider.isLoading && provider.selectedBalance == null,
                ),
                const SizedBox(height: 16),
                _ActionRow(
                  wallet: _wallet,
                  isSubmitting: provider.isSubmitting,
                  onSetDefault: _wallet.isDefaultDeposit ? null : _setDefault,
                  onClearDefault: _wallet.isDefaultDeposit ? _confirmClearDefault : null,
                  onSend: _wallet.isActive ? _openSendSheet : null,
                ),
                const SizedBox(height: 24),
                _TransactionHistory(
                  transactions: provider.transactions,
                  isLoading: provider.isLoading,
                  walletAddress: _wallet.address,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _Action { deactivate }

class _ChainAppBarBadge extends StatelessWidget {
  final String apiValue;

  const _ChainAppBarBadge({required this.apiValue});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.28)),
      ),
      child: Text(
        apiValue,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String balance;
  final String symbol;
  final bool isLoading;

  const _BalanceCard({required this.balance, required this.symbol, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).managedWalletOnchainBalance,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            isLoading
                ? const SizedBox(height: 32, child: Center(child: CircularProgressIndicator()))
                : Text(
                    '$balance $symbol',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final ManagedWallet wallet;
  final bool isSubmitting;
  final VoidCallback? onSetDefault;
  final VoidCallback? onClearDefault;
  final VoidCallback? onSend;

  const _ActionRow({
    required this.wallet,
    required this.isSubmitting,
    this.onSetDefault,
    this.onClearDefault,
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (wallet.isDefaultDeposit) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: Icon(Icons.star_rounded, size: 18, color: scheme.primary),
                  label: Text(l10n.managedWalletDefaultDeposit),
                  style: OutlinedButton.styleFrom(foregroundColor: scheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  label: Text(l10n.managedWalletSendTrx),
                ),
              ),
            ],
          ),
          if (onClearDefault != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onClearDefault,
              icon: Icon(Icons.star_border_rounded, size: 18, color: scheme.error),
              label: Text(l10n.managedWalletClearDefaultDeposit),
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.error,
                side: BorderSide(color: scheme.error.withValues(alpha: 0.55)),
              ),
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        if (onSetDefault != null) ...[
          Expanded(
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : onSetDefault,
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(l10n.managedWalletSetDefault),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onSend,
            icon: const Icon(Icons.send_outlined, size: 18),
            label: Text(l10n.managedWalletSendTrx),
          ),
        ),
      ],
    );
  }
}

class _TransactionHistory extends StatelessWidget {
  final List<ManagedWalletTransaction> transactions;
  final bool isLoading;
  final String walletAddress;
  final ColorScheme colorScheme;

  const _TransactionHistory({
    required this.transactions,
    required this.isLoading,
    required this.walletAddress,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).managedWalletTxHistory,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
        else if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: colorScheme.outline),
                  const SizedBox(height: 8),
                  Text(AppLocalizations.of(context).managedWalletNoTx, style: TextStyle(color: colorScheme.outline)),
                ],
              ),
            ),
          )
        else
          ...transactions.map((tx) => _TxListTile(tx: tx, walletAddress: walletAddress)),
      ],
    );
  }
}

class _TxListTile extends StatelessWidget {
  final ManagedWalletTransaction tx;
  final String walletAddress;

  const _TxListTile({required this.tx, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    final isIncoming = tx.toAddress.toLowerCase() == walletAddress.toLowerCase();
    final colorScheme = Theme.of(context).colorScheme;

    final incomingBg = colorScheme.primaryContainer.withValues(alpha: 0.55);
    final outgoingBg = colorScheme.tertiaryContainer.withValues(alpha: 0.45);
    final incomingFg = colorScheme.onPrimaryContainer;
    final outgoingFg = colorScheme.onTertiaryContainer;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isIncoming ? incomingBg : outgoingBg,
        child: Icon(
          isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded,
          size: 18,
          color: isIncoming ? incomingFg : outgoingFg,
        ),
      ),
      title: Text(
        tx.truncatedHash.isNotEmpty ? tx.truncatedHash : tx.txId,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
      ),
      subtitle: Text(
        '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year}  •  ${tx.status}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        '${isIncoming ? '+' : '-'}${FormatUtils.formatDecimalAmountDisplay(tx.amount)} TRX',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isIncoming ? incomingFg : outgoingFg,
            ),
      ),
    );
  }
}
