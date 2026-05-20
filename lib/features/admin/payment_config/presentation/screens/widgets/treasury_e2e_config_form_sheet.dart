import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/widgets/app_dropdown_field.dart';
import 'package:crypto_trading_app/features/admin/payment_config/data/models/treasury_e2e_config_model.dart';
import 'package:crypto_trading_app/features/admin/payment_config/presentation/providers/treasury_e2e_config_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/constants/treasury_chains.dart';
import 'package:crypto_trading_app/features/treasury/presentation/providers/onchain_chain_picker_provider.dart';
import 'package:crypto_trading_app/features/treasury/presentation/utils/treasury_dropdown_menu_layout.dart';

class TreasuryE2EConfigFormSheet extends StatefulWidget {
  const TreasuryE2EConfigFormSheet({
    super.key,
    this.existing,
    this.onSaved,
  });

  final TreasuryE2EConfigModel? existing;
  final VoidCallback? onSaved;

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
  TreasuryChainEcosystem? _ecosystem;
  String? _network;
  String? _linkedWalletId;
  String? _traderUserId;
  String? _selectedRiskUserId;
  bool _allowSkip = true;
  bool _healthFailOnCritical = false;
  bool _showAdvanced = false;
  bool _showGuide = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _environment = existing?.environment ?? 'development';
    final chainCode = existing?.chain;
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
      final chainPicker = context.read<OnchainChainPickerProvider>();
      await chainPicker.ensureLoaded();
      if (!mounted) return;
      _resolveInitialEcosystemAndNetwork(chainPicker, chainCode);
      if (mounted) {
        await context.read<TreasuryE2EConfigProvider>().loadFormOptions(
              environment: _environment,
              chain: _network ?? _chain ?? 'BSC_CHAPEL',
              force: true,
            );
      }
    });
  }

  String? _chain;

  void _resolveInitialEcosystemAndNetwork(OnchainChainPickerProvider chainPicker, String? chainCode) {
    final chains = chainPicker.treasuryE2eChainsFromApi;
    if (chains.isEmpty) return;
    final code = chainCode ?? 'BSC_CHAPEL';
    _chain = code;
    try {
      _ecosystem = ecosystemForChain(code);
    } catch (_) {
      _ecosystem = treasuryOpsEcosystems(chains).first;
    }
    final nets = treasuryOpsNetworksForEcosystem(_ecosystem!, chains);
    if (nets.contains(code)) {
      _network = code;
    } else if (nets.isNotEmpty) {
      _network = nets.first;
      _chain = _network;
    }
    if (mounted) setState(() {});
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 600;
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

    final chainPicker = context.watch<OnchainChainPickerProvider>();
    final chains = chainPicker.treasuryE2eChainsFromApi;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDialogMode = isWideScreen;
        final effectiveMaxHeight = isDialogMode
            ? constraints.maxHeight
            : screenHeight * 0.85;

        return Container(
          constraints: BoxConstraints(maxHeight: effectiveMaxHeight),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: isDialogMode ? 24 : 16,
                right: isDialogMode ? 24 : 16,
                top: 12,
                bottom: isDialogMode ? 24 : MediaQuery.of(context).viewInsets.bottom + 16,
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
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isDialogMode ? 22 : 18,
                          ),
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
                            // Guide card
                            if (_showGuide) ...[
                              _buildGuideCard(l10n, theme),
                              const SizedBox(height: 12),
                            ],

                            // Chain loading error state
                            if (chains.isEmpty && !_isChainPickerLoading(chainPicker)) ...[
                              _buildChainListUnavailable(l10n, chainPicker),
                              const SizedBox(height: 12),
                            ],

                            if (isDialogMode) ...[
                              // Wide screen: 2 columns with section headers
                              _sectionHeader(l10n.treasuryE2eSectionBasic, theme, Icons.settings),
                              const SizedBox(height: 8),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildEnvironmentDropdown(l10n, theme)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildEcosystemDropdown(l10n, chains, chainPicker)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildNetworkDropdown(l10n, chains, chainPicker)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _textField(_apiBaseUrl, l10n.treasuryE2eApiBaseUrlLabel)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _textField(_displayName, l10n.treasuryE2eDisplayNameLabel),
                              const SizedBox(height: 12),

                              _sectionHeader(l10n.treasuryE2eSectionTrader, theme, Icons.person),
                              const SizedBox(height: 8),
                              _buildTraderSearchRow(l10n),
                              const SizedBox(height: 12),
                              _buildTraderDropdown(l10n, traders),
                              const SizedBox(height: 12),
                              _buildLinkedWalletDropdown(l10n, linkedWallets),
                              const SizedBox(height: 12),

                              _sectionHeader(l10n.treasuryE2eSectionWithdrawal, theme, Icons.currency_exchange),
                              const SizedBox(height: 8),
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _textField(_withdrawAuto, l10n.treasuryE2eWithdrawAutoLabel)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _textField(_withdrawManual, l10n.treasuryE2eWithdrawManualLabel)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              _sectionHeader(l10n.treasuryE2eSectionOptions, theme, Icons.toggle_on),
                              const SizedBox(height: 8),
                              _buildSwitchRow(l10n),
                              const SizedBox(height: 12),
                              _buildAdvancedToggle(l10n, theme),
                              if (_showAdvanced) ...[
                                const SizedBox(height: 12),
                                _buildAdvancedSection(l10n, traders, options, theme),
                              ],
                            ] else ...[
                              // Narrow screen: stacked layout
                              _sectionHeader(l10n.treasuryE2eSectionBasic, theme, Icons.settings),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _buildEnvironmentDropdown(l10n, theme)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildEcosystemDropdown(l10n, chains, chainPicker)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _buildNetworkDropdown(l10n, chains, chainPicker)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _textFieldCompact(_apiBaseUrl, l10n.treasuryE2eApiBaseUrlLabel)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _textFieldCompact(_displayName, l10n.treasuryE2eDisplayNameLabel),
                              const SizedBox(height: 12),

                              _sectionHeader(l10n.treasuryE2eSectionTrader, theme, Icons.person),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _textFieldCompact(_traderSearch, l10n.treasuryE2eTraderSearchLabel, required: false)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: _reloadOptions,
                                    icon: const Icon(Icons.search),
                                    tooltip: l10n.treasuryE2eLoadTraderAction,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildTraderDropdownNarrow(l10n, traders),
                              const SizedBox(height: 8),
                              _buildLinkedWalletDropdownNarrow(l10n, linkedWallets),
                              const SizedBox(height: 12),

                              _sectionHeader(l10n.treasuryE2eSectionWithdrawal, theme, Icons.currency_exchange),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _textFieldCompact(_withdrawAuto, l10n.treasuryE2eWithdrawAutoLabel)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _textFieldCompact(_withdrawManual, l10n.treasuryE2eWithdrawManualLabel)),
                                ],
                              ),
                              const SizedBox(height: 12),

                              _sectionHeader(l10n.treasuryE2eSectionOptions, theme, Icons.toggle_on),
                              const SizedBox(height: 8),
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
                              _buildAdvancedToggle(l10n, theme),
                              if (_showAdvanced) ...[
                                const SizedBox(height: 8),
                                _buildAdvancedSectionNarrow(l10n, traders, options, theme),
                              ],
                            ],

                            // Status feedback
                            if (provider.lastValidation != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Text(l10n.treasuryE2eValidationPassed, style: const TextStyle(color: Colors.green, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                            if (provider.lastConnectionTest != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (provider.lastConnectionTest!['ok'] == true ? Colors.green : Colors.red).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      provider.lastConnectionTest!['ok'] == true ? Icons.check_circle : Icons.error,
                                      color: provider.lastConnectionTest!['ok'] == true ? Colors.green : Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      provider.lastConnectionTest!['ok'] == true
                                          ? l10n.treasuryE2eTestConnectionPassed
                                          : l10n.treasuryE2eTestConnectionFailed,
                                      style: TextStyle(
                                        color: provider.lastConnectionTest!['ok'] == true ? Colors.green : Colors.red,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (provider.error != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(provider.error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            // Action buttons
                            if (isDialogMode) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: provider.isSubmitting ? null : _validateDraft,
                                      icon: const Icon(Icons.fact_check_outlined, size: 18),
                                      label: Text(l10n.treasuryE2eValidateAction),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: provider.isSubmitting ? null : _testConnection,
                                      icon: const Icon(Icons.network_check, size: 18),
                                      label: Text(l10n.treasuryE2eTestConnectionAction),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(l10n.cancel),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: FilledButton(
                                      onPressed: provider.isSubmitting ? null : _submit,
                                      child: provider.isSubmitting
                                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : Text(provider.isSubmitting ? l10n.treasuryE2eSaving : l10n.save),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
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
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!isDialogMode) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: provider.isSubmitting ? null : _submit,
                        child: Text(provider.isSubmitting ? l10n.treasuryE2eSaving : l10n.save),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isChainPickerLoading(OnchainChainPickerProvider chainPicker) {
    return chainPicker.rawOptions == null && _showGuide;
  }

  Widget _buildChainListUnavailable(AppLocalizations l10n, OnchainChainPickerProvider chainPicker) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(l10n.treasuryE2eNoChainList, style: const TextStyle(fontSize: 13))),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              await chainPicker.ensureLoaded(force: true);
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  String? _resolveRiskActorInitialValue(List<Map<String, dynamic>> traders, Map<String, dynamic>? options) {
    if (_selectedRiskUserId != null) return _selectedRiskUserId;
    if (widget.existing?.riskUserId != null) {
      _selectedRiskUserId = widget.existing!.riskUserId;
      return _selectedRiskUserId;
    }
    final riskActors = ((options?['riskActors'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    if (riskActors.isNotEmpty) {
      _selectedRiskUserId = riskActors.first['user_id']?.toString();
    }
    return _selectedRiskUserId;
  }

  Future<void> _reloadOptions() {
    return context.read<TreasuryE2EConfigProvider>().loadFormOptions(
          environment: _environment,
          chain: _network ?? _chain ?? 'BSC_CHAPEL',
          traderUserId: _traderUserId,
          traderSearch: _traderSearch.text.trim().isEmpty ? null : _traderSearch.text.trim(),
          force: true,
        );
  }

  Widget _sectionHeader(String title, ThemeData theme, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildGuideCard(AppLocalizations l10n, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 12, right: 6),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.treasuryE2eGuideTitle,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _showGuide = false),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              l10n.treasuryE2eGuideWhatIs,
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          _buildGuideStep(Icons.check_circle_outline, l10n.treasuryE2eGuideStep1Title, l10n.treasuryE2eGuideStep1Desc),
          _buildGuideStep(Icons.account_balance_wallet_outlined, l10n.treasuryE2eGuideStep2Title, l10n.treasuryE2eGuideStep2Desc),
          _buildGuideStep(Icons.play_circle_outline, l10n.treasuryE2eGuideStep3Title, l10n.treasuryE2eGuideStep3Desc),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.security, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    l10n.treasuryE2eGuideNote,
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label, {bool obscure = false, bool required = true}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      validator: (value) {
        if (!required) return null;
        if (value == null || value.trim().isEmpty) return '*';
        return null;
      },
    );
  }

  Widget _textFieldCompact(TextEditingController controller, String label, {bool obscure = false, bool required = true}) {
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
        if (value == null || value.trim().isEmpty) return '*';
        return null;
      },
    );
  }

  Widget _buildEnvironmentDropdown(AppLocalizations l10n, ThemeData theme) {
    return AppDropdownField<String>(
      value: _environment,
      labelText: l10n.treasuryE2eEnvironmentLabel,
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
      items: ['development', 'staging', 'test', 'production']
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          _environment = value;
          _linkedWalletId = null;
        });
        _reloadOptions();
      },
    );
  }

  Widget _buildEcosystemDropdown(AppLocalizations l10n, List<String> chains, OnchainChainPickerProvider chainPicker) {
    final ecosystems = treasuryOpsEcosystems(chains);
    if (ecosystems.isEmpty) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: l10n.treasuryE2eChainLabel,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintText: l10n.treasuryE2eNoChainList,
        ),
      );
    }
    final effectiveEco = (_ecosystem != null && ecosystems.contains(_ecosystem!))
        ? _ecosystem!
        : ecosystems.first;
    if (_ecosystem == null || !ecosystems.contains(_ecosystem!)) {
      _ecosystem = effectiveEco;
    }
    return AppDropdownField<TreasuryChainEcosystem>(
      value: effectiveEco,
      labelText: l10n.treasuryE2eChainLabel,
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
      items: ecosystems
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(treasuryEcosystemLabel(l10n, e)),
              ))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() {
          _ecosystem = v;
          final nets = treasuryOpsNetworksForEcosystem(v, chains);
          _network = nets.isNotEmpty ? nets.first : null;
          _chain = _network;
          _linkedWalletId = null;
        });
        _reloadOptions();
      },
    );
  }

  Widget _buildNetworkDropdown(AppLocalizations l10n, List<String> chains, OnchainChainPickerProvider chainPicker) {
    if (chains.isEmpty || _ecosystem == null) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Network',
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintText: l10n.treasuryE2eNoChainList,
        ),
      );
    }
    final nets = treasuryOpsNetworksForEcosystem(_ecosystem!, chains);
    if (nets.isEmpty) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: 'Network',
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          hintText: l10n.treasuryE2eNoChainList,
        ),
      );
    }
    final effectiveNet = (_network != null && nets.contains(_network!))
        ? _network!
        : nets.first;
    if (_network == null || !nets.contains(_network!)) {
      _network = effectiveNet;
      _chain = _network;
    }
    return AppDropdownField<String>(
      value: effectiveNet,
      labelText: 'Network',
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
      items: nets
          .map((code) => DropdownMenuItem(
                value: code,
                child: Text(
                  treasuryChainDisplayLabel(
                    l10n,
                    code,
                    apiLabelResolver: chainPicker.displayLabelForCode,
                  ),
                ),
              ))
          .toList(),
      onChanged: nets.isEmpty
          ? null
          : (v) {
              if (v == null) return;
              setState(() {
                _network = v;
                _chain = v;
                _linkedWalletId = null;
              });
              _reloadOptions();
            },
    );
  }

  Widget _buildTraderSearchRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: _textField(_traderSearch, l10n.treasuryE2eTraderSearchLabel, required: false)),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _reloadOptions,
          icon: const Icon(Icons.search),
          tooltip: l10n.treasuryE2eLoadTraderAction,
        ),
      ],
    );
  }

  Widget _buildTraderDropdown(AppLocalizations l10n, List<Map<String, dynamic>> traders) {
    return AppDropdownField<String?>(
      value: _traderUserId,
      labelText: l10n.treasuryE2eTraderSelectLabel,
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(l10n.treasuryE2eTraderEmpty)),
        ...traders.map((user) => DropdownMenuItem<String?>(
              value: user['user_id']?.toString(),
              child: Text(
                '${user['email']} (${user['first_name'] ?? ''})',
                overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildTraderDropdownNarrow(AppLocalizations l10n, List<Map<String, dynamic>> traders) {
    return AppDropdownField<String?>(
      value: _traderUserId,
      labelText: l10n.treasuryE2eTraderSelectLabel,
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
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
    );
  }

  Widget _buildLinkedWalletDropdown(AppLocalizations l10n, List<Map<String, dynamic>> linkedWallets) {
    return AppDropdownField<String?>(
      value: linkedWallets.any((e) => e['link_id'] == _linkedWalletId) ? _linkedWalletId : null,
      labelText: l10n.treasuryE2eLinkedWalletLabel,
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
      items: [
        DropdownMenuItem<String?>(value: null, child: Text(l10n.treasuryE2eLinkedWalletEmpty)),
        ...linkedWallets.map((wallet) {
          final label = wallet['label']?.toString();
          final address = wallet['address']?.toString() ?? '-';
          return DropdownMenuItem<String?>(
            value: wallet['link_id']?.toString(),
            child: Text(
              '${label?.isNotEmpty == true ? label : address.substring(0, 8)}...',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }),
      ],
      onChanged: (value) => setState(() => _linkedWalletId = value),
    );
  }

  Widget _buildLinkedWalletDropdownNarrow(AppLocalizations l10n, List<Map<String, dynamic>> linkedWallets) {
    return AppDropdownField<String?>(
      value: linkedWallets.any((e) => e['link_id'] == _linkedWalletId) ? _linkedWalletId : null,
      labelText: l10n.treasuryE2eLinkedWalletLabel,
      menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
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
    );
  }

  Widget _buildSwitchRow(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(l10n.treasuryE2eAllowSkipLabel, style: const TextStyle(fontSize: 14)),
            value: _allowSkip,
            onChanged: (value) => setState(() => _allowSkip = value),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(l10n.treasuryE2eFailOnCriticalLabel, style: const TextStyle(fontSize: 14)),
            value: _healthFailOnCritical,
            onChanged: (value) => setState(() => _healthFailOnCritical = value),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedToggle(AppLocalizations l10n, ThemeData theme) {
    return InkWell(
      onTap: () => setState(() => _showAdvanced = !_showAdvanced),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more, size: 20),
            const SizedBox(width: 8),
            Text(l10n.treasuryE2eLegacyTokenSection, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(
    AppLocalizations l10n,
    List<Map<String, dynamic>> traders,
    Map<String, dynamic>? options,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _textField(_staleManual, l10n.treasuryE2eStaleManualLabel)),
              const SizedBox(width: 16),
              Expanded(child: _textField(_staleConfirming, l10n.treasuryE2eStaleConfirmingLabel)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _textField(_failed24h, l10n.treasuryE2eFailed24hLabel)),
              const SizedBox(width: 16),
              Expanded(child: _textField(_reconcileLimit, l10n.treasuryE2eReconcileLimitLabel)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _textField(_reconciliationThreshold, l10n.treasuryE2eReconciliationThresholdLabel),
        const SizedBox(height: 12),
        if (widget.existing?.traderBearerTokenMasked != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.treasuryE2eCurrentTraderToken(widget.existing!.traderBearerTokenMasked!),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        Text(l10n.treasuryE2eIdentityPreferredHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 12),
        AppDropdownField<String?>(
          value: _resolveRiskActorInitialValue(traders, options),
          labelText: l10n.treasuryE2eRiskActorLabel,
          menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(l10n.treasuryE2eRiskActorEmpty)),
            ...(((options?['riskActors'] as List?) ?? const [])
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .map((user) => DropdownMenuItem<String?>(
                      value: user['user_id']?.toString(),
                      child: Text('${user['email']} (${user['role'] ?? '-'})', overflow: TextOverflow.ellipsis),
                    ))),
          ],
          onChanged: (value) => setState(() => _selectedRiskUserId = value),
        ),
        const SizedBox(height: 12),
        _textField(_traderToken, l10n.treasuryE2eTraderTokenLabel, obscure: true, required: false),
        const SizedBox(height: 12),
        if (widget.existing?.riskBearerTokenMasked != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.treasuryE2eCurrentRiskToken(widget.existing!.riskBearerTokenMasked!),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        _textField(_riskToken, l10n.treasuryE2eRiskTokenLabel, obscure: true, required: false),
      ],
    );
  }

  Widget _buildAdvancedSectionNarrow(
    AppLocalizations l10n,
    List<Map<String, dynamic>> traders,
    Map<String, dynamic>? options,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _textFieldCompact(_staleManual, l10n.treasuryE2eStaleManualLabel)),
            const SizedBox(width: 8),
            Expanded(child: _textFieldCompact(_staleConfirming, l10n.treasuryE2eStaleConfirmingLabel)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _textFieldCompact(_failed24h, l10n.treasuryE2eFailed24hLabel)),
            const SizedBox(width: 8),
            Expanded(child: _textFieldCompact(_reconcileLimit, l10n.treasuryE2eReconcileLimitLabel)),
          ],
        ),
        const SizedBox(height: 8),
        _textFieldCompact(_reconciliationThreshold, l10n.treasuryE2eReconciliationThresholdLabel),
        const SizedBox(height: 8),
        if (widget.existing?.traderBearerTokenMasked != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(l10n.treasuryE2eCurrentTraderToken(widget.existing!.traderBearerTokenMasked!), style: theme.textTheme.bodySmall),
          ),
        Text(l10n.treasuryE2eIdentityPreferredHint, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        AppDropdownField<String?>(
          value: _resolveRiskActorInitialValue(traders, options),
          labelText: l10n.treasuryE2eRiskActorLabel,
          menuMaxHeight: kTreasurySheetDropdownMenuMaxHeight,
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
        ),
        const SizedBox(height: 8),
        _textFieldCompact(_traderToken, l10n.treasuryE2eTraderTokenLabel, obscure: true, required: false),
        const SizedBox(height: 8),
        if (widget.existing?.riskBearerTokenMasked != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(l10n.treasuryE2eCurrentRiskToken(widget.existing!.riskBearerTokenMasked!), style: theme.textTheme.bodySmall),
          ),
        _textFieldCompact(_riskToken, l10n.treasuryE2eRiskTokenLabel, obscure: true, required: false),
      ],
    );
  }

  Map<String, dynamic> _payload() => <String, dynamic>{
        'environment': _environment,
        'display_name': _displayName.text.trim(),
        'api_base_url': _apiBaseUrl.text.trim(),
        'chain': _network ?? _chain ?? 'BSC_CHAPEL',
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
    if (success) {
      widget.onSaved?.call();
      if (mounted) Navigator.pop(context, true);
    }
  }
}
