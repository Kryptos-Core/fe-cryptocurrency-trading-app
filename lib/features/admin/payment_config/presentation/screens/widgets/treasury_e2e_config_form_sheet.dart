import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/treasury_e2e_config_model.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/treasury_e2e_config_provider.dart';

class TreasuryE2EConfigFormSheet extends StatefulWidget {
  const TreasuryE2EConfigFormSheet({super.key, this.existing});

  final TreasuryE2EConfigModel? existing;

  @override
  State<TreasuryE2EConfigFormSheet> createState() => _TreasuryE2EConfigFormSheetState();
}

class _TreasuryE2EConfigFormSheetState extends State<TreasuryE2EConfigFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayName;
  late final TextEditingController _apiBaseUrl;
  late final TextEditingController _withdrawAuto;
  late final TextEditingController _withdrawManual;
  late final TextEditingController _depositTxHash;
  late final TextEditingController _depositAmount;
  late final TextEditingController _staleManual;
  late final TextEditingController _staleConfirming;
  late final TextEditingController _failed24h;
  late final TextEditingController _reconcileLimit;
  late final TextEditingController _reconciliationThreshold;
  late final TextEditingController _traderToken;
  late final TextEditingController _riskToken;
  late final TextEditingController _traderSearch;

  String _environment = 'development';
  String _chain = 'BSC_CHAPEL';
  String? _linkedWalletId;
  String? _traderUserId;
  String? _selectedRiskUserId;
  bool _allowSkip = true;
  bool _healthFailOnCritical = false;
  bool _showAdvanced = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _environment = existing?.environment ?? 'development';
    _chain = existing?.chain ?? 'BSC_CHAPEL';
    _linkedWalletId = existing?.linkedWalletId;
    _traderUserId = existing?.traderUserId;
    _allowSkip = existing?.allowSkip ?? true;
    _healthFailOnCritical = existing?.healthFailOnCritical ?? false;
    _displayName = TextEditingController(text: existing?.displayName ?? '');
    _apiBaseUrl = TextEditingController(text: existing?.apiBaseUrl ?? 'http://127.0.0.1:3000');
    _withdrawAuto = TextEditingController(text: existing?.withdrawAmountAuto ?? '0.01');
    _withdrawManual = TextEditingController(text: existing?.withdrawAmountManual ?? '1.0');
    _depositTxHash = TextEditingController(text: existing?.depositTxHash ?? '');
    _depositAmount = TextEditingController(text: existing?.depositAmount ?? '');
    _staleManual = TextEditingController(text: '${existing?.staleManualMinutes ?? 15}');
    _staleConfirming = TextEditingController(text: '${existing?.staleConfirmingMinutes ?? 30}');
    _failed24h = TextEditingController(text: '${existing?.failedWithdrawals24h ?? 10}');
    _reconcileLimit = TextEditingController(text: '${existing?.reconcilePairLimit ?? 100}');
    _reconciliationThreshold = TextEditingController(text: existing?.reconciliationThreshold ?? '0.001');
    _traderToken = TextEditingController();
    _riskToken = TextEditingController();
    _traderSearch = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<TreasuryE2EConfigProvider>().loadFormOptions(
            environment: _environment,
            chain: _chain,
            force: true,
          );
    });
  }

  @override
  void dispose() {
    _displayName.dispose();
    _apiBaseUrl.dispose();
    _withdrawAuto.dispose();
    _withdrawManual.dispose();
    _depositTxHash.dispose();
    _depositAmount.dispose();
    _staleManual.dispose();
    _staleConfirming.dispose();
    _failed24h.dispose();
    _reconcileLimit.dispose();
    _reconciliationThreshold.dispose();
    _traderToken.dispose();
    _riskToken.dispose();
    _traderSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TreasuryE2EConfigProvider>();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final options = provider.formOptions;
    final linkedWallets = (options?['linkedWallets'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];
    final traders = (options?['traders'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.existing == null
                          ? l10n.treasuryE2eCreateTitle
                          : l10n.treasuryE2eEditTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic info row
                        Row(
                          children: [
                            Expanded(child: DropdownButtonFormField<String>(
                              initialValue: _environment,
                              items: const [
                                DropdownMenuItem(value: 'development', child: Text('development')),
                                DropdownMenuItem(value: 'staging', child: Text('staging')),
                                DropdownMenuItem(value: 'test', child: Text('test')),
                                DropdownMenuItem(value: 'production', child: Text('production')),
                              ],
                              onChanged: (value) => setState(() => _environment = value ?? 'development'),
                              decoration: InputDecoration(labelText: l10n.treasuryE2eEnvironmentLabel, isDense: true),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: DropdownButtonFormField<String>(
                              initialValue: _chain,
                              items: const [
                                'BSC_CHAPEL', 'ETH_SEPOLIA', 'SOLANA_DEVNET', 'TRON_NILE',
                                'TRON_SHASTA', 'BASE_SEPOLIA', 'ARBITRUM_SEPOLIA',
                              ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (value) async {
                                setState(() {
                                  _chain = value ?? 'BSC_CHAPEL';
                                  _linkedWalletId = null;
                                });
                                await _reloadOptions();
                              },
                              decoration: InputDecoration(labelText: l10n.treasuryE2eChainLabel, isDense: true),
                            )),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _textCompactCompact(_displayName, l10n.treasuryE2eDisplayNameLabel),
                        const SizedBox(height: 10),
                        _textCompactCompact(_apiBaseUrl, l10n.treasuryE2eApiBaseUrlLabel),
                        const SizedBox(height: 10),
                        // Trader selection
                        Row(
                          children: [
                            Expanded(child: _textCompactCompact(_traderSearch, l10n.treasuryE2eTraderSearchLabel, required: false)),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _reloadOptions,
                              icon: const Icon(Icons.search),
                              tooltip: l10n.treasuryE2eLoadTraderAction,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String?>(
                          initialValue: _traderUserId,
                          items: [
                            DropdownMenuItem<String?>(value: null, child: Text(l10n.treasuryE2eTraderEmpty, style: const TextStyle(fontSize: 12))),
                            ...traders.map((user) => DropdownMenuItem<String?>(
                              value: user['user_id']?.toString(),
                              child: Text(
                                '${user['email']} (${user['first_name'] ?? ''})',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                            )),
                          ],
                          onChanged: (value) async {
                            setState(() {
                              _traderUserId = value;
                              _linkedWalletId = null;
                            });
                            await _reloadOptions();
                          },
                          decoration: InputDecoration(labelText: l10n.treasuryE2eTraderSelectLabel, isDense: true),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String?>(
                          initialValue: linkedWallets.any((e) => e['link_id'] == _linkedWalletId) ? _linkedWalletId : null,
                          items: [
                            DropdownMenuItem<String?>(value: null, child: Text(l10n.treasuryE2eLinkedWalletEmpty, style: const TextStyle(fontSize: 12))),
                            ...linkedWallets.map((wallet) {
                              final label = wallet['label']?.toString();
                              final address = wallet['address']?.toString() ?? '-';
                              return DropdownMenuItem<String?>(
                                value: wallet['link_id']?.toString(),
                                child: Text(
                                  '${label?.isNotEmpty == true ? label : address.substring(0, 8)}...',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) => setState(() => _linkedWalletId = value),
                          decoration: InputDecoration(labelText: l10n.treasuryE2eLinkedWalletLabel, isDense: true),
                        ),
                        const SizedBox(height: 10),
                        // Amounts row
                        Row(
                          children: [
                            Expanded(child: _textCompactCompact(_withdrawAuto, l10n.treasuryE2eWithdrawAutoLabel)),
                            const SizedBox(width: 12),
                            Expanded(child: _textCompactCompact(_withdrawManual, l10n.treasuryE2eWithdrawManualLabel)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Switches row
                        Row(
                          children: [
                            Expanded(child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(l10n.treasuryE2eAllowSkipLabel, style: const TextStyle(fontSize: 12)),
                              value: _allowSkip,
                              onChanged: (value) => setState(() => _allowSkip = value),
                            )),
                            Expanded(child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(l10n.treasuryE2eFailOnCriticalLabel, style: const TextStyle(fontSize: 12)),
                              value: _healthFailOnCritical,
                              onChanged: (value) => setState(() => _healthFailOnCritical = value),
                            )),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Advanced toggle
                        InkWell(
                          onTap: () => setState(() => _showAdvanced = !_showAdvanced),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more, size: 20),
                                const SizedBox(width: 4),
                                Text(l10n.treasuryE2eLegacyTokenSection, style: theme.textTheme.labelMedium),
                              ],
                            ),
                          ),
                        ),
                        if (_showAdvanced) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _textCompactCompact(_staleManual, l10n.treasuryE2eStaleManualLabel)),
                              const SizedBox(width: 8),
                              Expanded(child: _textCompactCompact(_staleConfirming, l10n.treasuryE2eStaleConfirmingLabel)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _textCompactCompact(_failed24h, l10n.treasuryE2eFailed24hLabel)),
                              const SizedBox(width: 8),
                              Expanded(child: _textCompactCompact(_reconcileLimit, l10n.treasuryE2eReconcileLimitLabel)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _textCompactCompact(_reconciliationThreshold, l10n.treasuryE2eReconciliationThresholdLabel),
                          const SizedBox(height: 8),
                          if (widget.existing?.traderBearerTokenMasked != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(l10n.treasuryE2eCurrentTraderToken(widget.existing!.traderBearerTokenMasked!), style: theme.textTheme.bodySmall),
                            ),
                          Text(l10n.treasuryE2eIdentityPreferredHint, style: theme.textTheme.bodySmall),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String?>(
                            initialValue: _resolveRiskActorInitialValue(traders, options),
                            items: [
                              DropdownMenuItem<String?>(value: null, child: Text(l10n.treasuryE2eRiskActorEmpty, style: const TextStyle(fontSize: 12))),
                              ...(((options?['riskActors'] as List?) ?? const [])
                                  .whereType<Map>()
                                  .map((e) => Map<String, dynamic>.from(e))
                                  .map((user) => DropdownMenuItem<String?>(
                                        value: user['user_id']?.toString(),
                                        child: Text('${user['email']} (${user['role'] ?? '-'})', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                                      ))),
                            ],
                            onChanged: (value) => setState(() => _selectedRiskUserId = value),
                            decoration: InputDecoration(labelText: l10n.treasuryE2eRiskActorLabel, isDense: true),
                          ),
                          const SizedBox(height: 8),
                          _textCompactCompact(_traderToken, l10n.treasuryE2eTraderTokenLabel, obscure: true, required: false),
                          const SizedBox(height: 8),
                          if (widget.existing?.riskBearerTokenMasked != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(l10n.treasuryE2eCurrentRiskToken(widget.existing!.riskBearerTokenMasked!), style: theme.textTheme.bodySmall),
                            ),
                          _textCompactCompact(_riskToken, l10n.treasuryE2eRiskTokenLabel, obscure: true, required: false),
                        ],
                        // Validation results
                        if (provider.lastValidation != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(l10n.treasuryE2eValidationPassed, style: const TextStyle(color: Colors.green, fontSize: 12)),
                          ),
                        ],
                        if (provider.lastConnectionTest != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (provider.lastConnectionTest!['ok'] == true ? Colors.green : Colors.red).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              provider.lastConnectionTest!['ok'] == true
                                  ? l10n.treasuryE2eTestConnectionPassed
                                  : l10n.treasuryE2eTestConnectionFailed,
                              style: TextStyle(
                                color: provider.lastConnectionTest!['ok'] == true ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        if (provider.error != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: provider.isSubmitting ? null : _validateDraft,
                                icon: const Icon(Icons.fact_check_outlined, size: 18),
                                label: Text(l10n.treasuryE2eValidateAction, style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: provider.isSubmitting ? null : _testConnection,
                                icon: const Icon(Icons.network_check, size: 18),
                                label: Text(l10n.treasuryE2eTestConnectionAction, style: const TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: provider.isSubmitting ? null : _submit,
                  child: Text(provider.isSubmitting ? l10n.treasuryE2eSaving : l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  String? _resolveRiskActorInitialValue(List<Map<String, dynamic>> traders, Map<String, dynamic>? options) {
    if (_selectedRiskUserId != null) return _selectedRiskUserId;
    if (widget.existing?.riskUserId != null) {
      _selectedRiskUserId = widget.existing!.riskUserId;
      return _selectedRiskUserId;
    }
    final riskActors = ((options?['riskActors'] as List?) ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    if (riskActors.isNotEmpty) {
      _selectedRiskUserId = riskActors.first['user_id']?.toString();
    }
    return _selectedRiskUserId;
  }

  Future<void> _reloadOptions() {
    return context.read<TreasuryE2EConfigProvider>().loadFormOptions(
          environment: _environment,
          chain: _chain,
          traderUserId: _traderUserId,
          traderSearch: _traderSearch.text.trim().isEmpty ? null : _traderSearch.text.trim(),
          force: true,
        );
  }

  Widget _textCompactCompact(TextEditingController controller, String label, {bool obscure = false, bool required = true}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: (value) {
        if (!required) return null;
        if (value == null || value.trim().isEmpty) {
          return '*';
        }
        return null;
      },
    );
  }

  Map<String, dynamic> _payload() => <String, dynamic>{
        'environment': _environment,
        'display_name': _displayName.text.trim(),
        'api_base_url': _apiBaseUrl.text.trim(),
        'chain': _chain,
        'linked_wallet_id': _linkedWalletId,
        'withdraw_amount_auto': _withdrawAuto.text.trim(),
        'withdraw_amount_manual': _withdrawManual.text.trim(),
        'deposit_tx_hash': _depositTxHash.text.trim().isEmpty ? null : _depositTxHash.text.trim(),
        'deposit_amount': _depositAmount.text.trim().isEmpty ? null : _depositAmount.text.trim(),
        'allow_skip': _allowSkip,
        'health_fail_on_critical': _healthFailOnCritical,
        'stale_manual_minutes': int.tryParse(_staleManual.text.trim()) ?? 15,
        'stale_confirming_minutes': int.tryParse(_staleConfirming.text.trim()) ?? 30,
        'failed_withdrawals_24h': int.tryParse(_failed24h.text.trim()) ?? 10,
        'reconcile_pair_limit': int.tryParse(_reconcileLimit.text.trim()) ?? 100,
        'reconciliation_threshold': _reconciliationThreshold.text.trim(),
        'trader_user_id': _traderUserId,
        'risk_user_id': _selectedRiskUserId,
        if (_traderToken.text.trim().isNotEmpty) 'trader_bearer_token': _traderToken.text.trim(),
        if (_riskToken.text.trim().isNotEmpty) 'risk_bearer_token': _riskToken.text.trim(),
      };

  Future<void> _validateDraft() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<TreasuryE2EConfigProvider>().validateDraft(_payload());
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<TreasuryE2EConfigProvider>().testConnection(_payload());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<TreasuryE2EConfigProvider>();
    final success = widget.existing == null
        ? await provider.createConfig(_payload())
        : await provider.updateConfig(widget.existing!.configId, _payload());
    if (!mounted) return;
    if (success) Navigator.pop(context, true);
  }
}
