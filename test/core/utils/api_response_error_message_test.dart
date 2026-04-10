import 'package:crypto_trading_app/core/utils/api_response_error_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBackendErrorMessage', () {
    test('returns string as-is', () {
      expect(parseBackendErrorMessage('  hello  '), 'hello');
    });

    test('joins list of validation messages', () {
      expect(
        parseBackendErrorMessage([
          'privateKey must be longer than or equal to 32 characters',
          'chain must be a valid enum value',
        ]),
        'privateKey must be longer than or equal to 32 characters\n'
        'chain must be a valid enum value',
      );
    });

    test('null and empty yield null', () {
      expect(parseBackendErrorMessage(null), isNull);
      expect(parseBackendErrorMessage(''), isNull);
      expect(parseBackendErrorMessage('   '), isNull);
      expect(parseBackendErrorMessage(<dynamic>[]), isNull);
    });
  });

  group('backendErrorMessageOrDefault', () {
    test('uses default when message missing', () {
      expect(backendErrorMessageOrDefault(null, 'fallback'), 'fallback');
    });
  });
}
