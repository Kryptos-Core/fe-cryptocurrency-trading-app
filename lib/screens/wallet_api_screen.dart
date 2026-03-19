import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/domain/entities/wallet.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/presentation/screens/blockchain/blockchain_hub_screen.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/screens/deposits_screen.dart';

/// Format số tiền hiển thị: dấu phẩy nghìn, tối đa 2 chữ số thập phân (bỏ số 0 thừa).
String _formatAmountForDisplay(String amountStr) {
  final n = double.tryParse(amountStr.replaceAll(',', ''));
  if (n == null) return amountStr;
  final formatter = NumberFormat('#,##0.##');
  return formatter.format(n);
}

/// Format ngày giờ giao dịch (ngắn gọn, chuẩn doanh nghiệp).
String _formatTxDate(DateTime dt) {
  return DateFormat('yyyy-MM-dd HH:mm').format(dt);
}

/// Wallet API Screen - Hiển thị wallet balance từ API thật
class WalletApiScreen extends StatefulWidget {
  const WalletApiScreen({super.key});

  @override
  State<WalletApiScreen> createState() => _WalletApiScreenState();
}

class _WalletApiScreenState extends State<WalletApiScreen> {
  String? _selectedCurrencyId;
  List<CurrencyModel> _currencies = [];
  bool _isLoadingCurrencies = true;
  String? _currenciesError;

  final CurrenciesRemoteDataSource _currenciesDataSource =
      sl<CurrenciesRemoteDataSource>();

  final TextEditingController _txSearchController = TextEditingController();
  WalletTransactionAction? _txFilterType;

