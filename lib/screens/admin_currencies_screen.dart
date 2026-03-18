import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/data/models/create_currency_dto.dart';
import 'package:crypto_trading_app/data/models/update_currency_dto.dart';
import 'package:crypto_trading_app/domain/entities/currency.dart';
import 'package:crypto_trading_app/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/presentation/providers/currencies_provider.dart';

/// Admin screen for browsing and managing currencies/coins.
///
/// Role-aware:
///  - ADMIN / currencies:manage → full CRUD (create, edit, delete, toggle switches)
///  - RISK_OFFICER / SUPPORT_AGENT → read-only list with search & filters
class AdminCurrenciesScreen extends StatefulWidget {
  const AdminCurrenciesScreen({super.key});

  @override
  State<AdminCurrenciesScreen> createState() => _AdminCurrenciesScreenState();
}

// Status filter values
enum _StatusFilter { all, active, inactive }

// Trading filter values
enum _TradableFilter { all, tradable, paused }

class _AdminCurrenciesScreenState extends State<AdminCurrenciesScreen> {
  final _scrollController = ScrollController();
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  // Local filter state — drives the provider
  _StatusFilter _statusFilter = _StatusFilter.all;
  _TradableFilter _tradableFilter = _TradableFilter.all;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CurrenciesProvider>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _applyFilters);
  }

  void _applyFilters() {
    final provider = context.read<CurrenciesProvider>();
    bool? isActive;
    bool includeInactive = true;

    switch (_statusFilter) {
      case _StatusFilter.all:
        includeInactive = true;
        isActive = null;
      case _StatusFilter.active:
        includeInactive = false;
        isActive = null;
      case _StatusFilter.inactive:
        includeInactive = true;
        isActive = false;
    }

    bool? isTradable;
    switch (_tradableFilter) {
      case _TradableFilter.all:
        isTradable = null;
      case _TradableFilter.tradable:
        isTradable = true;
      case _TradableFilter.paused:
        isTradable = false;
    }

    provider.applyFilters(
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      isActive: isActive,
      isTradable: isTradable,
      includeInactive: includeInactive,
    );
  }

  void _setStatusFilter(_StatusFilter f) {
    if (_statusFilter == f) return;
    setState(() => _statusFilter = f);
    _applyFilters();
  }

  void _setTradableFilter(_TradableFilter f) {
    if (_tradableFilter == f) return;
    setState(() => _tradableFilter = f);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final canManage = auth.canManageCurrencies;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Coin'),
        actions: [
          Consumer<CurrenciesProvider>(
            builder: (_, p, __) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('${p.total}'),
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.monetization_on_outlined, size: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Search bar ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm theo symbol hoặc tên...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _applyFilters();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
            ),
          ),

          // ── Filter chips ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status row
                Row(
                  children: [
                    Text('Trạng thái:',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 6),
                    _buildStatusChip(_StatusFilter.all, 'Tất cả'),
                    const SizedBox(width: 4),
                    _buildStatusChip(_StatusFilter.active, 'Hoạt động'),
                    const SizedBox(width: 4),
                    _buildStatusChip(_StatusFilter.inactive, 'Không HĐ'),
                  ],
                ),
                const SizedBox(height: 4),
                // Tradable row
                Row(
                  children: [
                    Text('Giao dịch:',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(width: 6),
                    _buildTradableChip(_TradableFilter.all, 'Tất cả'),
                    const SizedBox(width: 4),
                    _buildTradableChip(_TradableFilter.tradable, 'Đang GD'),
                    const SizedBox(width: 4),
                    _buildTradableChip(_TradableFilter.paused, 'Tạm dừng'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 12),

          // ── List ───────────────────────────────────────────────────────────
          Expanded(
            child: Consumer<CurrenciesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.currencies.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.currencies.isEmpty) {
                  return _ErrorPanel(
                    message: provider.error!,
                    onRetry: _applyFilters,
                  );
                }

                if (!provider.isLoading && provider.currencies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 48,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text('Không tìm thấy coin nào',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _applyFilters(),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: provider.currencies.length +
                        (provider.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 12, endIndent: 12),
                    itemBuilder: (context, i) {
                      if (i >= provider.currencies.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final currency = provider.currencies[i];
                      return _CurrencyRow(
                        currency: currency,
                        canManage: canManage,
                        onToggleActive: canManage
                            ? (v) => _handleToggle(context,
                                () => provider.toggleActive(currency.currencyId, v))
                            : null,
                        onToggleTradable: canManage
                            ? (v) => _handleToggle(context,
                                () => provider.toggleTradable(currency.currencyId, v))
                            : null,
                        onEdit: canManage
                            ? () => _showEditDialog(context, currency)
                            : null,
                        onDelete: canManage
                            ? () => _confirmDelete(context, currency)
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // FAB only for users who can manage currencies
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tạo coin'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            )
          : null,
    );
  }

  // ── Chip helpers ─────────────────────────────────────────────────────────

  Widget _buildStatusChip(_StatusFilter value, String label) {
    final selected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => _setStatusFilter(value),
    );
  }

  Widget _buildTradableChip(_TradableFilter value, String label) {
    final selected = _tradableFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => _setTradableFilter(value),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _handleToggle(
      BuildContext context, Future<String?> Function() action) async {
    final err = await action();
    if (!context.mounted) return;
    if (err != null) {
      showAppSnackBar(context, message: err, type: SnackBarType.error);
    }
  }

  void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _CurrencyFormDialog(
        title: 'Tạo coin mới',
        onSubmit: (dto) async {
          final provider = context.read<CurrenciesProvider>();
          final err = await provider.createCurrency(dto);
          if (!context.mounted) return;
          if (err != null) {
            showAppSnackBar(context, message: err, type: SnackBarType.error);
          } else {
            Navigator.pop(context);
            showAppSnackBar(context,
                message: 'Tạo coin thành công!', type: SnackBarType.success);
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Currency currency) {
    showDialog(
      context: context,
      builder: (_) => _CurrencyEditDialog(
        currency: currency,
        onSubmit: (dto) async {
          final provider = context.read<CurrenciesProvider>();
          final err = await provider.updateCurrency(currency.currencyId, dto);
          if (!context.mounted) return;
          if (err != null) {
            showAppSnackBar(context, message: err, type: SnackBarType.error);
          } else {
            Navigator.pop(context);
            showAppSnackBar(context,
                message: 'Cập nhật thành công!', type: SnackBarType.success);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Currency currency) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoá coin'),
        content: Text(
            'Bạn có chắc muốn xoá "${currency.symbol} — ${currency.name}"?\nThao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Huỷ')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final provider = context.read<CurrenciesProvider>();
              final err = await provider.deleteCurrency(currency.currencyId);
              if (!context.mounted) return;
              if (err != null) {
                showAppSnackBar(context, message: err, type: SnackBarType.error);
              } else {
                showAppSnackBar(context,
                    message: 'Đã xoá coin!', type: SnackBarType.success);
              }
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}

// ── Currency Row ──────────────────────────────────────────────────────────────

/// Single currency list tile.
///
/// When [canManage] is false (read-only roles) all mutation callbacks are null
/// and interactive controls are hidden / disabled.
class _CurrencyRow extends StatelessWidget {
  final Currency currency;
  final bool canManage;
  final ValueChanged<bool>? onToggleActive;
  final ValueChanged<bool>? onToggleTradable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CurrencyRow({
    required this.currency,
    required this.canManage,
    this.onToggleActive,
    this.onToggleTradable,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = currency.isActive;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        child: Text(
          currency.symbol.length > 4
              ? currency.symbol.substring(0, 4)
              : currency.symbol,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              '${currency.symbol} — ${currency.name}',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? null : colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          if (!isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Ẩn',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      subtitle: Text(
        'Precision: ${currency.precisionScale} · Min Withdraw: ${currency.minWithdraw}',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: colorScheme.onSurfaceVariant),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tradable indicator / toggle
          Tooltip(
            message: currency.isTradable ? 'Đang giao dịch' : 'Không giao dịch',
            child: canManage
                ? InkWell(
                    onTap: () => onToggleTradable?.call(!currency.isTradable),
                    borderRadius: BorderRadius.circular(4),
                    child: _TradableBadge(isTradable: currency.isTradable),
                  )
                : _TradableBadge(isTradable: currency.isTradable),
          ),
          const SizedBox(width: 4),
          // Active switch (manage only) or static badge
          if (canManage)
            Switch(
              value: isActive,
              onChanged: onToggleActive,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                size: 18,
                color: isActive ? Colors.green : colorScheme.onSurfaceVariant,
              ),
            ),
          // More options (manage only)
          if (canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
                const PopupMenuItem(
                    value: 'delete',
                    child:
                        Text('Xoá', style: TextStyle(color: Colors.red))),
              ],
              onSelected: (v) {
                if (v == 'edit') onEdit?.call();
                if (v == 'delete') onDelete?.call();
              },
            ),
        ],
      ),
    );
  }
}

class _TradableBadge extends StatelessWidget {
  final bool isTradable;
  const _TradableBadge({required this.isTradable});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 16,
            color: isTradable ? Colors.green : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 2),
          Text(
            isTradable ? 'GD' : 'Off',
            style: TextStyle(
                fontSize: 10,
                color: isTradable
                    ? Colors.green
                    : colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Create Currency Dialog ────────────────────────────────────────────────────

class _CurrencyFormDialog extends StatefulWidget {
  final String title;
  final Future<void> Function(CreateCurrencyDto) onSubmit;

  const _CurrencyFormDialog({
    required this.title,
    required this.onSubmit,
  });

  @override
  State<_CurrencyFormDialog> createState() => _CurrencyFormDialogState();
}

class _CurrencyFormDialogState extends State<_CurrencyFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _symbolCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _precisionCtrl = TextEditingController(text: '8');
  final _minWithdrawCtrl = TextEditingController(text: '0');
  bool _isTradable = true;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _symbolCtrl.dispose();
    _nameCtrl.dispose();
    _precisionCtrl.dispose();
    _minWithdrawCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final dto = CreateCurrencyDto(
      symbol: _symbolCtrl.text.trim().toUpperCase(),
      name: _nameCtrl.text.trim(),
      precisionScale: int.tryParse(_precisionCtrl.text.trim()),
      minWithdraw: _minWithdrawCtrl.text.trim().isEmpty
          ? null
          : _minWithdrawCtrl.text.trim(),
      isTradable: _isTradable,
      isActive: _isActive,
    );
    await widget.onSubmit(dto);
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _symbolCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Symbol *',
                      hintText: 'BTC'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Name *',
                      hintText: 'Bitcoin'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _precisionCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Precision Scale',
                      hintText: '8'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minWithdrawCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Min Withdraw',
                      hintText: '0.001'),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Giao dịch'),
                    Switch(
                        value: _isTradable,
                        onChanged: (v) =>
                            setState(() => _isTradable = v)),
                    const SizedBox(width: 12),
                    const Text('Hoạt động'),
                    Switch(
                        value: _isActive,
                        onChanged: (v) =>
                            setState(() => _isActive = v)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Huỷ')),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Tạo'),
        ),
      ],
    );
  }
}

// ── Edit Currency Dialog ──────────────────────────────────────────────────────

class _CurrencyEditDialog extends StatefulWidget {
  final Currency currency;
  final Future<void> Function(UpdateCurrencyDto) onSubmit;

  const _CurrencyEditDialog({
    required this.currency,
    required this.onSubmit,
  });

  @override
  State<_CurrencyEditDialog> createState() => _CurrencyEditDialogState();
}

class _CurrencyEditDialogState extends State<_CurrencyEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _precisionCtrl;
  late final TextEditingController _minWithdrawCtrl;
  late bool _isTradable;
  late bool _isActive;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.currency;
    _nameCtrl = TextEditingController(text: c.name);
    _precisionCtrl =
        TextEditingController(text: c.precisionScale.toString());
    _minWithdrawCtrl = TextEditingController(text: c.minWithdraw);
    _isTradable = c.isTradable;
    _isActive = c.isActive;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _precisionCtrl.dispose();
    _minWithdrawCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final dto = UpdateCurrencyDto(
      name: _nameCtrl.text.trim(),
      precisionScale: int.tryParse(_precisionCtrl.text.trim()),
      minWithdraw: _minWithdrawCtrl.text.trim().isEmpty
          ? null
          : _minWithdrawCtrl.text.trim(),
      isTradable: _isTradable,
      isActive: _isActive,
    );
    await widget.onSubmit(dto);
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Chỉnh sửa ${widget.currency.symbol}'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _precisionCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Precision Scale'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _minWithdrawCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Min Withdraw'),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Giao dịch'),
                    Switch(
                        value: _isTradable,
                        onChanged: (v) =>
                            setState(() => _isTradable = v)),
                    const SizedBox(width: 12),
                    const Text('Hoạt động'),
                    Switch(
                        value: _isActive,
                        onChanged: (v) =>
                            setState(() => _isActive = v)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Huỷ')),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Lưu'),
        ),
      ],
    );
  }
}

// ── Error Panel ───────────────────────────────────────────────────────────────

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
