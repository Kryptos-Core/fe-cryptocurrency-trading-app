import 'package:crypto_trading_app/core/enums/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole.fromString', () {
    test('maps known backend roles', () {
      expect(UserRole.fromString('ADMIN'), UserRole.admin);
      expect(UserRole.fromString('market_maker'), UserRole.marketMaker);
      expect(UserRole.fromString('  TRADER  '), UserRole.trader);
    });

    test('maps unknown non-empty role to unrecognized', () {
      expect(UserRole.fromString('NEW_OPS_ROLE'), UserRole.unrecognized);
    });

    test('empty or whitespace falls back to trader', () {
      expect(UserRole.fromString(''), UserRole.trader);
      expect(UserRole.fromString('   '), UserRole.trader);
      expect(UserRole.fromString(null), UserRole.trader);
    });
  });

  group('UserRole.formatDisplayLabel', () {
    test('humanizes raw claim for unrecognized', () {
      expect(
        UserRole.formatDisplayLabel(
          UserRole.unrecognized,
          rawRoleClaim: 'NEW_OPS_ROLE',
        ),
        'New Ops Role',
      );
    });

    test('known roles ignore raw claim', () {
      expect(
        UserRole.formatDisplayLabel(
          UserRole.admin,
          rawRoleClaim: 'IGNORE_ME',
        ),
        'Admin',
      );
    });
  });
}
