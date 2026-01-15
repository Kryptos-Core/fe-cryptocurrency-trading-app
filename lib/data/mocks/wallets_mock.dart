import 'package:crypto_trading_app/data/models/wallet_model.dart';
import 'package:crypto_trading_app/data/models/currency_model.dart';
import 'currencies_mock.dart';

/// Mock data for Wallets
class WalletsMock {
  static final List<WalletModel> mockWallets = [
    WalletModel(
      walletId: 1,
      userId: 1,
      currency: CurrenciesMock.getBySymbol("BTC")!,
      available: "1.5",
      frozen: "0.2",
      total: "1.7",
      updatedAt: DateTime.parse("2024-01-15T10:30:00.000Z"),
    ),
    WalletModel(
      walletId: 2,
      userId: 1,
      currency: CurrenciesMock.getBySymbol("USDT")!,
      available: "10000.50",
      frozen: "500.00",
      total: "10500.50",
      updatedAt: DateTime.parse("2024-01-15T10:30:00.000Z"),
    ),
    WalletModel(
      walletId: 3,
      userId: 1,
      currency: CurrenciesMock.getBySymbol("ETH")!,
      available: "5.0",
      frozen: "0.0",
      total: "5.0",
      updatedAt: DateTime.parse("2024-01-15T10:30:00.000Z"),
    ),
    WalletModel(
      walletId: 4,
      userId: 1,
      currency: CurrenciesMock.getBySymbol("BNB")!,
      available: "10.0",
      frozen: "0.0",
      total: "10.0",
      updatedAt: DateTime.parse("2024-01-15T10:30:00.000Z"),
    ),
  ];

  /// Get mock wallet by ID
  static WalletModel? getById(int walletId) {
    try {
      return mockWallets.firstWhere((w) => w.walletId == walletId);
    } catch (e) {
      return null;
    }
  }

  /// Get mock wallet by currency ID
  static WalletModel? getByCurrencyId(int currencyId) {
    try {
      return mockWallets.firstWhere((w) => w.currency.currencyId == currencyId);
    } catch (e) {
      return null;
    }
  }

  /// Filter wallets
  static List<WalletModel> filter({
    int? currencyId,
    bool includeZero = false,
  }) {
    var filtered = List<WalletModel>.from(mockWallets);

    if (currencyId != null) {
      filtered = filtered.where((w) => w.currency.currencyId == currencyId).toList();
    }

    if (!includeZero) {
      filtered = filtered.where((w) {
        final total = double.tryParse(w.total) ?? 0;
        return total > 0;
      }).toList();
    }

    return filtered;
  }

  /// Generate mock ledger
  static List<WalletLedgerModel> generateLedger(int walletId, {int count = 20}) {
    final wallet = getById(walletId);
    if (wallet == null) {
      return [];
    }

    final ledger = <WalletLedgerModel>[];
    final now = DateTime.now();
    double balance = double.parse(wallet.total);

    final refTypes = ['DEPOSIT', 'WITHDRAW', 'ORDER', 'TRADE', 'ADJUST'];
    final directions = ['CREDIT', 'DEBIT'];

    for (int i = count - 1; i >= 0; i--) {
      final refType = refTypes[i % refTypes.length];
      final direction = refType == 'DEPOSIT' || refType == 'TRADE' ? 'CREDIT' : 'DEBIT';
      final amount = (0.1 + (i % 10) * 0.1).toStringAsFixed(8);

      if (direction == 'CREDIT') {
        balance += double.parse(amount);
      } else {
        balance -= double.parse(amount);
        if (balance < 0) balance = 0;
      }

      ledger.add(WalletLedgerModel(
        ledgerId: i + 1,
        userId: wallet.userId,
        currencyId: wallet.currency.currencyId,
        refType: refType,
        refId: 100 + i,
        direction: direction,
        amount: amount,
        balanceAfter: balance.toStringAsFixed(8),
        createdAt: now.subtract(Duration(days: count - i)),
      ));
    }

    return ledger.reversed.toList();
  }
}
