import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/error/app_error.dart';
import 'package:crypto_trading_app/core/network/result.dart';

class _FakeError extends AppError {
  const _FakeError() : super(code: 'TEST/FAKE', userMessageKey: 'test.fake');
}

void main() {
  group('Result', () {
    test('Success.unwrap returns value', () {
      const r = Success<int>(42);
      expect(r.isSuccess, true);
      expect(r.isFailure, false);
      expect(r.unwrap(), 42);
    });

    test('Failure.unwrap throws AppError', () {
      const r = Failure<int>(_FakeError());
      expect(r.isFailure, true);
      expect(() => r.unwrap(), throwsA(isA<AppError>()));
    });

    test('valueOrNull returns null on Failure', () {
      const r = Failure<int>(_FakeError());
      expect(r.valueOrNull, isNull);
    });

    test('errorOrNull returns error on Failure', () {
      const r = Failure<int>(_FakeError());
      expect(r.errorOrNull, isA<_FakeError>());
    });

    test('map transforms Success value', () {
      const r = Success<int>(10);
      final mapped = r.map((v) => v.toString());
      expect(mapped, isA<Success<String>>());
      expect(mapped.unwrap(), '10');
    });

    test('map propagates Failure', () {
      const r = Failure<int>(_FakeError());
      final mapped = r.map<String>((v) => v.toString());
      expect(mapped, isA<Failure<String>>());
    });

    test('fold dispatches to correct branch', () {
      const ok = Success<int>(1);
      const fail = Failure<int>(_FakeError());
      expect(
        ok.fold(onSuccess: (v) => 'ok:$v', onFailure: (_) => 'fail'),
        'ok:1',
      );
      expect(
        fail.fold(onSuccess: (v) => 'ok:$v', onFailure: (_) => 'fail'),
        'fail',
      );
    });

    test('switch expression exhaustiveness', () {
      // Pattern matching in switch should compile and match both branches.
      const Result<int> r = Success<int>(7);
      final out = switch (r) {
        Success(:final value) => 'S:$value',
        Failure(:final error) => 'F:${error.code}',
      };
      expect(out, 'S:7');
    });
  });
}
