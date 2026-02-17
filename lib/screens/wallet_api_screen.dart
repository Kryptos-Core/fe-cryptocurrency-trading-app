import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/data/datasources/currencies_remote_datasource.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/toast_service.dart';

/// Chuẩn hóa chuỗi số tiền để gửi API: bỏ dấu phẩy (ví dụ "10,000.50" -> "10000.50").
String _parseAmountForApi(String formatted) {
  return formatted.replaceAll(',', '');
}

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

/// Formatter hiển thị số tiền: phần nguyên có dấu phẩy, phần thập phân sau dấu chấm (vd 10,000.00).
class _AmountInputFormatter extends TextInputFormatter {
  static const int _maxDecimalPlaces = 8;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final raw = newValue.text.replaceAll(',', '');
    final dotIndex = raw.indexOf('.');
    String intPart = dotIndex >= 0 ? raw.substring(0, dotIndex) : raw;
    String decPart = dotIndex >= 0 && dotIndex < raw.length - 1
        ? raw.substring(dotIndex + 1)
        : '';
    intPart = intPart.replaceAll(RegExp(r'\D'), '');
    if (intPart.isEmpty) intPart = '0';
    decPart = decPart.replaceAll(RegExp(r'\D'), '');
    if (decPart.length > _maxDecimalPlaces) decPart = decPart.substring(0, _maxDecimalPlaces);

