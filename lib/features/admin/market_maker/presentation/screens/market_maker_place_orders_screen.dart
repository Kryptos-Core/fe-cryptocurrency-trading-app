import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/api_error_localizer.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/snackbar_helper.dart';
import 'package:crypto_trading_app/core/widgets/app_empty_state.dart';

import 'package:crypto_trading_app/features/admin/market_maker/data/models/market_maker_config_model.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/providers/market_maker_provider.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/widgets/market_maker_action_bar.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/widgets/market_maker_section.dart';
import 'package:crypto_trading_app/features/admin/market_maker/presentation/widgets/pair_selector_card.dart';

/// Dedicated screen for placing two-sided maker orders.
///
/// All configuration (spread, order amount, etc.) lives in the saved MM
/// configuration; this screen only exposes optional overrides (order amount
/// override + idempotency refresh cycle key).
class MarketMakerPlaceOrdersScreen extends StatefulWidget {
  const MarketMakerPlaceOrdersScreen({super.key});

  @override
  State<MarketMakerPlaceOrdersScreen> createState() =>
      _MarketMakerPlaceOrdersScreenState();
}

class _MarketMakerPlaceOrdersScreenState
    extends State<MarketMakerPlaceOrdersScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedPairId;
  final _orderAmountOverrideCtrl = TextEditingController();
  final _refreshCycleKeyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MarketMakerProvider>().loadAll();
      if (!mounted) return;
      final provider = context.read<MarketMakerProvider>();
      if (provider.pairs.isNotEmpty) {
        setState(() {
          _selectedPairId = provider.pairs.first.pairId;
        });
      }
    });
  }

  @override
  void dispose() {
    _orderAmountOverrideCtrl.dispose();
    _refreshCycleKeyCtrl.dispose();
    super.dispose();
  }

  static MarketMakerPairOption? _findPair(
    List<MarketMakerPairOption> pairs,
    String pairId,
  ) {
    for (final p in pairs) {
      if (p.pairId == pairId) return p;
    }
    return null;
  }

  static String _formatMinForDisplay(double v) {
    return FormatUtils.formatCryptoBalance(v, 8);
  }

  String? _validateOrderOverride(String? raw, double? minValue, AppLocalizations l10n) {
    if (minValue == null || minValue <= 0) return null;
    final trimmed = (raw ?? '').trim();
    if (trimmed.isEmpty) return null;
    final n = double.tryParse(trimmed);
    if (n == null || !n.isFinite || n <= 0) {
      return l10n.marketMakerValidationOrderAmount;
    }
    if (n < minValue) {
      return l10n.marketMakerValidationMustBeAtLeast(
          _formatMinForDisplay(minValue));
    }
    return null;
  }

  Future<void> _placeMakerOrders() async {
    if (_selectedPairId == null) return;
    if (!_formKey.currentState!.validate()) return;

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
message: localizeApiError(
        l10n,
        code: provider.apiErrorCode,
        message: provider.error,
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

    final action =
        replay ? l10n.marketMakerOrdersResultReplayed : l10n.marketMakerOrdersResultRefreshed;
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
        title: Text(l10n.marketMakerPlaceOrdersCardTitle),
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
                    localizeApiError(
                      l10n,
                      code: provider.apiErrorCode,
                      message: provider.error,
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

          final pairOption = _selectedPairId == null
              ? null
              : _findPair(provider.pairs, _selectedPairId!);
          final minValue = pairOption?.minOrderAmountValue;
          final baseSym = _baseSymbol(provider.pairs);

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
                    onChanged: (v) => setState(() => _selectedPairId = v),
                  ),
                  const SizedBox(height: 16),
                  MarketMakerSectionHeader(
                    title: l10n.marketMakerSectionOrderParams,
                    subtitle: l10n.marketMakerPlaceOrdersInfoBanner,
                  ),
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
                          validator: (v) => _validateOrderOverride(v, minValue, l10n),
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
              ),
            ),
          );
        },
      ),
    );
  }
}