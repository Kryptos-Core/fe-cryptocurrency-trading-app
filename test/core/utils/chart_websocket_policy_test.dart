import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_trading_app/core/utils/chart_websocket_policy.dart';

void main() {
  group('chartWebSocketNeedsInitialize', () {
    test('true only when token present and provider not connected', () {
      expect(
        chartWebSocketNeedsInitialize(
          providerReportsConnected: false,
          hasNonEmptyToken: true,
        ),
        isTrue,
      );
      expect(
        chartWebSocketNeedsInitialize(
          providerReportsConnected: true,
          hasNonEmptyToken: true,
        ),
        isFalse,
      );
      expect(
        chartWebSocketNeedsInitialize(
          providerReportsConnected: false,
          hasNonEmptyToken: false,
        ),
        isFalse,
      );
    });
  });
}