    final formattedInt = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) formattedInt.write(',');
      formattedInt.write(intPart[i]);
    }
    final formatted = decPart.isEmpty
        ? formattedInt.toString()
        : '${formattedInt}.$decPart';

    final sel = newValue.selection.extentOffset.clamp(0, newValue.text.length);
    final rawBeforeCursor = newValue.text.substring(0, sel).replaceAll(',', '');
    int n = 0;
    bool seenDot = false;
    for (int i = 0; i < rawBeforeCursor.length; i++) {
      if (RegExp(r'\d').hasMatch(rawBeforeCursor[i])) {
        n++;
      } else if (rawBeforeCursor[i] == '.' && !seenDot) {
        n++;
        seenDot = true;
      }
    }
    int newOffset = formatted.length;
    int count = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (count >= n) {
        newOffset = i;
        break;
      }
      if (formatted[i] == ',') continue;
      if (formatted[i] == '.') {
        count++;
        newOffset = i + 1;
      } else {
        count++;
        newOffset = i + 1;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newOffset.clamp(0, formatted.length)),
    );
  }
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
      print('[WalletApiScreen] Error loading currencies: $e');
    }
  }

  void _fetchBalance() {
    if (_selectedCurrencyId != null && _currencies.isNotEmpty) {
      final selectedCurrency = _currencies.firstWhere(
        (c) => c.currencyId == _selectedCurrencyId,
        orElse: () => _currencies.first,
      );
      print(
          '[WalletApiScreen] Fetching balance for ${selectedCurrency.symbol} (currencyId: $_selectedCurrencyId)');

      context.read<WalletsProvider>().fetchWalletBalance(
            _selectedCurrencyId!,
            forceRefresh: true,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _selectedCurrencyId,
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
                  decoration: InputDecoration(
                    labelText: l10n.selectCurrency,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.currency_bitcoin,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
    final l10n = AppLocalizations.of(context)!;
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

              const SizedBox(height: 24),

              Text(
                l10n.actions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildActionButton(
                    context,
                    l10n.deposit,
                    Icons.add_circle,
                    Theme.of(context).colorScheme.primary,
                    () => _showDepositDialog(),
                  ),
                  _buildActionButton(
                    context,
                    l10n.withdraw,
                    Icons.remove_circle,
                    Theme.of(context).colorScheme.error,
                    () => _showWithdrawDialog(),
                  ),
                  _buildActionButton(
                    context,
                    l10n.transfer,
                    Icons.send,
                    Theme.of(context).colorScheme.secondary,
                    () => _showTransferDialog(),
                  ),
                ],
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
                ...WalletTransactionAction.values
                    .map((a) => DropdownMenuItem(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildBalanceRow(
      BuildContext context, String label, String amount, Color color, IconData icon) {
    final theme = Theme.of(context);
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
                amount,
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

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Color color, VoidCallback onPressed) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = color == scheme.primary
        ? scheme.onPrimary
        : color == scheme.error
            ? scheme.onError
            : scheme.onSecondary;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  IconData _getActionIcon(WalletTransactionAction action) {
    switch (action) {
      case WalletTransactionAction.credit:
        return Icons.add_circle;
      case WalletTransactionAction.debit:
        return Icons.remove_circle;
      case WalletTransactionAction.freeze:
        return Icons.lock;
      case WalletTransactionAction.unfreeze:
        return Icons.lock_open;
      case WalletTransactionAction.transfer:
        return Icons.send;
    }
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
        return l10n?.deposit ?? 'Deposit';
      case WalletReferenceType.withdraw:
        return l10n?.withdraw ?? 'Withdraw';
      case WalletReferenceType.transfer:
        return l10n?.transfer ?? 'Transfer';
      case WalletReferenceType.order:
        return 'Order';
      case WalletReferenceType.trade:
        return 'Trade';
      case WalletReferenceType.adjust:
        return 'Adjust';
    }
  }

  void _showDepositDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.deposit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_AmountInputFormatter()],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final provider = context.read<WalletsProvider>();
                final success = await provider.deposit(
                  currencyId: _selectedCurrencyId!,
                  amount: _parseAmountForApi(amountController.text),
                  refId: '${DateTime.now().millisecondsSinceEpoch}',
                );
                if (!mounted) return;
                final l10nSuccess = AppLocalizations.of(context)!;
                if (success) {
                  ToastService().show(
                    context,
                    message: l10nSuccess.depositSuccess,
                    type: ToastType.success,
                  );
                  _fetchBalance();
                } else {
                  ToastService().show(
                    context,
                    message: '${l10nSuccess.depositFailed}: ${provider.error ?? ''}',
                    type: ToastType.error,
                    duration: const Duration(seconds: 4),
                  );
                }
              },
              child: Text(l10n.deposit),
            ),
          ],
        );
      },
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.withdraw),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_AmountInputFormatter()],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final provider = context.read<WalletsProvider>();
                final success = await provider.withdraw(
                  currencyId: _selectedCurrencyId!,
                  amount: _parseAmountForApi(amountController.text),
                  refId: '${DateTime.now().millisecondsSinceEpoch}',
                );
                if (!mounted) return;
                final l10nSuccess = AppLocalizations.of(context)!;
                if (success) {
                  ToastService().show(
                    context,
                    message: l10nSuccess.withdrawSuccess,
                    type: ToastType.success,
                  );
                  _fetchBalance();
                } else {
                  ToastService().show(
                    context,
                    message: '${l10nSuccess.withdrawFailed}: ${provider.error ?? ''}',
                    type: ToastType.error,
                    duration: const Duration(seconds: 4),
                  );
                }
              },
              child: Text(l10n.withdraw),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog() {
    final amountController = TextEditingController();
    final toUserIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.transfer),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: toUserIdController,
                decoration: InputDecoration(
                  labelText: l10n.toUserId,
                  hintText: '1',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  hintText: '0.00',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_AmountInputFormatter()],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final provider = context.read<WalletsProvider>();
                final success = await provider.transfer(
                  currencyId: _selectedCurrencyId!,
                  amount: _parseAmountForApi(amountController.text),
                  toUserId: toUserIdController.text.trim(),
                );
                if (!mounted) return;
                final l10nSuccess = AppLocalizations.of(context)!;
                if (success) {
                  ToastService().show(
                    context,
                    message: l10nSuccess.transferSuccess,
                    type: ToastType.success,
                  );
                  _fetchBalance();
                } else {
                  ToastService().show(
                    context,
                    message: '${l10nSuccess.transferFailed}: ${provider.error ?? ''}',
                    type: ToastType.error,
                    duration: const Duration(seconds: 4),
                  );
                }
              },
              child: Text(l10n.transfer),
            ),
          ],
        );
      },
    );
  }
}
