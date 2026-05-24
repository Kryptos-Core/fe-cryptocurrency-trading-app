import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/features/wallets/presentation/widgets/wallet_transaction_tile.dart';
import 'package:crypto_trading_app/features/wallets/presentation/widgets/transaction_filter_bar.dart';

/// Wallet Detail Screen
/// Displays wallet balance and transaction history with filter support,
/// pagination, and consistent UI across all transaction types.
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
  final ScrollController _scrollController = ScrollController();
  String? _selectedRefType;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<WalletsProvider>();
      provider.getWalletBalance(widget.walletId);
      provider.fetchLedger(walletId: widget.walletId, refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 100) {
      final provider = context.read<WalletsProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadMoreLedger(
          walletId: widget.walletId,
          refType: _selectedRefType,
        );
      }
    }
  }

  void _onFilterChanged(String? refType) {
    setState(() {
      _selectedRefType = refType == 'ALL' ? null : refType;
    });
    final provider = context.read<WalletsProvider>();
    provider.setLedgerFilter(refType: _selectedRefType);
    provider.fetchLedger(
      walletId: widget.walletId,
      refType: _selectedRefType,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<WalletsProvider>(
          builder: (context, provider, child) {
            return Text(provider.selectedWallet?.currency.symbol ?? l10n.walletDetails);
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
            return Center(child: Text(l10n.walletNotFound));
          }

          final currencySymbol = wallet.currency.symbol;
          final filters = buildWalletLedgerFilters(l10n);

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchLedger(
                walletId: widget.walletId,
                refType: _selectedRefType,
                refresh: true,
              );
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      color: scheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.walletAvailableBalance,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${FormatUtils.formatDecimalAmountDisplay(wallet.available)} $currencySymbol',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.walletFrozen,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${FormatUtils.formatDecimalAmountDisplay(wallet.frozen)} $currencySymbol',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 36,
                                  color: scheme.outlineVariant,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.walletTotal,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${FormatUtils.formatDecimalAmountDisplay(wallet.total)} $currencySymbol',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Transaction History Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 20,
                          color: scheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.walletRecentTransactions,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        if (provider.isLoading && provider.ledger.isNotEmpty)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ),
                ),

                // Filter Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TransactionFilterBar(
                      filters: filters,
                      selectedValue: _selectedRefType ?? 'ALL',
                      onChanged: _onFilterChanged,
                    ),
                  ),
                ),

                // Transaction List
                if (provider.ledger.isEmpty && !provider.isLoading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: _selectedRefType != null
                          ? AppEmptyState(
                              message: l10n.walletNoTransactionsMatch,
                              icon: Icons.filter_list_off,
                            )
                          : AppEmptyState(
                              message: l10n.walletNoTransactions,
                              icon: Icons.receipt_long_outlined,
                            ),
                    ),
                  )
                else if (provider.ledger.isEmpty && provider.isLoading)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 200),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= provider.ledger.length) {
                            if (provider.hasMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }
                          return WalletTransactionTile(
                            ledger: provider.ledger[index],
                            currencySymbol: currencySymbol,
                          );
                        },
                        childCount: provider.ledger.length + (provider.hasMore ? 1 : 0),
                      ),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
