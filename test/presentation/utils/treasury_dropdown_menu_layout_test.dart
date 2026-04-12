import 'package:crypto_trading_app/presentation/utils/treasury_dropdown_menu_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('defaultTreasuryDropdownMenuMaxHeight', () {
    test('caps tall screens so menu does not dominate popups', () {
      expect(defaultTreasuryDropdownMenuMaxHeight(2000), 220);
      expect(defaultTreasuryDropdownMenuMaxHeight(1200), 220);
    });

    test('uses fraction of height on mid-size viewports', () {
      expect(defaultTreasuryDropdownMenuMaxHeight(800), 208);
      expect(defaultTreasuryDropdownMenuMaxHeight(700), 182);
    });

    test('applies minimum for short viewports', () {
      expect(defaultTreasuryDropdownMenuMaxHeight(400), 168);
    });

    test('invalid height falls back to sensible default', () {
      expect(defaultTreasuryDropdownMenuMaxHeight(0), 220);
      expect(defaultTreasuryDropdownMenuMaxHeight(-10), 220);
    });
  });
}
