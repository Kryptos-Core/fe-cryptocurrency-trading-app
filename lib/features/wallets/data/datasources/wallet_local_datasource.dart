import 'package:crypto_trading_app/features/wallets/domain/entities/wallet_balance.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Local data source for caching wallet balances
///
/// This data source provides offline storage capability for wallet balances
/// using Hive (embedded database).
///
/// Hive Box name: 'wallet_balances'
/// Cache key format: 'wallet_balance_${currencyId}'
abstract class WalletLocalDataSource {
  /// Cache wallet balance in local storage
  Future<void> cacheBalance(WalletBalance balance, String currencyId);

  /// Get cached balance from local storage
  /// Returns null if not found
  Future<WalletBalance?> getCachedBalance(String currencyId);

  /// Clear specific cached balance
  Future<void> clearCachedBalance(String currencyId);

  /// Clear all cached balances
  Future<void> clearAllCachedBalances();
}

/// Implementation of WalletLocalDataSource using Hive
class WalletLocalDataSourceImpl implements WalletLocalDataSource {
  static const String _boxName = 'wallet_balances';
  static const String _keyPrefix = 'wallet_balance_';

  @override
  Future<void> cacheBalance(WalletBalance balance, String currencyId) async {
    try {
      final box = await Hive.openBox<Map>(_boxName);
      final key = '$_keyPrefix$currencyId';

      // Store balance as Map
      await box.put(key, {
        'userId': balance.userId,
        'currencyId': balance.currencyId,
        'available': balance.available,
        'frozen': balance.frozen,
        'total': balance.total,
      });
    } catch (e) {
      // Log but don't fail - caching is not critical
      if (kDebugMode) {
        debugPrint('Failed to cache wallet balance');
      }
    }
  }

  @override
  Future<WalletBalance?> getCachedBalance(String currencyId) async {
    try {
      final box = await Hive.openBox<Map>(_boxName);
      final key = '$_keyPrefix$currencyId';
      final data = box.get(key);

      if (data == null) return null;

      return WalletBalance(
        userId: data['userId'] as String? ?? '',
        currencyId: data['currencyId'] as String? ?? currencyId,
        available: data['available'] as String? ?? '0',
        frozen: data['frozen'] as String? ?? '0',
        total: data['total'] as String? ?? '0',
      );
    } catch (e) {
      // Log but don't fail - cache read failure is not critical
      if (kDebugMode) {
        debugPrint('Failed to read cached wallet balance');
      }
      return null;
    }
  }

  @override
  Future<void> clearCachedBalance(String currencyId) async {
    try {
      final box = await Hive.openBox<Map>(_boxName);
      final key = '$_keyPrefix$currencyId';
      await box.delete(key);
    } catch (e) {
      // Log but don't fail
      if (kDebugMode) {
        debugPrint('Failed to clear cached wallet balance');
      }
    }
  }

  @override
  Future<void> clearAllCachedBalances() async {
    try {
      final box = await Hive.openBox<Map>(_boxName);
      await box.clear();
    } catch (e) {
      // Log but don't fail
      if (kDebugMode) {
        debugPrint('Failed to clear all cached wallet balances');
      }
    }
  }
}
