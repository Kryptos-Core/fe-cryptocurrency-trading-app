import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:crypto_trading_app/core/di/injection_container.dart';
import 'package:crypto_trading_app/core/error/failures.dart';
import 'package:crypto_trading_app/data/models/create_market_pair_dto.dart';
import 'package:crypto_trading_app/data/models/update_market_pair_dto.dart';
import 'package:crypto_trading_app/domain/entities/market_pair.dart';
import 'package:crypto_trading_app/domain/entities/order.dart';
import 'package:crypto_trading_app/domain/entities/order_book_level.dart';
import 'package:crypto_trading_app/domain/entities/admin_wallet_adjustment.dart';
import 'package:crypto_trading_app/domain/entities/wallet_balance.dart';
import 'package:crypto_trading_app/domain/entities/wallet_transaction.dart';
import 'package:crypto_trading_app/domain/repositories/markets_repository.dart';
import 'package:crypto_trading_app/features/wallets/domain/repositories/wallet_repository.dart';
import 'package:crypto_trading_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:crypto_trading_app/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/presentation/providers/markets_provider.dart';
import 'package:crypto_trading_app/presentation/widgets/market_row.dart';
import 'package:crypto_trading_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:crypto_trading_app/features/orders/presentation/screens/orders_screen.dart';

class FakeOrdersRepository implements OrdersRepository {
  int createOrderCalls = 0;

