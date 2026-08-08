import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/error/app_error.dart';

class _SampleError extends AppError {
  const _SampleError() : super(code: 'TEST/SAMPLE', userMessageKey: 'error.test');
}

void main() {
  group('AppError', () {
    test('props include code, messageKey, metadata, cause', () {
      const err = _SampleError();
      expect(err.props, contains('TEST/SAMPLE'));
      expect(err.runtimeType.toString(), '_SampleError');
    });

    test('toLogMap includes structured fields', () {
      const err = _SampleError(metadata: {'userId': 'u1'});
      final log = err.toLogMap();
      expect(log['code'], 'TEST/SAMPLE');
      expect(log['userMessageKey'], 'error.test');
      expect(log['name'], '_SampleError');
      expect(log['metadata'], isA<Map<String, Object>>());
    });

    test('uses Equatable for value equality', () {
      const a = _SampleError();
      const b = _SampleError();
      expect(a, equals(b));
    });

    test('subclass is also AppError', () {
      const err = _SampleError();
      expect(err, isA<AppError>());
      expect(err, isA<Exception>());
    });
  });
}
