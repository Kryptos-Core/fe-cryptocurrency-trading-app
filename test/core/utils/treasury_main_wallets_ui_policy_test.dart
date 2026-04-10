import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:crypto_trading_app/core/utils/treasury_main_wallets_ui_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('treasuryMainWalletsShowsPendingTab', () {
    test('is false for FINANCE_MANAGER and RISK_OFFICER', () {
      expect(treasuryMainWalletsShowsPendingTab(UserRole.financeManager), isFalse);
      expect(treasuryMainWalletsShowsPendingTab(UserRole.riskOfficer), isFalse);
    });

    test('is true for other roles (e.g. ADMIN)', () {
      expect(treasuryMainWalletsShowsPendingTab(UserRole.admin), isTrue);
      expect(treasuryMainWalletsShowsPendingTab(UserRole.supportAgent), isTrue);
      expect(treasuryMainWalletsShowsPendingTab(UserRole.marketMaker), isTrue);
      expect(treasuryMainWalletsShowsPendingTab(UserRole.trader), isTrue);
    });
  });
}
