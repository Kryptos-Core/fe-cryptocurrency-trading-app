import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/providers/market_maker_provider.dart';

/// Which Market Maker workflow this screen focuses on (separate hub entries).
enum MarketMakerScreenMode {
  /// Spread, limits, save / delete only.
  configuration,

  /// Pair selection + optional overrides + place two-sided maker orders.
  placeOrders,
}

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

    setState(() {
      _selectedPairId = pairId;
      if (config != null) {
        _spreadBpsCtrl.text = config.spreadBps.toString();
        _spreadAlertBpsCtrl.text = config.spreadAlertThresholdBps.toString();
        _orderAmountCtrl.text = config.orderAmount;
        _stopLossPctCtrl.text = config.stopLossPct ?? '';
        _maxPositionBaseCtrl.text = config.maxPositionBase ?? '';
        _isActive = config.isActive;
      } else {
        final d = provider.formDefaults;
        _spreadBpsCtrl.text = '${d?.spreadBps ?? 10}';
        _spreadAlertBpsCtrl.text = '${d?.spreadAlertThresholdBps ?? 20}';
        _orderAmountCtrl.text = d?.orderAmount ?? '0.001';
        _stopLossPctCtrl.clear();
        _maxPositionBaseCtrl.clear();
        _isActive = true;
      }
    });
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.marketMakerSnackSavedConfig : (provider.error ?? l10n.marketMakerSnackSaveFailed),
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _deleteConfig() async {
    if (_selectedPairId == null) return;
    final l10n = AppLocalizations.of(context);
    final provider = context.read<MarketMakerProvider>();
    final ok = await provider.deleteConfig(_selectedPairId!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.marketMakerSnackDeletedConfig : (provider.error ?? l10n.marketMakerSnackDeleteFailed),
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? l10n.marketMakerSnackPlaceOrdersFailed),
          backgroundColor: Colors.red,
        ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.marketMakerOrdersPlacedSummary(
            action,
            cancelledCount,
            count,
            buyPrice,
            sellPrice,
          ),
        ),
        backgroundColor: Colors.green,
      ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(l10n)),
        actions: [
          IconButton(
            onPressed: () => context.read<MarketMakerProvider>().loadAll(),
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
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
                child: Text(provider.error!, textAlign: TextAlign.center),
              ),
            );
          }

          if (provider.pairs.isEmpty) {
            return Center(child: Text(l10n.marketMakerNoActivePairs));
          }

          final selectedConfig = _selectedPairId == null
              ? null
              : provider.configByPairId(_selectedPairId!);

          String pairBaseSymbol() {
            if (_selectedPairId == null) return '';
            for (final p in provider.pairs) {
              if (p.pairId == _selectedPairId) {
                return CurrencyAmountInput.baseSymbolFromPairDisplay(p.symbol);
              }
            }
            return '';
          }

          final baseSym = pairBaseSymbol();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey<String?>(_selectedPairId),
                    initialValue: _selectedPairId,
                    decoration: InputDecoration(
                      labelText: l10n.marketMakerFieldPair,
                      border: const OutlineInputBorder(),
                    ),
                    items: provider.pairs
                        .map(
                          (pair) => DropdownMenuItem<String>(
                            value: pair.pairId,
                            child: Text(pair.symbol),
                          ),
                        )
                        .toList(),
                    onChanged: _onPairChanged,
                  ),
                  if (!_isConfigMode) ...[
                    const SizedBox(height: 16),
                    Text(
                      l10n.marketMakerPlaceOrdersFormHint,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                  if (_isConfigMode) ...[
                    const SizedBox(height: 16),
                    TextFormField(
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
                    const SizedBox(height: 12),
                    TextFormField(
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _orderAmountCtrl,
                      decoration: CurrencyAmountInput.withCurrencySuffix(
                        context,
                        InputDecoration(
                          labelText: l10n.marketMakerFieldOrderAmount,
                          border: const OutlineInputBorder(),
                        ),
                        currencySymbol: baseSym,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final n = double.tryParse((v ?? '').trim());
                        if (n == null || n <= 0) return l10n.marketMakerValidationOrderAmount;
                        return null;
                      },
                    ),
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
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.marketMakerFieldActiveConfig),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    if (selectedConfig != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          l10n.marketMakerLastUpdated(
                            DateFormat('dd/MM/yyyy HH:mm').format(selectedConfig.updatedAt.toLocal()),
                          ),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: provider.isSubmitting ? null : _saveConfig,
                            icon: const Icon(Icons.save),
                            label: Text(l10n.marketMakerButtonSaveConfig),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: provider.isSubmitting ? null : _deleteConfig,
                            icon: const Icon(Icons.delete_outline),
                            label: Text(l10n.marketMakerButtonDelete),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!_isConfigMode) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orderAmountOverrideCtrl,
                      decoration: CurrencyAmountInput.withCurrencySuffix(
                        context,
                        InputDecoration(
                          labelText: l10n.marketMakerFieldOrderAmountOverrideOptional,
                          border: const OutlineInputBorder(),
                        ),
                        currencySymbol: baseSym,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _refreshCycleKeyCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.marketMakerFieldRefreshCycleKeyOptional,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isSubmitting ? null : _placeMakerOrders,
                        icon: const Icon(Icons.trending_up),
                        label: Text(l10n.marketMakerButtonPlaceTwoSidedOrders),
                      ),
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
}
