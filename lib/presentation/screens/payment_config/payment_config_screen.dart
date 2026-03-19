import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/data/models/payment_method_config_model.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/payment_config_provider.dart';
import 'package:crypto_trading_app/presentation/providers/treasury_provider.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/widgets/treasury_create_wallet_sheet.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/widgets/treasury_history_tab_view.dart';
import 'package:crypto_trading_app/presentation/screens/payment_config/widgets/treasury_wallets_tab_view.dart';

/// Payment Method Config Screen — accessible only to ADMIN and FINANCE_MANAGER.
/// Allows dynamic management of PayOS credentials, blockchain hot wallet keys,
/// and network settings without restarting the server.
class PaymentConfigScreen extends StatefulWidget {
  const PaymentConfigScreen({super.key});

  @override
  State<PaymentConfigScreen> createState() => _PaymentConfigScreenState();
}

class _PaymentConfigScreenState extends State<PaymentConfigScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentConfigProvider>().loadConfigs();
      context.read<TreasuryProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.paymentConfigTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshCurrentTab,
              tooltip: l10n.refresh,
            ),
          ],
          bottom: TabBar(
            onTap: (idx) => setState(() => _tabIndex = idx),
            tabs: [
              Tab(text: l10n.paymentConfigMethodsTab),
              Tab(text: l10n.paymentConfigTreasuryWalletsTab),
              Tab(text: l10n.paymentConfigHistoryTab),
            ],
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(context),
        body: const TabBarView(
          children: [
            _PaymentConfigTabView(),
            TreasuryWalletsTabView(),
            TreasuryHistoryTabView(),
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_tabIndex == 0) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateConfigSheet(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.paymentConfigAddMethod),
      );
    }

    if (_tabIndex == 1) {
      return FloatingActionButton.extended(
        onPressed: () => _showCreateTreasuryWalletSheet(context),
        icon: const Icon(Icons.account_balance_wallet_outlined),
        label: Text(l10n.treasuryCreateWalletFab),
      );
    }

    return null;
  }

  Future<void> _refreshCurrentTab() async {
    if (_tabIndex == 0) {
      await context.read<PaymentConfigProvider>().loadConfigs();
      return;
    }

    final treasuryProvider = context.read<TreasuryProvider>();
    if (_tabIndex == 1) {
      await treasuryProvider.loadWallets();
      return;
    }

    await treasuryProvider.loadHistory();
  }

  void _showCreateConfigSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentConfigProvider>(),
        child: const _ConfigFormSheet(configId: null),
      ),
    );
  }

  void _showEditConfigSheet(BuildContext context, PaymentMethodConfigModel config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<PaymentConfigProvider>(),
        child: _ConfigFormSheet(configId: config.configId, existing: config),
      ),
    );
  }

  Future<void> _showCreateTreasuryWalletSheet(BuildContext context) async {
    final provider = context.read<TreasuryProvider>();
    final l10n = AppLocalizations.of(context);

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const TreasuryCreateWalletSheet(),
    );

    if (!context.mounted) return;
    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.treasuryWalletCreatedSuccess)),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _confirmActivate(BuildContext context, PaymentMethodConfigModel config) async {
    final provider = context.read<PaymentConfigProvider>();
    final l10n = AppLocalizations.of(context);
    final graceMinsController = TextEditingController(
      text: config.gracePeriodMinutes.toString(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentConfigActivateDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.paymentConfigActivateTarget(config.displayName)),
            const SizedBox(height: 4),
            Text(
              l10n.paymentConfigActivateWarning,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: graceMinsController,
              decoration: InputDecoration(
                labelText: l10n.paymentConfigGracePeriodLabel,
                border: const OutlineInputBorder(),
                helperText: l10n.paymentConfigGracePeriodHelper,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.paymentConfigActivateAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final graceMins = int.tryParse(graceMinsController.text) ?? config.gracePeriodMinutes;
    final result = await provider.activateConfig(config.configId, gracePeriodMinutes: graceMins);

    if (!context.mounted) return;
    if (result != null) {
      final activatesAt = result['activatesAt'] as String?;
      final activationInfo = activatesAt != null
          ? '. ${l10n.paymentConfigActivationAt(activatesAt.substring(0, 16).replaceAll('T', ' '))}'
          : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.paymentConfigActivationStartedMinutes(graceMins)}$activationInfo',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.paymentConfigActivateFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDeactivate(BuildContext context, PaymentMethodConfigModel config) async {
    final provider = context.read<PaymentConfigProvider>();
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.paymentConfigDeactivateDialogTitle),
        content: Text(
          l10n.paymentConfigDeactivateDialogContent(config.displayName),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.paymentConfigDeactivateAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await provider.deactivateConfig(config.configId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? l10n.paymentConfigDeactivatedSuccess : (provider.error ?? l10n.error)),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
}

class _PaymentConfigTabView extends StatelessWidget {
  const _PaymentConfigTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<PaymentConfigProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.configs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.configs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(provider.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.loadConfigs,
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.configs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.paymentConfigEmptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadConfigs,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: provider.configs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final screenState = context.findAncestorStateOfType<_PaymentConfigScreenState>();
              final config = provider.configs[index];
              return _PaymentConfigCard(
                config: config,
                onEdit: () => screenState?._showEditConfigSheet(context, config),
                onActivate: () => screenState?._confirmActivate(context, config),
                onDeactivate: () => screenState?._confirmDeactivate(context, config),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Payment Config Card ──────────────────────────────────────────────────────

class _PaymentConfigCard extends StatelessWidget {
  final PaymentMethodConfigModel config;
  final VoidCallback onEdit;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;

  const _PaymentConfigCard({
    required this.config,
    required this.onEdit,
    required this.onActivate,
    required this.onDeactivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final statusColor = config.isActive
        ? Colors.green
        : config.isTransitioning
            ? Colors.orange
            : Colors.grey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.displayName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${config.typeLabel} · ${config.network}',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: config.status, color: statusColor),
              ],
            ),
            if (config.isTransitioning && config.graceMinsRemaining != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.hourglass_top, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    l10n.paymentConfigTransitioningRemaining(config.graceMinsRemaining ?? 0),
                    style: const TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              l10n.paymentConfigVersionAndSort(config.configVersion, config.sortOrder),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (config.activatedAt != null)
              Text(
                l10n.paymentConfigActivatedAt(_formatDate(config.activatedAt!)),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(l10n.paymentConfigEditAction),
                ),
                const SizedBox(width: 8),
                if (!config.isActive && !config.isTransitioning)
                  FilledButton.icon(
                    onPressed: onActivate,
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: Text(l10n.paymentConfigActivateAction),
                  )
                else if (config.isActive)
                  OutlinedButton.icon(
                    onPressed: onDeactivate,
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.stop, size: 16),
                    label: Text(l10n.paymentConfigDeactivateAction),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (status) {
      'ACTIVE' => l10n.paymentConfigStatusActiveUpper,
      'TRANSITIONING' => l10n.paymentConfigStatusTransitioningUpper,
      _ => l10n.paymentConfigStatusInactiveUpper,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

// ── Config Form Sheet ────────────────────────────────────────────────────────

/// Bottom sheet for creating or editing a payment method config.
/// Credentials (API keys, private keys) are masked by default.
class _ConfigFormSheet extends StatefulWidget {
  final String? configId;
  final PaymentMethodConfigModel? existing;

  const _ConfigFormSheet({this.configId, this.existing});

  @override
  State<_ConfigFormSheet> createState() => _ConfigFormSheetState();
}

class _ConfigFormSheetState extends State<_ConfigFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late String _type;
  late String _network;
  late final TextEditingController _displayNameCtrl;
  late final TextEditingController _graceMinsCtrl;

  // PayOS fields
  final _payosClientIdCtrl = TextEditingController();
  final _payosApiKeyCtrl = TextEditingController();
  final _payosChecksumKeyCtrl = TextEditingController();
  final _payosReturnUrlCtrl = TextEditingController();
  final _payosCancelUrlCtrl = TextEditingController();
  final _payosFiatSymbolCtrl = TextEditingController(text: 'VND');
  final _payosQuoteSymbolCtrl = TextEditingController(text: 'USDT');
  final _payosRateCtrl = TextEditingController(text: '0.00004');
  final _payosSpreadCtrl = TextEditingController(text: '0');

  // Blockchain fields
  final _rpcUrlCtrl = TextEditingController();
  final _hotWalletKeyCtrl = TextEditingController();
  final _withdrawMaxCtrl = TextEditingController(text: '0.5');
  final _nativeCurrencyCtrl = TextEditingController();
  final _fxFallbackRateCtrl = TextEditingController(text: '1');
  bool _isMainnet = false;

  bool _showSensitiveFields = false;
  bool _isSubmitting = false;

  final List<String> _types = ['PAYOS', 'ETH', 'TRON', 'SOL'];
  final Map<String, List<String>> _networks = {
    'PAYOS': ['MAINNET'],
    'ETH': ['SEPOLIA', 'MAINNET'],
    'TRON': ['NILE', 'SHASTA', 'MAINNET'],
    'SOL': ['DEVNET', 'MAINNET'],
  };

  @override
  void initState() {
    super.initState();
    _type = widget.existing?.type ?? 'PAYOS';
    _network = widget.existing?.network ?? 'MAINNET';
    _displayNameCtrl = TextEditingController(text: widget.existing?.displayName ?? '');
    _graceMinsCtrl = TextEditingController(
      text: (widget.existing?.gracePeriodMinutes ?? 15).toString(),
    );
    _isMainnet = _network == 'MAINNET';
    _nativeCurrencyCtrl.text = switch (_type) {
      'ETH' => 'ETH',
      'TRON' => 'TRX',
      'SOL' => 'SOL',
      _ => '',
    };
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _graceMinsCtrl.dispose();
    _payosClientIdCtrl.dispose();
    _payosApiKeyCtrl.dispose();
    _payosChecksumKeyCtrl.dispose();
    _payosReturnUrlCtrl.dispose();
    _payosCancelUrlCtrl.dispose();
    _payosFiatSymbolCtrl.dispose();
    _payosQuoteSymbolCtrl.dispose();
    _payosRateCtrl.dispose();
    _payosSpreadCtrl.dispose();
    _rpcUrlCtrl.dispose();
    _hotWalletKeyCtrl.dispose();
    _withdrawMaxCtrl.dispose();
    _nativeCurrencyCtrl.dispose();
    _fxFallbackRateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) => Form(
          key: _formKey,
          child: ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Text(
                    widget.configId == null
                        ? l10n.paymentConfigAddMethod
                        : l10n.paymentConfigEditConfigTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Type selector
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigMethodTypeLabel,
                  border: const OutlineInputBorder(),
                ),
                items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _type = v;
                      _network = _networks[v]!.first;
                      _nativeCurrencyCtrl.text = switch (v) {
                        'ETH' => 'ETH',
                        'TRON' => 'TRX',
                        'SOL' => 'SOL',
                        _ => '',
                      };
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              // Network selector
              DropdownButtonFormField<String>(
                initialValue: _network,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigNetworkLabel,
                  border: const OutlineInputBorder(),
                ),
                items: (_networks[_type] ?? [])
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _network = v;
                      _isMainnet = v == 'MAINNET';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameCtrl,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigDisplayNameLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.paymentConfigDisplayNameHint,
                ),
                validator: (v) => (v?.isEmpty ?? true) ? l10n.paymentConfigRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _graceMinsCtrl,
                decoration: InputDecoration(
                  labelText: l10n.paymentConfigGracePeriodLabel,
                  border: const OutlineInputBorder(),
                  helperText: l10n.paymentConfigGracePeriodEffectHelper,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    l10n.paymentConfigCredentialsSectionTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showSensitiveFields = !_showSensitiveFields),
                    icon: Icon(
                      _showSensitiveFields ? Icons.visibility_off : Icons.visibility,
                      size: 16,
                    ),
                    label: Text(_showSensitiveFields ? l10n.paymentConfigHideAction : l10n.paymentConfigShowAction),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_type == 'PAYOS') ..._buildPayOSFields(),
              if (_type != 'PAYOS') ..._buildBlockchainFields(),
              const SizedBox(height: 24),
              if (_isMainnet)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.paymentConfigMainnetWarning,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.configId == null
                            ? l10n.paymentConfigCreateConfigAction
                            : l10n.paymentConfigSaveChangesAction,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPayOSFields() {
    final l10n = AppLocalizations.of(context);
    return [
        _MaskedTextField(
          controller: _payosClientIdCtrl,
          label: 'Client ID',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _payosApiKeyCtrl,
          label: 'API Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _payosChecksumKeyCtrl,
          label: 'Checksum Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _payosReturnUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Return URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _payosCancelUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'Cancel URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosFiatSymbolCtrl,
              decoration: const InputDecoration(labelText: 'Fiat Symbol', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosQuoteSymbolCtrl,
              decoration: const InputDecoration(labelText: 'Quote Symbol', border: OutlineInputBorder()),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _payosRateCtrl,
              decoration: InputDecoration(labelText: l10n.paymentConfigRateLabel, border: const OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _payosSpreadCtrl,
              decoration: const InputDecoration(labelText: 'FX Spread (bps)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ),
        ]),
      ];
  }

  List<Widget> _buildBlockchainFields() {
    final l10n = AppLocalizations.of(context);
    return [
        TextFormField(
          controller: _rpcUrlCtrl,
          decoration: const InputDecoration(
            labelText: 'RPC URL',
            border: OutlineInputBorder(),
            hintText: 'https://...',
          ),
        ),
        const SizedBox(height: 10),
        _MaskedTextField(
          controller: _hotWalletKeyCtrl,
          label: 'Hot Wallet Private Key',
          show: _showSensitiveFields,
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: _nativeCurrencyCtrl,
              decoration: const InputDecoration(labelText: 'Native Symbol', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _withdrawMaxCtrl,
              decoration: const InputDecoration(labelText: 'Withdraw Auto Max', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextFormField(
          controller: _fxFallbackRateCtrl,
          decoration: const InputDecoration(
            labelText: 'FX Fallback Rate (1 Native → X USDT)',
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('Mainnet'),
          subtitle: Text(l10n.paymentConfigMainnetSubtitle),
          value: _isMainnet,
          onChanged: (v) => setState(() => _isMainnet = v),
          contentPadding: EdgeInsets.zero,
        ),
      ];
  }

  Map<String, dynamic> _buildConfigPayload() {
    if (_type == 'PAYOS') {
      return {
        'clientId': _payosClientIdCtrl.text.trim(),
        'apiKey': _payosApiKeyCtrl.text.trim(),
        'checksumKey': _payosChecksumKeyCtrl.text.trim(),
        'returnUrl': _payosReturnUrlCtrl.text.trim(),
        'cancelUrl': _payosCancelUrlCtrl.text.trim(),
        'fiatSymbol': _payosFiatSymbolCtrl.text.trim().toUpperCase(),
        'quoteCurrencySymbol': _payosQuoteSymbolCtrl.text.trim().toUpperCase(),
        'fiatToQuoteRate': _payosRateCtrl.text.trim(),
        'fxSpreadBps': _payosSpreadCtrl.text.trim(),
      };
    }
    return {
      'rpcUrl': _rpcUrlCtrl.text.trim(),
      'hotWalletPrivateKey': _hotWalletKeyCtrl.text.trim(),
      'nativeCurrencySymbol': _nativeCurrencyCtrl.text.trim().toUpperCase(),
      'withdrawAutoMax': _withdrawMaxCtrl.text.trim(),
      'fxFallbackRate': _fxFallbackRateCtrl.text.trim(),
      'isMainnet': _isMainnet,
    };
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<PaymentConfigProvider>();
    final configPayload = _buildConfigPayload();

    bool success;
    if (widget.configId == null) {
      success = await provider.createConfig(
        type: _type,
        network: _network,
        displayName: _displayNameCtrl.text.trim(),
        config: configPayload,
        gracePeriodMinutes: int.tryParse(_graceMinsCtrl.text) ?? 15,
      );
    } else {
      success = await provider.updateConfig(
        widget.configId!,
        displayName: _displayNameCtrl.text.trim(),
        config: configPayload.values.any((v) => v.toString().isNotEmpty) ? configPayload : null,
        gracePeriodMinutes: int.tryParse(_graceMinsCtrl.text),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.configId == null
                ? l10n.paymentConfigCreatedSuccess
                : l10n.paymentConfigUpdatedSuccess,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.paymentConfigUnknownError),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _MaskedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool show;

  const _MaskedTextField({
    required this.controller,
    required this.label,
    required this.show,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      obscureText: !show,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: show ? null : l10n.paymentConfigMaskedHelper,
      ),
    );
  }
}