  @override
  Future<Either<Failure, Order>> createOrder(CreateOrderRequest request) async {
    createOrderCalls += 1;
    return Right(
      Order(
        orderId: 'order-1',
        userId: 'user-1',
        pairId: request.pairId,
        side: OrderSide.fromString(request.side),
        type: OrderType.fromString(request.type),
        price: request.price,
        amount: request.amount,
        filledAmount: '0',
        avgPrice: null,
        status: OrderStatus.open,
        timeInForce: TimeInForce.fromString(request.timeInForce),
        reservedQuote: '0',
        reservedBase: '0',
        clientOrderId: request.clientOrderId,
        idempotencyKey: request.idempotencyKey,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, Order>> cancelOrder(String orderId) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, List<OrderBookLevel>>> getOrderBook(
    String pairId, {
    required String side,
    int limit = 50,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, MyOrdersResult>> getMyOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return const Right(
      MyOrdersResult(
        data: [],
        total: 0,
        page: 1,
        limit: 20,
      ),
    );
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }
}

class FakeWalletRepository implements WalletRepository {
  FakeWalletRepository({
    required this.baseCurrencyId,
    required this.quoteCurrencyId,
    required this.baseAvailable,
    required this.quoteAvailable,
  });

  final String baseCurrencyId;
  final String quoteCurrencyId;
  final String baseAvailable;
  final String quoteAvailable;

  @override
  Future<Either<Failure, WalletBalance>> getBalance(String currencyId) async {
    if (currencyId == baseCurrencyId) {
      return Right(
        WalletBalance(
          userId: 'user-1',
          currencyId: currencyId,
          available: baseAvailable,
          frozen: '0',
          total: baseAvailable,
        ),
      );
    }

    if (currencyId == quoteCurrencyId) {
      return Right(
        WalletBalance(
          userId: 'user-1',
          currencyId: currencyId,
          available: quoteAvailable,
          frozen: '0',
          total: quoteAvailable,
        ),
      );
    }

    return const Left(ServerFailure(message: 'Unknown currencyId'));
  }

  @override
  Future<Either<Failure, List<WalletTransactionResponse>>>
      getTransactionHistory(
    String currencyId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, WalletTransactionResponse>> executeTransaction(
    WalletTransactionRequest request,
  ) async {
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<void> cacheBalance(WalletBalance balance, String currencyId) async {}

  @override
  Future<WalletBalance?> getCachedBalance(String currencyId) async {
    return null;
  }

  @override
  Future<void> clearCachedBalance(String currencyId) async {}

  @override
  Future<void> clearAllCachedBalances() async {}

  @override
  Future<Either<Failure, AdminWalletAdjustment>> adminAdjustBalance({
    required String userId,
    required String currencyId,
    required String amount,
    required String type,
    String? note,
  }) async {
    return const Left(ServerFailure(message: 'Not implemented in tests'));
  }

  @override
  Future<Either<Failure, List<AdminWalletAdjustment>>>
      getAdminAdjustmentHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return const Right([]);
  }
}

class FakeMarketsRepository implements MarketsRepository {
  FakeMarketsRepository({required this.market});

  final MarketPair market;

  @override
  Future<Either<Failure, List<MarketPair>>> getActiveMarkets() async {
    return Right([market]);
  }

  @override
  Future<Either<Failure, MarketTicker>> getMarketTicker(String pairId) async {
    return Right(
      MarketTicker(
        pairId: pairId,
        symbol: market.symbol,
        lastPrice: '100',
        open24h: '99',
        high24h: '101',
        low24h: '98',
        volume24h: '1000',
        quoteVolume24h: '100000',
        change24h: '1.01',
        changeAmount24h: '1',
        bestBid: '99.5',
        bestAsk: '100.5',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBook({
    required String pairId,
    int limit = 20,
  }) async {
    return Right(
      OrderBook(
        pairId: pairId,
        symbol: market.symbol,
        bids: const [],
        asks: const [],
        bidLevels: 0,
        askLevels: 0,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<Either<Failure, List<Trade>>> getTrades({
    required String pairId,
    int limit = 50,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<OHLCV>>> getOHLCV({
    required String pairId,
    String? interval,
    String? range,
    String? startTime,
    String? endTime,
    int limit = 100,
    String? locale,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, PaginatedMarketsResult>> getMarkets({
    int page = 1,
    int limit = 10,
    bool includeInactive = false,
    bool includeTickers = false,
    String? search,
    String? baseSymbol,
    String? quoteSymbol,
    List<String>? quoteSymbols,
    String? sortBy,
    String? sortOrder,
    bool fuzzySearch = false,
  }) async {
    return Right(
      PaginatedMarketsResult(
        markets: [market],
        total: 1,
        page: 1,
        limit: 10,
        totalPages: 1,
        tickers: includeTickers
            ? [
                MarketTicker(
                  pairId: market.pairId,
                  symbol: market.symbol,
                  lastPrice: '100',
                  open24h: '99',
                  high24h: '101',
                  low24h: '98',
                  volume24h: '1000',
                  quoteVolume24h: '100000',
                  change24h: '1.01',
                  changeAmount24h: '1',
                  bestBid: '99.5',
                  bestAsk: '100.5',
                  timestamp: DateTime.now(),
                )
              ]
            : null,
      ),
    );
  }

  @override
  Future<Either<Failure, MarketPair>> getMarketById(String pairId) async {
    return Right(market);
  }

  @override
  Future<Either<Failure, MarketPair>> getMarketBySymbol(String symbol) async {
    return Right(market);
  }

  @override
  Future<Either<Failure, MarketTicker>> getMarketTickerBySymbol(
      String symbol) async {
    return getMarketTicker(market.pairId);
  }

  @override
  Future<Either<Failure, List<MarketTicker>>> getAllTickers() async {
    final tickerResult = await getMarketTicker(market.pairId);
    return tickerResult.fold(
      (l) => Left(l),
      (r) => Right([r]),
    );
  }

  @override
  Future<Either<Failure, OrderBook>> getOrderBookBySymbol({
    required String symbol,
    int limit = 20,
  }) async {
    return getOrderBook(pairId: market.pairId, limit: limit);
  }

  @override
  Future<Either<Failure, List<Trade>>> getTradesBySymbol({
    required String symbol,
    int limit = 50,
  }) async {
    return getTrades(pairId: market.pairId, limit: limit);
  }

  @override
  Future<Either<Failure, MarketPair>> createMarketPair(
      CreateMarketPairDto dto) async {
    return Right(market);
  }

  @override
  Future<Either<Failure, MarketPair>> updateMarketPair(
    String pairId,
    UpdateMarketPairDto dto,
  ) async {
    return Right(market);
  }

  @override
  Future<Either<Failure, void>> deleteMarketPair(String pairId) async {
    return const Right(null);
  }
}

Future<void> _registerPickerServiceLocator(
  MarketsRepository marketsRepository,
) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  if (sl.isRegistered<MarketsRepository>()) {
    sl.unregister<MarketsRepository>();
  }
  if (sl.isRegistered<SharedPreferences>()) {
    sl.unregister<SharedPreferences>();
  }
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<MarketsRepository>(marketsRepository);
}

Widget _buildTestApp({
  required FakeMarketsRepository marketsRepository,
  required FakeOrdersRepository ordersRepository,
  required FakeWalletRepository walletRepository,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => MarketsProvider(marketsRepository: marketsRepository),
      ),
      ChangeNotifierProvider(
        create: (_) => OrdersProvider(
          ordersRepository: ordersRepository,
          walletRepository: walletRepository,
        ),
      ),
    ],
    child: const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OrdersScreen(),
    ),
  );
}

Future<void> _selectFirstMarket(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('trading_pair_picker')));
  await tester.pumpAndSettle();
  final sheet = find.byKey(const Key('trading_pair_picker_sheet'));
  final marketRows =
      find.descendant(of: sheet, matching: find.byType(MarketRow));

  for (var i = 0; i < 10 && marketRows.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  expect(
    marketRows,
    findsWidgets,
    reason: 'Trading pair picker should show at least one market row',
  );
  await tester.tap(marketRows.first);
  await tester.pumpAndSettle();
}

Future<void> _tapMaxAmountSuffix(WidgetTester tester) async {
  final amountField = find.byKey(const Key('orders_amount_field'));
  final maxButton = find.descendant(
    of: amountField,
    matching: find.byType(TextButton),
  );
  await tester.ensureVisible(amountField);
  await tester.ensureVisible(maxButton);
  // Gesture hits can be absorbed by a just-dismissed modal route in tests;
  // invoke the handler directly (same outcome as user tap).
  final btn = tester.widget<TextButton>(maxButton);
  btn.onPressed?.call();
  await tester.pumpAndSettle();
}

Future<void> _tapPlaceOrderButton(WidgetTester tester) async {
  final buttonFinder = find.widgetWithText(FilledButton, 'Place Order');
  await tester.ensureVisible(buttonFinder);
  await tester.tap(buttonFinder);
  await tester.pumpAndSettle();
}

void main() {
  const baseCurrencyId = 'base-1';
  const quoteCurrencyId = 'quote-1';

  MarketPair buildMarket({
    int amountScale = 6,
    int priceScale = 2,
  }) {
    return MarketPair(
      pairId: 'pair-1',
      baseCurrencyId: baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId,
      symbol: 'BTC/USDT',
      priceScale: priceScale,
      amountScale: amountScale,
      minOrderAmount: '0.001',
      makerFeeRate: '0.001',
      takerFeeRate: '0.001',
      isActive: true,
    );
  }

  testWidgets('SELL tap MAX fills amount truncated by amountScale',
      (tester) async {
    final marketsRepository = FakeMarketsRepository(
      market: buildMarket(amountScale: 6, priceScale: 2),
    );
    final ordersRepository = FakeOrdersRepository();
    final walletRepository = FakeWalletRepository(
      baseCurrencyId: baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId,
      baseAvailable: '1.23456789',
      quoteAvailable: '10000',
    );

    await _registerPickerServiceLocator(marketsRepository);

    await tester.pumpWidget(
      _buildTestApp(
        marketsRepository: marketsRepository,
        ordersRepository: ordersRepository,
        walletRepository: walletRepository,
      ),
    );
    await tester.pumpAndSettle();

    await _selectFirstMarket(tester);

    await tester.tap(find.text('Sell').first);
    await tester.pumpAndSettle();

    await _tapMaxAmountSuffix(tester);

    final amountField =
        tester.widget<TextField>(find.byKey(const Key('orders_amount_field')));
    expect(amountField.controller?.text, '1.234567');
  });

  testWidgets('SELL tap MAX keeps integer balance without decimal suffix',
      (tester) async {
    final marketsRepository = FakeMarketsRepository(
      market: buildMarket(amountScale: 6, priceScale: 2),
    );
    final ordersRepository = FakeOrdersRepository();
    final walletRepository = FakeWalletRepository(
      baseCurrencyId: baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId,
      baseAvailable: '12',
      quoteAvailable: '10000',
    );

    await _registerPickerServiceLocator(marketsRepository);

    await tester.pumpWidget(
      _buildTestApp(
        marketsRepository: marketsRepository,
        ordersRepository: ordersRepository,
        walletRepository: walletRepository,
      ),
    );
    await tester.pumpAndSettle();

    await _selectFirstMarket(tester);

    await tester.tap(find.text('Sell').first);
    await tester.pumpAndSettle();

    await _tapMaxAmountSuffix(tester);

    final amountField =
        tester.widget<TextField>(find.byKey(const Key('orders_amount_field')));
    expect(amountField.controller?.text, '12');
  });

  testWidgets('submit is blocked when amount or price exceeds configured scale',
      (tester) async {
    final marketsRepository = FakeMarketsRepository(
      market: buildMarket(amountScale: 3, priceScale: 2),
    );
    final ordersRepository = FakeOrdersRepository();
    final walletRepository = FakeWalletRepository(
      baseCurrencyId: baseCurrencyId,
      quoteCurrencyId: quoteCurrencyId,
      baseAvailable: '10',
      quoteAvailable: '100000',
    );

    await _registerPickerServiceLocator(marketsRepository);

    await tester.pumpWidget(
      _buildTestApp(
        marketsRepository: marketsRepository,
        ordersRepository: ordersRepository,
        walletRepository: walletRepository,
      ),
    );
    await tester.pumpAndSettle();

    await _selectFirstMarket(tester);

    await tester.ensureVisible(find.byKey(const Key('orders_price_field')));
    await tester.enterText(
        find.byKey(const Key('orders_price_field')), '100.12');
    await tester.enterText(
        find.byKey(const Key('orders_amount_field')), '1.1234');
    await _tapPlaceOrderButton(tester);

    expect(ordersRepository.createOrderCalls, 0);
    expect(find.text('Amount supports up to 3 decimal places'), findsOneWidget);

    await tester.enterText(
        find.byKey(const Key('orders_amount_field')), '1.123');
    await tester.enterText(
        find.byKey(const Key('orders_price_field')), '100.123');
    await _tapPlaceOrderButton(tester);

    expect(ordersRepository.createOrderCalls, 0);

    await tester.enterText(
        find.byKey(const Key('orders_price_field')), '100.12');
    await _tapPlaceOrderButton(tester);

    expect(ordersRepository.createOrderCalls, 1);
  });
}
