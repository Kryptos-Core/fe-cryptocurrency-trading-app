import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart';
import 'package:crypto_trading_app/domain/entities/user.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';
import 'package:crypto_trading_app/presentation/providers/wallets_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/app_dropdown_field.dart';
import 'admin_user_list_screen.dart';

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
  String? _selectedCurrencyId;

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
    if (_selectedUser == null) {
      showAppSnackBar(context,
          message: 'Vui lòng chọn người dùng', type: SnackBarType.warning);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCurrencyId == null) {
      showAppSnackBar(context,
          message: 'Vui lòng chọn loại tiền tệ', type: SnackBarType.warning);
      return;
    }

    final provider = context.read<WalletsProvider>();
    final success = await provider.adminAdjustBalance(
      userId: _selectedUser!.id,
      currencyId: _selectedCurrencyId!,
      amount: _amountController.text.trim(),
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
      setState(() {
        _selectedCurrencyId = null;
        _selectedUser = null;
      });
    } else {
      showAppSnackBar(
        context,
        message: provider.adjustError ?? 'Có lỗi xảy ra. Vui lòng thử lại.',
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _loadHistory() async {
    final uid = _historyUserIdController.text.trim();
    if (uid.isEmpty) {
      showAppSnackBar(context,
          message: 'Vui lòng nhập User ID', type: SnackBarType.warning);
      return;
    }
    await context.read<WalletsProvider>().loadAdjustmentHistory(
          uid,
          refresh: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều chỉnh ví'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nạp / Rút'),
            Tab(text: 'Lịch sử'),
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
                    title: const Text('Nên dùng: Quản lý người dùng'),
                    subtitle: const Text(
                        'Vào mục Quản lý người dùng → Chọn user → Nạp/Rút để có trải nghiệm tốt hơn.',
                        style: TextStyle(fontSize: 12)),
                    trailing: TextButton(
                      child: const Text('Mở'),
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
                    title: 'Loại thao tác',
                    child: _buildTypeSegment(colorScheme)),
                const SizedBox(height: 12),
                _sectionCard(
                  theme,
                  title: 'Thông tin điều chỉnh',
                  child: Column(
                    children: [
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
                                        'Chọn người dùng...',
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
                      _buildCurrencyDropdown(),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          hintText: '0.00',
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
                          if (v == null || v.trim().isEmpty) {
                            return 'Vui lòng nhập số tiền';
                          }
                          if (!RegExp(r'^\d+(\.\d{1,18})?$')
                              .hasMatch(v.trim())) {
                            return 'Số tiền không hợp lệ (tối đa 18 chữ số thập phân)';
                          }
                          final num = double.tryParse(v.trim());
                          if (num == null || num <= 0) {
                            return 'Số tiền phải lớn hơn 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 2,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chú (tuỳ chọn)',
                          hintText: 'Lý do điều chỉnh...',
                          prefixIcon: Icon(Icons.notes_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSubmitButton(walletsProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSegment(ColorScheme colorScheme) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'DEPOSIT',
          label: Text('Nạp tiền'),
          icon: Icon(Icons.arrow_downward),
        ),
        ButtonSegment(
          value: 'WITHDRAW',
          label: Text('Rút tiền'),
          icon: Icon(Icons.arrow_upward),
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

  Widget _buildCurrencyDropdown() {
    return Consumer<CurrenciesProvider>(
      builder: (context, currProvider, _) {
        final currencies = currProvider.currencies;
        if (currProvider.isLoading && currencies.isEmpty) {
          return const LinearProgressIndicator();
        }
        return AppDropdownField<String>(
          value: _selectedCurrencyId,
          labelText: 'Loại tiền tệ',
          hintText: 'Chọn currency...',
          items: currencies
              .map((c) => DropdownMenuItem(
                    value: c.currencyId,
                    child: Text('${c.symbol} — ${c.name}'),
                  ))
              .toList(),
          onChanged: (v) => setState(() => _selectedCurrencyId = v),
        );
      },
    );
  }

  Widget _buildSubmitButton(WalletsProvider provider) {
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
            ? 'Đang xử lý...'
            : (isDeposit ? 'Nạp số dư' : 'Rút số dư'),
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
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        hintText: 'Nhập UUID người dùng',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
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
                        : const Text('Tìm'),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.people_alt_outlined, size: 16),
                label: const Text('Tìm qua danh sách người dùng'),
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
                      ? const Center(
                          child: Text('Chưa có lịch sử điều chỉnh'),
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: provider.adjustmentHistory.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) => _AdjustmentTile(
                            item: provider.adjustmentHistory[i],
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

  const _AdjustmentTile({required this.item});

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
          Text('Người nhận: ${item.targetEmail ?? item.targetUserId}'),
          Text('Thực hiện bởi: ${item.actorEmail ?? item.actorUserId}'),
          if (item.note != null && item.note!.isNotEmpty)
            Text(
              'Ghi chú: ${item.note}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      isThreeLine: true,
    );
  }
}
