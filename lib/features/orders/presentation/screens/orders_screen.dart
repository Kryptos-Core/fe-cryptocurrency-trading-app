import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/app/router/app_routes.dart';
import 'package:crypto_trading_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/features/orders/domain/entities/order.dart';
import 'package:crypto_trading_app/features/orders/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/core/utils/amount_input_formatter.dart';
import 'package:crypto_trading_app/core/utils/api_error_localizer.dart';
import 'package:crypto_trading_app/core/utils/currency_amount_input.dart';
import 'package:crypto_trading_app/core/utils/format_utils.dart';
import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/app/di/injection_container.dart';
import 'package:crypto_trading_app/core/services/trading_pair_bookmark_store.dart';
import 'package:crypto_trading_app/core/responsive/app_responsive.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/features/markets/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:crypto_trading_app/features/markets/presentation/widgets/trading_pair_picker_sheet.dart';

// --- Format số hiển thị (best practice: dấu phân cách hàng nghìn, bỏ số 0 thừa) ---

/// Giá: dấu phân cách hàng nghìn, 1–8 chữ số thập phân theo magnitude, bỏ 0 thừa.
String _formatPriceDisplay(String raw) {
  return PriceFormatter.formatPriceStr(raw);
}

/// Volume: K/M/B khi lớn, dấu phân cách hàng nghìn, bỏ 0 thừa.
String _formatVolumeDisplay(String raw) {
  return PriceFormatter.formatVolumeStr(raw);
}

/// Số dư / số lượng: dấu phân cách hàng nghìn, tối đa 8 chữ số thập phân, bỏ 0 thừa.
String _formatAmountDisplay(String raw) {
  return FormatUtils.formatDecimalAmountDisplay(raw);
}

/// Khối lượng tối thiểu: bỏ số 0 thừa, dễ đọc.
String _formatMinAmountDisplay(String raw) {
  return FormatUtils.formatDecimalAmountDisplay(raw);
}

