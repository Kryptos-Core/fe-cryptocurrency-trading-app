import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/amount_input_formatter.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'admin_user_list_screen.dart';

/// Platform cash currency symbol — must match PLATFORM_CASH_CURRENCY_SYMBOL on BE
const _kPlatformCashSymbol = 'USDT';

/// Màn hình điều chỉnh số dư ví thủ công dành cho Admin / Risk Officer.
/// Nên ưu tiên sử dụng flow: Quản lý người dùng → Chọn user → Nạp/Rút.
/// Màn hình này giữ lại như fallback hoặc quick access.
class AdminWalletAdjustScreen extends StatefulWidget {
  const AdminWalletAdjustScreen({super.key});

  @override
  State<AdminWalletAdjustScreen> createState() =>
      _AdminWalletAdjustScreenState();
}

class _AdminWalletAdjustScreenState extends State<AdminWalletAdjustScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Người dùng được chọn từ user picker
  User? _selectedUser;
  String _selectedType = 'DEPOSIT';

  // For history tab
  final _historyUserIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrenciesProvider>().fetchCurrencies(refresh: false);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _historyUserIdController.dispose();
    super.dispose();
  }

  Future<void> _pickUser() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_selectedUser == null) {
      showAppSnackBar(context,
          message: l10n.adminWalletAdjustSelectUserRequired, type: SnackBarType.warning);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final currProvider = context.read<CurrenciesProvider>();
    final usdt = currProvider.currencies
        .where((c) => c.symbol.toUpperCase() == _kPlatformCashSymbol)
        .firstOrNull;
    if (usdt == null) {
      showAppSnackBar(context,
          message: l10n.adminWalletAdjustUsdtNotFound,
          type: SnackBarType.warning);
      return;
    }

    final provider = context.read<WalletsProvider>();
    final success = await provider.adminAdjustBalance(
      userId: _selectedUser!.id,
      currencyId: usdt.currencyId,
      amount: parseAmountInput(_amountController.text),
      type: _selectedType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      showAppSnackBar(
        context,
        message: _selectedType == 'DEPOSIT'
            ? 'Nạp số dư thành công!'
            : 'Rút số dư thành công!',
        type: SnackBarType.success,
      );
      _formKey.currentState!.reset();
      _amountController.clear();
      _noteController.clear();
      setState(() => _selectedUser = null);
    } else {
      showAppSnackBar(
        context,
        message: provider.adjustError ?? l10n.adminWalletAdjustError,
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _loadHistory() async {
    final l10n = AppLocalizations.of(context);
    final uid = _historyUserIdController.text.trim();
    if (uid.isEmpty) {
      showAppSnackBar(context,
          message: l10n.adminWalletAdjustUserIdRequired, type: SnackBarType.warning);
      return;
    }
    await context.read<WalletsProvider>().loadAdjustmentHistory(
          uid,
          refresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminWalletAdjustTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.adminWalletAdjustDepositWithdrawTab),
            Tab(text: l10n.adminWalletAdjustHistoryTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdjustTab(theme, colorScheme),
          _buildHistoryTab(theme, colorScheme),
        ],
      ),
    );
  }

  // ── Tab 1: Form điều chỉnh ──────────────────────────────────────────────────

  Widget _buildAdjustTab(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<WalletsProvider>(
      builder: (context, walletsProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gợi ý dùng flow mới
                Card(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(Icons.info_outline,
                        color: colorScheme.primary),
                    title: Text(AppLocalizations.of(context).adminWalletAdjustUseUserMgmt),
                    subtitle: Text(
                        AppLocalizations.of(context).adminWalletAdjustUseUserMgmtSubtitle,
                        style: const TextStyle(fontSize: 12)),
                    trailing: TextButton(
                      child: Text(AppLocalizations.of(context).adminWalletAdjustOpen),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUserListScreen(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(theme,
                    title: AppLocalizations.of(context).adminWalletAdjustOperationType,
                    child: _buildTypeSegment(context, colorScheme)),
                const SizedBox(height: 12),
                _sectionCard(
                  theme,
                  title: AppLocalizations.of(context).adminWalletAdjustInfo,
                  child: Column(
                    children: [
                      _buildPlatformCashInfo(context, theme, colorScheme),
                      const SizedBox(height: 12),
                      // User picker
                      InkWell(
                        onTap: _pickUser,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: colorScheme.outline),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_search,
                                  color: colorScheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _selectedUser == null
                                    ? Text(
                                        AppLocalizations.of(context).adminWalletAdjustSelectUserHint,
                                        style: TextStyle(
                                            color: colorScheme
                                                .onSurfaceVariant),
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedUser!.fullName,
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight.w600),
                                          ),
                                          Text(
                                            _selectedUser!.email,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: colorScheme
                                                    .onSurfaceVariant),
                                          ),
                                        ],
                                      ),
                              ),
                              if (_selectedUser != null)
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      setState(() => _selectedUser = null),
                                  iconSize: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [AmountInputFormatter()],
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).adminWalletAdjustAmountLabel,
                          hintText: AppLocalizations.of(context).adminWalletAdjustAmountHint,
                          prefixIcon: Icon(
                            _selectedType == 'DEPOSIT'
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: _selectedType == 'DEPOSIT'
                                ? Colors.green
                                : Colors.red,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final l10n = AppLocalizations.of(context);
                          final raw = parseAmountInput(v ?? '');
                          if (raw.isEmpty) {
                            return l10n.adminWalletAdjustAmountRequired;
                          }
                          if (!RegExp(r'^\d+(\.\d{1,18})?$').hasMatch(raw)) {
                            return l10n.adminWalletAdjustAmountInvalid;
                          }
                          final num = double.tryParse(raw);
                          if (num == null || num <= 0) {
                            return l10n.adminWalletAdjustAmountMustBePositive;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context).adminWalletAdjustNoteLabel,
                          hintText: AppLocalizations.of(context).adminWalletAdjustReasonHint,
                          prefixIcon: Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSubmitButton(context, walletsProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSegment(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'DEPOSIT',
          label: Text(l10n.adminWalletAdjustDepositTab),
          icon: const Icon(Icons.arrow_downward),
        ),
        ButtonSegment(
          value: 'WITHDRAW',
          label: Text(l10n.adminWalletAdjustWithdrawTab),
          icon: const Icon(Icons.arrow_upward),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (set) =>
          setState(() => _selectedType = set.first),
      style: ButtonStyle(
        iconColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _selectedType == 'DEPOSIT' ? Colors.green : Colors.red;
          }
          return null;
        }),
      ),
    );
  }

  Widget _buildPlatformCashInfo(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Consumer<CurrenciesProvider>(
      builder: (context, currProvider, _) {
        if (currProvider.isLoading && currProvider.currencies.isEmpty) {
          return const LinearProgressIndicator();
        }
        final hasUsdt = currProvider.currencies
            .any((c) => c.symbol.toUpperCase() == _kPlatformCashSymbol);
        final l10n = AppLocalizations.of(context);
        return ListTile(
          leading: const Icon(Icons.account_balance_wallet),
          title: Text(l10n.adminWalletPlatformCash),
          subtitle: Text(
            hasUsdt
                ? l10n.adminWalletPlatformCashInfo
                : l10n.adminWalletLoading,
            style: theme.textTheme.bodySmall,
          ),
          tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(BuildContext context, WalletsProvider provider) {
    final l10n = AppLocalizations.of(context);
    final isDeposit = _selectedType == 'DEPOSIT';
    return FilledButton.icon(
      onPressed: provider.isAdjusting ? null : _submit,
      icon: provider.isAdjusting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(isDeposit ? Icons.add_circle : Icons.remove_circle),
      label: Text(
        provider.isAdjusting
            ? l10n.adminWalletAdjustProcessing
            : (isDeposit ? l10n.adminWalletAdjustDepositBalance : l10n.adminWalletAdjustWithdrawBalance),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: isDeposit ? Colors.green : Colors.red,
      ),
    );
  }

  // ── Tab 2: Lịch sử điều chỉnh ───────────────────────────────────────────────

  Widget _buildHistoryTab(ThemeData theme, ColorScheme colorScheme) {
    return Consumer<WalletsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
                  child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _historyUserIdController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context).adminWalletHistoryUserIdLabel,
                        hintText: AppLocalizations.of(context).adminWalletSearchUserIdHint,
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed:
                        provider.isLoadingHistory ? null : _loadHistory,
                    child: provider.isLoadingHistory
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(AppLocalizations.of(context).adminWalletSearchButton),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child:               OutlinedButton.icon(
                icon: const Icon(Icons.people_alt_outlined, size: 16),
                label: Text(AppLocalizations.of(context).adminWalletSearchByUserList),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserListScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: provider.isLoadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : provider.adjustmentHistory.isEmpty
                      ? Center(
                          child: Text(AppLocalizations.of(context).adminWalletNoAdjustmentHistory),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: provider.adjustmentHistory.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) => _AdjustmentTile(
                            item: provider.adjustmentHistory[i],
                            l10n: AppLocalizations.of(context),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _sectionCard(
    ThemeData theme, {
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị một dòng trong lịch sử điều chỉnh.
class _AdjustmentTile extends StatelessWidget {
  final AdminWalletAdjustment item;
  final AppLocalizations l10n;

  const _AdjustmentTile({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isDeposit = item.isDeposit;
    final color = isDeposit ? Colors.green : Colors.red;
    final sign = isDeposit ? '+' : '-';
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt.toLocal());

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        '$sign${item.amount} ${item.currencySymbol ?? item.currencyId}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l10n.adminWalletTargetLabel}: ${item.targetEmail ?? item.targetUserId}'),
          Text('${l10n.adminWalletActorLabel}: ${item.actorEmail ?? item.actorUserId}'),
          if (item.note != null && item.note!.isNotEmpty)
            Text(
              '${l10n.adminUserDetailNoteLabel}: ${item.note}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }
}
