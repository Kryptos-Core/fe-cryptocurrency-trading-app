import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:intl/intl.dart';

/// Wallet Detail Screen
/// Displays wallet balance and transaction history
class WalletDetailScreen extends StatefulWidget {
  final String walletId;

  const WalletDetailScreen({
    super.key,
    required this.walletId,
  });

  @override
  State<WalletDetailScreen> createState() => _WalletDetailScreenState();
}

class _WalletDetailScreenState extends State<WalletDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletsProvider>();
      provider.getWalletBalance(widget.walletId);
      provider.fetchLedger(walletId: widget.walletId, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<WalletsProvider>(
          builder: (context, provider, child) {
            return Text(provider.selectedWallet?.currency.symbol ?? AppLocalizations.of(context).walletDetails);
          },
        ),
      ),
      body: Consumer<WalletsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.selectedWallet == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final wallet = provider.selectedWallet;
          if (wallet == null) {
            return Center(child: Text(AppLocalizations.of(context).walletNotFound));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).walletAvailableBalance,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${FormatUtils.formatDecimalAmountDisplay(wallet.available)} ${wallet.currency.symbol}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).walletFrozen,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${FormatUtils.formatDecimalAmountDisplay(wallet.frozen)} ${wallet.currency.symbol}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppLocalizations.of(context).walletTotal,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${FormatUtils.formatDecimalAmountDisplay(wallet.total)} ${wallet.currency.symbol}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Transaction History
                Text(
                  AppLocalizations.of(context).walletTransactionHistory,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (provider.ledger.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(AppLocalizations.of(context).walletNoTransactions),
                    ),
                  )
                else
                  ...provider.ledger.map((entry) => _buildLedgerItem(entry)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLedgerItem(ledger) {
    final isCredit = ledger.isCredit;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getLedgerIcon(ledger.refType),
          color: isCredit ? Colors.green : Colors.red,
        ),
        title: Text(
          ledger.refType,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(dateFormat.format(ledger.createdAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}${FormatUtils.formatDecimalAmountDisplay(ledger.amount.toString())}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            Text(
              AppLocalizations.of(context).walletBalanceAfter(FormatUtils.formatDecimalAmountDisplay(ledger.balanceAfter.toString())),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLedgerIcon(String refType) {
    switch (refType) {
      case 'DEPOSIT':
        return Icons.arrow_downward;
      case 'WITHDRAW':
        return Icons.arrow_upward;
      case 'TRADE':
        return Icons.swap_horiz;
      case 'ORDER':
        return Icons.shopping_cart;
      default:
        return Icons.info;
    }
  }
}
