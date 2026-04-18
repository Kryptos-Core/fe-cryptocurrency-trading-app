import 'package:crypto_trading_app/features/admin/payment_config/data/models/admin_enums_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromApiMap parses lists', () {
    final s = AdminEnumsSnapshot.fromApiMap({
      'orderStatus': ['OPEN', 'FILLED'],
      'depositStatus': ['PENDING'],
      'withdrawalStatus': ['FAILED'],
      'userRole': ['ADMIN'],
      'userStatus': ['ACTIVE'],
      'treasuryWalletPurpose': ['BOTH'],
    });
    expect(s.orderStatus, ['OPEN', 'FILLED']);
    expect(s.depositStatus, ['PENDING']);
    expect(s.treasuryWalletPurpose, ['BOTH']);
  });

  test('mergedWithFallback fills empty keys from fallback', () {
    final s = const AdminEnumsSnapshot(
      orderStatus: ['OPEN'],
      depositStatus: [],
      withdrawalStatus: [],
      userRole: [],
      userStatus: [],
      treasuryWalletPurpose: [],
    ).mergedWithFallback();
    expect(s.orderStatus, ['OPEN']);
    expect(s.depositStatus, isNotEmpty);
    expect(s.userRole, contains('FINANCE_MANAGER'));
  });
}
