import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/providers/orders_provider.dart';

// --- Format số hiển thị (best practice: dấu phân cách hàng nghìn, bỏ số 0 thừa) ---

/// Giá: dấu phẩy nghìn, 2–6 chữ số thập phân theo magnitude, bỏ 0 thừa.
String _formatPriceDisplay(String raw) {
  final v = double.tryParse(raw.replaceAll(',', '').trim());
  if (v == null) return raw;
  if (v == 0) return '0';
  int decimals;
  if (v >= 10000) {
    decimals = 2;
  } else if (v >= 1) {
    decimals = 2;
  } else if (v >= 0.01) {
    decimals = 4;
  } else {
    decimals = 6;
  }
  final pattern = '#,##0.${'#' * decimals}';
  var s = NumberFormat(pattern).format(v);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// Volume: K/M khi lớn, dấu phẩy nghìn, tối đa 2 số lẻ.
String _formatVolumeDisplay(String raw) {
  final v = double.tryParse(raw.replaceAll(',', '').trim());
  if (v == null) return raw;
  if (v == 0) return '0';
  if (v >= 1e6) return '${NumberFormat('#,##0.##').format(v / 1e6)}M';
  if (v >= 1e3) return '${NumberFormat('#,##0.##').format(v / 1e3)}K';
  return NumberFormat('#,##0.##').format(v);
}

/// Số dư / số lượng: dấu phẩy nghìn, tối đa 8 chữ số thập phân, bỏ 0 thừa.
String _formatAmountDisplay(String raw) {
  final v = double.tryParse(raw.replaceAll(',', '').trim());
  if (v == null) return raw;
  if (v == 0) return '0';
  var s = NumberFormat('#,##0.########').format(v);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// Khối lượng tối thiểu: bỏ số 0 thừa, dễ đọc.
String _formatMinAmountDisplay(String raw) {
  final v = double.tryParse(raw.replaceAll(',', '').trim());
  if (v == null) return raw;
  if (v == 0) return '0';
  var s = NumberFormat('#,##0.########').format(v);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s;
}

/// Tổng tiền (quote): 2 số thập phân, dấu phẩy nghìn.
String _formatTotalDisplay(double value) {
  return NumberFormat('#,##0.00').format(value);
}

double? _parseDecimalInput(String raw) {
  final sanitized = raw.replaceAll(',', '').trim();
  if (sanitized.isEmpty) return null;
  return double.tryParse(sanitized);
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) return value;
  return value.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

String _truncateToScale(String raw, int scale) {
  final sanitized = raw.replaceAll(',', '').trim();
  if (sanitized.isEmpty) return '';

  final isNegative = sanitized.startsWith('-');
  final unsigned = isNegative ? sanitized.substring(1) : sanitized;
  final parts = unsigned.split('.');
  final integerPart = parts.first.isEmpty ? '0' : parts.first;

  if (parts.length == 1 || scale <= 0) {
    return isNegative ? '-$integerPart' : integerPart;
  }

  final decimalPart = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
  final kept = decimalPart.substring(0, min(scale, decimalPart.length));
  final combined = kept.isEmpty ? integerPart : '$integerPart.$kept';
  return _trimTrailingZeros(isNegative ? '-$combined' : combined);
}

int _countDecimals(String raw) {
  final sanitized = raw.replaceAll(',', '').trim();
  if (!sanitized.contains('.')) return 0;
  return sanitized.split('.')[1].length;
}

/// Màn hình Orders: Danh sách lệnh của user + Order book (theo pair).
///
/// Sử dụng OrdersProvider (CreateOrder, CancelOrder, GetOrderBook, GetMyOrders).
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

/* Style constants for orders screen (Material 3, indigo) */
const _kCardElevation = 2.0;
const _kCardRadius = 12.0;
const _kInputRadius = 10.0;
const _kSectionPadding = 16.0;
const _kSectionSpacing = 20.0;

class _OrdersScreenState extends State<OrdersScreen> {
  final _priceController = TextEditingController();
  final _amountController = TextEditingController();
  String _side = 'BUY';
  String _orderType = 'LIMIT';
  MarketPair? _selectedMarket;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().fetchMyOrders(refresh: true);
      context.read<MarketsProvider>().fetchActiveMarkets();
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrdersProvider>().fetchMyOrders(refresh: true);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<OrdersProvider>().fetchMyOrders(refresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(_kSectionPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPlaceOrderSection(context),
              const SizedBox(height: _kSectionSpacing),
              _buildOrderBookSection(context),
              if (_selectedMarket != null) ...[
                const SizedBox(height: _kSectionSpacing),
                _buildRecentTradesSection(context),
              ],
              const SizedBox(height: _kSectionSpacing),
              _buildMyOrdersSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceOrderSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersProvider = context.watch<OrdersProvider>();
    final marketsProvider = context.watch<MarketsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final markets = marketsProvider.markets;

    final inputDecoration = InputDecoration(
      labelText: l10n.tradingPair,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_kInputRadius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kInputRadius),
        borderSide:
            BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_kInputRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Card(
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(_kSectionPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.placeOrder,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MarketPair>(
              initialValue: _selectedMarket,
              decoration: inputDecoration.copyWith(labelText: l10n.tradingPair),
              hint: Text(markets.isEmpty ? l10n.loading : l10n.tradingPair),
              items: markets
                  .map((m) => DropdownMenuItem<MarketPair>(
                        value: m,
                        child: Text(_formatSymbol(m.symbol),
                            style: theme.textTheme.bodyLarge),
                      ))
                  .toList(),
              onChanged: markets.isEmpty
                  ? null
                  : (MarketPair? v) {
                      setState(() => _selectedMarket = v);
                      if (v != null) {
                        marketsProvider.fetchTicker(v.pairId);
                        marketsProvider.fetchOrderBook(v.pairId, limit: 20);
                        marketsProvider.fetchTrades(v.pairId, limit: 20);
                        ordersProvider.fetchBaseQuoteBalances(
                            v.baseCurrencyId, v.quoteCurrencyId);
                        ordersProvider.fetchOrderBook(v.pairId, limit: 20);
                      } else {
                        ordersProvider.clearPairBalances();
                      }
                    },
            ),
            if (_selectedMarket != null) ...[
              const SizedBox(height: 14),
              _buildTickerBlock(context),
              const SizedBox(height: 14),
              _buildBalanceBlock(context),
              const SizedBox(height: 14),
            ],
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'BUY',
                  label: Text(l10n.buy),
                  icon: Icon(Icons.arrow_upward,
                      size: 18,
                      color: _side == 'BUY'
                          ? colorScheme.onPrimary
                          : Colors.green.shade700),
                ),
                ButtonSegment(
                  value: 'SELL',
                  label: Text(l10n.sell),
                  icon: Icon(Icons.arrow_downward,
                      size: 18,
                      color: _side == 'SELL'
                          ? colorScheme.onPrimary
                          : Colors.red.shade700),
                ),
              ],
              selected: {_side},
              onSelectionChanged: (Set<String> s) =>
                  setState(() => _side = s.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.comfortable,
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12)),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.primary;
                  }
                  return colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5);
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return colorScheme.onPrimary;
                  }
                  return colorScheme.onSurface;
                }),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('${l10n.orderType}: ',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurface)),
                const SizedBox(width: 8),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                          value: 'LIMIT', label: Text(l10n.limitOrder)),
                      ButtonSegment(
                          value: 'MARKET', label: Text(l10n.marketOrder)),
                    ],
                    selected: {_orderType},
                    onSelectionChanged: (Set<String> s) =>
                        setState(() => _orderType = s.first),
                    style: ButtonStyle(
                      visualDensity: VisualDensity.comfortable,
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 10)),
                      backgroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return colorScheme.primary;
                        }
                        return colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5);
                      }),
                      foregroundColor:
                          WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return colorScheme.onPrimary;
                        }
                        return colorScheme.onSurface;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            if (_orderType == 'LIMIT') ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        labelText: l10n.price,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_kInputRadius)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_kInputRadius),
                          borderSide: BorderSide(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(_kInputRadius),
                          borderSide: BorderSide(
                              color: colorScheme.primary, width: 1.5),
                        ),
                        hintText: marketsProvider.ticker != null
                            ? marketsProvider.ticker!.lastPrice
                            : 'e.g. 50000.00',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (marketsProvider.ticker != null)
                    FilledButton.tonalIcon(
                      onPressed: () => _priceController.text =
                          marketsProvider.ticker!.lastPrice,
                      icon: const Icon(Icons.touch_app, size: 18),
                      label: Text(l10n.lastPrice),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: l10n.amount,
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_kInputRadius)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kInputRadius),
                  borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(_kInputRadius),
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                hintText: 'e.g. 0.01',
                suffixIcon: (_side == 'SELL' && _selectedMarket != null)
                    ? TextButton(
                        onPressed: () {
                          final available =
                              ordersProvider.baseBalance?.available ?? '';
                          if (available.isEmpty) return;

                          final amountScale = _selectedMarket!.amountScale;
                          final maxSell =
                              _truncateToScale(available, amountScale);
                          if (maxSell.isEmpty) return;

                          _amountController.text = maxSell;
                          _amountController.selection = TextSelection.collapsed(
                            offset: _amountController.text.length,
                          );
                        },
                        child: const Text('MAX'),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            if (_selectedMarket != null) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.minOrderAmount}: ${_formatMinAmountDisplay(_selectedMarket!.minOrderAmount)} ${_baseSymbol(_selectedMarket!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(height: 10),
              ListenableBuilder(
                listenable:
                    Listenable.merge([_priceController, _amountController]),
                builder: (context, _) => _buildTotalRow(context),
              ),
            ],
            if (ordersProvider.error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(_kInputRadius),
                ),
                child: Text(
                  ordersProvider.error!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onErrorContainer),
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  ordersProvider.isLoading ? null : () => _submitOrder(context),
              icon: ordersProvider.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colorScheme.onPrimary))
                  : Icon(Icons.send_rounded,
                      size: 20, color: colorScheme.onPrimary),
              label: Text(l10n.placeOrder,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kInputRadius)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateOrderInput(BuildContext context) {
    if (_selectedMarket == null) return null;

    final l10n = AppLocalizations.of(context);
    final amountRaw = _amountController.text.trim();
    final amount = _parseDecimalInput(amountRaw);
    if (amount == null || amount <= 0) {
      return '${l10n.amount} must be a positive number';
    }

    final amountScale = _selectedMarket!.amountScale;
    if (_countDecimals(amountRaw) > amountScale) {
      return 'Amount supports up to $amountScale decimal places';
    }

    if (_orderType == 'LIMIT') {
      final priceRaw = _priceController.text.trim();
      final price = _parseDecimalInput(priceRaw);
      if (price == null || price <= 0) {
        return '${l10n.price} must be a positive number';
      }

      final priceScale = _selectedMarket!.priceScale;
      if (_countDecimals(priceRaw) > priceScale) {
        return 'Price supports up to $priceScale decimal places';
      }
    }

    return null;
  }

  static String _baseSymbol(MarketPair m) {
    return m.baseCurrency?.symbol ??
        (m.symbol.contains('/')
            ? m.symbol.split('/').first
            : m.symbol
                .replaceAll('USDT', '')
                .replaceAll(RegExp(r'[^A-Za-z]'), ''));
  }

  static String _quoteSymbol(MarketPair m) {
    return m.quoteCurrency?.symbol ??
        (m.symbol.contains('/') ? m.symbol.split('/').last : 'USDT');
  }

  Widget _buildTickerBlock(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ticker = context.watch<MarketsProvider>().ticker;
    if (ticker == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(_kInputRadius),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.lastPrice,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatPriceDisplay(ticker.lastPrice),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (ticker.isPositive ? Colors.green : Colors.red)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ticker.changePercentFormatted,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: ticker.isPositive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _tickerChip(context, 'Bid', _formatPriceDisplay(ticker.bestBid)),
              _tickerChip(context, 'Ask', _formatPriceDisplay(ticker.bestAsk)),
              _tickerChip(
                  context, '24h H', _formatPriceDisplay(ticker.high24h)),
              _tickerChip(context, '24h L', _formatPriceDisplay(ticker.low24h)),
              _tickerChip(
                  context, 'Vol', _formatVolumeDisplay(ticker.volume24h)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tickerChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      '$label: $value',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBalanceBlock(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ordersProvider = context.watch<OrdersProvider>();
    if (_selectedMarket == null) return const SizedBox.shrink();
    final baseSym = _baseSymbol(_selectedMarket!);
    final quoteSym = _quoteSymbol(_selectedMarket!);
    final baseAvail = ordersProvider.baseBalance?.available != null
        ? _formatAmountDisplay(ordersProvider.baseBalance!.available)
        : '—';
    final quoteAvail = ordersProvider.quoteBalance?.available != null
        ? _formatAmountDisplay(ordersProvider.quoteBalance!.available)
        : '—';
    final isBuy = _side == 'BUY';
    final baseFrozen = ordersProvider.baseBalance?.frozen != null
        ? _formatAmountDisplay(ordersProvider.baseBalance!.frozen)
        : '—';
    final quoteFrozen = ordersProvider.quoteBalance?.frozen != null
        ? _formatAmountDisplay(ordersProvider.quoteBalance!.frozen)
        : '—';

    final fromWallet = isBuy ? quoteSym : baseSym;
    final toWallet = isBuy ? baseSym : quoteSym;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(_kInputRadius),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.available} ($baseSym / $quoteSym)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _balanceChip(context, baseSym, baseAvail,
                    highlight: !isBuy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _balanceChip(context, quoteSym, quoteAvail,
                    highlight: isBuy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.frozen}: $baseSym $baseFrozen • $quoteSym $quoteFrozen',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.orderFundsFrom}: ${l10n.spotWallet} ($fromWallet)  →  ${l10n.orderFundsTo}: ${l10n.spotWallet} ($toWallet)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _balanceChip(BuildContext context, String symbol, String value,
      {required bool highlight}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? colorScheme.primaryContainer.withValues(alpha: 0.6)
            : colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(symbol,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              color: highlight ? colorScheme.primary : colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_selectedMarket == null) return const SizedBox.shrink();
    final quoteSym = _quoteSymbol(_selectedMarket!);
    final priceStr = _orderType == 'MARKET'
        ? (context.watch<MarketsProvider>().ticker?.lastPrice ?? '')
        : _priceController.text.trim();
    final amountStr = _amountController.text.trim();
    final price = _parseDecimalInput(priceStr);
    final amount = _parseDecimalInput(amountStr);
    final total = (price != null && amount != null) ? price * amount : null;
    if (total == null) return const SizedBox.shrink();
    final amountValue = amount ?? 0;

    final feeRate = _side == 'BUY'
        ? _parseDecimalInput(_selectedMarket!.takerFeeRate) ?? 0
        : _parseDecimalInput(_selectedMarket!.makerFeeRate) ?? 0;
    final estimatedFee = total * feeRate;
    final estimatedReceive = _side == 'BUY'
        ? (amountValue - (amountValue * feeRate))
        : (total - estimatedFee);
    final receiveSym = _side == 'BUY'
        ? _baseSymbol(_selectedMarket!)
        : _quoteSymbol(_selectedMarket!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _side == 'BUY'
                ? '${l10n.total}: ${_formatTotalDisplay(total)} $quoteSym'
                : '${l10n.youWillReceive}: ${_formatTotalDisplay(total)} $quoteSym',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${l10n.estimatedFee}: ${_formatTotalDisplay(estimatedFee)} $quoteSym',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${l10n.youWillReceive}: ${_formatAmountDisplay(estimatedReceive.toString())} $receiveSym',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTradesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final trades = context.watch<MarketsProvider>().trades;
    if (trades.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(_kSectionPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.recentTrades,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_selectedMarket != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '(${_formatSymbol(_selectedMarket!.symbol)})',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(0.8),
                  3: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Text(
                          l10n.price,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Text(
                          l10n.amount,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Text(
                          'Side',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Text(
                          'Time',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...trades.take(15).map((t) {
                    return TableRow(
                      decoration: BoxDecoration(color: colorScheme.surface),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Text(
                            _formatPriceDisplay(t.price),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Text(
                            _formatAmountDisplay(t.amount),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Text(
                            t.isBuy ? l10n.buy : l10n.sell,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: t.isBuy
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 10,
                          ),
                          child: Text(
                            _formatTradeTime(t.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTradeTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return '${diff.inSeconds}s';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${t.day}/${t.month}';
  }

  static String _formatSymbol(String symbol) {
    if (symbol.contains('/')) return symbol;
    if (symbol.length >= 6 && symbol.endsWith('USDT')) {
      return '${symbol.substring(0, symbol.length - 4)}/USDT';
    }
    return symbol;
  }

  bool _hasEnoughBalanceForOrder(OrdersProvider provider) {
    if (_selectedMarket == null) return false;

    final amount = _parseDecimalInput(_amountController.text);
    if (amount == null || amount <= 0) return false;

    if (_side == 'SELL') {
      final availableBase =
          _parseDecimalInput(provider.baseBalance?.available ?? '0') ?? 0;
      return availableBase >= amount;
    }

    final priceInput = _orderType == 'MARKET'
        ? (context.read<MarketsProvider>().ticker?.lastPrice ?? '')
        : _priceController.text;
    final price = _parseDecimalInput(priceInput);
    if (price == null || price <= 0) return false;

    final requiredQuote = amount * price;
    final availableQuote =
        _parseDecimalInput(provider.quoteBalance?.available ?? '0') ?? 0;
    return availableQuote >= requiredQuote;
  }

  void _showInsufficientBalanceMessage(
      BuildContext context, OrdersProvider provider) {
    final l10n = AppLocalizations.of(context);
    if (_selectedMarket == null) return;

    if (_side == 'SELL') {
      final baseSym = _baseSymbol(_selectedMarket!);
      final available =
          _formatAmountDisplay(provider.baseBalance?.available ?? '0');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${l10n.orderInsufficientBase}: $available $baseSym')),
      );
      return;
    }

    final quoteSym = _quoteSymbol(_selectedMarket!);
    final available =
        _formatAmountDisplay(provider.quoteBalance?.available ?? '0');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('${l10n.orderInsufficientQuote}: $available $quoteSym')),
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<OrdersProvider>();
    if (_selectedMarket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.tradingPair} ${l10n.retry}')));
      return;
    }

    final inputError = _validateOrderInput(context);
    if (inputError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(inputError)));
      return;
    }

    final pairId = _selectedMarket!.pairId;
    final amount = _amountController.text.trim();

    if (!_hasEnoughBalanceForOrder(provider)) {
      _showInsufficientBalanceMessage(context, provider);
      return;
    }

    final idempotencyKey =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(0x7FFFFFFF)}';
    final request = CreateOrderRequest(
      pairId: pairId,
      side: _side,
      type: _orderType,
      price: _orderType == 'LIMIT' ? _priceController.text.trim() : null,
      amount: amount,
      idempotencyKey: idempotencyKey,
    );
    final order = await provider.createOrder(request);
    if (!context.mounted) return;
    if (order != null) {
      provider.clearError();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.orderPlacedSuccess)));
      _amountController.clear();
      if (_orderType == 'LIMIT') _priceController.clear();
      provider.fetchOrderBook(pairId);
      provider.fetchMyOrders(refresh: true);
      provider.fetchBaseQuoteBalances(
          _selectedMarket!.baseCurrencyId, _selectedMarket!.quoteCurrencyId);
    }
  }

  Widget _buildOrderBookSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<OrdersProvider>();
    return Card(
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(_kSectionPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.orderBook,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (_selectedMarket != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(${_formatSymbol(_selectedMarket!.symbol)})',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.primary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: provider.isLoading || _selectedMarket == null
                  ? null
                  : () => provider.fetchOrderBook(_selectedMarket!.pairId),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(l10n.refresh),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_kInputRadius)),
              ),
            ),
            if (_selectedMarket == null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.tradingPair,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
              ),
            if (provider.error != null) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(provider.error!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: colorScheme.onErrorContainer)),
              ),
            ],
            if (provider.orderBookBids.isNotEmpty ||
                provider.orderBookAsks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _OrderBookTable(
                      title: l10n.bidsBuy,
                      levels: provider.orderBookBids,
                      isBid: true,
                      onPriceTap: _orderType == 'LIMIT'
                          ? (price) =>
                              setState(() => _priceController.text = price)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OrderBookTable(
                      title: l10n.asksSell,
                      levels: provider.orderBookAsks,
                      isBid: false,
                      onPriceTap: _orderType == 'LIMIT'
                          ? (price) =>
                              setState(() => _priceController.text = price)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrdersSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<OrdersProvider>();
    if (provider.error != null && provider.myOrders.isEmpty) {
      return Card(
        elevation: _kCardElevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kCardRadius)),
        child: Padding(
          padding: const EdgeInsets.all(_kSectionPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(provider.error!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.error),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.tonal(
                  onPressed: () => provider.fetchMyOrders(refresh: true),
                  child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }
    if (provider.isLoading && provider.myOrders.isEmpty) {
      return Card(
        elevation: _kCardElevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kCardRadius)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (provider.myOrders.isEmpty) {
      return Card(
        elevation: _kCardElevation,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kCardRadius)),
        child: Padding(
          padding: const EdgeInsets.all(_kSectionPadding),
          child: Center(
            child: Text(
              l10n.orderBookEmpty,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }
    return Card(
      elevation: _kCardElevation,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kCardRadius)),
      child: Padding(
        padding: const EdgeInsets.all(_kSectionPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Orders (${provider.myOrdersTotal})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => provider.fetchMyOrders(refresh: true),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.myOrders.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1, color: colorScheme.outline.withValues(alpha: 0.3)),
              itemBuilder: (context, index) {
                final order = provider.myOrders[index];
                return _OrderListTile(
                  order: order,
                  onCancel: () async {
                    final p = context.read<OrdersProvider>();
                    await p.cancelOrder(order.orderId);
                    if (context.mounted) p.fetchMyOrders(refresh: true);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderBookTable extends StatelessWidget {
  final String title;
  final List<OrderBookLevel> levels;
  final bool isBid;
  final void Function(String price)? onPriceTap;

  const _OrderBookTable({
    required this.title,
    required this.levels,
    required this.isBid,
    this.onPriceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration:
                    BoxDecoration(color: colorScheme.surfaceContainerHighest),
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: _cell(context, 'Price', isHeader: true)),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: _cell(context, 'Size', isHeader: true)),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: _cell(context, 'Count', isHeader: true)),
                ],
              ),
              ...levels.take(10).map((l) {
                const cellPadding =
                    EdgeInsets.symmetric(vertical: 6, horizontal: 8);
                return TableRow(
                  children: [
                    onPriceTap != null
                        ? InkWell(
                            onTap: () => onPriceTap!(l.price),
                            child: Padding(
                                padding: cellPadding,
                                child: _cell(
                                    context, _formatPriceDisplay(l.price),
                                    isBid: isBid)),
                          )
                        : Padding(
                            padding: cellPadding,
                            child: _cell(context, _formatPriceDisplay(l.price),
                                isBid: isBid)),
                    Padding(
                        padding: cellPadding,
                        child:
                            _cell(context, _formatAmountDisplay(l.remaining))),
                    Padding(
                        padding: cellPadding,
                        child: _cell(context, '${l.orderCount}')),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, String text,
      {bool isHeader = false, bool? isBid}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color? color;
    if (isBid == true) color = Colors.green.shade700;
    if (isBid == false) color = Colors.red.shade700;
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        fontWeight: isHeader ? FontWeight.w600 : null,
        color: color ?? colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _OrderListTile extends StatelessWidget {
  final Order order;
  final VoidCallback onCancel;

  const _OrderListTile({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      title: Text(
        '${order.side.value} ${order.type.value}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: order.side == OrderSide.buy
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          'Price: ${order.price ?? "MKT"} | Amount: ${order.amount} | Filled: ${order.filledAmount} | ${order.status.value}',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
      trailing: order.isCancellable
          ? FilledButton.tonal(
              onPressed: onCancel,
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(AppLocalizations.of(context).cancel),
            )
          : null,
    );
  }
}