  @override
  void dispose() {
    _txSearchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    // Portfolio + quy đổi USDT cần GET /dashboard; ví list dùng include_zero=true
    // để mọi role (admin/support/…) vẫn có dòng tổng hợp dù trước đó chỉ gọi /wallets?include_zero=false.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refresh(force: true);
      context.read<WalletsProvider>().fetchWallets(includeZero: true);
    });
  }

  Future<void> _loadCurrencies() async {
    try {
      setState(() {
        _isLoadingCurrencies = true;
        _currenciesError = null;
      });

      final currencies = await _currenciesDataSource.getActiveCurrencies();

      setState(() {
        _currencies = currencies;
        _isLoadingCurrencies = false;

        // Select first currency (usually BTC) by default
        if (_currencies.isNotEmpty && _selectedCurrencyId == null) {
          _selectedCurrencyId = _currencies.first.currencyId;
          // Fetch balance after selecting currency
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchBalance();
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingCurrencies = false;
        _currenciesError = e.toString();
      });
      debugPrint('[WalletApiScreen] Error loading currencies: $e');
    }
  }

  void _fetchBalance() {
    if (_selectedCurrencyId != null && _currencies.isNotEmpty) {
      final selectedCurrency = _currencies.firstWhere(
        (c) => c.currencyId == _selectedCurrencyId,
        orElse: () => _currencies.first,
      );
      debugPrint(
          '[WalletApiScreen] Fetching balance for ${selectedCurrency.symbol} (currencyId: $_selectedCurrencyId)');

      context.read<WalletsProvider>().fetchWalletBalance(
            _selectedCurrencyId!,
            forceRefresh: true,
          );
    }
  }

  /// Refresh cả portfolio overview lẫn balance của currency đang chọn.
  /// Được gọi khi quay lại từ DepositsScreen hoặc BlockchainHubScreen.
  void _refreshAll() {
    final provider = context.read<WalletsProvider>();
    context.read<DashboardProvider>().refresh(force: true);
    provider.fetchWallets(includeZero: true);
    _fetchBalance();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Consumer<WalletsProvider>(
        builder: (context, provider, child) {
          if (_isLoadingCurrencies) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currenciesError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currenciesError!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurrencies,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (_currencies.isEmpty) {
            return Center(
              child: Text(l10n.noActiveCurrencies),
            );
          }

          return Column(
            children: [
              // Tổng danh mục: mọi role đã đăng nhập (fallback dashboard nếu /wallets rỗng)
              Consumer<DashboardProvider>(
                builder: (context, dash, _) => _PortfolioOverview(
                  walletsProvider: provider,
                  dashboardProvider: dash,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppDropdownField<String>(
                  value: _selectedCurrencyId,
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
                  labelText: l10n.selectCurrency,
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency.currencyId,
                      child: Text(
                        '${currency.symbol} (${currency.name})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrencyId = value;
                    });
                    _fetchBalance();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DepositsScreen(),
                            ),
                          );
                          if (context.mounted) _refreshAll();
                        },
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: Text(l10n.payosTopupVnd),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BlockchainHubScreen(),
                            ),
                          );
                          if (context.mounted) _refreshAll();
                        },
                        icon: const Icon(Icons.account_tree_outlined),
                        label: Text(l10n.openOnchainWalletFlow),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBalanceContent(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalanceContent(BuildContext context, WalletsProvider provider) {
    final l10n = AppLocalizations.of(context);
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              provider.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBalance,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (provider.walletBalance != null) {
      return RefreshIndicator(
        onRefresh: () async {
          _fetchBalance();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceRow(
                        context,
                        l10n.available,
                        provider.walletBalance!.available,
                        Theme.of(context).colorScheme.primary,
                        Icons.account_balance_wallet,
                      ),
                      const Divider(height: 32),
                      _buildBalanceRow(
                        context,
                        l10n.frozen,
                        provider.walletBalance!.frozen,
                        Theme.of(context).colorScheme.tertiary,
                        Icons.lock,
                      ),
                      const Divider(height: 32),
                      _buildBalanceRow(
                        context,
                        l10n.total,
                        provider.walletBalance!.total,
                        Theme.of(context).colorScheme.secondary,
                        Icons.account_balance,
                      ),
                    ],
                  ),
                ),
              ),
              _buildRecentTransactionsSection(context, provider, l10n),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  List<WalletTransactionResponse> _getFilteredTransactions(
      WalletsProvider provider) {
    // Chỉ hiển thị lịch sử đúng currency đang chọn, không trộn giữa các currency
    var list = provider.recentTransactions
        .where((tx) => tx.currencyId == _selectedCurrencyId)
        .toList();
    if (_txFilterType != null) {
      list = list.where((tx) => tx.action == _txFilterType).toList();
    }
    final q = _txSearchController.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((tx) {
      final amountStr = _formatAmountForDisplay(tx.amount).toLowerCase();
      final typeStr = tx.action.name.toLowerCase();
      final refTypeStr = tx.refType.name.toLowerCase();
      final dateStr = _formatTxDate(tx.timestamp).toLowerCase();
      final refStr = tx.refId.toString();
      return amountStr.contains(q) ||
          typeStr.contains(q) ||
          refTypeStr.contains(q) ||
          dateStr.contains(q) ||
          refStr.contains(q);
    }).toList();
  }

  Widget _buildRecentTransactionsSection(
      BuildContext context, WalletsProvider provider, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final filtered = _getFilteredTransactions(provider);
    final showRows = filtered.isNotEmpty;
    final hasAny = provider.recentTransactions
        .any((tx) => tx.currencyId == _selectedCurrencyId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.recentTransactions,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _txSearchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.searchTransactions,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<WalletTransactionAction?>(
              value: _txFilterType,
              hint: Text(l10n.filterByType),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.allTypes)),
                ...WalletTransactionAction.values.map((a) => DropdownMenuItem(
                      value: a,
                      child: Text(a.name),
                    )),
              ],
              onChanged: (v) {
                setState(() => _txFilterType = v);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(
                        l10n.date,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: Text(
                        l10n.type,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        l10n.amount,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        l10n.reference,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showRows)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final tx = filtered[i];
                    final color = _getActionColor(context, tx.action);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              _formatTxDate(tx.timestamp),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getRefTypeIcon(tx.refType),
                                  size: 18,
                                  color: color,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getRefTypeLabel(context, tx.refType),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              _formatAmountForDisplay(tx.amount),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              '#${tx.refId}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      hasAny
                          ? l10n.noTransactionsMatch
                          : l10n.noTransactionsFound,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(BuildContext context, String label, String amount,
      Color color, IconData icon) {
    final theme = Theme.of(context);
    final displayAmount = _formatAmountForDisplay(amount);
    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayAmount,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getActionColor(BuildContext context, WalletTransactionAction action) {
    final scheme = Theme.of(context).colorScheme;
    switch (action) {
      case WalletTransactionAction.credit:
        return scheme.primary;
      case WalletTransactionAction.debit:
        return scheme.error;
      case WalletTransactionAction.freeze:
      case WalletTransactionAction.unfreeze:
        return scheme.tertiary;
      case WalletTransactionAction.transfer:
        return scheme.secondary;
    }
  }

  IconData _getRefTypeIcon(WalletReferenceType refType) {
    switch (refType) {
      case WalletReferenceType.deposit:
        return Icons.add_circle;
      case WalletReferenceType.withdraw:
        return Icons.remove_circle;
      case WalletReferenceType.transfer:
        return Icons.send;
      case WalletReferenceType.order:
        return Icons.reorder;
      case WalletReferenceType.trade:
        return Icons.swap_horiz;
      case WalletReferenceType.adjust:
        return Icons.tune;
    }
  }

  String _getRefTypeLabel(BuildContext context, WalletReferenceType refType) {
    final l10n = AppLocalizations.of(context);
    switch (refType) {
      case WalletReferenceType.deposit:
        return l10n.deposit;
      case WalletReferenceType.withdraw:
        return l10n.withdraw;
      case WalletReferenceType.transfer:
        return l10n.transfer;
      case WalletReferenceType.order:
        return 'Order';
      case WalletReferenceType.trade:
        return 'Trade';
      case WalletReferenceType.adjust:
        return 'Adjust';
    }
  }
}

// ── Portfolio Overview ───────────────────────────────────────────────────────

bool _walletHasNonZeroBalance(Wallet w) {
  final a = double.tryParse(w.available) ?? 0;
  final f = double.tryParse(w.frozen) ?? 0;
  final t = double.tryParse(w.total) ?? 0;
  return a != 0 || f != 0 || t != 0;
}

/// Tổng quan danh mục + tổng quy USDT — **luôn** hiển thị cho mọi role đã đăng nhập.
///
/// Nguồn dòng coin: ưu tiên [WalletsProvider] (GET /wallets, `include_zero=true`);
/// nếu rỗng (lỗi mạng / user chưa có ví) thì fallback [DashboardSummary.wallets].
/// Ưu tiên các dòng có số dư; nếu toàn 0 vẫn hiện tối đa 12 dòng để thấy USDT/0G…
class _PortfolioOverview extends StatelessWidget {
  final WalletsProvider walletsProvider;
  final DashboardProvider dashboardProvider;

  const _PortfolioOverview({
    required this.walletsProvider,
    required this.dashboardProvider,
  });

  List<Wallet> _rowsForDisplay() {
    Iterable<Wallet> src;
    if (walletsProvider.wallets.isNotEmpty) {
      src = walletsProvider.wallets;
    } else {
      src = dashboardProvider.summary.wallets.map((e) => e.toWallet());
    }
    final list = src.toList();
    final nonZero = list.where(_walletHasNonZeroBalance).toList();
    if (nonZero.isNotEmpty) return nonZero;
    if (list.isNotEmpty) return list.take(12).toList();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat('#,##0.########');
    final rows = _rowsForDisplay();

    final totalUsdt = dashboardProvider.portfolioTotal;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_outline,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Tổng danh mục',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '≈ ${NumberFormat('#,##0.##').format(totalUsdt)} USDT',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(
                'Chưa có dữ liệu ví. Kéo để làm mới hoặc kiểm tra kết nối.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...rows.map((w) => _CoinBalanceRow(wallet: w, fmt: fmt)),
          ],
        ),
      ),
    );
  }
}

class _CoinBalanceRow extends StatelessWidget {
  final Wallet wallet;
  final NumberFormat fmt;

  const _CoinBalanceRow({required this.wallet, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = double.tryParse(wallet.available) ?? 0;
    final frozen = double.tryParse(wallet.frozen) ?? 0;
    final total = double.tryParse(wallet.total) ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Symbol badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              wallet.currency.symbol.length > 4
                  ? wallet.currency.symbol.substring(0, 4)
                  : wallet.currency.symbol,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Currency name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.currency.symbol,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (frozen > 0)
                  Text(
                    'Đóng băng: ${fmt.format(frozen)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
              ],
            ),
          ),
          // Available + Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fmt.format(total),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Khả dụng: ${fmt.format(available)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
