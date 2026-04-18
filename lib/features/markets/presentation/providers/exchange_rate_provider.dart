import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/exchange_rate_preview.dart';
import 'package:crypto_trading_app/features/markets/domain/entities/market_price.dart';
import 'package:crypto_trading_app/features/markets/domain/repositories/exchange_rate_repository.dart';

class ExchangeRateProvider extends ChangeNotifier {
  final ExchangeRateRepository repository;

  ExchangeRateProvider({required this.repository});

  ExchangeRatePreview? _depositPreview;
  List<MarketPrice> _marketPrices = const [];
  bool _isLoadingPreview = false;
  bool _isLoadingPrices = false;
  String? _error;
  Timer? _previewDebounce;
  int _previewRequestVersion = 0;

  ExchangeRatePreview? get depositPreview => _depositPreview;
  List<MarketPrice> get marketPrices => _marketPrices;
  bool get isLoadingPreview => _isLoadingPreview;
  bool get isLoadingPrices => _isLoadingPrices;
  String? get error => _error;

  Future<void> fetchMarketPrices({List<String>? symbols}) async {
    _isLoadingPrices = true;
    _error = null;
    notifyListeners();

    try {
      _marketPrices = await repository.getMarketPrices(symbols: symbols);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingPrices = false;
      notifyListeners();
    }
  }

  void scheduleDepositPreview(int? amount) {
    _previewDebounce?.cancel();

    if (amount == null || amount <= 0) {
      _previewRequestVersion++;
      _isLoadingPreview = false;
      _depositPreview = null;
      notifyListeners();
      return;
    }

    _previewDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(fetchDepositPreview(amount));
    });
  }

  Future<void> fetchDepositPreview(int amount) async {
    final int requestVersion = ++_previewRequestVersion;
    _isLoadingPreview = true;
    _error = null;
    notifyListeners();

    try {
      final preview = await repository.getDepositPreview(amount);
      if (requestVersion != _previewRequestVersion) {
        return;
      }
      _depositPreview = preview;
    } catch (e) {
      if (requestVersion != _previewRequestVersion) {
        return;
      }
      _error = e.toString();
      _depositPreview = null;
    } finally {
      if (requestVersion == _previewRequestVersion) {
        _isLoadingPreview = false;
        notifyListeners();
      }
    }
  }

  void clearPreview() {
    _previewDebounce?.cancel();
    _previewRequestVersion++;
    _isLoadingPreview = false;
    _depositPreview = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }
}
