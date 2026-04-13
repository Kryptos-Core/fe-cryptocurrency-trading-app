import 'package:crypto_trading_app/core/constants/api_constants.dart';
import 'package:crypto_trading_app/core/error/exceptions.dart';
import 'package:crypto_trading_app/core/network/dio_client.dart';
import 'package:crypto_trading_app/data/models/market_price_model.dart';
import 'package:crypto_trading_app/data/models/rate_preview_model.dart';
import 'package:crypto_trading_app/domain/entities/exchange_rate_preview.dart';
import 'package:crypto_trading_app/domain/entities/market_price.dart';
import 'package:crypto_trading_app/domain/repositories/exchange_rate_repository.dart';
import 'package:dio/dio.dart';

class ExchangeRateRepositoryImpl implements ExchangeRateRepository {
  final DioClient dioClient;

  ExchangeRateRepositoryImpl({required this.dioClient});

  T _unwrap<T>(dynamic payload) {
    if (payload is Map<String, dynamic> && payload['data'] is T) {
      return payload['data'] as T;
    }
    if (payload is T) {
      return payload;
    }
    throw const FormatException('Unexpected API response format');
  }

  @override
  Future<ExchangeRatePreview> getDepositPreview(
    int fiatAmount, {
    String fiatSymbol = 'VND',
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.exchangeRateDepositPreview,
        queryParameters: {
          'fiatAmount': fiatAmount.toString(),
          'fiatSymbol': fiatSymbol,
        },
      );
      final payload = _unwrap<Map<String, dynamic>>(response.data);
      return ExchangeRatePreviewModel.fromJson(payload);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load deposit preview',
      );
    } on FormatException {
      throw ServerException(message: 'Failed to parse deposit preview response');
    }
  }

  @override
  Future<List<MarketPrice>> getMarketPrices({List<String>? symbols}) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.exchangeRateMarketPrices,
        queryParameters: {
          if (symbols != null && symbols.isNotEmpty) 'symbols': symbols.join(','),
        },
      );
      final payload = _unwrap<Map<String, dynamic>>(response.data);
      final rawPrices = payload['prices'];
      if (rawPrices is! List) {
        throw const FormatException('Missing prices list');
      }
      return rawPrices
          .whereType<Map<String, dynamic>>()
          .map(MarketPriceModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Failed to load market prices',
      );
    } on FormatException {
      throw ServerException(message: 'Failed to parse market prices response');
    }
  }
}
