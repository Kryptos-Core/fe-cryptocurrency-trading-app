import 'package:crypto_trading_app/features/markets/domain/entities/exchange_sync_result.dart';

/// Binance / exchange metadata sync (`POST /exchange/sync-info`).
abstract class ExchangeRepository {
  Future<ExchangeSyncResult> syncInfo({bool forceRefresh = false});
}
