import 'package:crypto_trading_app/core/constants/payos_deposit_limits.dart';
import 'package:crypto_trading_app/features/deposits/domain/entities/deposit.dart';
import 'package:crypto_trading_app/features/deposits/domain/repositories/deposit_repository.dart';
import 'package:crypto_trading_app/features/deposits/presentation/providers/deposits_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDepositRepository implements DepositRepository {
  Map<String, dynamic>? meta;

  @override
  Future<Map<String, dynamic>> createDepositLink(int amount) async => {};

  @override
  Future<Map<String, dynamic>> getCheckoutMeta() async =>
      meta ?? <String, dynamic>{};

  @override
  Future<List<Deposit>> getMyDeposits() async => [];

  @override
  Future<Map<String, dynamic>> syncDepositStatus(int orderCode) async => {};
}

void main() {
  test('effectivePayosMinAmountFiat falls back to kPayosMinAmountVnd', () {
    final repo = _FakeDepositRepository();
    final p = DepositsProvider(repository: repo);
    expect(p.effectivePayosMinAmountFiat, kPayosMinAmountVnd);
    expect(p.effectivePayosMaxAmountFiat, isNull);
  });

  test('loadCheckoutMeta applies runtime min and max', () async {
    final repo = _FakeDepositRepository()
      ..meta = {'minAmount': 5000, 'maxAmount': 1e6};
    final p = DepositsProvider(repository: repo);
    await p.loadCheckoutMeta();
    expect(p.effectivePayosMinAmountFiat, 5000);
    expect(p.effectivePayosMaxAmountFiat, 1000000);
  });
}
