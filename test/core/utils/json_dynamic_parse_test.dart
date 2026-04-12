import 'package:crypto_trading_app/core/utils/json_dynamic_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseJsonInt', () {
    test('accepts int, double, and numeric strings', () {
      expect(parseJsonInt(7), 7);
      expect(parseJsonInt(7.9), 7);
      expect(parseJsonInt('42'), 42);
      expect(parseJsonInt(' 12 '), 12);
    });

    test('returns fallback on bad input', () {
      expect(parseJsonInt(null, 3), 3);
      expect(parseJsonInt('x', 9), 9);
      expect(parseJsonInt(Object(), 1), 1);
    });
  });

  group('parseJsonBool', () {
    test('accepts bool, 0/1, and common strings', () {
      expect(parseJsonBool(true), true);
      expect(parseJsonBool(false), false);
      expect(parseJsonBool(1), true);
      expect(parseJsonBool(0), false);
      expect(parseJsonBool('true'), true);
      expect(parseJsonBool('FALSE'), false);
    });
  });
}
