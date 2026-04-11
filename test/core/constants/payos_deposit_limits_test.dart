import 'package:crypto_trading_app/core/constants/payos_deposit_limits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kPayosMinAmountVnd matches legacy client guard', () {
    expect(kPayosMinAmountVnd, 10000);
  });
}
