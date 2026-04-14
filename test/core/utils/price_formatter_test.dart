import 'package:crypto_trading_app/core/utils/price_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceFormatter.formatPrice', () {
    test('returns "0" for zero', () {
      expect(PriceFormatter.formatPrice(0), '0');
    });

    test('>= 10000: 1 decimal, trailing zeros trimmed', () {
      expect(PriceFormatter.formatPrice(66088.0), '66088');
      expect(PriceFormatter.formatPrice(66088.7), '66088.7');
    });

    test('>= 1000: 2 decimals', () {
      expect(PriceFormatter.formatPrice(3412.5), '3412.5');
      expect(PriceFormatter.formatPrice(1000.0), '1000');
    });

    test('>= 1: 2 decimals', () {
      expect(PriceFormatter.formatPrice(8.34), '8.34');
      expect(PriceFormatter.formatPrice(1.0), '1');
    });

    test('>= 0.01: 4 decimals', () {
      expect(PriceFormatter.formatPrice(0.2595), '0.2595');
      expect(PriceFormatter.formatPrice(0.1), '0.1');
    });

    test('>= 0.0001: 6 decimals', () {
      expect(PriceFormatter.formatPrice(0.1234), '0.1234');
      expect(PriceFormatter.formatPrice(0.000100), '0.0001');
    });

    test('< 0.0001: 8 decimals (meme coins)', () {
      expect(PriceFormatter.formatPrice(0.00001234), '0.00001234');
      expect(PriceFormatter.formatPrice(0.00000001), '0.00000001');
    });
  });

  group('PriceFormatter.formatPriceStr', () {
    test('parses and formats valid string', () {
      expect(PriceFormatter.formatPriceStr('66088.7'), '66088.7');
    });

    test('returns original string on parse failure', () {
      expect(PriceFormatter.formatPriceStr('N/A'), 'N/A');
      expect(PriceFormatter.formatPriceStr(''), '');
    });
  });

  group('PriceFormatter.formatVolume', () {
    test('returns "0" for zero', () {
      expect(PriceFormatter.formatVolume(0), '0');
    });

    test('>= 1B: B suffix', () {
      expect(PriceFormatter.formatVolume(1250000000), '1.25B');
    });

    test('>= 1M: M suffix', () {
      expect(PriceFormatter.formatVolume(1250000), '1.25M');
    });

    test('>= 1K: K suffix', () {
      expect(PriceFormatter.formatVolume(1250), '1.25K');
    });

    test('< 1K: up to 2 decimals, trailing zeros trimmed', () {
      expect(PriceFormatter.formatVolume(5.0), '5');
      expect(PriceFormatter.formatVolume(5.5), '5.5');
    });

    test('< 1: up to 4 decimals, trailing zeros trimmed', () {
      expect(PriceFormatter.formatVolume(0.1234), '0.1234');
      expect(PriceFormatter.formatVolume(0.1), '0.1');
    });
  });

  group('PriceFormatter.formatVolumeStr', () {
    test('parses and formats valid string', () {
      expect(PriceFormatter.formatVolumeStr('1250000'), '1.25M');
    });

    test('returns original string on parse failure', () {
      expect(PriceFormatter.formatVolumeStr('--'), '--');
    });
  });
}
