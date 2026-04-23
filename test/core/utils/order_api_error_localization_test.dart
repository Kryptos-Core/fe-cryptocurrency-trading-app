import 'package:crypto_trading_app/core/gen_l10n/app_localizations.dart';
import 'package:crypto_trading_app/core/utils/order_api_error_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('localizeOrderApiError', () {
    test('returns Vietnamese copy for known codes', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('vi'));

      expect(
        localizeOrderApiError(l10n,
            code: 'INVALID_PRICE', message: 'Invalid price'),
        'Giá không hợp lệ.',
      );
      expect(
        localizeOrderApiError(
          l10n,
          code: 'INSUFFICIENT_BALANCE',
          message: 'Insufficient balance',
        ),
        l10n.insufficientBalance,
      );
    });

    test('returns English copy for known codes', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        localizeOrderApiError(l10n,
            code: 'ORDER_NOT_FOUND', message: 'Order not found'),
        'Order not found.',
      );
      expect(
        localizeOrderApiError(l10n, code: 'FORBIDDEN', message: 'Forbidden'),
        'You are not allowed to perform this action.',
      );
    });

    test('falls back to server message when code is unknown', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));

      expect(
        localizeOrderApiError(l10n,
            code: 'SOME_NEW_CODE', message: 'Fallback message'),
        'Fallback message',
      );
    });
  });
}