/// Tổng tiền (quote): 2 số thập phân, dấu phân cách hàng nghìn.
String _formatTotalDisplay(double value) {
  return FormatUtils.formatQuoteAmount(value);
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

/// Giá last từ ticker → ô đặt lệnh: theo [MarketPair.priceScale], bỏ số 0 thập phân thừa.
String _formatLastPriceForOrderInput(String raw, MarketPair? market) {
  final scale = market?.priceScale ?? 8;
  return _truncateToScale(raw, scale);
}

int _countDecimals(String raw) {
  final sanitized = raw.replaceAll(',', '').trim();
  if (!sanitized.contains('.')) return 0;
  return sanitized.split('.')[1].length;
}

String _orderStatusLocalized(AppLocalizations l10n, OrderStatus s) {
  switch (s) {
    case OrderStatus.open:
      return l10n.orderStatusOpen;
    case OrderStatus.partial:
      return l10n.orderStatusPartial;
    case OrderStatus.filled:
      return l10n.orderStatusFilled;
    case OrderStatus.cancelled:
      return l10n.orderStatusCancelled;
    case OrderStatus.rejected:
      return l10n.orderStatusRejected;
  }
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
  final _orderDecimalFormatter = AmountInputFormatter();
  String _side = 'BUY';
  String _orderType = 'LIMIT';
  MarketPair? _selectedMarket;

  AuthProvider? _authProvider;
  bool? _lastIsAuthenticated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = context.read<AuthProvider>();
      _authProvider!.addListener(_onAuthChanged);
      _lastIsAuthenticated = _authProvider!.isAuthenticated;
      _maybeFetchOrders();
    });
  }

  @override
  void dispose() {
    _authProvider?.removeListener(_onAuthChanged);
    _authProvider = null;
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAuthChanged() {
    final auth = context.read<AuthProvider>();
    if (_lastIsAuthenticated == null) {
      _lastIsAuthenticated = auth.isAuthenticated;
      return;
    }
    if (_lastIsAuthenticated == auth.isAuthenticated) return;

    _lastIsAuthenticated = auth.isAuthenticated;
    if (!auth.isAuthenticated) {
      context.read<OrdersProvider>().reset();
    } else {
      context.read<OrdersProvider>().fetchMyOrders(refresh: true);
    }
  }

  void _maybeFetchOrders() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      context.read<OrdersProvider>().fetchMyOrders(refresh: true);
    }
  }

  Future<void> _openTradingPairPicker(
    BuildContext context,
    MarketsProvider marketsProvider,
    OrdersProvider ordersProvider,
  ) async {
    final repo = sl<MarketsRepository>();
    final store = TradingPairBookmarkStore(sl<SharedPreferences>());
    final pair = await showTradingPairPickerBottomSheet(
      context,
      marketsRepository: repo,
      bookmarkStore: store,
      selected: _selectedMarket,
    );
    if (!context.mounted || pair == null) return;
    await store.addRecent(pair);
    setState(() => _selectedMarket = pair);
    marketsProvider.fetchTicker(pair.pairId);
    marketsProvider.fetchOrderBook(pair.pairId, limit: 20);
    marketsProvider.fetchTrades(pair.pairId, limit: 20);
    ordersProvider.fetchBaseQuoteBalances(
        pair.baseCurrencyId, pair.quoteCurrencyId);
    ordersProvider.fetchOrderBook(pair.pairId, limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.select<AuthProvider, bool>((a) => a.isAuthenticated);

    if (!auth) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.orders),
        ),
        body: _OrdersGuestGate(
          onSignIn: () => context.push(AppRoutes.login),
          onRegister: () => context.push(AppRoutes.register),
        ),
      );
    }

    final ordersProvider = context.watch<OrdersProvider>();
    if (ordersProvider.sessionExpired) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.orders),
        ),
        body: _OrdersSessionExpiredGate(
          onSignInAgain: () => context.push(AppRoutes.login),
        ),
      );
    }

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final layout = width < _kCompactBreakpoint
              ? _OrdersLayout.compact
              : width < _kMediumBreakpoint
                  ? _OrdersLayout.medium
                  : _OrdersLayout.expanded;
          return _buildBody(context, l10n, layout);
        },
      ),
    );
  }

  /// Responsive layout tier for the Orders screen.
  static const double _kCompactBreakpoint = 600;
  static const double _kMediumBreakpoint = 900;

  Widget _buildBody(BuildContext context, AppLocalizations l10n, _OrdersLayout layout) {
    switch (layout) {
      case _OrdersLayout.compact:
        return _buildCompactLayout(context, l10n);
      case _OrdersLayout.medium:
        return _buildMediumLayout(context, l10n);
      case _OrdersLayout.expanded:
        return _buildExpandedLayout(context, l10n);
    }
  }

  // ── Compact: mobile vertical stack ─────────────────────────────────────────

  Widget _buildCompactLayout(BuildContext context, AppLocalizations l10n) {
    return _ResponsiveOrdersScrollView(
      layout: _OrdersLayout.compact,
      onRefresh: () =>
          context.read<OrdersProvider>().fetchMyOrders(refresh: true),
      children: [
        _buildPlaceOrderSection(context),
        const SizedBox(height: _kSectionSpacing),
        _buildOrderBookSection(context, maxLevels: 8),
        if (_selectedMarket != null) ...[
          const SizedBox(height: _kSectionSpacing),
          _buildRecentTradesSection(context, maxRows: 10),
        ],
        const SizedBox(height: _kSectionSpacing),
        _buildMyOrdersSection(context, compact: true),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Medium: 600–899px – two columns ───────────────────────────────────────

  Widget _buildMediumLayout(BuildContext context, AppLocalizations l10n) {
    return _ResponsiveOrdersScrollView(
      layout: _OrdersLayout.medium,
      onRefresh: () =>
          context.read<OrdersProvider>().fetchMyOrders(refresh: true),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPlaceOrderSection(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOrderBookSection(context, maxLevels: 10),
            ),
          ],
        ),
        const SizedBox(height: _kSectionSpacing),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMyOrdersSection(context, compact: false),
            ),
            if (_selectedMarket != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildRecentTradesSection(context, maxRows: 12),
              ),
            ],
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Expanded: ≥900px – three columns ─────────────────────────────────────

  Widget _buildExpandedLayout(BuildContext context, AppLocalizations l10n) {
    return _ResponsiveOrdersScrollView(
      layout: _OrdersLayout.expanded,
      onRefresh: () =>
          context.read<OrdersProvider>().fetchMyOrders(refresh: true),
      children: [
        // Row 1: Place Order | Order Book | Recent Trades
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPlaceOrderSection(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildOrderBookSection(context, maxLevels: 12),
            ),
            if (_selectedMarket != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: _buildRecentTradesSection(context, maxRows: 15),
              ),
            ] else ...[
              const Spacer(),
            ],
          ],
        ),
        const SizedBox(height: _kSectionSpacing),
        // Row 2: My Orders full width
        _buildMyOrdersSection(context, compact: false),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPlaceOrderSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ordersProvider = context.watch<OrdersProvider>();
    final marketsProvider = context.watch<MarketsProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('trading_pair_picker'),
                borderRadius: BorderRadius.circular(8),
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _openTradingPairPicker(
                  context,
                  marketsProvider,
                  ordersProvider,
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.tradingPair,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  child: Text(
                    _selectedMarket != null
                        ? _formatSymbol(_selectedMarket!.symbol)
                        : l10n.tradingPairSelectPairHint,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _selectedMarket != null
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.ordersPayosUsdtHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
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
                      key: const Key('orders_price_field'),
                      controller: _priceController,
                      inputFormatters: [_orderDecimalFormatter],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: theme.textTheme.bodyLarge,
                      decoration: CurrencyAmountInput.withCurrencySuffix(
                        context,
                        InputDecoration(
                          labelText: l10n.price,
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(_kInputRadius)),
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
                              ? AmountInputFormatter.valueFromPlainDecimal(
                                      _formatLastPriceForOrderInput(
                                          marketsProvider.ticker!.lastPrice,
                                          _selectedMarket))
                                  .text
                              : l10n.priceHintExample,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        currencySymbol: _selectedMarket != null
                            ? _quoteSymbol(_selectedMarket!)
                            : '',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (marketsProvider.ticker != null)
                    FilledButton.tonalIcon(
                      onPressed: () => _priceController.value =
                          AmountInputFormatter.valueFromPlainDecimal(
                              _formatLastPriceForOrderInput(
                                  marketsProvider.ticker!.lastPrice,
                                  _selectedMarket)),
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
              key: const Key('orders_amount_field'),
              controller: _amountController,
              inputFormatters: [_orderDecimalFormatter],
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
                hintText: l10n.amountHintExample,
                suffix: _selectedMarket == null
                    ? null
                    : (_side == 'SELL'
                        ? Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _baseSymbol(_selectedMarket!),
                                  style:
                                      CurrencyAmountInput.suffixStyle(context),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final available =
                                        ordersProvider.baseBalance?.available ??
                                            '';
                                    if (available.isEmpty) return;

                                    final amountScale =
                                        _selectedMarket!.amountScale;
                                    final maxSell = _truncateToScale(
                                        available, amountScale);
                                    if (maxSell.isEmpty) return;

                                    _amountController.value =
                                        AmountInputFormatter
                                            .valueFromPlainDecimal(maxSell);
                                  },
                                  child: Text(l10n.maxAmountButton),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Align(
                              widthFactor: 1,
                              alignment: Alignment.centerRight,
                              child: Text(
                                _baseSymbol(_selectedMarket!),
                                style: CurrencyAmountInput.suffixStyle(context),
                              ),
                            ),
                          )),
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
                  localizeApiError(
                    l10n,
                    code: ordersProvider.apiErrorCode,
                    message: ordersProvider.error,
                  ),
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
      return l10n.amountMustBePositive;
    }

    final amountScale = _selectedMarket!.amountScale;
    if (_countDecimals(amountRaw) > amountScale) {
      return l10n.amountMaxDecimals(amountScale);
    }

    if (_orderType == 'LIMIT') {
      final priceRaw = _priceController.text.trim();
      final price = _parseDecimalInput(priceRaw);
      if (price == null || price <= 0) {
        return l10n.priceMustBePositive;
      }

      final priceScale = _selectedMarket!.priceScale;
      if (_countDecimals(priceRaw) > priceScale) {
        return l10n.priceMaxDecimals(priceScale);
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
              _tickerChip(
                  context, l10n.tickerBid, _formatPriceDisplay(ticker.bestBid)),
              _tickerChip(
                  context, l10n.tickerAsk, _formatPriceDisplay(ticker.bestAsk)),
              _tickerChip(context, l10n.ticker24hHigh,
                  _formatPriceDisplay(ticker.high24h)),
              _tickerChip(context, l10n.ticker24hLow,
                  _formatPriceDisplay(ticker.low24h)),
              _tickerChip(context, l10n.tickerVolume,
                  _formatVolumeDisplay(ticker.volume24h)),
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

  Widget _buildRecentTradesSection(BuildContext context, {int maxRows = 15}) {
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
                          l10n.orderColumnSide,
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
                          l10n.orderColumnTime,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...trades.take(maxRows).map((t) {
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
                            _formatTradeTime(context, t.createdAt),
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

  String _formatTradeTime(BuildContext context, DateTime t) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return l10n.timeSecondsShort(diff.inSeconds);
    if (diff.inHours < 1) return l10n.timeMinutesShort(diff.inMinutes);
    if (diff.inDays < 1) return l10n.timeHoursShort(diff.inHours);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.ordersSelectPairFirst)));
      return;
    }

    final inputError = _validateOrderInput(context);
    if (inputError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(inputError)));
      return;
    }

    final pairId = _selectedMarket!.pairId;
    final amount = parseAmountInput(_amountController.text.trim());

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
      price: _orderType == 'LIMIT'
          ? parseAmountInput(_priceController.text.trim())
          : null,
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

  Widget _buildOrderBookSection(BuildContext context, {int maxLevels = 10}) {
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
                child: Text(
                  localizeApiError(
                    l10n,
                    code: provider.apiErrorCode,
                    message: provider.error,
                  ),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onErrorContainer),
                ),
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
                      maxLevels: maxLevels,
                      onPriceTap: _orderType == 'LIMIT'
                          ? (price) => setState(() => _priceController.value =
                              AmountInputFormatter.valueFromPlainDecimal(price))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OrderBookTable(
                      title: l10n.asksSell,
                      levels: provider.orderBookAsks,
                      isBid: false,
                      maxLevels: maxLevels,
                      onPriceTap: _orderType == 'LIMIT'
                          ? (price) => setState(() => _priceController.value =
                              AmountInputFormatter.valueFromPlainDecimal(price))
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

  Widget _buildMyOrdersSection(BuildContext context, {bool compact = true}) {
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
              Text(
                localizeApiError(
                  l10n,
                  code: provider.apiErrorCode,
                  message: provider.error,
                ),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
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
              l10n.myOrdersEmpty,
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
                  l10n.ordersMyOrdersWithCount(provider.myOrdersTotal),
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

enum _OrdersLayout { compact, medium, expanded }

class _OrderBookTable extends StatelessWidget {
  final String title;
  final List<OrderBookLevel> levels;
  final bool isBid;
  final int maxLevels;
  final void Function(String price)? onPriceTap;

  const _OrderBookTable({
    required this.title,
    required this.levels,
    required this.isBid,
    this.maxLevels = 10,
    this.onPriceTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      child: _cell(context, l10n.price, isHeader: true)),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: _cell(context, l10n.orderBookColumnSize,
                          isHeader: true)),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: _cell(context, l10n.orderBookColumnCount,
                          isHeader: true)),
                ],
              ),
              ...levels.take(maxLevels).map((l) {
                const cellPadding =
                    EdgeInsets.symmetric(vertical: 6, horizontal: 8);
                return TableRow(
                  children: [
                    onPriceTap != null
                        ? InkWell(
                            onTap: () => onPriceTap!(l.price),
                            mouseCursor: SystemMouseCursors.click,
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

// ── Auth gate widgets ─────────────────────────────────────────────────────────

class _OrderListTile extends StatelessWidget {
  final Order order;
  final VoidCallback onCancel;

  const _OrderListTile({required this.order, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final sideLabel = order.side == OrderSide.buy ? l10n.buy : l10n.sell;
    final typeLabel =
        order.type == OrderType.limit ? l10n.limitOrder : l10n.marketOrder;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      title: Text(
        '$sideLabel · $typeLabel',
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
          '${l10n.price}: ${order.price != null ? _formatPriceDisplay(order.price!) : l10n.marketPriceAbbrev} | '
          '${l10n.amount}: ${_formatAmountDisplay(order.amount)} | '
          '${l10n.orderFilledQuantity}: ${_formatAmountDisplay(order.filledAmount)} | '
          '${_orderStatusLocalized(l10n, order.status)}',
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

/// Full-screen gate shown to unauthenticated users trying to access the Orders tab.
class _OrdersGuestGate extends StatelessWidget {
  final VoidCallback onSignIn;
  final VoidCallback onRegister;

  const _OrdersGuestGate({
    required this.onSignIn,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppCenteredContent(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.lock_outline,
              size: 72,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.ordersGuestGateTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ordersGuestGateSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSignIn,
                icon: const Icon(Icons.login),
                label: Text(l10n.signIn),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRegister,
                child: Text(l10n.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen gate shown when the auth token has expired on the Orders tab.
class _OrdersSessionExpiredGate extends StatelessWidget {
  final VoidCallback onSignInAgain;

  const _OrdersSessionExpiredGate({required this.onSignInAgain});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AppCenteredContent(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.timer_off_outlined,
              size: 72,
              color: colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.ordersSessionExpiredTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ordersSessionExpiredSubtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSignInAgain,
                icon: const Icon(Icons.login),
                label: Text(l10n.signInAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Responsive scroll view wrapper ─────────────────────────────────────────────

/// Wrapper that applies layout-appropriate padding and a RefreshIndicator.
class _ResponsiveOrdersScrollView extends StatelessWidget {
  final _OrdersLayout layout;
  final Future<void> Function() onRefresh;
  final List<Widget> children;

  const _ResponsiveOrdersScrollView({
    required this.layout,
    required this.onRefresh,
    required this.children,
  });

  EdgeInsets get _padding {
    switch (layout) {
      case _OrdersLayout.compact:
        return const EdgeInsets.all(_kSectionPadding);
      case _OrdersLayout.medium:
        return const EdgeInsets.all(20);
      case _OrdersLayout.expanded:
        return const EdgeInsets.all(24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: _padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
