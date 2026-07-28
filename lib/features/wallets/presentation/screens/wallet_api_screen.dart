import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/wallets/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:crypto_trading_app/features/wallets/domain/entities/wallet.dart';
import 'package:crypto_trading_app/features/wallets/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/currencies_repository.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/currency.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/currency_bookmark_store.dart';
import 'package:crypto_trading_app/features/blockchain/presentation/screens/blockchain_hub_screen.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';
import 'package:crypto_trading_app/features/wallets/presentation/widgets/transaction_filter_bar.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/currency_picker_sheet.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/features/deposits/presentation/screens/deposits_screen.dart';
import 'package:crypto_trading_app/features/withdrawals/presentation/screens/fiat_bank_withdrawal_screen.dart';

String _formatAmountForDisplay(String amountStr) =>
    FormatUtils.formatDecimalAmountDisplay(amountStr);

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
  List<Currency> _currencies = [];
  bool _isLoadingCurrencies = true;
  String? _currenciesError;

  WalletsProvider? _walletsProviderListener;
  bool _userLockedCurrencySelection = false;
  bool _appliedWalletLoadedDefault = false;

  final CurrenciesRepository _currenciesRepository = sl<CurrenciesRepository>();

  final TextEditingController _txSearchController = TextEditingController();
  String? _txFilterRefType; // refType value: DEPOSIT, WITHDRAW, ORDER, TRADE, ADJUST, TRANSFER, ONCHAIN

  @override
  void dispose() {
    _walletsProviderListener?.removeListener(_onWalletsProviderChanged);
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
      if (!mounted) return;
      final walletsProvider = context.read<WalletsProvider>();
      _walletsProviderListener = walletsProvider;
      walletsProvider.addListener(_onWalletsProviderChanged);
      context.read<DashboardProvider>().refresh(force: true);
      walletsProvider.fetchWallets(includeZero: true);
    });
  }

  void _onWalletsProviderChanged() {
    if (!mounted ||
        _userLockedCurrencySelection ||
        _appliedWalletLoadedDefault ||
        _currencies.isEmpty) {
      return;
    }
    final wallets = _walletsProviderListener?.wallets ?? [];
    if (wallets.isEmpty) return;

    final id = _defaultSelectedCurrencyId(_currencies, wallets);
    if (id == null) return;

    _appliedWalletLoadedDefault = true;
    if (id != _selectedCurrencyId) {
      setState(() => _selectedCurrencyId = id);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchBalance();
      });
    }
  }

  Future<void> _loadCurrencies() async {
    setState(() {
      _isLoadingCurrencies = true;
      _currenciesError = null;
    });

    final result = await _currenciesRepository.getActiveCurrencies();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingCurrencies = false;
          _currenciesError = failure.message;
        });
        if (kDebugMode) {
          debugPrint(
              '[WalletApiScreen] Error loading currencies: ${failure.message}');
        }
      },
      (currencies) {
        final wallets = context.read<WalletsProvider>().wallets;
        setState(() {
          _currencies = currencies;
          _isLoadingCurrencies = false;

          if (_currencies.isNotEmpty && _selectedCurrencyId == null) {
            _selectedCurrencyId =
                _defaultSelectedCurrencyId(_currencies, wallets);
            if (wallets.isNotEmpty) {
              _appliedWalletLoadedDefault = true;
            }
          }
        });

        if (mounted && _currencies.isNotEmpty && _selectedCurrencyId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fetchBalance();
          });
        }
      },
    );
  }

  void _fetchBalance() {
    if (_selectedCurrencyId != null && _currencies.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[WalletApiScreen] Fetching selected wallet balance');
      }

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

  Currency? get _selectedCurrency {
    final id = _selectedCurrencyId;
    if (id == null || _currencies.isEmpty) return null;
    for (final c in _currencies) {
      if (c.currencyId == id) return c;
    }
    return null;
  }

  Future<void> _openCurrencyPicker(BuildContext context) async {
    final store = CurrencyBookmarkStore(sl<SharedPreferences>());
    final picked = await showCurrencyPickerBottomSheet(
      context,
      currencies: _currencies,
      selectedCurrencyId: _selectedCurrencyId,
      bookmarkStore: store,
    );
    if (!mounted || picked == null) return;
    _userLockedCurrencySelection = true;
    setState(() => _selectedCurrencyId = picked.currencyId);
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

          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final selected = _selectedCurrency;

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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const Key('wallet_currency_picker'),
                    borderRadius: BorderRadius.circular(8),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () => _openCurrencyPicker(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.selectCurrency,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        suffixIcon:
                            const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                      child: Text(
                        selected != null
                            ? '${selected.symbol} (${selected.name})'
                            : l10n.currencySelectHint,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: selected != null
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
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
                    const SizedBox(width: 8),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FiatBankWithdrawalScreen(),
                        ),
                      );
                      if (context.mounted) _refreshAll();
                    },
                    icon: const Icon(Icons.payments_outlined),
                    label: Text(l10n.fiatWithdrawToBankShort),
                  ),
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
    // Lọc theo refType
    if (_txFilterRefType != null && _txFilterRefType != 'ALL') {
      if (_txFilterRefType == 'ONCHAIN') {
        list = list.where((tx) {
          final rt = tx.refType.name.toUpperCase();
          return rt == 'EXTERNAL_DEPOSIT' ||
              rt == 'EXTERNAL_WITHDRAWAL' ||
              rt == 'EXTERNAL_SYNC';
        }).toList();
      } else {
        list = list.where((tx) => tx.refType.name.toUpperCase() == _txFilterRefType).toList();
      }
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
        Row(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.recentTransactions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
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
        const SizedBox(height: 8),
        TransactionFilterBar(
          filters: buildWalletLedgerFilters(l10n),
          selectedValue: _txFilterRefType ?? 'ALL',
          onChanged: (v) {
            setState(
              () => _txFilterRefType = (v == null || v == 'ALL') ? null : v,
            );
          },
        ),
        const SizedBox(height: 16),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Table header
              Container(
                color: theme.colorScheme.surfaceContainerLow,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        l10n.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        l10n.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        l10n.direction,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          l10n.amount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12,
                      child: Center(
                        child: Container(
                          width: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          l10n.reference,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
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
                    final color = _getRefTypeColor(context, tx.refType);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _formatTxDate(tx.timestamp),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  _getRefTypeIcon(tx.refType),
                                  size: 18,
                                  color: color,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _getRefTypeLabel(tx.refType, l10n),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _DirectionBadge(
                              action: tx.action,
                              color: color,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                _formatAmountForDisplay(tx.amount),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                            child: Center(
                              child: Container(
                                width: 1,
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                '#${tx.refId}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: hasAny
                      ? AppEmptyStateInline(
                          message: l10n.noTransactionsMatch,
                          icon: Icons.filter_list_off,
                        )
                      : AppEmptyStateInline(
                          message: l10n.noTransactionsFound,
                          icon: Icons.receipt_long_outlined,
                        ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRefTypeColor(BuildContext context, WalletReferenceType refType) {
    final scheme = Theme.of(context).colorScheme;
    switch (refType) {
      case WalletReferenceType.deposit:
        return const Color(0xFF0F8A49);
      case WalletReferenceType.withdraw:
        return const Color(0xFFB3261E);
      case WalletReferenceType.trade:
        return scheme.primary;
      case WalletReferenceType.order:
        return scheme.tertiary;
      case WalletReferenceType.transfer:
        return scheme.secondary;
      case WalletReferenceType.adjust:
        return scheme.outline;
    }
  }

  IconData _getRefTypeIcon(WalletReferenceType refType) {
    switch (refType) {
      case WalletReferenceType.deposit:
        return Icons.arrow_downward_rounded;
      case WalletReferenceType.withdraw:
        return Icons.arrow_upward_rounded;
      case WalletReferenceType.transfer:
        return Icons.people_outline_rounded;
      case WalletReferenceType.order:
        return Icons.shopping_cart_outlined;
      case WalletReferenceType.trade:
        return Icons.swap_horiz_rounded;
      case WalletReferenceType.adjust:
        return Icons.tune_rounded;
    }
  }

  String _getRefTypeLabel(WalletReferenceType refType, AppLocalizations l10n) {
    switch (refType) {
      case WalletReferenceType.deposit:
        return l10n.walletFilterDeposit;
      case WalletReferenceType.withdraw:
        return l10n.walletFilterWithdraw;
      case WalletReferenceType.trade:
        return l10n.walletFilterTrade;
      case WalletReferenceType.order:
        return l10n.walletFilterOrder;
      case WalletReferenceType.transfer:
        return l10n.walletFilterTransfer;
      case WalletReferenceType.adjust:
        return l10n.walletFilterAdjust;
    }
  }
}

// ── Filter Dropdown ──────────────────────────────────────────────────────────

// ── Direction Badge ──────────────────────────────────────────────────────────

/// Compact badge showing transaction direction (CREDIT → IN / DEBIT → OUT).
class _DirectionBadge extends StatelessWidget {
  final WalletTransactionAction action;
  final Color color;

  const _DirectionBadge({required this.action, required this.color});

  @override
  Widget build(BuildContext context) {
    final isCredit = action == WalletTransactionAction.credit;
    final label = isCredit ? 'IN' : 'OUT';
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Portfolio Overview ───────────────────────────────────────────────────────

bool _walletHasNonZeroBalance(Wallet w) {
  final a = double.tryParse(w.available) ?? 0;
  final f = double.tryParse(w.frozen) ?? 0;
  final t = double.tryParse(w.total) ?? 0;
  return a != 0 || f != 0 || t != 0;
}

/// Ưu tiên ví có số dư (theo thứ tự GET /wallets), sau đó USDT, cuối cùng coin đầu danh sách active.
String? _defaultSelectedCurrencyId(
  List<Currency> currencies,
  List<Wallet> wallets,
) {
  if (currencies.isEmpty) return null;
  final active = currencies.map((c) => c.currencyId).toSet();
  for (final w in wallets) {
    final id = w.currency.currencyId;
    if (active.contains(id) && _walletHasNonZeroBalance(w)) {
      return id;
    }
  }
  for (final c in currencies) {
    if (c.symbol.toUpperCase() == 'USDT') return c.currencyId;
  }
  return currencies.first.currencyId;
}

/// Tổng quan danh mục + tổng quy USDT — **luôn** hiển thị cho mọi role đã đăng nhập.
///
/// Nguồn dòng coin: ưu tiên [WalletsProvider] (GET /wallets, `include_zero=true`);
/// nếu rỗng (lỗi mạng / user chưa có ví) thì fallback [DashboardSummary.wallets].
/// Chỉ hiển thị các dòng có số dư khác 0 để card gọn và dễ đọc.
class _PortfolioOverview extends StatelessWidget {
  static const int _maxVisibleRows = 5;
  static const double _rowExtent = 52;
  static const double _rowSpacing = 4;

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
    // Chỉ hiển thị coin có số dư > 0.
    return nonZero;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fmt = NumberFormat('#,##0.########');
    final rows = _rowsForDisplay();
    const maxListHeight =
        (_maxVisibleRows * _rowExtent) + ((_maxVisibleRows - 1) * _rowSpacing);

    final totalUsdt = dashboardProvider.portfolioTotal;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.pie_chart_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.walletPortfolioCardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '≈ ${NumberFormat('#,##0.##').format(totalUsdt)} USDT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(
                l10n.walletPortfolioEmptyHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: maxListHeight),
                child: ListView.separated(
                  primary: false,
                  shrinkWrap: true,
                  physics: rows.length > _maxVisibleRows
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    return _CoinBalanceRow(
                      wallet: rows[index],
                      fmt: fmt,
                    );
                  },
                ),
              ),
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
    final l10n = AppLocalizations.of(context);
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wallet.currency.symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (frozen > 0)
                  Text(
                    '${l10n.frozen}: ${fmt.format(frozen)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                  ),
              ],
            ),
          ),
          // Available + Total
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fmt.format(total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${l10n.available}: ${fmt.format(available)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
