import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';

import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_config_model.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/providers/market_maker_provider.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/screens/market_maker_screen_mode.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/utils/market_maker_error_localizer.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/widgets/market_maker_action_bar.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/widgets/market_maker_section.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/widgets/pair_selector_card.dart';

/// Configuration screen for Market Maker workflows.
///
/// - [MarketMakerScreenMode.configuration]: spread / limits / save-delete.
/// - [MarketMakerScreenMode.placeOrders]: override + place two-sided orders.
class MarketMakerConfigScreen extends StatefulWidget {
  const MarketMakerConfigScreen({
    super.key,
    this.mode = MarketMakerScreenMode.configuration,
  });

  final MarketMakerScreenMode mode;

  @override
  State<MarketMakerConfigScreen> createState() => _MarketMakerConfigScreenState();
}

class _MarketMakerConfigScreenState extends State<MarketMakerConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPairId;
  bool _isActive = true;

  final _spreadBpsCtrl = TextEditingController(text: '10');
  final _spreadAlertBpsCtrl = TextEditingController(text: '20');
  final _orderAmountCtrl = TextEditingController(text: '0.001');
  final _stopLossPctCtrl = TextEditingController();
  final _maxPositionBaseCtrl = TextEditingController();
  final _orderAmountOverrideCtrl = TextEditingController();
  final _refreshCycleKeyCtrl = TextEditingController();

  bool get _isConfigMode => widget.mode == MarketMakerScreenMode.configuration;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MarketMakerProvider>().loadAll();
      if (!mounted) return;
      final provider = context.read<MarketMakerProvider>();
      if (provider.pairs.isNotEmpty) {
        _onPairChanged(provider.pairs.first.pairId);
      }
    });
  }

  @override
  void dispose() {
    _spreadBpsCtrl.dispose();
    _spreadAlertBpsCtrl.dispose();
    _orderAmountCtrl.dispose();
    _stopLossPctCtrl.dispose();
    _maxPositionBaseCtrl.dispose();
    _orderAmountOverrideCtrl.dispose();
    _refreshCycleKeyCtrl.dispose();
    super.dispose();
  }

  void _onPairChanged(String? pairId) {
    if (pairId == null) return;
    final provider = context.read<MarketMakerProvider>();
    final config = provider.configByPairId(pairId);
    final pairOption = _findPair(provider.pairs, pairId);

    setState(() {
      _selectedPairId = pairId;
      if (config != null) {
        _spreadBpsCtrl.text = config.spreadBps.toString();
        _spreadAlertBpsCtrl.text = config.spreadAlertThresholdBps.toString();
        _orderAmountCtrl.text =
            FormatUtils.normalizeDecimalInput(config.orderAmount);
        _stopLossPctCtrl.text =
            FormatUtils.normalizeDecimalInput(config.stopLossPct ?? '');
        _maxPositionBaseCtrl.text =
            FormatUtils.normalizeDecimalInput(config.maxPositionBase ?? '');
        _isActive = config.isActive;
      } else {
        final d = provider.formDefaults;
        final fallback = d?.orderAmount ?? '0.001';
        _spreadBpsCtrl.text = '${d?.spreadBps ?? 10}';
        _spreadAlertBpsCtrl.text = '${d?.spreadAlertThresholdBps ?? 20}';
        _orderAmountCtrl.text = _ensureMeetsMin(fallback, pairOption?.minOrderAmountValue);
        _stopLossPctCtrl.clear();
        _maxPositionBaseCtrl.clear();
        _isActive = true;
      }
    });
  }

  static MarketMakerPairOption? _findPair(List<MarketMakerPairOption> pairs, String pairId) {
    for (final p in pairs) {
      if (p.pairId == pairId) return p;
    }
    return null;
  }

  static String _ensureMeetsMin(String candidate, double? minValue) {
    if (minValue == null || minValue <= 0) return candidate;
    final n = double.tryParse(candidate.trim());
    if (n == null || !n.isFinite || n < minValue) {
      return FormatUtils.formatCryptoBalance(minValue, 8);
    }
    return candidate;
  }

  String? _minOrderAmountValidator(String? raw, double? minValue, AppLocalizations l10n) {
    if (minValue == null || minValue <= 0) return null;
    final n = double.tryParse((raw ?? '').trim());
    if (n == null || !n.isFinite || n <= 0) {
      return l10n.marketMakerValidationOrderAmount;
    }
    if (n < minValue) {
      return 'Must be ≥ ${_formatMinForDisplay(minValue)}';
    }
    return null;
  }

  static String _formatMinForDisplay(double v) {
    return FormatUtils.formatCryptoBalance(v, 8);
  }

  Future<void> _saveConfig() async {
    if (_selectedPairId == null) return;
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final payload = <String, dynamic>{
      'spread_bps': int.parse(_spreadBpsCtrl.text.trim()),
      'spread_alert_threshold_bps': int.parse(_spreadAlertBpsCtrl.text.trim()),
      'order_amount': _orderAmountCtrl.text.trim(),
      'is_active': _isActive,
      'stop_loss_pct': _stopLossPctCtrl.text.trim().isEmpty
          ? null
          : _stopLossPctCtrl.text.trim(),
      'max_position_base': _maxPositionBaseCtrl.text.trim().isEmpty
          ? null
          : _maxPositionBaseCtrl.text.trim(),
    };

    final provider = context.read<MarketMakerProvider>();
    final ok = await provider.upsertConfig(_selectedPairId!, payload);

    if (!mounted) return;
    final message = ok
        ? l10n.marketMakerSnackSavedConfig
        : localizeMarketMakerError(l10n, provider.errorCode, serverMessage: provider.error);
    showAppSnackBar(
      context,
      message: message,
      type: ok ? SnackBarType.success : SnackBarType.error,
    );
  }

  Future<void> _deleteConfig() async {
    if (_selectedPairId == null) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<MarketMakerProvider>();
    final ok = await provider.deleteConfig(_selectedPairId!);

    if (!mounted) return;
    final message = ok
        ? l10n.marketMakerSnackDeletedConfig
        : localizeMarketMakerError(l10n, provider.errorCode, serverMessage: provider.error);
    showAppSnackBar(
      context,
      message: message,
      type: ok ? SnackBarType.success : SnackBarType.error,
    );
    if (ok) {
      _onPairChanged(_selectedPairId);
    }
  }

  Future<void> _placeMakerOrders() async {
    if (_selectedPairId == null) return;

    final l10n = AppLocalizations.of(context);
    final provider = context.read<MarketMakerProvider>();
    final result = await provider.placeMakerOrders(
      _selectedPairId!,
      orderAmountOverride: _orderAmountOverrideCtrl.text.trim().isEmpty
          ? null
          : _orderAmountOverrideCtrl.text.trim(),
      refreshCycleKey: _refreshCycleKeyCtrl.text.trim().isEmpty
          ? null
          : _refreshCycleKeyCtrl.text.trim(),
    );

    if (!mounted) return;
    if (result == null) {
      showAppSnackBar(
        context,
        message: localizeMarketMakerError(
          l10n,
          provider.errorCode,
          serverMessage: provider.error,
        ),
        type: SnackBarType.error,
      );
      return;
    }

    final placed = (result['placed'] as Map<String, dynamic>?) ?? const {};
    final buyPrice = (placed['buyPrice'] ?? '').toString();
    final sellPrice = (placed['sellPrice'] ?? '').toString();
    final count = (placed['count'] ?? 0).toString();
    final cancelledCount = (result['cancelledCount'] ?? 0).toString();
    final replay = result['idempotentReplay'] == true;

    final action = replay ? l10n.marketMakerOrdersResultReplayed : l10n.marketMakerOrdersResultRefreshed;
    showAppSnackBar(
      context,
      message: l10n.marketMakerOrdersPlacedSummary(
        action,
        cancelledCount,
        count,
        buyPrice,
        sellPrice,
      ),
      type: SnackBarType.success,
    );
  }

  String _appBarTitle(AppLocalizations l10n) {
    switch (widget.mode) {
      case MarketMakerScreenMode.configuration:
        return l10n.marketMakerConfigCardTitle;
      case MarketMakerScreenMode.placeOrders:
        return l10n.marketMakerPlaceOrdersCardTitle;
    }
  }

  String _baseSymbol(List<MarketMakerPairOption> pairs) {
    if (_selectedPairId == null) return '';
    for (final p in pairs) {
      if (p.pairId == _selectedPairId) {
        return CurrencyAmountInput.baseSymbolFromPairDisplay(p.symbol);
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(l10n)),
        actions: [
          Consumer<MarketMakerProvider>(
            builder: (_, p, __) => IconButton(
              onPressed: p.isLoading ? null : () => p.loadAll(),
              icon: p.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: l10n.refresh,
            ),
          ),
        ],
      ),
      body: Consumer<MarketMakerProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading && provider.pairs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.pairs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      localizeMarketMakerError(
                        l10n,
                        provider.errorCode,
                        serverMessage: provider.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => provider.loadAll(),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.pairs.isEmpty) {
            return AppEmptyState(
              message: l10n.marketMakerNoActivePairs,
              icon: Icons.currency_exchange,
            );
          }

          final selectedConfig = _selectedPairId == null
              ? null
              : provider.configByPairId(_selectedPairId!);

          final baseSym = _baseSymbol(provider.pairs);
          final pairOption = _selectedPairId == null
              ? null
              : _findPair(provider.pairs, _selectedPairId!);
          final minValue = pairOption?.minOrderAmountValue;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarketMakerPairSelectorCard(
                    pairs: provider.pairs,
                    selectedPairId: _selectedPairId,
                    onChanged: _onPairChanged,
                  ),
                  if (_isConfigMode && selectedConfig != null) ...[
                    const SizedBox(height: 12),
                    _ConfigStatsBanner(
                      config: selectedConfig,
                      baseSymbol: baseSym,
                    ),
                  ],
                  if (_isConfigMode) ...[
                    const SizedBox(height: 16),
                    _buildTradingParamsSection(context, l10n, baseSym),
                    const SizedBox(height: 16),
                    _buildOrderAmountSection(context, l10n, baseSym, minValue),
                    const SizedBox(height: 16),
                    _buildRiskControlsSection(context, l10n, baseSym),
                    if (selectedConfig != null) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          l10n.marketMakerLastUpdated(
                            DateFormat('dd/MM/yyyy HH:mm').format(selectedConfig.updatedAt.toLocal()),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    MarketMakerActionBar(
                      isSubmitting: provider.isSubmitting,
                      primaryLabel: l10n.marketMakerButtonSaveConfig,
                      primaryIcon: Icons.save,
                      onPrimary: _saveConfig,
                      secondaryLabel: l10n.marketMakerButtonDelete,
                      secondaryIcon: Icons.delete_outline,
                      onSecondary: selectedConfig == null ? null : _deleteConfig,
                      confirmSecondaryTitle: l10n.marketMakerDeleteConfirmTitle,
                      confirmSecondaryMessage: pairOption == null
                          ? null
                          : l10n.marketMakerDeleteConfirmContent(pairOption.symbol),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    _buildPlaceOrdersSection(context, l10n, baseSym, minValue),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.marketMakerPlaceOrdersInfoBanner,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    MarketMakerActionBar(
                      isSubmitting: provider.isSubmitting,
                      primaryLabel: l10n.marketMakerButtonPlaceTwoSidedOrders,
                      primaryIcon: Icons.trending_up,
                      onPrimary: _placeMakerOrders,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTradingParamsSection(BuildContext context, AppLocalizations l10n, String baseSym) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketMakerSectionHeader(title: l10n.marketMakerSectionTradingParams),
        MarketMakerCard(
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _spreadBpsCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.marketMakerFieldSpreadBps,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return l10n.marketMakerValidationSpreadBps;
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _spreadAlertBpsCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.marketMakerFieldSpreadAlertBps,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n < 0) return l10n.marketMakerValidationAlertThreshold;
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderAmountSection(
    BuildContext context,
    AppLocalizations l10n,
    String baseSym,
    double? minValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketMakerSectionHeader(title: l10n.marketMakerSectionOrderAmount),
        MarketMakerCard(
          child: TextFormField(
            controller: _orderAmountCtrl,
            decoration: CurrencyAmountInput.withCurrencySuffix(
              context,
              InputDecoration(
                labelText: minValue != null && minValue > 0
                    ? '${l10n.marketMakerFieldOrderAmount} (≥ ${_formatMinForDisplay(minValue)})'
                    : l10n.marketMakerFieldOrderAmount,
                border: const OutlineInputBorder(),
              ),
              currencySymbol: baseSym,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) {
              final n = double.tryParse((v ?? '').trim());
              if (n == null || n <= 0) {
                return l10n.marketMakerValidationOrderAmount;
              }
              return _minOrderAmountValidator(v, minValue, l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRiskControlsSection(BuildContext context, AppLocalizations l10n, String baseSym) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketMakerSectionHeader(title: l10n.marketMakerSectionRiskControls),
        MarketMakerCard(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.marketMakerFieldActiveConfig),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stopLossPctCtrl,
                decoration: InputDecoration(
                  labelText: l10n.marketMakerFieldStopLossOptional,
                  border: const OutlineInputBorder(),
                  suffixText: '%',
                  suffixStyle: CurrencyAmountInput.suffixStyle(context),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _maxPositionBaseCtrl,
                decoration: CurrencyAmountInput.withCurrencySuffix(
                  context,
                  InputDecoration(
                    labelText: l10n.marketMakerFieldMaxPositionBaseOptional,
                    border: const OutlineInputBorder(),
                  ),
                  currencySymbol: baseSym,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceOrdersSection(
    BuildContext context,
    AppLocalizations l10n,
    String baseSym,
    double? minValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarketMakerSectionHeader(title: l10n.marketMakerSectionOrderParams),
        MarketMakerCard(
          child: Column(
            children: [
              TextFormField(
                controller: _orderAmountOverrideCtrl,
                decoration: CurrencyAmountInput.withCurrencySuffix(
                  context,
                  InputDecoration(
                    labelText: minValue != null && minValue > 0
                        ? '${l10n.marketMakerFieldOrderAmountOverrideOptional} (≥ ${_formatMinForDisplay(minValue)})'
                        : l10n.marketMakerFieldOrderAmountOverrideOptional,
                    border: const OutlineInputBorder(),
                    suffixIcon: Tooltip(
                      message: l10n.marketMakerTooltipOrderAmountOverride,
                      child: const Icon(Icons.info_outline, size: 20),
                    ),
                  ),
                  currencySymbol: baseSym,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final raw = (v ?? '').trim();
                  if (raw.isEmpty) return null;
                  return _minOrderAmountValidator(v, minValue, l10n);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _refreshCycleKeyCtrl,
                decoration: InputDecoration(
                  labelText: l10n.marketMakerFieldRefreshCycleKeyOptional,
                  border: const OutlineInputBorder(),
                  suffixIcon: Tooltip(
                    message: l10n.marketMakerTooltipRefreshCycleKey,
                    child: const Icon(Icons.info_outline, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact banner shown above the form when an existing config is loaded,
/// matching the `_StatsBanner` pattern used by withdrawal management.
class _ConfigStatsBanner extends StatelessWidget {
  const _ConfigStatsBanner({required this.config, required this.baseSymbol});

  final MarketMakerConfigModel config;
  final String baseSymbol;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isActive = config.isActive;
    final statusColor = isActive ? scheme.primary : scheme.outline;
    final statusLabel = isActive ? l10n.marketMakerStatActive : l10n.marketMakerStatInactive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
            size: 18,
            color: scheme.onTertiaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            statusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 16, color: scheme.onTertiaryContainer.withValues(alpha: 0.3)),
          const SizedBox(width: 12),
          Text(
            '${l10n.marketMakerStatSpread}: ${config.spreadBps} ${l10n.marketMakerStatBpsUnit}',
            style: TextStyle(fontSize: 12, color: scheme.onTertiaryContainer),
          ),
          if (baseSymbol.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 16, color: scheme.onTertiaryContainer.withValues(alpha: 0.3)),
            const SizedBox(width: 12),
            Text(
              '${FormatUtils.formatDecimalAmountDisplay(config.orderAmount)} $baseSymbol',
              style: TextStyle(
                fontSize: 12,
                color: scheme.onTertiaryContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
          const Spacer(),
          Icon(Icons.circle, size: 8, color: statusColor),
        ],
      ),
    );
  }
}